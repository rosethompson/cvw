///////////////////////////////////////////
// packetizer.sv
//
// Written: Rose Thompson rose@rosethompson.net
// Created: 21 May 2024
// Modified: 21 May 2024
//
// Purpose: Converts the compressed RVVI format into AXI 4 burst write transactions.
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

module packetizer import cvw::*; #(parameter cvw_t P,
                                   parameter integer      MAX_CSRS, 
                                   parameter logic [31:0] RVVI_INIT_TIME_OUT = 32'd4,
                                   parameter logic [31:0] RVVI_PACKET_DELAY = 32'd2,
                                   parameter              RVVI_WIDTH = 72+(5*P.XLEN) + MAX_CSRS*(P.XLEN+16),
                                   parameter              ETH_HEAD_WIDTH = 96,
                                   parameter              FRAME_COUNT_WIDTH = 64,
				                   parameter              RVVI_PREFIX_PAD = 16,
                                   parameter              RVVI_ENCODING = 0

)(
  input logic [RVVI_WIDTH-1:0]         rvvi,
  input logic                          valid,
  input logic                          clk, reset,
  output logic                         RVVIStall,
  // axi 4 write address channel
  // axi 4 write data channel
  output logic [31:0]                  RvviAxiWdata,
  output logic [3:0]                   RvviAxiWstrb,
  output logic                         RvviAxiWlast,
  output logic                         RvviAxiWvalid,
  input logic                          RvviAxiWready,
  input logic [47:0]                   SrcMac, DstMac,
  input logic [15:0]                   EthType,
  input logic [15:0]                   AckType,
  (* mark_debug = "true" *)  input logic [31:0] InnerPktDelay,
  input logic [FRAME_COUNT_WIDTH-1:0] FrameCount
  );

  localparam NearTotalFrameLengthBits = ETH_HEAD_WIDTH + RVVI_PREFIX_PAD + FRAME_COUNT_WIDTH + RVVI_WIDTH;
  localparam WordPadLen = 32 - (NearTotalFrameLengthBits % 32);
  localparam TotalFrameLengthBits = NearTotalFrameLengthBits + WordPadLen;
  localparam TotalFrameLengthBytes = TotalFrameLengthBits / 8;
  localparam StartOffset = (ETH_HEAD_WIDTH + RVVI_PREFIX_PAD)/8;
  
  logic [9:0]              WordCount;

  logic                    TransReady;
  logic                    BurstDone;
  logic                    WordCountReset;
  logic                    WordCountEnable;
  logic [TotalFrameLengthBits-1:0] TotalFrame;
  logic [31:0] TotalFrameWords [TotalFrameLengthBytes/4-1:0];
  logic [WordPadLen-1:0]     WordPad;
  logic [RVVI_PREFIX_PAD-1:0] HeaderPad;

  logic [RVVI_WIDTH+FRAME_COUNT_WIDTH-1:0] rvviDelay;
  logic                                    InstrDone;
  logic                                    GlobalWordCountReset;
  logic [10:0]                             GlobalWordCount;
  logic                                    NearEnd;
    
  typedef enum              {STATE_RST, STATE_COUNT, STATE_BEGIN, STATE_NEXT_INSTR, STATE_WAIT, STATE_TRANS, STATE_DELAY} statetype;
(* mark_debug = "true" *)  statetype CurrState, NextState;

