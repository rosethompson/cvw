///////////////////////////////////////////
// rvvi daemon
//
// Written: Rose Thompson rose@rosethompson.net
// Created: Sept 10 2024
// Modified: Sept 10 2024
//
// Purpose: Converts raw socket into rvvi interface to connect into ImperasDV
// 
// Documentation: Higher performance rvvi daemon
// three threads.
// T1 reads ethernet frames and stores into a queue
// T2 runs the ImperasDV software.  It pulls instruction frames from the queue
// T3 sends back error and maintenance messages to the FPGA
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwgroup/cvw
// 
// Copyright (C) 2021-23 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file 
// except in compliance with the License, or, at your option, the Apache License version 2.0. You 
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under the 
// License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 
// and limitations under the License.
////////////////////////////////////////////////////////////////////////////////////////////////

#include <arpa/inet.h>
#include <linux/if_packet.h>
#include <linux/ip.h>
#include <linux/udp.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/ether.h>
#include "rvviApi.h" // *** bug fix me when this file gets included into the correct directory.
#include "idv/idv.h"

#define PRINT_THRESHOLD 1
//#define PRINT_THRESHOLD 1024
//#define E_TARGET_CLOCK 25000
#define E_TARGET_CLOCK 70000
#define SYSTEM_CLOCK 50000000
#define INNER_PKT_DELAY (SYSTEM_CLOCK / E_TARGET_CLOCK)

#include "rvvidaemon.h"
#include "queue.h"

#define MAX_CSRS  5

#define DEST_MAC0	0x43
#define DEST_MAC1	0x68
#define DEST_MAC2	0x11
#define DEST_MAC3	0x11
#define DEST_MAC4	0x02
#define DEST_MAC5	0x45

#define SRC_MAC0	0x54
#define SRC_MAC1	0x16
#define SRC_MAC2	0x00
#define SRC_MAC3	0x00
#define SRC_MAC4	0x54
#define SRC_MAC5	0x8F

#define BUF_SIZ		1024

#define ETHER_TYPE	0x5c00  // The type defined in packetizer.sv

#define DEFAULT_IF	"eno1"

#define QUEUE_SIZE       16384
#define QUEUE_THREASHOLD 128

struct sockaddr_ll socket_address;
uint8_t sendbuf[BUF_SIZ];
struct ether_header *sendeh = (struct ether_header *) sendbuf;
int tx_len = 0;
int slow_len = 0;
int rate_len = 0;
int sockfd;

uint8_t slowbuf[BUF_SIZ];
struct ether_header *sloweh = (struct ether_header *) slowbuf;
uint8_t ratebuf[BUF_SIZ];
struct ether_header *rateeh = (struct ether_header *) ratebuf;
int PercentFull;


pthread_mutex_t SlowMessageLock;
pthread_cond_t SlowMessageCond;

// prototypes
void PrintInstructionData(RequiredRVVI_t *InstructionData);
void * ReceiveLoop(void * arg);
void * ProcessLoop(void * arg);
void * SendSlowMessage(void * arg);
int ProcessRvviAll(RequiredRVVI_t *InstructionData);
void set_gpr(int hart, int reg, uint64_t value);
void set_csr(int hart, int csrIndex, uint64_t value);
void set_fpr(int hart, int reg, uint64_t value);
int state_compare(int hart, uint64_t Minstret);
void WriteInstructionData(RequiredRVVI_t *InstructionData, FILE *fptr);

