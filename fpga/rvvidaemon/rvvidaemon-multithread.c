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
#include <pthread.h>
#include "rvviApi.h" // *** bug fix me when this file gets included into the correct directory.
#include "op/op.h" // *** bug fix me when this file gets included into the correct directory.
#include "idv/idv.h"

#define PRINT_THRESHOLD 1
//#define PRINT_THRESHOLD 65536
//#define PRINT_THRESHOLD 1024
//#define PRINT_THRESHOLD 8192
#define LOG_THRESHOLD 0x8000000 // ~128 Million instruction
//#define E_TARGET_CLOCK 25000
#define E_TARGET_CLOCK 95000
//#define E_TARGET_CLOCK 60000
//#define E_TARGET_CLOCK 69000
#define SYSTEM_CLOCK 50000000
#define INNER_PKT_DELAY (SYSTEM_CLOCK / E_TARGET_CLOCK)

#define RATE_SET_THREAHOLD 65536

#define HIST_LEN 8

#include "rvvidaemon.h"
#include "queue.h"

#define MAX_CSRS  5

#define DEST_MAC0	0x43
#define DEST_MAC1	0x68
#define DEST_MAC2	0x11
#define DEST_MAC3	0x11
#define DEST_MAC4	0x02
#define DEST_MAC5	0x45

#define DEST_MAC 0x450211116843

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

uint64_t EXT_MEM_BASE =  0x80000000;
uint64_t EXT_MEM_RANGE = 0x7FFFFFFF;
#define NUM_PMP_REGS 16

//#define MAX_64 ((uint64_t) 1 << (uint64_t) 64)

typedef struct {
  uint64_t MCycleHistory[HIST_LEN];
  uint64_t MInstretHistory[HIST_LEN];
  int Index;
} History_t;

typedef struct {
  History_t * History;
  queue_t * InstructionQueue;
} ReceiveLoop_t;



// load wally configuration
// must be set external to program
// export IMPERAS_TOOLS="../../config/rv64gc/imperas.ic"
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
pthread_mutex_t StartLock;
pthread_cond_t StartCond;

#define htonll(x) ((1==htonl(1)) ? (x) : ((uint64_t)htonl((x) & 0xFFFFFFFF) << 32) | htonl((x) >> 32))
#define ntohll(x) ((1==ntohl(1)) ? (x) : ((uint64_t)ntohl((x) & 0xFFFFFFFF) << 32) | ntohl((x) >> 32))

// prototypes
void PrintInstructionData(RequiredRVVI_t *InstructionData, History_t * History);
void * ReceiveLoop(void * arg);
void * ProcessLoop(void * arg);
void * SendSlowMessage(void * arg);
void * SetSpeedLoop(void * arg);
int ProcessRvviAll(RequiredRVVI_t *InstructionData, History_t * History);
void set_gpr(int hart, int reg, uint64_t value);
void set_csr(int hart, int csrIndex, uint64_t value);
void set_fpr(int hart, int reg, uint64_t value);
int state_compare(int hart, uint64_t Minstret);
void WriteInstructionData(RequiredRVVI_t *InstructionData, FILE *fptr);
void DumpState(uint32_t hartId, const char *FileName, uint64_t StartAddress, uint64_t EndAddress);
double UpdateHistory(RequiredRVVI_t *InstructionDataPtr, History_t *History);

