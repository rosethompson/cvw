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

// copy in rvvidaemon merge together and move to separate file
void PrintInstructionDataCopy(RequiredRVVI_t *InstructionData);

queue_t * InitQueue(int size){
  RequiredRVVI_t * InstructionDataArray =  (RequiredRVVI_t *) malloc(sizeof(RequiredRVVI_t) * size);
  queue_t * queue = (queue_t *) malloc(sizeof(queue_t));
  queue->InstructionData = InstructionDataArray;
  queue->head = 0;
  queue->tail = 0;
  queue->size = size;
  queue->empty = 1;
  return queue;
}

void Enqueue(RequiredRVVI_t * NewInstructionData, queue_t *queue){
  if(IsFull(queue)) return;
  pthread_mutex_lock(&(queue->lock));
  // deep copy
  queue->InstructionData[queue->head].PC = NewInstructionData->PC;
  queue->InstructionData[queue->head].insn = NewInstructionData->insn;
  queue->InstructionData[queue->head].Mcycle = NewInstructionData->Mcycle;
  queue->InstructionData[queue->head].Minstret = NewInstructionData->Minstret;
  queue->InstructionData[queue->head].Trap = NewInstructionData->Trap;
  queue->InstructionData[queue->head].PrivilegeMode = NewInstructionData->PrivilegeMode;
  queue->InstructionData[queue->head].GPREn = NewInstructionData->GPREn;
  queue->InstructionData[queue->head].FPREn = NewInstructionData->FPREn;
  queue->InstructionData[queue->head].Pad3 = NewInstructionData->Pad3;
  queue->InstructionData[queue->head].CSRCount = NewInstructionData->CSRCount;
  queue->InstructionData[queue->head].Pad4 = NewInstructionData->Pad4;
  queue->InstructionData[queue->head].GPRReg = NewInstructionData->GPRReg;
  queue->InstructionData[queue->head].PadG3 = NewInstructionData->PadG3;
  queue->InstructionData[queue->head].GPRValue = NewInstructionData->GPRValue;
  queue->InstructionData[queue->head].FPRReg = NewInstructionData->FPRReg;
  queue->InstructionData[queue->head].PadF3 = NewInstructionData->PadF3;
  queue->InstructionData[queue->head].FPRValue = NewInstructionData->FPRValue;
  int index;
  for(index = 0; index < MAXCSRS; index++){
  queue->InstructionData[queue->head].CSR[index].CSRReg = NewInstructionData->CSR[index].CSRReg;
  queue->InstructionData[queue->head].CSR[index].CSRPad = NewInstructionData->CSR[index].CSRPad;
  queue->InstructionData[queue->head].CSR[index].CSRValue = NewInstructionData->CSR[index].CSRValue;
  }
  //printf("Enqueue: head %d, tail %d\n", queue->head, queue->tail);
  if(queue->head == (queue->size - 1)) {
    //printf("End of queue wrapping around.\n");
    queue->head = 0;
  }
  else (queue->head)++;
  queue->empty = 0;
  pthread_mutex_unlock(&(queue->lock));
}