int main(int argc, char **argv){
  
  if(argc != 2){
    printf("Wrong number of arguments.\n");
    printf("rvvidaemon <ethernet device>\n");
    return -1;
  }

  int sockopt;
  struct ifreq ifopts;	/* set promiscuous mode */
  
  /* Open RAW socket to receive frames */
  if ((sockfd = socket(AF_PACKET, SOCK_RAW, htons(ETHER_TYPE))) == -1) {
    perror("socket");
  }
  printf("Here 0\n");

  /* Set interface to promiscuous mode - do we need to do this every time? */
  strncpy(ifopts.ifr_name, argv[1], IFNAMSIZ-1);
  ioctl(sockfd, SIOCGIFFLAGS, &ifopts);
  printf("Here 1\n");
  ifopts.ifr_flags |= IFF_PROMISC;
  ioctl(sockfd, SIOCSIFFLAGS, &ifopts);
  printf("Here 2\n");
  if (ioctl(sockfd, SIOCGIFINDEX, &ifopts) < 0)
    perror("SIOCGIFINDEX");
  
  /* Allow the socket to be reused - incase connection is closed prematurely */
  if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &sockopt, sizeof sockopt) == -1) {
    perror("setsockopt");
    close(sockfd);
    exit(EXIT_FAILURE);
  }
  printf("Here 3\n");
  
  /* Bind to device */
  if (setsockopt(sockfd, SOL_SOCKET, SO_BINDTODEVICE, argv[1], IFNAMSIZ-1) == -1)	{
    perror("SO_BINDTODEVICE");
    close(sockfd);
    exit(EXIT_FAILURE);
  }
  printf("Here 4\n");
  socklen_t RecvLen;
  if (getsockopt(sockfd, SOL_SOCKET, SO_RCVBUF, &RecvLen, &sockopt) == -1) {
    perror("SO_RCVBUF");
    close(sockfd);
    exit(EXIT_FAILURE);
  }
  printf("Recv buffer size is: %d\n", RecvLen);
  RecvLen = 262144;
  if (setsockopt(sockfd, SOL_SOCKET, SO_RCVBUF, &RecvLen, sizeof (socklen_t)) == -1) {
    perror("SO_RCVBUF");
    close(sockfd);
    exit(EXIT_FAILURE);
  }
  printf("Recv buffer size is: %d\n", RecvLen);

  /* Index of the network device */
  socket_address.sll_ifindex = ifopts.ifr_ifindex;
  /* Address length*/
  socket_address.sll_halen = ETH_ALEN;
  /* Destination MAC */
  socket_address.sll_addr[0] = DEST_MAC0;
  socket_address.sll_addr[1] = DEST_MAC1;
  socket_address.sll_addr[2] = DEST_MAC2;
  socket_address.sll_addr[3] = DEST_MAC3;
  socket_address.sll_addr[4] = DEST_MAC4;
  socket_address.sll_addr[5] = DEST_MAC5;

  // queue to store incoming instructions
  queue_t * InstructionQueue;
  InstructionQueue = InitQueue(QUEUE_SIZE);

  // frame to send on mismatch
  /* Construct the Ethernet header */
  memset(sendbuf, 0, BUF_SIZ);
  sendbuf[0] = DEST_MAC0;
  sendbuf[1] = DEST_MAC1;
  sendbuf[2] = DEST_MAC2;
  sendbuf[3] = DEST_MAC3;
  sendbuf[4] = DEST_MAC4;
  sendbuf[5] = DEST_MAC5;
  sendbuf[6] = SRC_MAC0;
  sendbuf[7] = SRC_MAC1;
  sendbuf[8] = SRC_MAC2;
  sendbuf[9] = SRC_MAC3;
  sendbuf[10] = SRC_MAC4;
  sendbuf[11] = SRC_MAC5;

  sendeh->ether_type = htons(ETHER_TYPE);
  tx_len += sizeof(struct ether_header);
  /* Packet data */
  sendbuf[tx_len++] = 't';
  sendbuf[tx_len++] = 'r';
  sendbuf[tx_len++] = 'i';
  sendbuf[tx_len++] = 'g';
  sendbuf[tx_len++] = 'i';
  sendbuf[tx_len++] = 'n';

  // frame to send to slow down the fpga
  /* Construct the Ethernet header */
  memset(slowbuf, 0, BUF_SIZ);
  slowbuf[0] = DEST_MAC0;
  slowbuf[1] = DEST_MAC1;
  slowbuf[2] = DEST_MAC2;
  slowbuf[3] = DEST_MAC3;
  slowbuf[4] = DEST_MAC4;
  slowbuf[5] = DEST_MAC5;
  slowbuf[6] = SRC_MAC0;
  slowbuf[7] = SRC_MAC1;
  slowbuf[8] = SRC_MAC2;
  slowbuf[9] = SRC_MAC3;
  slowbuf[10] = SRC_MAC4;
  slowbuf[11] = SRC_MAC5;

  sloweh->ether_type = htons(ETHER_TYPE);
  slow_len += sizeof(struct ether_header);
  /* Packet data */
  slowbuf[slow_len++] = 's';
  slowbuf[slow_len++] = 'l';
  slowbuf[slow_len++] = 'o';
  slowbuf[slow_len++] = 'w';
  slowbuf[slow_len++] = 'm';
  slowbuf[slow_len++] = 'e';

  // imperasdv
  if(!rvviVersionCheck(RVVI_API_VERSION)){
    printf("Bad RVVI_API_VERSION\n");
  }

  rvviRefConfigSetString(IDV_CONFIG_MODEL_VENDOR, "riscv.ovpworld.org");
  rvviRefConfigSetString(IDV_CONFIG_MODEL_NAME,"riscv");
  rvviRefConfigSetString(IDV_CONFIG_MODEL_VARIANT, "RV64GC");
  rvviRefConfigSetInt(IDV_CONFIG_MODEL_ADDRESS_BUS_WIDTH, 56);
  rvviRefConfigSetInt(IDV_CONFIG_MAX_NET_LATENCY_RETIREMENTS, 6);

  // eventually we want to put the elffiles here
  rvviRefInit(NULL);
  rvviRefPcSet(0, 0x1000);
  
  // Volatile CSRs
  rvviRefCsrSetVolatile(0, 0xC00);   // CYCLE
  rvviRefCsrSetVolatile(0, 0xB00);   // MCYCLE
  rvviRefCsrSetVolatile(0, 0xC02);   // INSTRET
  rvviRefCsrSetVolatile(0, 0xB02);   // MINSTRET
  rvviRefCsrSetVolatile(0, 0xC01);   // TIME

  // *** fix me
  rvviRefCsrSetVolatile(0, 0x301);   // MISA
  rvviRefCsrSetVolatile(0, 0xF13);   // mimpid


  int iter;
  for (iter = 0xC03; iter <= 0xC1F; iter++) {
    rvviRefCsrSetVolatile(0, iter);   // HPMCOUNTERx
  }
  // Machine MHPMCOUNTER3 - MHPMCOUNTER31
  for (iter = 0xB03; iter <= 0xB1F; iter++) {
    rvviRefCsrSetVolatile(0, iter);   // MHPMCOUNTERx
  }
  // cannot predict this register due to latency between
  // pending and taken
  rvviRefCsrSetVolatile(0, 0x344);   // MIP
  rvviRefCsrSetVolatile(0, 0x144);   // SIP

  // set bootrom and bootram as volatile memory
  rvviRefMemorySetVolatile(0x1000, 0x1FFF);
  rvviRefMemorySetVolatile(0x2000, 0x3FFF);

  // Privileges for PMA are set in the imperas.ic
  // volatile (IO) regions are defined here
  // only real ROM/RAM areas are BOOTROM and UNCORE_RAM
  rvviRefMemorySetVolatile(0x2000000, 0x2000000 + 0xFFFF);
  rvviRefMemorySetVolatile(0x10060000, 0x10060000 + 0xFF);
  rvviRefMemorySetVolatile(0x10000000, 0x10000000 + 0x7);
  rvviRefMemorySetVolatile(0x0C000000, 0x0C000000 + 0x03FFFFFF);
  rvviRefMemorySetVolatile(0x00013000, 0x00013000 + 0x7F);
  rvviRefMemorySetVolatile(0x10040000, 0x10040000 + 0xFFF);

  // this loop will go into Thread T1

  // frame to send to slow down the fpga
  /* Construct the Ethernet header */
  memset(ratebuf, 0, BUF_SIZ);
  ratebuf[0] = DEST_MAC0;
  ratebuf[1] = DEST_MAC1;
  ratebuf[2] = DEST_MAC2;
  ratebuf[3] = DEST_MAC3;
  ratebuf[4] = DEST_MAC4;
  ratebuf[5] = DEST_MAC5;
  ratebuf[6] = SRC_MAC0;
  ratebuf[7] = SRC_MAC1;
  ratebuf[8] = SRC_MAC2;
  ratebuf[9] = SRC_MAC3;
  ratebuf[10] = SRC_MAC4;
  ratebuf[11] = SRC_MAC5;

  rateeh->ether_type = htons(ETHER_TYPE);
  rate_len += sizeof(struct ether_header);
  /* Packet data */
  ratebuf[rate_len++] = 'r';
  ratebuf[rate_len++] = 'a';
  ratebuf[rate_len++] = 't';
  ratebuf[rate_len++] = 'e';
  ratebuf[rate_len++] = 'i';
  ratebuf[rate_len++] = 'n';
  ((uint32_t*) (ratebuf + rate_len))[0] = INNER_PKT_DELAY;

  pthread_t ReceiveID, ProcessID, SlowID;
  pthread_create(&ReceiveID, NULL, &ReceiveLoop, (void *) InstructionQueue);
  pthread_create(&ProcessID, NULL, &ProcessLoop, (void *) InstructionQueue);
  pthread_create(&SlowID, NULL, &SendSlowMessage, (void *) InstructionQueue);
  //pthread_join(ReceiveID, NULL);
  pthread_join(ProcessID, NULL);

  //opSessionTerminate();
  //close(sockfd);
  return 0;
}

