///////////////////////////////////////////
// vieufsm.sv
//
// Written: Rose Thompson rose@rosethompson.net
// Created: 10 Sept 2026
// Modified: 10 Sept 2026
//
// Purpose: Sequences beats of an integer vector instruction
//
// Documentation: RISC-V System on Chip Design
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwgroup/cvw
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

module vieufsm import cvw::*;  #(parameter     cvw_t P,
                                 parameter int BEATBITLEN)
  (
   input logic                   clk,
   input logic                   reset,
   input logic                   StallE,
   input logic                   FlushE,
   input logic                   ControllerValidD,
   output logic                  ExecutionUnitReadyD,
   output logic [BEATBITLEN-1:0] BeatE,
   output logic                  BeatDoneE,
   input logic [BEATBITLEN-1:0]  vlE
   );


  typedef enum logic {STATE_RDY, STATE_BEAT} statetype;
  statetype CurrState, NextState;
  logic BeatIncr, BeatRst;


  always_ff @(posedge clk)
    if (reset | FlushE)    CurrState <= STATE_RDY;
    else CurrState <= NextState;

  always_comb begin
    NextState = STATE_RDY;
    case (CurrState)
      STATE_RDY: if (ControllerValidD) NextState = STATE_BEAT;
                 else                                        NextState = STATE_RDY;
      STATE_BEAT: if (BeatDoneE & ~ControllerValidD) NextState = STATE_RDY;
                  else                  NextState = STATE_BEAT;
      default: NextState = STATE_RDY;
    endcase // case (CurrState)
  end

  counterval #(BEATBITLEN) beatcounter(clk, BeatRst, BeatIncr, P.VPU_INT_LANES[BEATBITLEN-1:0], BeatE);
  assign BeatIncr = CurrState == STATE_BEAT & ~StallE;
  assign BeatRst = ExecutionUnitReadyD;
  assign BeatDoneE = BeatE >= vlE - 1; // *** plan to optimize this away.
  assign ExecutionUnitReadyD = CurrState == STATE_RDY | (CurrState == STATE_BEAT & BeatDoneE);


endmodule
