///////////////////////////////////////////////////////////////////////
// spi.c
//
// Written: Jaocb Pease jacob.pease@okstate.edu 8/27/2024
//
// Purpose: C code to test SPI bugs
//
// 
//
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021-23 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the
// “License”); you may not use this file except in compliance with the
// License, or, at your option, the Apache License version 2.0. You
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work
// distributed under the License is distributed on an “AS IS” BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
// implied. See the License for the specific language governing
// permissions and limitations under the License.
///////////////////////////////////////////////////////////////////////

#include "spi.h"
#include "uart.h"
#include "norflash.h"
#include <string.h>

// Testing SPI peripheral in loopback mode
// TODO: Need to make sure the configuration I'm using uses loopback
//       mode. This can be specified in derivlists.txt
// TODO:

uint8_t spi_txrx(uint8_t byte) {
  spi_sendbyte(byte);
  waittx();
  return spi_readbyte();
}

uint8_t spi_dummy() {
  return spi_txrx(0xff);
}

void spi_set_clock(uint32_t clkin, uint32_t clkout) {
  uint32_t div = (clkin/(2*clkout)) - 1;
  write_reg(SPI_SCKDIV, div);
}

// Initialize Sifive FU540 based SPI Controller
void spi_init(uint32_t clkin) {
  // Enable interrupts
  write_reg(SPI_IE, 0x3);

  // Set TXMARK to 1. If the number of entries is < 1
  // IP's txwm field will go high.
  // Set RXMARK to 0. If the number of entries is > 0
  // IP's rwxm field will go high.
  write_reg(SPI_TXMARK, 1);
  write_reg(SPI_RXMARK, 0);

  // Set Delay 0 to default
  write_reg(SPI_DELAY0,
            SIFIVE_SPI_DELAY0_CSSCK(1) |
			SIFIVE_SPI_DELAY0_SCKCS(1));

  // Set Delay 1 to default
  write_reg(SPI_DELAY1,
            SIFIVE_SPI_DELAY1_INTERCS(1) |
            SIFIVE_SPI_DELAY1_INTERXFR(0));

  // Initialize the SPI controller clock to 
  // div = (20MHz/(2*400kHz)) - 1 = 24 = 0x18 
  write_reg(SPI_SCKDIV, 0x18); 
}


char romeo_and_juliet [] = "Two households, both alike in dignity\
(In fair Verona, where we lay our scene),\
From ancient grudge break to new mutiny,\
Where civil blood makes civil hands unclean.\
From forth the fatal loins of these two foes\
A pair of star-crossed lovers take their life;\
Whose misadventured piteous overthrows\
Doth with their death bury their parents’ strife.\
The fearful passage of their death-marked love\
And the continuance of their parents’ rage,\
Which, but their children’s end, naught could remove,\
Is now the two hours’ traffic of our stage;\
The which, if you with patient ears attend,\
What here shall miss, our toil shall strive to mend.";

char dst [128];


void main() {
  spi_init(100000000);

  spi_set_clock(100000000,25000000);
  //spi_set_clock(100000000,50000000);
  
  volatile uint8_t *p = (uint8_t *)(0x8F000000);
  int j;
  uint64_t n = 0;
  uint8_t data;

  write_reg(SPI_CSMODE, SIFIVE_SPI_CSMODE_MODE_HOLD);
  //n = 512/8;

  NorFlashWriteArray(0x0, romeo_and_juliet, 128);
  NorFlashReadArray(0x0, dst, 128);
  int res = strncmp(romeo_and_juliet, dst, 128);
  print_uart("romeo and juliet are same? ");
  if(res) print_uart("no!\n");
  //else print_uart("yes!\n");

  /* NorFlashWrite(0x0, 0x10); */
  /* NorFlashWrite(0x1, 0x11); */
  /* NorFlashWrite(0x2, 0x12); */
  /* NorFlashWrite(0x3, 0x13); */
  /* NorFlashWrite(0x25, 0x2A); */
  /* NorFlashWrite(0x26, 0x2B); */
  /* NorFlashWrite(0x27, 0x2C); */
  /* NorFlashWrite(0x28, 0x2D); */

  /* data = NorFlashRead(0x25); */
  /* print_uart("first data received = "); */
  /* print_uart_dec(data); */
  /* print_uart("\r\n"); */

  /* print_uart("second data received = "); */
  /* data = NorFlashRead(0x26); */
  /* print_uart_dec(data); */
  /* print_uart("\r\n"); */

  /* print_uart("third data received = "); */
  /* data = NorFlashRead(0x27); */
  /* print_uart_dec(data); */
  /* print_uart("\r\n"); */

  /* print_uart("fourth data received = "); */
  /* data = NorFlashRead(0x28); */
  /* print_uart_dec(data); */
  /* print_uart("\r\n"); */



  write_reg(SPI_CSMODE, SIFIVE_SPI_CSMODE_MODE_AUTO);
}
