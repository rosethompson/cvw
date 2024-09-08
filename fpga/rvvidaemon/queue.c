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
  return queue;
}

void Enqueue(RequiredRVVI_t * NewInstructionData, queue_t *queue){
  pthread_mutex_lock(&(queue->lock));
  // *** check if full
  queue->InstructionData[queue->head] = * NewInstructionData;
  (queue->head)++;
  pthread_mutex_unlock(&(queue->lock));
}

void Dequeue(RequiredRVVI_t * InstructionData, queue_t *queue){
  pthread_mutex_lock(&(queue->lock));
  // *** check if empty
  RequiredRVVI_t * InstructionDataArray = queue->InstructionData;
  *InstructionData = InstructionDataArray[queue->tail];
  (queue->tail)--;
  pthread_mutex_unlock(&(queue->lock));
}

bool IsFull(queue_t *queue){
  return IsAlmostFull(queue, queue->size);
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
  return diff == Threshold; 
}

bool IsEmpty(queue_t *queue){
  return (queue->head - queue->tail) == 0;
}

   
void PrintQueue(queue_t *queue){
  int index;
  printf("Queue Size = %d\n", queue->size);
  printf("Head pointer = %d\n", queue->head);
  printf("Tail pointer = %d\n", queue->tail);
  for(index = 0; index < queue->size; index++){
    PrintInstructionDataCopy(&(queue->InstructionData[index]));
  }
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
