#ifndef __QUEUE_H
#define __QUEUE_H

#define SAFE 0

#include "rvvidaemon.h"
#include <pthread.h>
#include <stdbool.h>

typedef struct {
  RequiredRVVI_t *InstructionData;
  int head, tail, size;
  pthread_mutex_t lock;
  pthread_mutex_t HeadLock;
  pthread_mutex_t TailLock;
} queue_t;

queue_t * InitQueue(int size);
void Enqueue(RequiredRVVI_t * NewInstructionData, queue_t *queue, int size);
void Dequeue(RequiredRVVI_t * InstructionData, queue_t *queue);
bool IsFull(queue_t *queue);
bool IsAlmostFull(queue_t *queue, int Threshold);
int HowFull(queue_t *queue);
bool IsEmpty(queue_t *queue);
void PrintQueue(queue_t *queue);
void PrintValidQueue(queue_t *queue);

#endif