void * ReceiveLoop(void * arg){
  uint8_t buf[BUF_SIZ];
  struct ether_header *eh = (struct ether_header *) buf;
  ssize_t headerbytes, numbytes;
  queue_t * InstructionQueue = (queue_t *) arg;

  FILE *LogFile;
  LogFile = fopen("receive-log.txt", "w");
  if(LogFile == NULL) {
    printf("Error opening receive.txt for writing!");   
    exit(1);             
  }

  int Emptiness = QUEUE_SIZE;
  while(1) {
    Emptiness = HowFull(InstructionQueue);
    PercentFull = (Emptiness * 1000) / QUEUE_SIZE;
    if(IsAlmostFull(InstructionQueue, QUEUE_THREASHOLD)){
      //pthread_mutex_lock(&SlowMessageLock);
      pthread_cond_signal(&SlowMessageCond);
      //pthread_mutex_lock(&SlowMessageLock);
      /* if (sendto(sockfd, slowbuf, slow_len, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0){ */
      /* 	printf("Send failed\n"); */
      /* }else { */
      /* 	printf("send success!\n"); */
      /* } */
      if(IsFull(InstructionQueue)){
        printf("Critical Error!!!!!!!!! Queue is now full. Terminating receive thread.\n");
        //pthread_exit(NULL);
        exit(-1);
      }
    }
    numbytes = recvfrom(sockfd, buf, BUF_SIZ, 0, NULL, NULL);
    headerbytes = (sizeof(struct ether_header));
    int result;
    if (eh->ether_dhost[0] == DEST_MAC0 &&
        eh->ether_dhost[1] == DEST_MAC1 &&
        eh->ether_dhost[2] == DEST_MAC2 &&
        eh->ether_dhost[3] == DEST_MAC3 &&
        eh->ether_dhost[4] == DEST_MAC4 &&
        eh->ether_dhost[5] == DEST_MAC5) {
      RequiredRVVI_t *InstructionDataPtr = (RequiredRVVI_t *) (buf + headerbytes);

      // now let's drive IDV
      // start simple just drive and compare PC.
      //printf("Before Enqueue\n");
      Enqueue(InstructionDataPtr, InstructionQueue);
      //printf("After Enqueue\n");
      //WriteInstructionData(InstructionDataPtr, LogFile);
    }
  }
  fclose(LogFile);
  pthread_exit(NULL);
}

