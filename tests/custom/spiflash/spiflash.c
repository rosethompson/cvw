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

void NorFlashWrite(uint32_t adr, uint8_t data){
  while(read_reg(SPI_TXDATA) & 0x100);
  spi_sendbyte((adr >> 24) & 0xFF);
  while(read_reg(SPI_TXDATA) & 0x100);
  spi_sendbyte((adr >> 16) & 0xFF);
  while(read_reg(SPI_TXDATA) & 0x100);
  spi_sendbyte((adr >> 8) & 0xFF);
  while(read_reg(SPI_TXDATA) & 0x100);
  spi_sendbyte(adr & 0xFF);
  // send command 0x2 to write
  while(read_reg(SPI_TXDATA) & 0x100);
  spi_sendbyte(0x02);
  while(read_reg(SPI_TXDATA) & 0x100);
  spi_sendbyte(data);
}


uint8_t NorFlashRead(uint32_t adr){
  // read address 0x25
  while(read_reg(SPI_TXDATA) & 0x100);
  spi_sendbyte((adr >> 24) & 0xFF);
  while(read_reg(SPI_TXDATA) & 0x100);
  spi_sendbyte((adr >> 16) & 0xFF);
  while(read_reg(SPI_TXDATA) & 0x100);
  spi_sendbyte((adr >> 8) & 0xFF);
  while(read_reg(SPI_TXDATA) & 0x100);
  spi_sendbyte(adr & 0xFF);
  // send command 0x1 to read
  while(read_reg(SPI_TXDATA) & 0x100);
  spi_sendbyte(0x01);

  // before reading this byte we need to read the junk in the receive fifo
  while ((read_reg(SPI_IP) & 2)) {
    volatile int delay;
    for (delay = 0; delay < 10; delay++); // Ugh. the SiFive spec is terrible. There is a race between the fifo empty (or IP) and receiving another byte.
    spi_readbyte();}
  spi_dummy();
  while (!(read_reg(SPI_IP) & 2)) {}
  return spi_readbyte();
}

void main() {
  spi_init(100000000);

  spi_set_clock(100000000,25000000);
  
  volatile uint8_t *p = (uint8_t *)(0x8F000000);
  int j;
  uint64_t n = 0;
  uint8_t data;

  write_reg(SPI_CSMODE, SIFIVE_SPI_CSMODE_MODE_HOLD);
  //n = 512/8;

  NorFlashWrite(0x0, 0x10);
  NorFlashWrite(0x1, 0x11);
  NorFlashWrite(0x2, 0x12);
  NorFlashWrite(0x3, 0x13);
  NorFlashWrite(0x25, 0x2A);
  NorFlashWrite(0x26, 0x2B);
  NorFlashWrite(0x27, 0x2C);
  NorFlashWrite(0x28, 0x2D);

  print_uart("first data received = ");
  data = NorFlashRead(0x25);
  print_uart_dec(data);
  print_uart("\r\n");

  print_uart("second data received = ");
  data = NorFlashRead(0x26);
  print_uart_dec(data);
  print_uart("\r\n");

  print_uart("third data received = ");
  data = NorFlashRead(0x27);
  print_uart_dec(data);
  print_uart("\r\n");

  print_uart("fourth data received = ");
  data = NorFlashRead(0x28);
  print_uart_dec(data);
  print_uart("\r\n");


// 
  /* n = 4; */
  /* do { */
  /*   // Send 8 dummy bytes (fifo should be empty) */
  /*   for (j = 0; j < 8; j++) { */
  /*     spi_sendbyte(0xaa + j); */
  /*   } */
    
  /*   // Reset counter. Process bytes AS THEY COME IN. */
  /*   for (j = 0; j < 8; j++) { */
  /*     while (!(read_reg(SPI_IP) & 2)) {} */
  /*     uint8_t x = spi_readbyte(); */
  /*     *p++ = x;       */
  /*   } */
  /* } while(--n > 0); */

  write_reg(SPI_CSMODE, SIFIVE_SPI_CSMODE_MODE_AUTO);
}
