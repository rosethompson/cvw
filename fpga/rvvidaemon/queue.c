///////////////////////////////////////////
// Helper library for rvvi deamon.
//
// Written: Rose Thomposn ross1728@gmail.com
// Created: 6 Sept 2024
// Modified: 6 Sept 2024
//
// Purpose:
// Implements a simple queue with one reader and one writer.  The reader and writer
// run in separate threads and share a region of heap allocated memory. THe queue is organized
// as an array with read and write pointers.
// 
// Documentation: 
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


// this first version will be single threaded

#include "queue.h"
#include "rvvidaemon.h"
#include <pthread.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// copy in rvvidaemon merge together and move to separate file
void PrintInstructionDataCopy(RequiredRVVI_t *InstructionData);

queue_t * InitQueue(int size){
  RequiredRVVI_t * InstructionDataArray =  (RequiredRVVI_t *) malloc(sizeof(RequiredRVVI_t) * size);
  queue_t * queue = (queue_t *) malloc(sizeof(queue_t));
  queue->InstructionData = InstructionDataArray;
  queue->head = 0;
  queue->tail = 0;
  queue->size = size;
  return queue;
}

void Enqueue(RequiredRVVI_t * NewInstructionData, queue_t *queue, int size){
  #if SAFE != 0
  if(IsFull(queue)) return;
  #endif

  
  pthread_mutex_lock(&(queue->HeadLock));
  // deep copy
  // total 99 bytes 12.375 ld/sd
  memcpy(&(queue->InstructionData[queue->head]), (void*) NewInstructionData, size);
  //printf("Enqueue: head %d, tail %d\n", queue->head, queue->tail);
  if(queue->head == (queue->size - 1)) {
    //printf("End of queue wrapping around.\n");
    queue->head = 0;
  }
  else (queue->head)++;
  pthread_mutex_unlock(&(queue->HeadLock));

  
}

void DecodeAndEnqueue(uint8_t *buf, queue_t *queue, int size){
  #if SAFE != 0
  if(IsFull(queue)) return;
  #endif
  RequiredRVVI_t *CurrentDataPtr;
  uint16_t CSRCount;
  uint8_t GPREn;
  uint8_t FPREn;
  int next;
  do {
    CurrentDataPtr = (RequiredRVVI_t *) buf;
    CSRCount = CurrentDataPtr->CSRCount;
    GPREn = CurrentDataPtr->GPREn;
    FPREn = CurrentDataPtr->FPREn;
    next = 48 + ((GPREn | FPREn) ? 8 : 0) + ((CSRCount) ? 52 : 0);
    //printf("DecodeAndEnqueue size = %d, next = %d, Sequence = %ld\n", size, next, CurrentDataPtr->Sequence);
    Enqueue(CurrentDataPtr, queue, next);
    buf = buf + next;
    size = size - next;
  }while(size > 0);
}

void Dequeue(RequiredRVVI_t * InstructionData, queue_t *queue){
  #if SAFE != 0
  if(IsEmpty(queue)) return;
  #endif

  
  pthread_mutex_lock(&(queue->TailLock));
  // deep copy
  //memcpy(InstructionData, &(queue->InstructionData[queue->tail]), sizeof(RequiredRVVI_t));
  RequiredRVVI_t *Src = &(queue->InstructionData[queue->tail]);
  int size = ((Src->GPREn || Src->GPREn) << 3) + (Src->CSRCount ? 50 : 0) + 56;
  memcpy(InstructionData, Src, size);
  if(queue->tail == (queue->size - 1)) queue->tail = 0;
  else (queue->tail)++;
  pthread_mutex_unlock(&(queue->TailLock));

  
}

bool IsFull(queue_t *queue){
  bool result;
  
  pthread_mutex_lock(&(queue->HeadLock));
  pthread_mutex_lock(&(queue->TailLock));
  result = (queue->tail - queue->head) == 1;
  pthread_mutex_unlock(&(queue->HeadLock));
  pthread_mutex_unlock(&(queue->TailLock));
  
  return result;
}

bool IsAlmostFull(queue_t *queue, int Threshold){
  // probably a better solution
  
  pthread_mutex_lock(&(queue->HeadLock));
  pthread_mutex_lock(&(queue->TailLock));
  int head = queue->head;
  int tail = queue->tail;
  int size = queue->size;
  pthread_mutex_unlock(&(queue->HeadLock));
  pthread_mutex_unlock(&(queue->TailLock));

  
  if (head < tail){ // head pointer wrapped around
    head += size;
  }
  int diff = head - tail;
  
  return (diff >= Threshold) | IsFull(queue); 
}
int HowFull(queue_t *queue){
  // probably a better solution
  
  pthread_mutex_lock(&(queue->HeadLock));
  pthread_mutex_lock(&(queue->TailLock));
  int head = queue->head;
  int tail = queue->tail;
  int size = queue->size;
  pthread_mutex_unlock(&(queue->HeadLock));
  pthread_mutex_unlock(&(queue->TailLock));

  
  if (head < tail){ // head pointer wrapped around
    head += size;
  }
  int diff = head - tail;
  
  return diff; 
}

bool IsEmpty(queue_t *queue){
  bool result;

  
  pthread_mutex_lock(&(queue->HeadLock));
  pthread_mutex_lock(&(queue->TailLock));
  result = (queue->head == queue->tail);
  pthread_mutex_unlock(&(queue->HeadLock));
  pthread_mutex_unlock(&(queue->TailLock));

  
  return result;
}

   
void PrintQueue(queue_t *queue){
  int index;

  
  pthread_mutex_lock(&(queue->HeadLock));
  pthread_mutex_lock(&(queue->TailLock));
  printf("Queue Size = %d\n", queue->size);
  printf("Head pointer = %d\n", queue->head);
  printf("Tail pointer = %d\n", queue->tail);
  for(index = 0; index < queue->size; index++){
    PrintInstructionDataCopy(&(queue->InstructionData[index]));
  }
  pthread_mutex_unlock(&(queue->HeadLock));
  pthread_mutex_unlock(&(queue->TailLock));

  
}

void PrintValidQueue(queue_t *queue){
  int index;

  pthread_mutex_lock(&(queue->HeadLock));
  pthread_mutex_lock(&(queue->TailLock));
  printf("Queue Size = %d\n", queue->size);
  printf("Head pointer = %d\n", queue->head);
  printf("Tail pointer = %d\n", queue->tail);
  for(index = queue->tail; index < queue->head; index++){
    PrintInstructionDataCopy(&(queue->InstructionData[index]));
  }
  if((queue->tail > queue->head) ||
     (queue->tail == queue->head)){
    for(index = queue->tail; index < queue->size; index++){
      PrintInstructionDataCopy(&(queue->InstructionData[index]));
    }
    for(index = 0; index < queue->head; index++){
      PrintInstructionDataCopy(&(queue->InstructionData[index]));
    }
  }
  pthread_mutex_unlock(&(queue->HeadLock));
  pthread_mutex_unlock(&(queue->TailLock));

  
}

void PrintInstructionDataCopy(RequiredRVVI_t *InstructionData){
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
    for(CSRIndex = 0; CSRIndex < MAXCSRS; CSRIndex++){ 
      if(InstructionData->CSRReg[CSRIndex] != 0){
	printf(", CSR[%x] = %lx", InstructionData->CSRReg[CSRIndex], InstructionData->CSRValue[CSRIndex]);
      }
    }
  }
  printf("\n");
}