void * ProcessLoop(void * arg){
  queue_t * InstructionQueue = (queue_t *) arg;
  RequiredRVVI_t  InstructionDataPtr;
  int result;
  uint64_t last = 0;
  uint64_t count = 0;
  while(1) {
    if(!IsEmpty(InstructionQueue)){
      //printf("Before Dequeue\n");
      Dequeue(&InstructionDataPtr, InstructionQueue);
      //printf("After Dequeue\n");
      count++;
      if(count == PRINT_THRESHOLD){
        printf("Queue depth = %d \t", (InstructionQueue->head + InstructionQueue->size - InstructionQueue->tail) % InstructionQueue->size);
        PrintInstructionData(&InstructionDataPtr);
        count = 0;
      }
      /* current = InstructionDataPtr.Minstret; */
      /* if(current != last + 1){ */
      /* 	printf("Error!\n"); */
      /* 	exit(-1); */
      /* } */
      /* last = current; */
      result = ProcessRvviAll(&InstructionDataPtr);
      //result = 0;
      if(result == -1) {
        PrintInstructionData(&InstructionDataPtr);
        break;
      }
    }
  }
  pthread_exit(NULL);
}

void * SendSlowMessage(void * arg){
  queue_t * InstructionQueue = (queue_t *) arg;
  while(1){
    pthread_mutex_lock(&SlowMessageLock);
    pthread_cond_wait(&SlowMessageCond, &SlowMessageLock);
    pthread_mutex_unlock(&SlowMessageLock);
    ((uint32_t*) (slowbuf + slow_len))[0] = PercentFull;
    if (sendto(sockfd, slowbuf, slow_len+4, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0){
      printf("Send failed\n");
    }else {
      printf("send success!\n");
    }
    if (sendto(sockfd, ratebuf, rate_len+4, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0){
      printf("Send failed\n");
    }else {
      printf("!?!?!?!?!?!?RATE SET RATE RATE RATE !?!?!!?!?!?!? success!\n");
    }
    
    printf("WARNING the Receive Queue is Almost Full %d !!!!!!!!!!!!!!!!!! %d\n", (InstructionQueue->head + InstructionQueue->size - InstructionQueue->tail) % InstructionQueue->size, PercentFull);
  }
  
}


int ProcessRvviAll(RequiredRVVI_t *InstructionData){
  long int found;
  uint64_t time = InstructionData->Mcycle;
  uint8_t trap = InstructionData->Trap;
  uint64_t order = InstructionData->Minstret;
  int result;
  int CSRIndex;

  result = 0;
  //if(InstructionData->GPREn) set_gpr(0, InstructionData->GPRReg, InstructionData->GPRValue);
  if(InstructionData->GPREn) rvviDutGprSet(0, InstructionData->GPRReg, InstructionData->GPRValue);
  //if(InstructionData->FPREn) set_fpr(0, InstructionData->FPRReg, InstructionData->FPRValue);
  if(InstructionData->FPREn) rvviDutFprSet(0, InstructionData->FPRReg, InstructionData->FPRValue);
  if(InstructionData->CSRCount > 0) {
    for(CSRIndex = 0; CSRIndex < MAX_CSRS; CSRIndex++){
      if(InstructionData->CSR[CSRIndex].CSRReg != 0){
	//set_csr(0, InstructionData->CSR[CSRIndex].CSRReg, InstructionData->CSR[CSRIndex].CSRValue);
        rvviDutCsrSet(0, InstructionData->CSR[CSRIndex].CSRReg, InstructionData->CSR[CSRIndex].CSRValue);
	printf("Setting CSR %x\n", InstructionData->CSR[CSRIndex].CSRReg);
      }
    }
  }

  if (trap) {
    rvviDutTrap(0, InstructionData->PC, InstructionData->insn);
  } else {
    rvviDutRetire(0, InstructionData->PC, InstructionData->insn, 0);
  }

  if(!trap) result = state_compare(0, InstructionData->Minstret);
  // *** set is for nets like interrupts  come back to this.
  //found = rvviRefNetIndexGet("pc_rdata");
  //rvviRefNetSet(found, InstructionData->PC, time);
  return result;
  
}

int state_compare(int hart, uint64_t Minstret){
  uint8_t result = 1;
  uint8_t stepOk = 0;
  char buf[80];
  rvviDutCycleCountSet(Minstret);
  if(rvviRefEventStep(hart) != 0) {
    stepOk = 1;
    result &= rvviRefPcCompare(hart);
    result &= rvviRefInsBinCompare(hart);
    result &= rvviRefGprsCompare(hart);
    result &= rvviRefFprsCompare(hart);
    result &= rvviRefCsrsCompare(hart);
  } else {
    result = 0;
  }

  if (result == 0) {
    /* Send packet */
    if (sendto(sockfd, sendbuf, tx_len, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0){
      printf("Send failed\n");
    }else {
      printf("send success!\n");
    }

    sprintf(buf, "MISMATCH @ instruction # %ld\n", Minstret);
    idvMsgError(buf);
    return -1;
  }
  
}

void set_csr(int hart, int csrIndex, uint64_t value){
  rvviDutCsrSet(hart, csrIndex, value);
}

void set_gpr(int hart, int reg, uint64_t value){
  rvviDutGprSet(hart, reg, value);
}

void set_fpr(int hart, int reg, uint64_t value){
  rvviDutFprSet(hart, reg, value);
}


 
void PrintInstructionData(RequiredRVVI_t *InstructionData){
  int CSRIndex;
  printf("PC = %lx, insn = %x, Mcycle = %lx, Minstret = %lx, Trap = %hhx, PrivilegeMode = %hhx",
	 InstructionData->PC, InstructionData->insn, InstructionData->Mcycle, InstructionData->Minstret, InstructionData->Trap, InstructionData->PrivilegeMode);
  if(InstructionData->GPREn){
    printf(", GPR[%d] = %lx", InstructionData->GPRReg, InstructionData->GPRValue);
  }
  if(InstructionData->FPREn){
    printf(", FPR[%d] = %lx", InstructionData->FPRReg, InstructionData->FPRValue);
  }
  if(InstructionData->CSRCount > 0) {
    printf( ", Num CSR = %d", InstructionData->CSRCount);
    for(CSRIndex = 0; CSRIndex < 3; CSRIndex++){
      if(InstructionData->CSR[CSRIndex].CSRReg != 0){
	printf(", CSR[%x] = %lx", InstructionData->CSR[CSRIndex].CSRReg, InstructionData->CSR[CSRIndex].CSRValue);
      }
    }
  }
  printf("\n");
}

void WriteInstructionData(RequiredRVVI_t *InstructionData, FILE *fptr){
  int CSRIndex;
  fprintf(fptr, "PC = %lx, insn = %x, Mcycle = %lx, Minstret = %lx, Trap = %hhx, PrivilegeMode = %hhx",
	  InstructionData->PC, InstructionData->insn, InstructionData->Mcycle, InstructionData->Minstret, InstructionData->Trap, InstructionData->PrivilegeMode);
  if(InstructionData->GPREn){
    fprintf(fptr, ", GPR[%d] = %lx", InstructionData->GPRReg, InstructionData->GPRValue);
  }
  if(InstructionData->FPREn){
    fprintf(fptr, ", FPR[%d] = %lx", InstructionData->FPRReg, InstructionData->FPRValue);
  }
  if(InstructionData->CSRCount > 0) {
    fprintf(fptr, ", Num CSR = %d", InstructionData->CSRCount);
    for(CSRIndex = 0; CSRIndex < 3; CSRIndex++){
      if(InstructionData->CSR[CSRIndex].CSRReg != 0){
	fprintf(fptr, ", CSR[%x] = %lx", InstructionData->CSR[CSRIndex].CSRReg, InstructionData->CSR[CSRIndex].CSRValue);
      }
    }
  }
  fprintf(fptr, "\n");
}