void Dequeue(RequiredRVVI_t * InstructionData, queue_t *queue){
  if(IsEmpty(queue)) return;
  pthread_mutex_lock(&(queue->lock));
  RequiredRVVI_t * InstructionDataArray = &queue->InstructionData[queue->tail];
  // deep copy
  InstructionData->PC = InstructionDataArray->PC;
  InstructionData->insn = InstructionDataArray->insn;
  InstructionData->Mcycle = InstructionDataArray->Mcycle;
  InstructionData->Minstret = InstructionDataArray->Minstret;
  InstructionData->Trap = InstructionDataArray->Trap;
  InstructionData->PrivilegeMode = InstructionDataArray->PrivilegeMode;
  InstructionData->GPREn = InstructionDataArray->GPREn;
  InstructionData->FPREn = InstructionDataArray->FPREn;
  InstructionData->Pad3 = InstructionDataArray->Pad3;
  InstructionData->CSRCount = InstructionDataArray->CSRCount;
  InstructionData->Pad4 = InstructionDataArray->Pad4;
  InstructionData->GPRReg = InstructionDataArray->GPRReg;
  InstructionData->PadG3 = InstructionDataArray->PadG3;
  InstructionData->GPRValue = InstructionDataArray->GPRValue;
  InstructionData->FPRReg = InstructionDataArray->FPRReg;
  InstructionData->PadF3 = InstructionDataArray->PadF3;
  InstructionData->FPRValue = InstructionDataArray->FPRValue;
  int index;
  for(index = 0; index < MAXCSRS; index++){
  InstructionData->CSR[index].CSRReg = InstructionDataArray->CSR[index].CSRReg;
  InstructionData->CSR[index].CSRPad = InstructionDataArray->CSR[index].CSRPad;
  InstructionData->CSR[index].CSRValue = InstructionDataArray->CSR[index].CSRValue;
  }
  if(queue->tail == (queue->size - 1)) queue->tail = 0;
  else (queue->tail)++;
  if(queue->tail == queue->head) queue->empty = 1;
  pthread_mutex_unlock(&(queue->lock));
}

bool IsFull(queue_t *queue){
  bool result;
  pthread_mutex_lock(&(queue->lock));
  result = (queue->head == queue->tail) && !(queue->empty);
  pthread_mutex_unlock(&(queue->lock));
  return result;
}

bool IsAlmostFull(queue_t *queue, int Threshold){
  // probably a better solution
  pthread_mutex_lock(&(queue->lock));
  int head = queue->head;
  int tail = queue->tail;
  int size = queue->size;
  pthread_mutex_unlock(&(queue->lock));
  if (head < tail){ // head pointer wrapped around
    head += size;
  }
  int diff = head - tail;
  return (diff >= Threshold) | IsFull(queue); 
}
int HowFull(queue_t *queue){
  // probably a better solution
  pthread_mutex_lock(&(queue->lock));
  int head = queue->head;
  int tail = queue->tail;
  int size = queue->size;
  pthread_mutex_unlock(&(queue->lock));
  if (head < tail){ // head pointer wrapped around
    head += size;
  }
  int diff = head - tail;
  return diff; 
}

bool IsEmpty(queue_t *queue){
  bool result;
  pthread_mutex_lock(&(queue->lock));
  result = (queue->head == queue->tail) && queue->empty;
  pthread_mutex_unlock(&(queue->lock));
  return result;
}

   
void PrintQueue(queue_t *queue){
  int index;
  pthread_mutex_lock(&(queue->lock));
  printf("Queue Size = %d\n", queue->size);
  printf("Head pointer = %d\n", queue->head);
  printf("Tail pointer = %d\n", queue->tail);
  for(index = 0; index < queue->size; index++){
    PrintInstructionDataCopy(&(queue->InstructionData[index]));
  }
  pthread_mutex_unlock(&(queue->lock));
}

void PrintValidQueue(queue_t *queue){
  int index;
  pthread_mutex_lock(&(queue->lock));
  printf("Queue Size = %d\n", queue->size);
  printf("Head pointer = %d\n", queue->head);
  printf("Tail pointer = %d\n", queue->tail);
  for(index = queue->tail; index < queue->head; index++){
    PrintInstructionDataCopy(&(queue->InstructionData[index]));
  }
  if((queue->tail > queue->head) ||
     (queue->tail == queue->head && !queue->empty)){
    for(index = queue->tail; index < queue->size; index++){
      PrintInstructionDataCopy(&(queue->InstructionData[index]));
    }
    for(index = 0; index < queue->head; index++){
      PrintInstructionDataCopy(&(queue->InstructionData[index]));
    }
  }
  pthread_mutex_unlock(&(queue->lock));
}

void PrintInstructionDataCopy(RequiredRVVI_t *InstructionData){
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
