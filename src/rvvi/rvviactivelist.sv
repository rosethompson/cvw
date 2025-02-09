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

module rvviactivelist #(parameter Entries=3, WIDTH=792, FRAME_COUNT_WIDTH=16)(                 // 2^Entries entries of WIDTH bits each
(* mark_debug = "true" *)    input logic              clk, DutValid, HostInstrValid, reset,
    input logic [WIDTH-1:0]  DutData, 
    input logic [FRAME_COUNT_WIDTH-1:0] HostFrameCount, 
    output logic [WIDTH-1:0] ActiveListData,
(* mark_debug = "true" *)    output logic             SelActiveList,
(* mark_debug = "true" *)    input  logic             RVVIStall,
(* mark_debug = "true" *)    output logic             ActiveListStall);

  // port 2 data is
  // InstrPackDelay (32-bit), Minstret (64-bit), eth src (16-bit), src mac (48-bit) , dst mac (48-bit)

  logic [WIDTH-1:0]          mem[2**Entries-1:0];
(* mark_debug = "true" *)  logic [2**Entries-1:0]     ActiveBits;
  logic [Entries-1:0]        Lut[2**Entries-1:0];
(* mark_debug = "true" *)  logic [Entries-1:0]        HeadPtr, ReplayPtr;
  logic [Entries-1:0]        HeadPtrNext, ReplayPtrNext;
  logic [Entries-1:0]        HostMatchingIndex;
  typedef enum               {STATE_IDLE, STATE_REPLAY, STATE_WAIT} statetype;
(* mark_debug = "true" *)  statetype CurrState, NextState;
  logic                      ReplayPtrLoad;
  logic                      Port3Active;
(* mark_debug = "true" *)  logic [2**Entries-1:0]     HostMatchingActiveBits;
  logic [(2**Entries)*2-1:0] ActiveBitsShift;
  logic [2**Entries-1:0]     ActiveBitsInvert;
  logic [(2**Entries)*2-1:0] ActiveBitsExtend;
  logic [Entries-1:0]        TailPtrUncompensated;
(* mark_debug = "true" *)  logic [Entries-1:0]        TailPtr;

  logic [2**Entries-1:0]     ActiveBitsRev;
(* mark_debug = "true" *)  logic                      Full, Empty;
  logic [WIDTH-1:0]	     ReadData;
  logic			     HostMatches;
  logic [FRAME_COUNT_WIDTH-1:0]	Tag;
    
  // search Lut for matching HostFrameCount[Entries:0]. The index tells us the correct entry in the memory array.
  genvar                 index;
  for(index=0; index<2**Entries; index++) begin
    assign HostMatchingActiveBits[index] = Lut[index] == HostFrameCount[Entries-1:0] & ActiveBits[index];
  end
  // assume only one matches
  binencoder #(2**Entries) binencoder(HostMatchingActiveBits, HostMatchingIndex);

  assign ReadData = mem[HostMatchingIndex];
  assign Tag = ReadData[FRAME_COUNT_WIDTH-1:0];
  assign HostMatches = Tag == HostFrameCount;
  
  always_ff @(posedge clk)
    if (DutValid & ~Full) begin 
      mem[HeadPtr] <= DutData;
    end

  always_ff @(posedge clk)
    if (reset) begin 
      HeadPtr <= '0;
      Full <= 1'b0;
      Empty <= 1'b1;
      ActiveBits <= '0;
    end else begin 
      if (DutValid) begin
        HeadPtr  <= HeadPtrNext;
        if(~Full) begin 
          Lut[HeadPtr] <= DutData[Entries-1:0];
          ActiveBits[HeadPtr] <= 1'b1;
        end
      end 
      if(HostInstrValid & HostMatches) begin
        ActiveBits[HostMatchingIndex] <= 1'b0;
      end
      Empty <= ~|ActiveBits;
      Full <= &ActiveBits;
    end 
  
  assign HeadPtrNext = HeadPtr + {{(Entries){1'b0}}, (DutValid & ~Full)};

  // derive tail pointer from the active bits.
  // it is the first 1 after the head pointer.  The easiest way to find it is a leading zero detector, but we first have to align the bits
  // we'll use a rotator to do this. Then we'll have to compenstate by adding back in the shift.
  for(index=0; index<2**Entries; index++) assign ActiveBitsRev[2**Entries-index-1] = ActiveBits[index];
  
  assign ActiveBitsExtend = {ActiveBitsRev[2**Entries-1:0], ActiveBitsRev[2**Entries-1:0]};
  assign ActiveBitsShift = ActiveBitsExtend << HeadPtr[Entries-1:0];
  assign ActiveBitsInvert = ActiveBitsShift[(2**Entries)*2-1:2**Entries];
  lzc #(2**Entries) lzc(ActiveBitsInvert, TailPtrUncompensated);
  assign TailPtr = TailPtrUncompensated + HeadPtr[Entries-1:0];

  // port 3
  // if port 2 writes to an address which is not the tail pointer, we iterate from the tail to the first non-active entry.
  // read out each memory entry through ActiveListData asserting SelActiveList. Wait until RVVIStall is low between transmissions.
  // During this time it is likely more instructions will arrive out of order on port 2. While the AL is in this state don't
  // restart this process. Wait until it is complete to begin again.

  always_ff @(posedge clk) begin
    if(reset) CurrState <= STATE_IDLE;
    else      CurrState <= NextState;
  end

  always_comb begin
    case(CurrState)
      STATE_IDLE: if(HostInstrValid & (HostMatchingIndex != TailPtr | ~HostMatches)) NextState = STATE_REPLAY;
      // this case is tricky.
      // 1. if the sequence number does not match the tail then it's out of order and we need to replay.
      // 2. if it does match because there are multiple sequencies which map into the same index (set) we need to
      // check the tags to see if that entry is even in the active list with ~HostMatches.
      else NextState = STATE_IDLE;
      STATE_REPLAY: if(~Port3Active & ~RVVIStall) NextState = STATE_WAIT;
      else NextState = STATE_REPLAY;
      STATE_WAIT: if(Empty) NextState = STATE_IDLE;
      else NextState = STATE_WAIT;
      default: NextState = STATE_IDLE;
    endcase
  end

  flopenl #(Entries) replayptrcounterreg(clk, ReplayPtrLoad, SelActiveList, ReplayPtrNext, TailPtr, ReplayPtr);

  assign ReplayPtrNext = ReplayPtr + 1;
  assign ReplayPtrLoad = (CurrState == STATE_IDLE & HostInstrValid & HostMatchingIndex != TailPtr) | reset;
  assign Port3Active = ActiveBits[ReplayPtr];
  assign ActiveListData = mem[ReplayPtr];
  assign SelActiveList = CurrState == STATE_REPLAY & ~RVVIStall & Port3Active;
  assign ActiveListStall = CurrState == STATE_WAIT | CurrState == STATE_REPLAY | Full;

endmodule
