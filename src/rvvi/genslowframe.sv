///////////////////////////////////////////
// genslowframe.sv
//
// Written: Rose Thompson rosethompson.net
// Created: 24 October 2024
// Modified: 24 October 2024
//
// Purpose: Creates a slow down Ethernet frame when requested
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

module genslowframe import cvw::*;
  (
  input logic        clk, reset,
  input logic        HostRequestSlowDown,
  input logic        RVVIStall,
  input logic [31:0] HostFiFoFillAmt,
  output logic       HostStall
  );

(* mark_debug = "true" *)    logic PendingHostRequest;
    logic					     SlowDownThreshold, SlowDownCounterEnable, SlowDownCounterRst;

    logic [9:0]                      ConcurrentCount;
(* mark_debug = "true" *)    logic					     ConcurrentSlowDownCounterRst,  ConcurrentSlowDownCounterEnable, ConcurrentSlowDownCounterEnableUp, ConcurrentSlowDownCounterEnableDown;
(* mark_debug = "true" *)    logic HostRequestSlowDownDelay, HostRequestSlowDownEdge;
(* mark_debug = "true" *)    logic DidHostRequest;
    logic					     ClearHostRequested;
    logic [16:0]				     CountThreshold;
  (* mark_debug = "true" *)    logic [16:0]				     Count;
  
    typedef enum				     {STATE_RST, STATE_PRE_COUNT, STATE_COUNT} statetype;
    statetype CurrState, NextState;

    always_ff @(posedge clk) begin
      if(reset) CurrState <= STATE_RST;
      else CurrState <= NextState;
    end

    always_comb begin
      case(CurrState)
	STATE_RST: if(HostRequestSlowDown | PendingHostRequest) NextState = STATE_PRE_COUNT;
	else NextState = STATE_RST;
	STATE_PRE_COUNT: if(RVVIStall) NextState = STATE_COUNT;  // *** try this to avoid the strange spi issue?
	else NextState = STATE_PRE_COUNT;
	STATE_COUNT: if(SlowDownThreshold) NextState = STATE_RST;
	else NextState = STATE_COUNT;
	default: NextState = STATE_RST;
      endcase // case (CurrState)
    end

/* -----\/----- EXCLUDED -----\/-----
    always_comb begin
      casez(HostFiFoFillAmt[31:24]) 
        8'b0: CountThreshold = 17'd800;
        8'b1: CountThreshold = 17'd1600;
        8'b10: CountThreshold = 17'd3200;
        8'b11: CountThreshold = 17'd6400;
        8'b1??: CountThreshold = 17'd12800;
        8'b1???: CountThreshold = 17'd25600;
        8'b1????: CountThreshold = 17'd51200;
        8'b1?????: CountThreshold = 17'd51200;
        8'b1??????: CountThreshold = 17'd51200;
        8'b1???????: CountThreshold = 17'd51200;
        default: CountThreshold = 17'd51200;
      endcase
    end
 -----/\----- EXCLUDED -----/\----- */
    assign CountThreshold = 17'd4000;
    assign SlowDownThreshold = Count >= CountThreshold;
    assign SlowDownCounterEnable = CurrState == STATE_COUNT;
    assign SlowDownCounterRst = CurrState == STATE_RST;
    assign HostStall = CurrState == STATE_COUNT;
    assign ConcurrentSlowDownCounterRst = reset;
    assign ConcurrentSlowDownCounterEnableUp = HostRequestSlowDownEdge & CurrState == STATE_COUNT;
    assign ConcurrentSlowDownCounterEnable = ConcurrentSlowDownCounterEnableUp | ConcurrentSlowDownCounterEnableDown;
    assign ConcurrentSlowDownCounterEnableDown = CurrState == STATE_COUNT & (SlowDownThreshold) & ~DidHostRequest & PendingHostRequest;
    
    
    flopr #(1) hostrequestslowdowndelayreg(clk, reset, HostRequestSlowDown, HostRequestSlowDownDelay);
    assign HostRequestSlowDownEdge = HostRequestSlowDown & ~HostRequestSlowDownDelay;

    flopenrc #(1) didhostrequestslowdownreg(clk, reset, ClearHostRequested, (ClearHostRequested | HostRequestSlowDownEdge), 1'b1, DidHostRequest);
    assign ClearHostRequested = CurrState == STATE_COUNT & SlowDownThreshold;
    
    counter #(17) SlowDownCounter(clk, SlowDownCounterRst, SlowDownCounterEnable, Count);

    updowncounter #(10) ConcurrentSlowDownCounter(clk, ConcurrentSlowDownCounterRst, ConcurrentSlowDownCounterEnable, ConcurrentSlowDownCounterEnableDown, ConcurrentCount);

    assign PendingHostRequest = (ConcurrentCount != '0);
  
endmodule
