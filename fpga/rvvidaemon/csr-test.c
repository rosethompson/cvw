#include <stdio.h>
#include <stdlib.h>
#include "rvvidaemon.h"

int main(int argc, char **argv){
  CSR_unpacked_t CSRs [56];
  FILE *fp;
  fp = fopen("CSRs.bin", "w");
  CSRs[0].CSRReg = 1;
  CSRs[0].CSRValue = 0x0000000000000000;
  CSRs[1].CSRReg = 0x002;
  CSRs[1].CSRValue = 0x0000000000000000; //frm
  CSRs[2].CSRReg = 0x003;
  CSRs[2].CSRValue = 0x0000000000000000; //fcsr
  CSRs[3].CSRReg = 0x100;
  CSRs[3].CSRValue = 0x0000000200000100; //sstatus
  CSRs[4].CSRReg = 0x104;
  CSRs[4].CSRValue = 0x0000000000000000; //sie
  CSRs[5].CSRReg = 0x105;
  CSRs[5].CSRValue = 0xffffffff8000308c; //stvec
  CSRs[6].CSRReg = 0x106;
  CSRs[6].CSRValue = 0x0000000000000007; //scounteren
  CSRs[7].CSRReg = 0x10A;
  CSRs[7].CSRValue = 0x0000000000000000; //senvcfg
  CSRs[8].CSRReg = 0x140;
  CSRs[8].CSRValue = 0x0000000000000000; //sscratch
  CSRs[9].CSRReg = 0x141;
  CSRs[9].CSRValue = 0x0000000080201048; //sepc
  CSRs[10].CSRReg = 0x142;
  CSRs[10].CSRValue = 0x000000000000000c; //scause
  CSRs[11].CSRReg = 0x143;
  CSRs[11].CSRValue = 0x0000000080201048; //stval
  CSRs[12].CSRReg = 0x144;
  CSRs[12].CSRValue = 0x0000000000000020; //sip
  CSRs[13].CSRReg = 0x14D;
  CSRs[13].CSRValue = 0x0000000000000000; //stimecmp
  CSRs[14].CSRReg = 0x180;
  CSRs[14].CSRValue = 0x9000000000080805; //satp
  CSRs[15].CSRReg = 0x300;
  CSRs[15].CSRValue = 0x0000000a00000180; //mstatus
  CSRs[16].CSRReg = 0x301;
  CSRs[16].CSRValue = 0x800000000014112f; //misa
  CSRs[17].CSRReg = 0x302;
  CSRs[17].CSRValue = 0x000000000000b108; //medeleg
  CSRs[18].CSRReg = 0x303;
  CSRs[18].CSRValue = 0x0000000000000222; //mideleg
  CSRs[19].CSRReg = 0x304;
  CSRs[19].CSRValue = 0x0000000000000008; //mie
  CSRs[20].CSRReg = 0x305;
  CSRs[20].CSRValue = 0x0000000080000428; //mtvec
  CSRs[21].CSRReg = 0x306;
  CSRs[21].CSRValue = 0x00000000ffffffff; //mcounteren
  CSRs[22].CSRReg = 0x30A;
  CSRs[22].CSRValue = 0xc0000000000000f0; //menvcfg
  CSRs[23].CSRReg = 0x320;
  CSRs[23].CSRValue = 0x00000000fffffff8; //mcountinhibit
  CSRs[24].CSRReg = 0x340;
  CSRs[24].CSRValue = 0x0000000080027000; //mscratch
  CSRs[25].CSRReg = 0x341;
  CSRs[25].CSRValue = 0x0000000080200000; //mepc
  CSRs[26].CSRReg = 0x342;
  CSRs[26].CSRValue = 0x0000000000000003; //mcause
  CSRs[27].CSRReg = 0x343;
  CSRs[27].CSRValue = 0x000000008000d3b4; //mtval
  CSRs[28].CSRReg = 0x344;
  CSRs[28].CSRValue = 0x0000000000000020; //mip
  CSRs[29].CSRReg = 0x3A0;
  CSRs[29].CSRValue = 0x000000001f181818; //pmpcfg0
  CSRs[30].CSRReg = 0x3A2;
  CSRs[30].CSRValue = 0x0000000000000000; //pmpcfg2
  CSRs[31].CSRReg = 0x3B0;
  CSRs[31].CSRValue = 0x0000000000801fff; //pmpaddr0
  CSRs[32].CSRReg = 0x3B1;
  CSRs[32].CSRValue = 0x0000000020003fff; //pmpaddr1
  CSRs[33].CSRReg = 0x3B2;
  CSRs[33].CSRValue = 0x000000002000bfff; //pmpaddr2
  CSRs[34].CSRReg = 0x3B3;
  CSRs[34].CSRValue = 0x003fffffffffffff; //pmpaddr3
  CSRs[35].CSRReg = 0x3B4;
  CSRs[35].CSRValue = 0x0000000000000000; //pmpaddr4
  CSRs[36].CSRReg = 0x3B5;
  CSRs[36].CSRValue = 0x0000000000000000; //pmpaddr5
  CSRs[37].CSRReg = 0x3B6;
  CSRs[37].CSRValue = 0x0000000000000000; //pmpaddr6
  CSRs[38].CSRReg = 0x3B7;
  CSRs[38].CSRValue = 0x0000000000000000; //pmpaddr7
  CSRs[39].CSRReg = 0x3B8;
  CSRs[39].CSRValue = 0x0000000000000000; //pmpaddr8
  CSRs[40].CSRReg = 0x3B9;
  CSRs[40].CSRValue = 0x0000000000000000; //pmpaddr9
  CSRs[41].CSRReg = 0x3BA;
  CSRs[41].CSRValue = 0x0000000000000000; //pmpaddr10
  CSRs[42].CSRReg = 0x3BB;
  CSRs[42].CSRValue = 0x0000000000000000; //pmpaddr11
  CSRs[43].CSRReg = 0x3BC;
  CSRs[43].CSRValue = 0x0000000000000000; //pmpaddr12
  CSRs[44].CSRReg = 0x3BD;
  CSRs[44].CSRValue = 0x0000000000000000; //pmpaddr13
  CSRs[45].CSRReg = 0x3BE;
  CSRs[45].CSRValue = 0x0000000000000000; //pmpaddr14
  CSRs[46].CSRReg = 0x3BF;
  CSRs[46].CSRValue = 0x0000000000000000; //pmpaddr15
  CSRs[47].CSRReg = 0xB00;
  CSRs[47].CSRValue = 0x000000001bd66166; //mcycle
  CSRs[48].CSRReg = 0xB02;
  CSRs[48].CSRValue = 0x000000001bd66160; //minstret
  CSRs[49].CSRReg = 0xC00;
  CSRs[49].CSRValue = 0x000000001bd66166; //cycle
  CSRs[50].CSRReg = 0xC02;
  CSRs[50].CSRValue = 0x000000001bd66160; //instret
  CSRs[51].CSRReg = 0xF11;
  CSRs[51].CSRValue = 0x0000000000000602; //mvendorid
  CSRs[52].CSRReg = 0xF12;
  CSRs[52].CSRValue = 0x0000000000000024; //marchid
  CSRs[53].CSRReg = 0xF13;
  CSRs[53].CSRValue = 0x0000000000000100; //mimpid
  CSRs[54].CSRReg = 0xF14;
  CSRs[54].CSRValue = 0x0000000000000000; //mhartid
  CSRs[55].CSRReg = 0xF15;
  CSRs[55].CSRValue = 0x0000000000000000; //mconfigptr


  fwrite(CSRs, 16, 56, fp);
  fclose(fp);
}
