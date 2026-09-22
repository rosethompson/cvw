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
   input logic                   FlushVectorE,
   input logic                   ControllerValidD,
   output logic                  ExecutionUnitReadyD,
   output logic [BEATBITLEN-1:0] BeatE,
   output logic                  ExecutionUnitResultValidE,
   output logic                  BeatValidE,
   input logic [BEATBITLEN-1:0]  vlE
   );


  typedef enum logic {STATE_RDY, STATE_BEAT} statetype;
  statetype CurrState, NextState;
  logic BeatIncr, BeatRst;
  logic [BEATBITLEN-1:0] BeatLength;
  logic                  Remainder;

  localparam             SPLIT = $clog2(P.VPU_INT_EU);

  logic                  NotExecutionUnitResultValidE;
  logic                  ReadyOrReset;
  logic                  DoneE, ReadyE;
  logic                  CaptureInstrD;

  // computes vl / how many ELEN elements are consummed each beat.
  // vl / # Lanes. If there is a remainder, there is one extra beat.
  /* verilator lint_off WIDTHEXPAND */ // *** fix this later
  assign BeatLength = vlE[BEATBITLEN-1:SPLIT] + Remainder;
  /* verilator lint_on WIDTHEXPAND */
  assign Remainder = |(vlE[SPLIT-1:0]);

/* -----\/----- EXCLUDED -----\/-----
  always_ff @(posedge clk)
    if (reset | FlushVectorE)    CurrState <= STATE_RDY;
    else CurrState <= NextState;

  always_comb begin
    NextState = STATE_RDY;
    case (CurrState)
      STATE_RDY: if (ControllerValidD) NextState = STATE_BEAT;
                 else                                        NextState = STATE_RDY;
      STATE_BEAT: if (ExecutionUnitResultValidE & ~ControllerValidD) NextState = STATE_RDY;
                  else                  NextState = STATE_BEAT;
      default: NextState = STATE_RDY;
    endcase // case (CurrState)
  end

  counterval #(BEATBITLEN) beatcounter(clk, BeatRst, BeatIncr, P.VPU_INT_LANES[BEATBITLEN-1:0], BeatE);
  assign BeatIncr = CurrState == STATE_BEAT & ~StallE;
  assign BeatRst = ExecutionUnitReadyD;
  assign ExecutionUnitResultValidE = BeatE >= BeatLength - 1; // *** plan to optimize this away.
  assign ExecutionUnitReadyD = CurrState == STATE_RDY | (CurrState == STATE_BEAT & ExecutionUnitResultValidE);
  assign BeatValidE = CurrState == STATE_BEAT;
 -----/\----- EXCLUDED -----/\----- */

  flopenr #(1) validreg(clk, CaptureInstrD, ReadyOrReset, '1, NotExecutionUnitResultValidE);
  assign BeatValidE = ~NotExecutionUnitResultValidE;
  flopenr #(1) readyreg(clk, CaptureInstrD, ReadyOrReset, '1, ReadyE);
  assign CaptureInstrD = ControllerValidD & ExecutionUnitReadyD;

  assign ReadyOrReset = ExecutionUnitReadyD | reset;

  counterval #(BEATBITLEN) beatcounter(clk, BeatRst, BeatIncr, P.VPU_INT_LANES[BEATBITLEN-1:0], BeatE);
  //assign BeatRst = reset | (ControllerValidD & ExecutionUnitReadyD);
  //assign BeatIncr = ControllerValidE & ~StallE;
  //assign ExecutionUnitResultValidE = ~ControllerValidE | (BeatE >= BeatLength - 1);
  assign BeatRst = ReadyOrReset;
  assign BeatIncr = BeatValidE & ~StallE;
  assign DoneE = BeatE >= BeatLength - 1;
  assign ExecutionUnitReadyD = (DoneE & ExecutionUnitResultValidE) | ReadyE;
  assign ExecutionUnitResultValidE = DoneE & BeatValidE;

endmodule
