///////////////////////////////////////////
// inversepacketerizer.sv
//
// Written: Rose Thompson rose@rosethompson.net
// Created: 26 December 2024
// Modified: 26 December 2024
//
// Purpose: Scans 32-bit word AXI Ethernet frames and builds an inverted partial RVVI transaction. Only contains Minstret and the inter-packet delay.
//
// Documentation: 
//
// A component of the CORE-V-WALLY configurable RISC-V project.
//
// Copyright (C) 2021-24 Harvey Mudd College & Oklahoma State University
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

module inversepacketizer import cvw::*; #(parameter cvw_t P, 
                                          parameter FRAME_COUNT_WIDTH,
                                          parameter RVVI_ENCODING
) (
  input logic               clk, reset,
  input logic [31:0]        RvviAxiRdata,
  input logic [3:0]         RvviAxiRstrb,
  input logic               RvviAxiRlast,
  input logic               RvviAxiRvalid,
  output logic              Valid,
  output logic              IlaTrigger,
(* mark_debug = "true" *)  output logic [P.XLEN-1:0] Minstr,
  output logic [31:0]       InterPacketDelay,
(* mark_debug = "true" *)  output logic [FRAME_COUNT_WIDTH-1:0] FrameCount,
  input logic [47:0]        DstMac,
  input logic [47:0]        SrcMac,
  input logic [15:0]        EthType,
  input logic [15:0]        AckType,
  input logic [15:0]        TriggerType,
  input logic [32*5-1:0]    TriggerString);

  typedef enum              {STATE_RST, STATE_RUN, STATE_ALL_CAPTURED, STATE_WAIT} statetype;
(* mark_debug = "true" *)  statetype CurrState, NextState;

