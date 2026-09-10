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
  input logic                       VALUResultSrcD,
   // datapath from vregfile
  input logic [P.VLEN-1:0]          VRD1D, VRD2D, VRD3D,
  input logic [P.VLEN-1:0]          v0D,
   //
  // from/to the scalar core
  input logic [P.XLEN-1:0]          ForwardedSrcAE, ForwardedSrcBE, // Integer/FP input for convert, move (from IEU)
  output logic [P.XLEN-1:0]         VtoIEUFPResultW,                  // Int or FP result for
  output logic [P.VLEN-1:0]         VIEUResultW
);

  localparam BEATBITLEN = $clog2((P.VLEN/P.ELEN) + 1);
  //localparam VLBITLEN = $clog2(P.VLEN);
  localparam XLENTOINTLANES = P.VPU_INT_BLEN / P.XLEN;

  logic [5:0] Funct6E;
  logic [2:0] Funct3E;
  logic       RegWriteE;
  logic       VRegWriteE;
  logic [1:0] VALUSrcAE;
  logic       VALUSrcBE;
  logic       VALUResultSrcE;

  logic       RegWriteM;
  logic       VRegWriteM;
  logic       VALUResultSrcM;

  logic       RegWriteW;
  logic       VRegWriteW;
  logic       VALUResultSrcW;

  logic [BEATBITLEN-1:0]   vlE;
  logic [BEATBITLEN-1:0] BeatE, BeatM;
  logic                  CaptureD;
  logic                  BeatDoneE;

  logic [P.VLEN-1:0]     VRD1E, VRD2E, VRD3E, v0E;
  logic [P.VPU_INT_BLEN-1:0] VRD1BeatE [P.VPU_INT_MAX_BEATS-1:0];
  logic [P.VPU_INT_BLEN-1:0] VRD2BeatE [P.VPU_INT_MAX_BEATS-1:0];
  logic [P.VPU_INT_BLEN-1:0] VRD3BeatE [P.VPU_INT_MAX_BEATS-1:0];
  logic [P.VPU_INT_BLEN-1:0] v0BeatE [P.VPU_INT_MAX_BEATS-1:0];

  logic [P.VPU_INT_BLEN-1:0] VRD1SelectedE, VRD2SelectedE, VRD3SelectedE, v0SelectedE;
  logic [P.VPU_INT_BLEN-1:0] VImmE;

  logic [P.VPU_INT_BLEN-1:0] VSrcAE, VSrcBE, VSrcCE;
  logic [P.VPU_INT_BLEN-1:0] VALUResultE, VALUResultM;
  logic [P.VLEN-1:0]         VALUResultW;



  // *** add vector length later
  assign vlE = 4;
  assign VImmE = '0; // *** fix me

  vieufsm #(P, BEATBITLEN) vieufsm(.clk, .reset, .FlushE, .StallE,
                       .ControllerValidD, .ExecutionUnitReadyD, .BeatE, .BeatDoneE, .vlE);
  assign CaptureD = ControllerValidD & ExecutionUnitReadyD;

  flopenrc #(P.VLEN) VRD1EReg(clk, reset, FlushE, ~StallE & CaptureD, VRD1D, VRD1E);
  flopenrc #(P.VLEN) VRD2EReg(clk, reset, FlushE, ~StallE & CaptureD, VRD2D, VRD2E);
  flopenrc #(P.VLEN) VRD3EReg(clk, reset, FlushE, ~StallE & CaptureD, VRD3D, VRD3E);
  flopenrc #(P.VLEN) v0EReg  (clk, reset, FlushE, ~StallE & CaptureD, v0D,   v0E);

  // convert to index format
  genvar index;
  for (index = 0; index < P.VPU_INT_MAX_BEATS; index++) begin : laneconvert
    assign VRD1BeatE[index] = VRD1E[(index*P.VPU_INT_BLEN)+P.VPU_INT_BLEN-1 : (index*P.VPU_INT_BLEN)];
    assign VRD2BeatE[index] = VRD2E[(index*P.VPU_INT_BLEN)+P.VPU_INT_BLEN-1 : (index*P.VPU_INT_BLEN)];
    assign VRD3BeatE[index] = VRD3E[(index*P.VPU_INT_BLEN)+P.VPU_INT_BLEN-1 : (index*P.VPU_INT_BLEN)];
    assign v0BeatE[index]   = v0E[(index*P.VPU_INT_BLEN)+P.VPU_INT_BLEN-1   : (index*P.VPU_INT_BLEN)];
  end

  // mux down to the current lane(s)
  assign VRD1SelectedE = VRD1BeatE[BeatE[BEATBITLEN-3:0]];
  assign VRD2SelectedE = VRD2BeatE[BeatE[BEATBITLEN-3:0]];
  assign VRD3SelectedE = VRD3BeatE[BeatE[BEATBITLEN-3:0]];
  assign v0SelectedE   = v0BeatE[BeatE[BEATBITLEN-3:0]];

  // unlike the integer controller and datapath, the controller must be pipelined inside the vieu, because the
  // controll is routed to different EUs.

  flopenrc #(15) contrlregE(clk, reset, FlushE, ~StallE,
                           {Funct6D, Funct3D, RegWriteD, VRegWriteD, VALUSrcAD, VALUSrcBD, VALUResultSrcD},
                           {Funct6E, Funct3E, RegWriteE, VRegWriteE, VALUSrcAE, VALUSrcBE, VALUResultSrcE});

  mux3 #(P.VPU_INT_BLEN) vscramux(VRD1SelectedE, VImmE, {XLENTOINTLANES{ForwardedSrcAE}}, VALUSrcAE, VSrcAE);

  mux2 #(P.VPU_INT_BLEN) vscrbmux(VRD2SelectedE, {XLENTOINTLANES{ForwardedSrcBE}}, VALUSrcBE, VSrcBE);

  valu #(P) valu(VSrcAE, VSrcBE, VALUResultE);

  flopenrc #(P.VPU_INT_BLEN) VALUResultMReg(clk, reset, FlushM, ~StallM, VALUResultE, VALUResultM); // *** may need an enable

  flopenrc #(3+BEATBITLEN) contrlregM(clk, reset, FlushM, ~StallM,
                           {RegWriteE, VRegWriteE, VALUResultSrcE, BeatE},
                           {RegWriteM, VRegWriteM, VALUResultSrcM, BeatM});

  // demux - the beat tells me which indices of output reg should be written

  for (index = 0; index < P.VPU_INT_MAX_BEATS; index++) begin : lanedemuxreg
    flopenrc #(P.VPU_INT_BLEN) VALUResultWReg(clk, reset, FlushW & BeatM == index, ~StallW, VALUResultM,
                                              VALUResultW[(index*P.VPU_INT_BLEN)+P.VPU_INT_BLEN-1 : (index*P.VPU_INT_BLEN)]);
  end


  assign VIEUResultW = VALUResultW; // *** replace with mux?

  assign VtoIEUFPResultW = '0;    // ***

endmodule
