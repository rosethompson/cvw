///////////////////////////////////////////
// vieu.sv
//
// Written: Rose Thompson rose.thompson@skyworksinc.com
// Created: 2 September 2026
// Modified: 2 September 2026
//
// Purpose: vector integer execution unit
//
// Documentation: RISC-V System on Chip Design Volume 2
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwgroup/cvw
//
// Copyright (C) 2021-26 Harvey Mudd College & Oklahoma State University & Skyworks Solutions Inc.
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

module vieu import cvw::*;  #(parameter cvw_t P)
  (
  input logic                       clk,
  input logic                       reset,
  // Hazards
  input logic                       StallE, StallM, StallW,         // stall signals (from HZU)
  input logic                       FlushE, FlushM, FlushW,         // flush signals (from HZU)
   // flow control
  input logic                       ControllerValidD,
  output logic                      ExecutionUnitReadyD,
   // control from the controller
  input logic                       VMD,                            // 0 = mask enabled, 1 mask disabled
  input logic [5:0]                 Funct6D,
  input logic [2:0]                 Funct3D,
  input logic                       RegWriteD,
  input logic                       VRegWriteD,
  input logic [1:0]                 VALUSrcAD,
  input logic                       VALUSrcBD,
  input logic                       VALUResultD,
   // datapath from vregfile
  input logic [P.VLEN-1:0]          VRD1D, VRD2D, VRD3D,
  input logic [P.VLEN-1:0]          v0D,
   //
  // from/to the scalar core
  input logic [P.XLEN-1:0]          ForwardedSrcAE, ForwardedSrcBE, // Integer/FP input for convert, move (from IEU)
  output logic [P.XLEN-1:0]         VtoIEUFPResultW,                  // Int or FP result for
  output logic [P.VLEN-1:0]         VIEUResultW
);

  localparam SEWMAX = 64;
  localparam BEATBITLEN = $clog2((P.VLEN/SEWMAX) + 1);
  //localparam VLBITLEN = $clog2(P.VLEN);
  localparam INT_LANE_WIDTH = P.VPU_INT_LANES * SEWMAX;
  localparam INT_MAX_BEATS = P.VLEN/(INT_LANE_WIDTH);

  logic [BEATBITLEN-1:0]   vlE;
  logic [BEATBITLEN-1:0] BeatE;
  logic                  CaptureD;
  logic                  BeatDoneE;

  logic [P.VLEN-1:0]   VRD1E, VRD2E, VRD3E, v0E;
  logic [INT_LANE_WIDTH-1:0] VRD1BeatE [INT_MAX_BEATS-1:0];
  logic [INT_LANE_WIDTH-1:0] VRD2BeatE [INT_MAX_BEATS-1:0];
  logic [INT_LANE_WIDTH-1:0] VRD3BeatE [INT_MAX_BEATS-1:0];
  logic [INT_LANE_WIDTH-1:0] v0BeatE [INT_MAX_BEATS-1:0];

  logic [INT_LANE_WIDTH-1:0]   VRD1SelectedE, VRD2SelectedE, VRD3SelectedE, v0SelectedE;

  // *** add vector length later
  assign vlE = 4;

  vieufsm #(P, BEATBITLEN) vieufsm(.clk, .reset, .FlushE, .StallE,
                       .ControllerValidD, .ExecutionUnitReadyD, .BeatE, .BeatDoneE, .vlE);
  assign CaptureD = ControllerValidD & ExecutionUnitReadyD;

  flopenrc #(P.VLEN) VRD1EReg(clk, reset, FlushE, ~StallE & CaptureD, VRD1D, VRD1E);
  flopenrc #(P.VLEN) VRD2EReg(clk, reset, FlushE, ~StallE & CaptureD, VRD2D, VRD2E);
  flopenrc #(P.VLEN) VRD3EReg(clk, reset, FlushE, ~StallE & CaptureD, VRD3D, VRD3E);
  flopenrc #(P.VLEN) v0EReg  (clk, reset, FlushE, ~StallE & CaptureD, v0D,   v0E);

  // convert to index format
  genvar index;
  for (index = 0; index < INT_MAX_BEATS; index++) begin : laneconvert
    assign VRD1BeatE[index] = VRD1E[(index*INT_LANE_WIDTH)+INT_LANE_WIDTH-1 : (index*INT_LANE_WIDTH)];
    assign VRD2BeatE[index] = VRD2E[(index*INT_LANE_WIDTH)+INT_LANE_WIDTH-1 : (index*INT_LANE_WIDTH)];
    assign VRD3BeatE[index] = VRD3E[(index*INT_LANE_WIDTH)+INT_LANE_WIDTH-1 : (index*INT_LANE_WIDTH)];
    assign v0BeatE[index]   = v0E[(index*INT_LANE_WIDTH)+INT_LANE_WIDTH-1   : (index*INT_LANE_WIDTH)];
  end

  // mux down to the current lane(s)
  assign VRD1SelectedE = VRD1BeatE[BeatE[BEATBITLEN-3:0]];
  assign VRD2SelectedE = VRD2BeatE[BeatE[BEATBITLEN-3:0]];
  assign VRD3SelectedE = VRD3BeatE[BeatE[BEATBITLEN-3:0]];
  assign v0SelectedE   = v0BeatE[BeatE[BEATBITLEN-3:0]];


  assign VIEUResultW = '0;

  assign VtoIEUFPResultW = '0;

endmodule