(* mark_debug = "true" *)  logic [9:0]               Counter;	
  logic                     CounterEn, CounterRst;

  logic [31:0]		    ROM [3:0];
  logic [31:0]		    Mask;
  logic [31:0]		    ROMReadData;
  logic [31:0]		    Rdata;
  logic			    CurrentMatch;
  logic [3:0]		    BeatMatch;
  logic			    NewFrame;
  logic			    MatchAll;
  logic			    TriggerTypeSig, AckTypeSig;
  logic			    TriggerTypeSigDelay, AckTypeSigDelay;

  logic [31:0]		    TriggerROM[8:0];
  logic			    CurrentTriggerMatch;
  logic			    TriggerReadData;
  logic			    TriggerRegEn;
  logic			    NextTriggerSig;
  logic			    TriggerPulse;
  genvar		    index;
    
  assign ROM[0] = DstMac[31:0];
  assign ROM[1] = {SrcMac[15:0], DstMac[47:32]};
  assign ROM[2] = SrcMac[47:16];
  assign ROM[3] = {16'b0, EthType};
  assign ROMReadData = ROM[Counter[1:0]];
  assign Mask = Counter == 4'd3 ? 32'h0000ffff : '1;
  assign Rdata = RvviAxiRdata & Mask;
  assign CurrentMatch = Rdata == ROMReadData;
  assign NewFrame = reset | RvviAxiRlast;
  
  flopenr #(1) matchreg0 (clk, NewFrame, CurrentMatch & Counter == 10'd0, CurrentMatch, BeatMatch[0]);
  flopenr #(1) matchreg1 (clk, NewFrame, CurrentMatch & Counter == 10'd1, CurrentMatch, BeatMatch[1]);
  flopenr #(1) matchreg2 (clk, NewFrame, CurrentMatch & Counter == 10'd2, CurrentMatch, BeatMatch[2]);
  flopenr #(1) matchreg3 (clk, NewFrame, CurrentMatch & Counter == 10'd3, CurrentMatch, BeatMatch[3]);
  assign MatchAll = &BeatMatch;  

//  counter #(10) counter(clk, CounterRst, CounterEn, Counter);
  counterl #(10) counter(clk, CounterRst, CounterEn, CounterLoad, 10'd4, Counter);

  flopenr #(32) framecountlowreg(clk, reset, Counter == 10'd4 & MatchAll & RvviAxiRvalid, RvviAxiRdata, FrameCount[31:0]);
  flopenr #(32) framecounthighreg(clk, reset, Counter == 10'd5 & MatchAll & RvviAxiRvalid, RvviAxiRdata, FrameCount[63:32]);
  flopenr #(32) interpacketdelayreg(clk, reset, Counter == 10'd8 & MatchAll & RvviAxiRvalid, RvviAxiRdata, InterPacketDelay);

  assign TriggerTypeSig = RvviAxiRdata[31:16] == TriggerType;
  assign AckTypeSig = RvviAxiRdata[31:16] == AckType;

  flopenr #(1) acktypereg(clk, NewFrame, CurrentMatch & Counter == 10'd3, AckTypeSig, AckTypeSigDelay);
  
    
  always_ff @(posedge clk) begin
    if(reset) CurrState <= STATE_RST;
    else      CurrState <= NextState;
  end

  always_comb begin
    case(CurrState)
      STATE_RST: if(RvviAxiRvalid) NextState = STATE_RUN;
                 else NextState = STATE_RST;
      STATE_RUN: if(RvviAxiRvalid & Counter == 10'h7) NextState = STATE_ALL_CAPTURED;
                 else NextState = STATE_RUN;
      STATE_ALL_CAPTURED: if(RvviAxiRlast & RvviAxiRvalid) NextState = STATE_RST;
                          else if(RvviAxiRlast & ~RvviAxiRvalid) NextState = STATE_ALL_CAPTURED;
                          else NextState = STATE_RUN;
      STATE_WAIT: if(RvviAxiRlast) NextState = STATE_RST;
                  else NextState = STATE_WAIT;
      default: NextState = STATE_RST;
    endcase
  end

  assign CounterRst = RvviAxiRlast | reset;
  assign CounterLoad = CurrState == STATE_ALL_CAPTURED & RvviAxiRvalid;
  assign CounterEn = RvviAxiRvalid;

  assign Minstr = '0;

  assign Valid = CurrState == STATE_ALL_CAPTURED & MatchAll & AckTypeSigDelay;


  // trigger logic
  for(index = 0; index < 5; index++) begin
    assign TriggerROM[index+4] = TriggerString[index*32+31:index*32];
  end
  assign TriggerReadData = TriggerROM[Counter];
  assign CurrentTriggerMatch = TriggerReadData == RvviAxiRdata;

  assign TriggerRegEn = (CurrentMatch & Counter == 4'd3 & RvviAxiRvalid) |
			(CurrentTriggerMatch & Counter[3:2] == 2'b10 & RvviAxiRvalid) | // 4, 5, 6, 7
			(CurrentTriggerMatch & Counter == 4'd8 & RvviAxiRvalid) ;
  mux2 #(1) triggermux(CurrentTriggerMatch & TriggerTypeSigDelay, TriggerTypeSig, Counter == 4'd3,
		       NextTriggerSig);
  
  flopenr #(1) triggertypereg(clk, NewFrame, TriggerRegEn, 
			      NextTriggerSig, TriggerTypeSigDelay);
  
  assign TriggerPulse = CurrState == STATE_ALL_CAPTURED & MatchAll & TriggerTypeSigDelay;

  // this is a bit hacky, but it works!
  logic [3:0] TriggerCount;
  logic       TriggerReset, TriggerEn;
  counter #(4) triggercounter(clk, reset | TriggerReset, TriggerEn, TriggerCount);
  assign TriggerReset = TriggerCount == 4'd10;
  assign TriggerEn = TriggerPulse | (TriggerCount != 4'd0 & TriggerCount < 4'd10);
  assign IlaTrigger = TriggerEn;

  

endmodule
