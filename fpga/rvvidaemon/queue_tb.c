#include <stdio.h>
#include "queue.h"
#include <stdbool.h>
#include "rvvidaemon.h"

int main(){
  int size = 10;
  queue_t * TestQueue;
  TestQueue = InitQueue(size);

  // create a test instruction
  RequiredRVVI_t Instruction0;
  Instruction0.PC = 0x1000;
  Instruction0.insn = 0x00003197;
  Instruction0.Mcycle = 1;
  Instruction0.Mcycle = 1;
  Instruction0.Trap = 0;
  Instruction0.PrivilegeMode = 3;
  Instruction0.GPREn = 1;
  Instruction0.FPREn = 0;
  Instruction0.Pad3 = 0;
  Instruction0.CSRCount = 0;
  Instruction0.Pad4 = 0;
  Instruction0.GPRReg = 1;
  Instruction0.PadG3 = 0;
  Instruction0.GPRValue = 0x4000;
  Instruction0.FPRReg = 0;
  Instruction0.PadF3 = 0;
  Instruction0.FPRValue = 0;
  Instruction0.CSR[0].CSRReg = 0;
  Instruction0.CSR[0].CSRPad = 0;
  Instruction0.CSR[0].CSRValue = 0;
  Instruction0.CSR[1].CSRReg = 0;
  Instruction0.CSR[1].CSRPad = 0;
  Instruction0.CSR[1].CSRValue = 0;
  Instruction0.CSR[2].CSRReg = 0;
  Instruction0.CSR[2].CSRPad = 0;
  Instruction0.CSR[2].CSRValue = 0;

  Enqueue(&Instruction0, TestQueue);

  PrintQueue(TestQueue);
}