int main(int argc, char **argv){

  // get Wally environment var
  char ImperasToolStr [256];
  const char* WALLY = getenv("WALLY");
  if(WALLY) {
    snprintf(ImperasToolStr, 256, "IMPERAS_TOOLS=%s/config/rv64gc/imperas-fpga.ic", WALLY);
    putenv(ImperasToolStr);
  } else {
    printf("WALLY environment variable not set. Did you run source ./setup.sh in cvw?\n");
  }
  History_t HistoryValues;
  
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

  ReceiveLoop_t ReceiveThreadObj;
  ReceiveThreadObj.InstructionQueue = InstructionQueue;
  ReceiveThreadObj.History = &HistoryValues;
  pthread_t ReceiveID, ProcessID, SlowID, SetSpeedLoopID;
  pthread_create(&ReceiveID, NULL, &ReceiveLoop, (void *) &ReceiveThreadObj);
  pthread_create(&ProcessID, NULL, &ProcessLoop, (void *) &ReceiveThreadObj);
  //pthread_create(&SlowID, NULL, &SendSlowMessage, (void *) InstructionQueue);
  //pthread_create(&SetSpeedLoopID, NULL, &SetSpeedLoop, (void *) InstructionQueue);
  //pthread_join(ReceiveID, NULL);
  pthread_join(ProcessID, NULL);

  //opSessionTerminate();
  //close(sockfd);
  return 0;
}

