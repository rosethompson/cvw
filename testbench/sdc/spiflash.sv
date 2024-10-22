///////////////////////////////////////////
// spiflash.sv
//
// Written: Rose Thompson rose@rosethompson.net
// Modified:
//
// Purpose: A basic model of SPI NOR flash device.  Does not model any specific IC.
//
// A component of the Wally configurable RISC-V project.
//
// Copyright (C) 2021 Harvey Mudd College & Oklahoma State University
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

module spiflash import cvw::*; #(parameter CLK_PHA = 0, CLK_POL = 0)(
  input logic  CLK,
  output logic MISO,
  input logic  MOSI,
  input logic  CS);

  // This is simulation model. There is no reset, but I don't want there to be x's in the simulation so
  // signals shall have initial values.

  logic [7:0]  Command;
  logic [31:0] Address;
  logic [7:0]  ReadData, WriteData;
  logic [7:0] mem [63:0];
  logic        CntReset, CntEn;
  logic [4:0]  Count;
  logic        LastBit, LastBitAdr;
  logic        CommandEn, AddressEn;
  logic        WriteEn;
  logic        WriteArray;
  logic        ReadArray;
  
  
  typedef enum {STATE_RDY, STATE_ADR, STATE_CMD, STATE_DATA} statetype;
  statetype CurrState, NextState;

  // command format (read 1), (write 2), (nop 0), (undefined other). All operations are bytes
  // send address first, then command, then write data if write.  or wait for read data

  initial begin
    CurrState = STATE_RDY;
    ReadData = 0;
    
  end

  always_ff @(posedge CLK) begin
    if(~CS) begin
      CurrState <= NextState;
    end
  end

  always_comb begin
    case(CurrState)
      STATE_RDY: if (~CS) NextState = STATE_ADR;
      else NextState = STATE_RDY;
      STATE_ADR: if (~CS & LastBitAdr) NextState = STATE_CMD;
      else NextState = STATE_ADR;
      STATE_CMD: if (~CS & LastBit) NextState = STATE_DATA;
      else NextState = STATE_CMD;
      STATE_DATA: if (LastBit & CS) NextState = STATE_RDY;
      else if (~LastBit & ~CS) NextState = STATE_DATA;
      else if (LastBit & ~CS) NextState = STATE_ADR;
      default NextState = STATE_RDY;
    endcase
  end

  assign CntReset = (CurrState == STATE_RDY) | (CurrState == STATE_ADR & LastBitAdr) | (CurrState == STATE_CMD & LastBit) | (CurrState == STATE_DATA & LastBit);
  assign CntEn = (CurrState == STATE_ADR) | (CurrState == STATE_CMD) | (CurrState == STATE_DATA);
  counter #(5) counter(CLK, CntReset, CntEn, Count);
  assign LastBit    = Count == 5'b00111;  
  assign LastBitAdr = Count == 5'b11111;

  assign CommandEn = NextState == STATE_CMD & ~CS;
  flopen #(8) commandreg(CLK, CommandEn, {Command[6:0], MOSI}, Command);
  assign ReadArray = CurrState == STATE_CMD & ~CS & LastBit & Command == 8'b1;

  assign AddressEn = NextState == STATE_ADR & ~CS;
  flopen #(32) addressreg(CLK, AddressEn, {Address[30:0], MOSI}, Address);

  assign WriteEn = (NextState == STATE_DATA) & ~CS & (Command == 8'b10);
  flopen #(8) writedatareg(CLK, WriteEn, {WriteData[6:0], MOSI}, WriteData);
  assign WriteArray = (CurrState == STATE_DATA) & ~CS & (Command == 8'b10) & LastBit;

  /* verilator lint_off MULTIDRIVEN */
  always_ff @(posedge CLK) begin
    if(~CS & WriteArray) begin
      mem[Address] <= WriteData;
    end
  end

  always_ff @(negedge CLK) begin
    if(~CS & ReadArray) begin
      ReadData <= mem[Address];
    end 
    if (CurrState == STATE_DATA & ~CS & Command == 8'b1) begin
      ReadData <= {ReadData[6:0], 1'b0};
    end
  end
  /* verilator lint_on MULTIDRIVEN */

  assign MISO = ReadData[7];
  
endmodule


