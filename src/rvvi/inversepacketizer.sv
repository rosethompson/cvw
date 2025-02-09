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
                                          parameter FRAME_COUNT_WIDTH) (
  input logic               clk, reset,
  input logic [31:0]        RvviAxiRdata,
  input logic [3:0]         RvviAxiRstrb,
  input logic               RvviAxiRlast,
  input logic               RvviAxiRvalid,
  output logic              Valid,
(* mark_debug = "true" *)  output logic [P.XLEN-1:0] Minstr,
  output logic [31:0]       InterPacketDelay,
(* mark_debug = "true" *)  output logic [FRAME_COUNT_WIDTH-1:0] FrameCount,
  input logic [47:0]        DstMac,
  input logic [47:0]        SrcMac,
  input logic [15:0]        EthType);

  typedef enum              {STATE_RST, STATE_ALL_CAPTURED, STATE_WAIT} statetype;
(* mark_debug = "true" *)  statetype CurrState, NextState;

  logic [31:0]              mem [8:0];
(* mark_debug = "true" *)  logic [3:0]               Counter;	
  logic                     CounterEn, CounterRst;
(* mark_debug = "true" *)  logic [3:0]               Match;
(* mark_debug = "true" *)  logic                     AllMatch;

  counter #(4) counter(clk, CounterRst, CounterEn, Counter);
  
  always_ff @(posedge clk) begin
    if(reset) CurrState <= STATE_RST;
    else      CurrState <= NextState;
  end

  always_comb begin
    case(CurrState)
      STATE_RST: if(RvviAxiRvalid & Counter == 4'h8) NextState = STATE_ALL_CAPTURED;
                 else NextState = STATE_RST;
      STATE_ALL_CAPTURED: if(RvviAxiRlast) NextState = STATE_RST;
                          else NextState = STATE_WAIT;
      STATE_WAIT: if(RvviAxiRlast) NextState = STATE_RST;
                  else NextState = STATE_WAIT;
      default: NextState = STATE_RST;
    endcase
  end

  assign CounterRst = RvviAxiRlast | reset;
  assign CounterEn = RvviAxiRvalid;

  always_ff @(posedge clk) begin
    if(RvviAxiRvalid) begin
      mem[Counter] <= RvviAxiRdata;
    end
  end

  // *** This is very inefficient. Can reduce to a single compare.
  assign Match[0] = mem[0] == DstMac[31:0];
  assign Match[1] = mem[1] == {SrcMac[15:0], DstMac[47:32]};
  assign Match[2] = mem[2] == SrcMac[47:16];
  assign Match[3] = mem[3][15:0] == EthType;
  assign AllMatch = &Match;
  
/* -----\/----- EXCLUDED -----\/-----
  assign Minstr = {mem[5][15:0], mem[4], mem[3][31:16]};
  assign InterPacketDelay = {mem[6][15:0], mem[5][31:16]};
  assign FrameCount = mem[6][31:16];
 -----/\----- EXCLUDED -----/\----- */
  //assign FrameCount = mem[3][31:16];
  // pad mem[3][31:16]
  assign FrameCount = {mem[5], mem[4]};
  assign Minstr = {mem[7], mem[6]};
  assign InterPacketDelay = mem[8];

  assign Valid = CurrState == STATE_ALL_CAPTURED & AllMatch;
  

endmodule
