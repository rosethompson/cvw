#ifndef __RVVIDAEMON_H
#define __RVVIDAEMON_H

#include <stdint.h>

#define MAXCSRS 5 // *** bad to have defined in multiple locations

typedef struct {
  uint64_t CSRReg;
  uint64_t CSRValue;
} CSR_unpacked_t;

//typedef struct __attribute__((packed)) {
typedef struct {
  uint64_t Sequence;
  uint64_t PC;
  uint64_t Mcycle;
  uint64_t Minstret;
  uint32_t insn;
  uint16_t CSRCount;
  uint8_t Trap;
  uint8_t PrivilegeMode;
  uint8_t GPREn;
  uint8_t FPREn;
  uint8_t GPRReg;
  uint8_t FPRReg;
  uint32_t Pad32;
  uint64_t GPRValue; // or FPRValue
  uint64_t CSRValue[MAXCSRS];
  uint16_t CSRReg[MAXCSRS];
  uint16_t Pad16;
} RequiredRVVI_t; // 920 bits

#endif