void * ReceiveLoop(void * arg){
  uint8_t buf[BUF_SIZ];
  ssize_t headerbytes, numbytes;
  //queue_t * InstructionQueue = (queue_t *) arg;
  ReceiveLoop_t * ThreadPtr = (ReceiveLoop_t *) arg;
  queue_t * InstructionQueue = ThreadPtr->InstructionQueue;

  uint8_t AckBuf[BUF_SIZ];
  int AckLen = 0;
  struct ether_header *AckHeader = (struct ether_header *) AckBuf;

  memset(AckBuf, 0, BUF_SIZ);
  AckBuf[0] = DEST_MAC0;
  AckBuf[1] = DEST_MAC1;
  AckBuf[2] = DEST_MAC2;
  AckBuf[3] = DEST_MAC3;
  AckBuf[4] = DEST_MAC4;
  AckBuf[5] = DEST_MAC5;
  AckBuf[6] = SRC_MAC0;
  AckBuf[7] = SRC_MAC1;
  AckBuf[8] = SRC_MAC2;
  AckBuf[9] = SRC_MAC3;
  AckBuf[10] = SRC_MAC4;
  AckBuf[11] = SRC_MAC5;

  AckHeader->ether_type = htons(ETHER_TYPE);
  AckLen += sizeof(struct ether_header);


  FILE *LogFile;
  int count = 0;
  int result;
  uint64_t DstMAC;
  uint64_t Sequence, LastSequence;
  LastSequence = 0xffffffffffffffff;//(MAX_64 - 1);
  LogFile = fopen("receive-log.txt", "w");
  if(LogFile == NULL) {
    printf("Error opening receive.txt for writing!");   
    exit(1);             
  }

  // receive first frame
  numbytes = recvfrom(sockfd, buf, BUF_SIZ, 0, NULL, NULL);
  headerbytes = (sizeof(struct ether_header));
  DstMAC = *((uint64_t*)buf);
  DstMAC = DstMAC & 0xFFFFFFFFFFFF;
  if(DstMAC == DEST_MAC){
    RequiredRVVI_t *InstructionDataPtr = (RequiredRVVI_t *) (buf + headerbytes + 2);
    Sequence = InstructionDataPtr->Sequence;
    if(Sequence == (LastSequence + 1)){
      Enqueue(InstructionDataPtr, InstructionQueue);
      LastSequence = Sequence;
    }

    ((uint16_t*) (AckBuf + AckLen))[0] = 0;
    ((uint64_t*) (AckBuf + AckLen + 2))[0] = InstructionDataPtr->Sequence;
    ((uint64_t*) (AckBuf + AckLen + 10))[0] = 0;
    ((uint32_t*) (AckBuf + AckLen + 18))[0] = INNER_PKT_DELAY;
    if (sendto(sockfd, AckBuf, AckLen + 22, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0) printf("Send failed\n");

    pthread_cond_signal(&StartCond);  // send message to other thread to slow down
  }

  int QueueDepth = QUEUE_SIZE;
  while(1) {
    QueueDepth = HowFull(InstructionQueue);
    PercentFull = (QueueDepth * 1000) / QUEUE_SIZE;
    if(QueueDepth >= QUEUE_THREASHOLD){
      pthread_cond_signal(&SlowMessageCond);  // send message to other thread to slow down
      if(QueueDepth == QUEUE_SIZE){
        printf("Critical Error!!!!!!!!! Queue is now full. Terminating receive thread.\n");
        exit(-1);
      }
    }
    numbytes = recvfrom(sockfd, buf, BUF_SIZ, 0, NULL, NULL);
    headerbytes = (sizeof(struct ether_header));
    DstMAC = *((uint64_t*)buf);
    DstMAC = DstMAC & 0xFFFFFFFFFFFF;
    if(DstMAC == DEST_MAC){
      RequiredRVVI_t *InstructionDataPtr = (RequiredRVVI_t *) (buf + headerbytes + 2);
      Sequence = InstructionDataPtr->Sequence;
      if(Sequence == (LastSequence + 1)){
        Enqueue(InstructionDataPtr, InstructionQueue);
	LastSequence = Sequence;
      }
      //      Enqueue(InstructionDataPtr, InstructionQueue);

      ((uint16_t*) (AckBuf + AckLen))[0] = 0;
      ((uint64_t*) (AckBuf + AckLen + 2))[0] = InstructionDataPtr->Sequence;
      ((uint64_t*) (AckBuf + AckLen + 10))[0] = 0;
      ((uint32_t*) (AckBuf + AckLen + 18))[0] = INNER_PKT_DELAY + 8 * QueueDepth;
      if (sendto(sockfd, AckBuf, AckLen + 22, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0) printf("Send failed\n");

    }
    if(count == RATE_SET_THREAHOLD){
      /* if (sendto(sockfd, ratebuf, rate_len+4, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0){ */
      /*   printf("Send failed\n"); */
      /* } */
      count = 0;
    }
    count++;

  }
  fclose(LogFile);
  pthread_exit(NULL);
}

/* void * SetSpeedLoop(void * arg){ */
/*   queue_t * InstructionQueue = (queue_t *) arg; */

/*   int INIT_INSTR_PRE_SEC = 10000; */
/*   int InstrPreSec = INIT_INSTR_PRE_SEC; */
/*   int Phase = 0; */
/*   int Slope = 10000; // Instr/s to change in phase 1. */

/*   struct timespec UpdateInterval = { .tv_sec = 0, .tv_nsec = 10000000 }; // 0.01 seconds */
/*   //struct timespec UpdateInterval = { .tv_sec = 3, .tv_nsec = 0 }; // 0.1 seconds */
/*   int Rate = ((UpdateInterval.tv_nsec * Slope) / 1000000000) + UpdateInterval.tv_sec * Slope; */

/*   int THREASHOLD_C1 = 4; // Soft limit. Start slow down */
/*   int THREASHOLD_C2 = 16; // Critial limit. Dramatic slow down */
/*   int THREASHOLD_C3 = QUEUE_SIZE - (QUEUE_SIZE/8); // Near limit. Critial Warning. */

/*   int QueueDepth = 0; */
  
/*   uint8_t SpeedBuf[BUF_SIZ]; */
/*   int SpeedLen = 0; */
/*   struct ether_header *SpeedHeader = (struct ether_header *) SpeedBuf; */
/*   memset(SpeedBuf, 0, BUF_SIZ); */
/*   SpeedBuf[0] = DEST_MAC0; */
/*   SpeedBuf[1] = DEST_MAC1; */
/*   SpeedBuf[2] = DEST_MAC2; */
/*   SpeedBuf[3] = DEST_MAC3; */
/*   SpeedBuf[4] = DEST_MAC4; */
/*   SpeedBuf[5] = DEST_MAC5; */
/*   SpeedBuf[6] = SRC_MAC0; */
/*   SpeedBuf[7] = SRC_MAC1; */
/*   SpeedBuf[8] = SRC_MAC2; */
/*   SpeedBuf[9] = SRC_MAC3; */
/*   SpeedBuf[10] = SRC_MAC4; */
/*   SpeedBuf[11] = SRC_MAC5; */

/*   SpeedHeader->ether_type = htons(ETHER_TYPE); */
/*   SpeedLen += sizeof(struct ether_header); */
/*   /\* Packet data *\/ */
/*   SpeedBuf[SpeedLen++] = 'r'; */
/*   SpeedBuf[SpeedLen++] = 'a'; */
/*   SpeedBuf[SpeedLen++] = 't'; */
/*   SpeedBuf[SpeedLen++] = 'e'; */
/*   SpeedBuf[SpeedLen++] = 'i'; */
/*   SpeedBuf[SpeedLen++] = 'n'; */
/*   // set initial value */

/*   // wait until we receive first frame. */
/*   pthread_mutex_lock(&StartLock); */
/*   pthread_cond_wait(&StartCond, &StartLock); */
/*   pthread_mutex_unlock(&StartLock); */
  
/*   ((uint32_t*) (SpeedBuf + SpeedLen))[0] = (SYSTEM_CLOCK / InstrPreSec); */
/*   if (sendto(sockfd, SpeedBuf, SpeedLen+4, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0) printf("Send failed\n"); */
/*   else printf("send success!\n"); */

/*   while(1){ */
/*     nanosleep(&UpdateInterval, NULL); */
/*     QueueDepth = HowFull(InstructionQueue); */
/*     if(QueueDepth <= THREASHOLD_C1 / 2) { */
/*       if(!Phase) InstrPreSec = InstrPreSec * 2; */
/*       else InstrPreSec = InstrPreSec + Rate; */
/*     } else if(QueueDepth <= THREASHOLD_C1) { */
/*       if(!Phase){ */
/*         InstrPreSec = InstrPreSec / 4; */
/*         Phase = 1; */
/*       } else InstrPreSec = InstrPreSec - Rate; */
/*     } else if(QueueDepth <= THREASHOLD_C2) { */
/*       InstrPreSec = InstrPreSec / 2; */
/*     } else if(QueueDepth <= THREASHOLD_C3) { */
/*       printf("Near upper limit of queue depth. Revert to 10K Instr/s, Phase = %d\n", Phase); */
/*       InstrPreSec = INIT_INSTR_PRE_SEC; */
/*       Phase = 1; */
/*     } else if(QueueDepth <= QUEUE_SIZE){ */
/*       printf("Critial failure. SetSpeedLoop Thread Phase = %d.\n", Phase); */
/*       //exit(-1); */
/*       break; */
/*     } */
/*     ((uint32_t*) (SpeedBuf + SpeedLen))[0] = (SYSTEM_CLOCK / InstrPreSec); */
/*     printf("InstrPreSec = %d, InterPacketDelay = %d, Phase = %d, Rate = %d\n", InstrPreSec, (SYSTEM_CLOCK / InstrPreSec), Phase, Rate); */
/*     if (sendto(sockfd, SpeedBuf, SpeedLen+4, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0) printf("Send failed\n"); */
/*   }   */
/* } */

void * ProcessLoop(void * arg){
  ReceiveLoop_t * ThreadPtr = (ReceiveLoop_t *) arg;
  queue_t * InstructionQueue = ThreadPtr->InstructionQueue;
  History_t * History = ThreadPtr->History;
  RequiredRVVI_t  InstructionDataPtr;
  int result;
  uint64_t last = 0;
  uint64_t count = 0;
  uint64_t RefModelLogCount = 0;
  while(1) {
    if(!IsEmpty(InstructionQueue)){
      //printf("Before Dequeue\n");
      Dequeue(&InstructionDataPtr, InstructionQueue);
      //printf("After Dequeue\n");
      count++;
      if(count % PRINT_THRESHOLD == 0){
        printf("Queue depth = %d \t", (InstructionQueue->head + InstructionQueue->size - InstructionQueue->tail) % InstructionQueue->size);
        PrintInstructionData(&InstructionDataPtr, History);
      }
      if(count % LOG_THRESHOLD == 0) {
        printf("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
        printf("!!!!!!!!!!!!!!!!!!!!Logging reference model state!!!!!!!!!!!!!!!!!!!!\n");
        printf("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
        char buf[40];
	printf("count = %ld, LOG_THRESHOLD = %d\n", count, LOG_THRESHOLD);
        snprintf(buf, 40, "Log-%ldM-Instr-dump", ((RefModelLogCount * LOG_THRESHOLD) >> 20));
        DumpState(0, buf, EXT_MEM_BASE, EXT_MEM_RANGE + EXT_MEM_BASE + 1);
	RefModelLogCount++;
      }
      result = ProcessRvviAll(&InstructionDataPtr, History);
      //result = 0;
      if(result == -1) {
        PrintInstructionData(&InstructionDataPtr, History);
        break;
      }
    }
  }
  pthread_exit(NULL);
}

/* void * SendSlowMessage(void * arg){ */
/*   queue_t * InstructionQueue = (queue_t *) arg; */
/*   while(1){ */
/*     pthread_mutex_lock(&SlowMessageLock); */
/*     pthread_cond_wait(&SlowMessageCond, &SlowMessageLock); */
/*     pthread_mutex_unlock(&SlowMessageLock); */
/*     ((uint32_t*) (slowbuf + slow_len))[0] = PercentFull; */
/*     if (sendto(sockfd, slowbuf, slow_len+4, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0){ */
/*       printf("Send failed\n"); */
/*     }else { */
/*       printf("send success!\n"); */
/*     } */
/*     /\* if (sendto(sockfd, ratebuf, rate_len+4, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0){ *\/ */
/*     /\*   printf("Send failed\n"); *\/ */
/*     /\* }else { *\/ */
/*     /\*   printf("!?!?!?!?!?!?RATE SET RATE RATE RATE !?!?!!?!?!?!? success!\n"); *\/ */
/*     /\* } *\/ */
    
/*     printf("WARNING the Receive Queue is Almost Full %d !!!!!!!!!!!!!!!!!! %d\n", (InstructionQueue->head + InstructionQueue->size - InstructionQueue->tail) % InstructionQueue->size, PercentFull); */
/*   } */
  
/* } */


int ProcessRvviAll(RequiredRVVI_t *InstructionData, History_t * History){
  long int found;
  uint8_t trap = InstructionData->Trap;
  int result;
  int CSRIndex;

  result = 0;
  if(InstructionData->GPREn) rvviDutGprSet(0, InstructionData->GPRReg, InstructionData->GPRValue);
  if(InstructionData->FPREn) rvviDutFprSet(0, InstructionData->FPRReg, InstructionData->GPRValue);
  if(InstructionData->CSRCount > 0) {
    int TotalCSRs = MAX_CSRS <= InstructionData->CSRCount ? MAX_CSRS : InstructionData->CSRCount;
    for(CSRIndex = 0; CSRIndex < TotalCSRs; CSRIndex++){
      if(InstructionData->CSRReg[CSRIndex] != 0){
        rvviDutCsrSet(0, InstructionData->CSRReg[CSRIndex], InstructionData->CSRValue[CSRIndex]);
	printf("Setting CSR %x\n", InstructionData->CSRReg[CSRIndex]);
      }
    }
  }

  if (trap) {
    printf("Got a Trap!\n");
    PrintInstructionData(InstructionData, History);
    printf("The instruction is %x\n", InstructionData->insn);
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

    // copy all state out to a log file so we can rebuild in simulation
    DumpState(hart, "mismatch", EXT_MEM_BASE, EXT_MEM_BASE + EXT_MEM_RANGE + 1);
    return -1;
  }
  
}

/* void set_csr(int hart, int csrIndex, uint64_t value){ */
/*   rvviDutCsrSet(hart, csrIndex, value); */
/* } */

/* void set_gpr(int hart, int reg, uint64_t value){ */
/*   rvviDutGprSet(hart, reg, value); */
/* } */

/* void set_fpr(int hart, int reg, uint64_t value){ */
/*   rvviDutFprSet(hart, reg, value); */
/* } */


 
void PrintInstructionData(RequiredRVVI_t *InstructionData, History_t *History){
  int CSRIndex;
  printf("PC = %lx, insn = %x, Mcycle = %lx, Minstret = %lx, Trap = %hhx, PrivilegeMode = %hhx",
	 InstructionData->PC, InstructionData->insn, InstructionData->Mcycle, InstructionData->Minstret, InstructionData->Trap, InstructionData->PrivilegeMode);
  if(InstructionData->GPREn){
    printf(", GPR[%d] = %lx", InstructionData->GPRReg, InstructionData->GPRValue);
  }
  if(InstructionData->FPREn){
    printf(", FPR[%d] = %lx", InstructionData->FPRReg, InstructionData->GPRValue);
  }
  if(InstructionData->CSRCount > 0) {
    printf( ", Num CSR = %d", InstructionData->CSRCount);
    for(CSRIndex = 0; CSRIndex < InstructionData->CSRCount; CSRIndex++){
      printf(", CSR[%x] = %lx", InstructionData->CSRReg[CSRIndex], InstructionData->CSRValue[CSRIndex]);
    }
  }
  double freq = UpdateHistory(InstructionData, History);
  printf(", Freq = %.0f", freq);
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
    fprintf(fptr, ", FPR[%d] = %lx", InstructionData->FPRReg, InstructionData->GPRValue);
  }
  if(InstructionData->CSRCount > 0) {
    fprintf(fptr, ", Num CSR = %d", InstructionData->CSRCount);
    for(CSRIndex = 0; CSRIndex < 3; CSRIndex++){
      if(InstructionData->CSRReg[CSRIndex] != 0){
	fprintf(fptr, ", CSR[%x] = %lx", InstructionData->CSRReg[CSRIndex], InstructionData->CSRValue[CSRIndex]);
      }
    }
  }
  fprintf(fptr, "\n");
}

void DumpState(uint32_t hartId, const char *FileNameRoot, uint64_t StartAddress, uint64_t EndAddress){
  /// **** these values are all in the wrong byte order.
  uint64_t Index1, Index2;
  uint64_t Address;
  const uint32_t BufferSize = 4096;
  uint64_t Total8ByteAddress = (EndAddress - StartAddress) >> 3; // i.e. 2^31 = 2G / 2^3 = 2^28 = 256M
  uint64_t InnterLoopLimit = BufferSize >> 3;                    // i.e. 2^9 =  512
  uint64_t OuterLoopLimit = Total8ByteAddress / InnterLoopLimit; // 2^28 / 2^9 = 2^19 = 512K
  uint64_t Buf[InnterLoopLimit]; // 4KiB buffer
  FILE * GPRfp, * FPRfp, * PCfp, * CSRfp, * MEMfp, * PRIVfp;
  char GPRFileName[256], FPRFileName[256], PCFileName[256], CSRFileName[256], MEMFileName[256], PRIVFileName[256];
  sprintf(GPRFileName, "%s-GPR.bin", FileNameRoot);
  sprintf(FPRFileName, "%s-FPR.bin", FileNameRoot);
  sprintf(PCFileName, "%s-PC.bin", FileNameRoot);
  sprintf(CSRFileName, "%s-CSR.bin", FileNameRoot);
  sprintf(MEMFileName, "%s-MEM.bin", FileNameRoot);
  sprintf(PRIVFileName, "%s-PRIV.bin", FileNameRoot);
  GPRfp = fopen(GPRFileName, "w");
  FPRfp = fopen(FPRFileName, "w");
  PCfp = fopen(PCFileName, "w");
  CSRfp = fopen(CSRFileName, "w");
  MEMfp = fopen(MEMFileName, "w");
  PRIVfp = fopen(PRIVFileName, "w");
  if(GPRfp == NULL || GPRfp == NULL || PCfp == NULL || CSRfp == NULL || MEMfp == NULL || PRIVfp == NULL){
    printf("Filed to open one of %s, %s, %s, %s, %s, or %s for writting\n", GPRFileName, FPRFileName, PCFileName, CSRFileName, MEMFileName, PRIVFileName);
    exit(-1);
  }
  for(Index1 = 0; Index1 < OuterLoopLimit; Index1++) {
    for(Index2 = 0; Index2 < InnterLoopLimit; Index2++){
      Address = StartAddress + Index1 * BufferSize + (Index2 << 3);
      Buf[Index2] = rvviRefMemoryRead(hartId, Address, 8);
    }
    fwrite(Buf, 8, InnterLoopLimit, MEMfp);
  }

  int Index;
  CSR_unpacked_t CSRs[4096];
  int CSRCount;
  uint64_t GPR[32];
  uint64_t FPR[32];
  uint64_t PC;
  uint64_t value;

  for(Index = 0; Index<32; Index++){
    GPR[Index] = htonll(rvviRefGprGet(hartId, Index));
    FPR[Index] = htonll(rvviRefFprGet(hartId, Index));
  }
  fwrite(GPR+1, 8, 31, GPRfp); // skip x0
  fwrite(FPR, 8, 32, GPRfp);
  PC = htonll(rvviRefPcGet(hartId));
  fwrite(&PC, 8, 1, PCfp);

  uint64_t CSR[4096];
  CSRCount = 0;
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x001)); // 
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x002)); // FRM
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x003)); // FCSR
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x100)); // SSTATUS
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x104)); // SIE
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x105)); // STVEC
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x106)); // SCOUNTEREN
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x10A)); // SENVCFG
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x140)); // SSCRATCH
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x141)); // SEPC
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x142)); // SCAUSE
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x143)); // STVAL
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x144)); // SIP
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x144)); // SIDELEG
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x14D)); // STIMECMP
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x180)); // SATP
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x300)); // MSTATUS
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x301)); // MIA
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x302)); // MEDELEG
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x303)); // MIDELEG
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x304)); // MIE
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x305)); // MTVEC
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x306)); // MCOUNTEREN
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x30A)); // MENVCFG
  //CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x310)); // MSTATUSH
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x320)); // MCOUNTINHIBT
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x340)); // MSCRATCH
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x341)); // MEPC
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x342)); // MCAUSE
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x343)); // MTVAL
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x344)); // MIP
  //CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x34A)); // MTINST

  for(Index = 0; Index < NUM_PMP_REGS/8; Index++) {
    CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x3A0 + Index*2));
  }

  for(Index = 0; Index < NUM_PMP_REGS; Index++) {
    CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0x3B0 + Index));
  }

  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0xF11)); // MVENDORID
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0xF12)); // MARCHID
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0xF13)); // MIMPID
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0xF14)); // MHARTID
  CSR[CSRCount++] = htonll(rvviRefCsrGet(hartId, 0xF15)); // MCONFIGPTR  


  fwrite(CSRs, 8, CSRCount, CSRfp);

  fclose(GPRfp);
  fclose(FPRfp);
  fclose(CSRfp);
  fclose(PCfp);
  fclose(MEMfp);
  fclose(PRIVfp);

  rvviRefStateDump(hartId);
}

double UpdateHistory(RequiredRVVI_t *InstructionDataPtr, History_t *History){
  int Index = History->Index;
  uint64_t MCycleDelta, MInstretDelta;
  History->MCycleHistory[Index] = InstructionDataPtr->Mcycle;
  History->MInstretHistory[Index] = InstructionDataPtr->Minstret;
  Index = (Index + 1) % HIST_LEN;
  MCycleDelta = InstructionDataPtr->Mcycle - History->MCycleHistory[Index];
  MInstretDelta = InstructionDataPtr->Minstret - History->MInstretHistory[Index];
  History->Index = Index;
  double freq = MInstretDelta / (MCycleDelta * (1.0 / SYSTEM_CLOCK));
  return freq;
}
