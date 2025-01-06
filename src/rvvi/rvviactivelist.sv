///////////////////////////////////////////
// rvviactivelist
//
// Written: Rose Thompson rosethompson.net
// Created: 02 January 2025
// Modified: 02 January 2025
//
// Purpose: Similar to an ooo core active list. inserts instructions into the AL inorder like a FIFO.
//          The second port ACKS the entries marking them not active.  The tail pointer only moves forward
//          if the next entries are not active.
//          The third port scans reads out rvvi instructions from tail to current non-active entry and resends 
//          these instructions.
//
// Documentation: 
//
// A component of the CORE-V-WALLY configurable RISC-V project.
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

module rvviactivelist #(parameter Entries=3, WIDTH=792, WIDTH2=96)(                 // 2^Entries entries of WIDTH bits each
    input logic              clk, Port1Wen, Port2Wen, reset,
    input logic [WIDTH-1:0]  Port1WData, 
    input logic [WIDTH2-1:0] Port2WData, 
    output logic [WIDTH-1:0] Port3RData,
    output logic             Port3RValid,
    input  logic             Port3Stall,
    output logic             Full, Empty);

  // port 2 data is
  // InstrPackDelay (32-bit), Minstret (64-bit), eth src (16-bit), src mac (48-bit) , dst mac (48-bit)

  /* Pointer FIFO using design elements from "Simulation and Synthesis Techniques
   for Asynchronous FIFO Design" by Clifford E. Cummings. Namely, Entries bit read and write pointers
   are an extra bit larger than address size to determine Full/Empty conditions. 
   Watermark comparisons use 2's complement subtraction between the Entries-1 bit pointers,
   which are also used to address memory
   */
  
  logic [WIDTH-1:0]      mem[2**Entries-1:0];
  logic [2**Entries-1:0] ActiveBits;
  logic [Entries:0]      Lut[2**Entries-1:0];
  logic [Entries:0]      TailPtr, HeadPtr, Port3Ptr, Port3PtrNext;
  logic [Entries:0]      TailPtrNext, HeadPtrNext;
  logic [Entries-1:0]    raddr;
  logic [Entries-1:0]    waddr;
  logic [Entries-1:0]    Port2LutIndex;
  typedef enum           {STATE_IDLE, STATE_REPLAY} statetype;
  statetype CurrState, NextState;
  logic                  Port3CounterLoad, Port3CounterEn;
  logic                  Port3Active;
  logic [2**Entries-1:0]    LutMatch;
  

  // search Lut for matching Port2WData[Entries:0]. The index tells us the correct entry in the memory array.
  genvar                 index;
  for(index=0; index<2**Entries; index++) begin
    assign LutMatch[index] = Lut[index] == Port2WData[Entries:0];
  end
  // assume only one matches
  binencoder #(2**Entries) binencoder(LutMatch, Port2LutIndex);
  
  always_ff @(posedge clk)
    if (Port1Wen & ~Full) begin 
      mem[waddr] <= Port1WData;
    end

  always_ff @(posedge clk)
    if (reset) begin 
      TailPtr <= '0;
      HeadPtr <= '0;
      Full <= 1'b0;
      Empty <= 1'b1;
      ActiveBits <= '0;
    end else begin 
      if (Port1Wen) begin
        HeadPtr  <= HeadPtrNext;
        if(~Full) begin 
          Lut[waddr] <= Port1WData[Entries+160:160];
          ActiveBits[waddr] <= 1'b1;
        end
      end 
      if(Port2Wen) begin
        ActiveBits[Port2LutIndex] <= 1'b0;
          //Lut[raddr] <= Port2WData[Entries:0]; // don't need to clear it.
        if(Port2LutIndex == TailPtr[Entries-1:0]) begin // only advance the tail pointer if most recent received instruction is at the end of the FIFO.
          if(Empty) TailPtr <= HeadPtr;
          else TailPtr <= TailPtrNext;
        end
      end
      Empty <= ~|ActiveBits;
      Full <= &ActiveBits;
    end 
  
  assign raddr = TailPtr[Entries-1:0];
  assign TailPtrNext = TailPtr + {{(Entries){1'b0}}, (Port2Wen & ~Empty)};      
  assign waddr = HeadPtr[Entries-1:0];
  assign HeadPtrNext = HeadPtr + {{(Entries){1'b0}}, (Port1Wen & ~Full)};

  // derive tail pointer from the active bits.
  // it is the first 1 after the head pointer.  The easiest way to find it is a leading zero detector, but we first have to align the bits
  // we'll use a rotator to do this. Then we'll have to compenstate by adding back in the shift.
  logic [(2**Entries)*2-1:0]     ActiveBitsShift;
  logic [2**Entries-1:0]     ActiveBitsInvert;
  logic [(2**Entries)*2-1:0] ActiveBitsExtend;
  logic [Entries-1:0]        TailPtrUncompensated;
  logic [Entries-1:0]        TailPtr2;

  logic [2**Entries-1:0]     ActiveBitsRev;
  for(index=0; index<2**Entries; index++) assign ActiveBitsRev[2**Entries-index-1] = ActiveBits[index];
  
  assign ActiveBitsExtend = {ActiveBitsRev[2**Entries-1:0], ActiveBitsRev[2**Entries-1:0]};
  assign ActiveBitsShift = ActiveBitsExtend << HeadPtr[Entries-1:0];
  assign ActiveBitsInvert = ActiveBitsShift[(2**Entries)*2-1:2**Entries];
  lzc #(2**Entries) lzc(ActiveBitsInvert, TailPtrUncompensated);
  assign TailPtr2 = TailPtrUncompensated + HeadPtr[Entries-1:0];

  // port 3
  // if port 2 writes to an address which is not the tail pointer, we iterate from the tail to the first non-active entry.
  // read out each memory entry through Port3RData asserting Port3RValid. Wait until Port3Stall is low between transmissions.
  // During this time it is likely more instructions will arrive out of order on port 2. While the AL is in this state don't
  // restart this process. Wait until it is complete to begin again.

  always_ff @(posedge clk) begin
    if(reset) CurrState <= STATE_IDLE;
    else      CurrState <= NextState;
  end

  always_comb begin
    case(CurrState)
      STATE_IDLE: if(Port2Wen & Port2LutIndex != TailPtr2) NextState = STATE_REPLAY;
      else NextState = STATE_IDLE;
      STATE_REPLAY: if(~Port3Active & ~Port3Stall) NextState = STATE_IDLE;
      else NextState = STATE_REPLAY;
      default: NextState = STATE_IDLE;
    endcase
  end

  flopenl #(Entries+1) port3counterreg(clk, Port3CounterLoad, Port3CounterEn, Port3PtrNext, TailPtr2, Port3Ptr);
  assign Port3PtrNext = Port3Ptr + 1;
  assign Port3CounterLoad = CurrState == STATE_IDLE & Port2Wen & Port2LutIndex != TailPtr2;
  assign Port3CounterEn = CurrState == STATE_IDLE & Port2Wen & Port2LutIndex != TailPtr2 & ~Port3Stall;
  assign Port3Active = ActiveBits[Port3Ptr];
  assign Port3RData = mem[Port3Ptr];
  assign Port3RValid = CurrState == STATE_REPLAY & ~Port3Stall;
  

endmodule
