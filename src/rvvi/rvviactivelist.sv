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

module rvviactivelist #(parameter Entries=3, WIDTH=792, WIDTH2=224)(                 // 2^Entries entries of WIDTH bits each
    input logic              clk, Port1Wen, Port2Wen, reset,
    input logic [WIDTH-1:0]  Port1WData, 
    input logic [WIDTH2-1:0] Port2WData, 
    output logic [WIDTH-1:0] Port3RData,
    output logic             Port3RValid,
    input  logic             Port3Stall,
    output logic             Full, Empty);
  

  /* Pointer FIFO using design elements from "Simulation and Synthesis Techniques
   for Asynchronous FIFO Design" by Clifford E. Cummings. Namely, Entries bit read and write pointers
   are an extra bit larger than address size to determine Full/Empty conditions. 
   Watermark comparisons use 2's complement subtraction between the Entries-1 bit pointers,
   which are also used to address memory
   */
  
  logic [WIDTH-1:0]      mem[2**Entries];
  logic [2**Entries]     ActiveBits;
  logic [WIDTH-1:0]      Lut[Entries:0];
  logic [Entries:0]      TailPtr, HeadPtr, Port3Ptr, Port3PtrNext;
  logic [Entries:0]      TailPtrNext, HeadPtrNext;
  logic [Entries-1:0]    raddr;
  logic [Entries-1:0]    waddr;
  logic [Entries-1:0]    Port2LutIndex;
  typedef enum           {STATE_IDLE, STATE_REPLAY} statetype;
  statetype CurrState, NextState;
  logic                  Port3CounterLoad, Port3CounterEn;
  logic                  Port3Active;
  
  
  
  assign Port2LutIndex = Lut[Port2WData[Entries+160:160]];
  
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
    end else begin 
      if (Port1Wen) begin
        Full <= ({~HeadPtrNext[Entries], HeadPtrNext[Entries-1:0]} == TailPtr);
        HeadPtr  <= HeadPtrNext;
        if(~Full) begin 
          Lut[waddr][2**Entries+160:160] <= HeadPtr; // 160 is offset for Minstret
          ActiveBits[waddr] <= 1'b1;
        end
      end else if(Port2Wen) begin
        ActiveBits[Port2LutIndex] <= 1'b0;
        if(Port2LutIndex == TailPtr) TailPtr <= TailPtrNext; // only advance the tail pointer if most recent received instruction is at the end of the FIFO.
      end
      Empty <= |ActiveBits;
    end 
  
  assign raddr = TailPtr[Entries-1:0];
  assign TailPtrNext = TailPtr + {{(Entries){1'b0}}, (Port2Wen & ~Empty)};      
  assign waddr = HeadPtr[Entries-1:0];
  assign HeadPtrNext = HeadPtr + {{(Entries){1'b0}}, (Port1Wen & ~Full)};

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
      STATE_IDLE: if(Port2Wen & Port2LutIndex != TailPtr) NextState = STATE_REPLAY;
      else NextState = STATE_IDLE;
      STATE_REPLAY: if(~Port3Active & ~Port3Stall) NextState = STATE_IDLE;
      else NextState = STATE_REPLAY;
      default: NextState = STATE_IDLE;
    endcase
  end

  flopenl #(Entries+1) port3counterreg(clk, Port3CounterLoad, Port3CounterEn, Port3PtrNext, TailPtr, Port3Ptr);
  assign Port3PtrNext = Port3Ptr + 1;
  assign Port3CounterLoad = CurrState == STATE_IDLE & Port2Wen & Port2LutIndex != TailPtr;
  assign Port3CounterEn = CurrState == STATE_REPLAY & ~Port3Stall;
  assign Port3Active = ActiveBits[Port3Ptr];
  assign Port3RData = mem[Port3Ptr];
  assign Port3RValid = CurrState == STATE_REPLAY & ~Port3Stall;
  

endmodule