(* mark_debug = "true" *)   logic [31:0] 	    RstCount;
(* mark_debug = "true" *)  logic 		    RstCountRst, RstCountEn, CountFlag, DelayFlag;
   

  always_ff @(posedge clk) begin
    if(reset) CurrState <= STATE_RST;
    else               CurrState <= NextState;
  end

  always_comb begin
    case(CurrState)
      STATE_RST: NextState = STATE_COUNT;
      STATE_COUNT: if (CountFlag) NextState = STATE_BEGIN;
                   else           NextState = STATE_COUNT;
      STATE_BEGIN : if (TransReady & valid) NextState = STATE_TRANS;
      else if(~TransReady & valid) NextState = STATE_WAIT;
      else                        NextState = STATE_BEGIN;
      STATE_NEXT_INSTR: if (TransReady & valid) NextState = STATE_TRANS;
      else if(~TransReady & valid) NextState = STATE_WAIT;
      else                        NextState = STATE_NEXT_INSTR;
      STATE_WAIT: if(TransReady)  NextState = STATE_TRANS;
                  else            NextState = STATE_WAIT;
      STATE_TRANS: if(BurstDone & TransReady & ~DelayFlag) NextState = STATE_DELAY;
                   else if(BurstDone & TransReady & DelayFlag) NextState = STATE_BEGIN;
                   else if(RVVI_ENCODING == 3 & TransReady & InstrDone) NextState = STATE_NEXT_INSTR;      // short cut to begin to avoid the global counter reset
                   else          NextState = STATE_TRANS;
      STATE_DELAY: if(DelayFlag) NextState = STATE_BEGIN;
                                else          NextState = STATE_DELAY;
      default: NextState = STATE_BEGIN;
    endcase
  end

  assign RVVIStall = CurrState != STATE_NEXT_INSTR & CurrState != STATE_BEGIN;
  assign TransReady = RvviAxiWready;
  assign WordCountEnable = ((CurrState == STATE_NEXT_INSTR | CurrState == STATE_BEGIN) & valid) | (CurrState == STATE_TRANS & TransReady);
  assign RstCountEn = CurrState == STATE_COUNT | CurrState == STATE_DELAY | CurrState == STATE_TRANS | STATE_WAIT;
  assign RstCountRst = CurrState == STATE_RST | CurrState == STATE_NEXT_INSTR | CurrState == STATE_BEGIN;

  // have to count at least 250 ms after reset pulled to wait for the phy to actually be ready
  // at 20MHz 250 ms is 250e-3 / (1/20e6) = 5,000,000.
  counter #(32) rstcounter(clk, RstCountRst, RstCountEn, RstCount);
  assign CountFlag = RstCount == RVVI_INIT_TIME_OUT;
  //assign DelayFlag = RstCount == RVVI_PACKET_DELAY;
  assign DelayFlag = RstCount >= InnerPktDelay;

  flopenr #(RVVI_WIDTH+FRAME_COUNT_WIDTH) rvvireg(clk, reset, valid, {rvvi, FrameCount}, rvviDelay);


  counterl #(10) WordCounter(clk, GlobalWordCountReset, WordCountEnable, WordCountReset, (ETH_HEAD_WIDTH + RVVI_PREFIX_PAD)/32, WordCount);


  if (RVVI_ENCODING == 1 | RVVI_ENCODING == 3) begin
    logic [11:0] CSRCount;
    logic        GPRWen, FPRWen;
    logic [11:0] BaseLength;
    logic [11:0] ActualLength;
    assign GPRWen = rvviDelay[320];
    assign FPRWen = rvviDelay[328];
    assign CSRCount = rvviDelay[299:288];

    // base length = 48 bytes + (ETH_HEAD_WIDTH + RVVI_PREFIX_PAD + FRAME_COUNT_WIDTH)/8
    // if GPRwen | FPRWen then + 1
    // + 10 * CSRCount
    // if CSRCount is non-zero, then GPRWen/FPRWen is automatically included to keep everything aligned
    assign BaseLength =  12'd48 + StartOffset;
    assign ActualLength = CSRCount != '0 ? BaseLength + 12'd8 + 12'd50 + 12'd2 ://12'd8 + (CSRCount * 12'd10) :
                          GPRWen | FPRWen ? BaseLength + 12'd8 :
                          BaseLength;
    assign GlobalWordCountReset = CurrState == STATE_BEGIN;

  if(RVVI_ENCODING == 3) begin
    counter #(11) globalwordcounter(clk, GlobalWordCountReset, WordCountEnable, GlobalWordCount);
    assign WordCountReset = CurrState == STATE_NEXT_INSTR | (CurrState == STATE_TRANS & InstrDone & RvviAxiWready); 
    assign InstrDone = WordCount == (ActualLength[9:2] - 1'b1);
    //assign InstrDone = WordCount == (ActualLength[9:2] - 8'd2); // what?
    //assign NearEnd = GlobalWordCount > 11'd347; // hmm? 270 causes issues with the mac. leave at 250 for now ***
    assign NearEnd = GlobalWordCount > 11'd200; 
    assign BurstDone = NearEnd & InstrDone;    
  end else begin
    assign InstrDone = '0;
    assign NearEnd = '0;
    assign WordCountReset = CurrState == STATE_NEXT_INSTR;
    assign BurstDone = WordCount == (ActualLength[9:2] - 1'b1);
  end

  end else begin  
    assign GlobalWordCountReset = CurrState == STATE_BEGIN;
    assign BurstDone = WordCount == (TotalFrameLengthBytes[11:2] - 1'b1);
    assign WordCountReset = CurrState == STATE_NEXT_INSTR;
    assign NearEnd = '0;
    assign InstrDone = '0;
  end

  genvar index;
  for (index = 0; index < TotalFrameLengthBytes/4; index++) begin 
    assign TotalFrameWords[index] = TotalFrame[(index*32)+32-1 : (index*32)];
  end

  assign WordPad = '0;
  assign HeaderPad = '0;
  assign TotalFrame = {WordPad, rvviDelay, AckType, EthType, DstMac, SrcMac};

  
  assign RvviAxiWdata = TotalFrameWords[WordCount];
  assign RvviAxiWstrb = '1;
  assign RvviAxiWlast = (BurstDone & (CurrState == STATE_TRANS));
  assign RvviAxiWvalid = (CurrState == STATE_TRANS);
  
endmodule
 
