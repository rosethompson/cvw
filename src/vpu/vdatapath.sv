///////////////////////////////////////////
// vdatapath.sv
//
// Written: Rose Thompson rose.thompson@skyworksinc.com
// Created: 2 September 2026
// Modified: 2 September 2026
//
// Purpose: vector datapath module
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

module vdatapath import cvw::*;  #(parameter cvw_t P) (
  input  logic                 clk,
  input  logic                 reset,
  // Hazards
  input  logic                 StallD, StallE, StallM, StallW,      // stall signals (from HZU)
  input  logic                 FlushD, FlushE, FlushM, FlushW,      // flush signals (from HZU)
  // flow control
  input  logic [P.VPU_MAX_EU-1:0] ControllerValidD,
  output logic [P.VPU_MAX_EU-1:0] ExecutionUnitReadyD,
  // control input
  input  logic [4:0] Vs1FinalD, Vs2FinalD,               // Vector Source 1 and 2
  input  logic [4:0] VdFinalD,                      // Vector Destination read (overwrite)
  input  logic VMD,                            // 0 = mask enabled, 1 mask disabled
  input  logic [5:0] Funct6D,
  input  logic [2:0] Funct3D,
  input  logic RegWriteD,
  input  logic VRegWriteD,
  input  logic [1:0] VALUSrcAD,
  input  logic VALUSrcBD,
  input  logic VALUResultD,
  input  logic IllegalVectorInstructionD,
  // from/to the scalar core
  input  logic [P.XLEN-1:0]    ForwardedSrcAE, ForwardedSrcBE,     // Integer/FP input for convert, move (from IEU)
  output logic [P.VPU_LSU_BLEN-1:0]    VWriteDataM,          // Data to be written to memory (to LSU)
  output logic [P.XLEN-1:0]            VEUAdrM    ,          // Data to be written to memory (to LSU)
  input  logic [P.VPU_LSU_BLEN-1:0]    VReadDataM , // Read data (from LSU)
  output logic [P.XLEN-1:0]            VIEUFPResultFinalW                            // Int or FP result for X or F regs.
  //
);

  logic [P.VLEN-1:0] SrcAD, SrcBD, SrcCD;
  logic [P.VLEN-1:0] v0D;
  logic [P.VLEN-1:0] VResultFinalW;

  logic [P.VLEN-1:0] VIEUResultW [P.VPU_INT_EU-1:0];
  logic [P.XLEN-1:0] VtoIEUFPResultW [P.VPU_INT_EU-1:0];


  logic            VdFinalweW;
  logic [4:0]      VdFinalW;
  genvar i;

  vregfile #(P.VLEN) vregfile(clk, reset, VdFinalweW, Vs1FinalD, Vs2FinalD, VdFinalD, VdFinalW,
                              VResultFinalW, SrcAD, SrcBD, SrcCD, v0D);

  for(i = 0; i < P.VPU_INT_EU; i++) begin
    // *** add interger EU when ready
    vieu #(P) vieu(.clk, .reset, .StallE, .StallM, .StallW, .FlushE, .FlushM, .FlushW,
                   .ControllerValidD(ControllerValidD[i]), .ExecutionUnitReadyD(ExecutionUnitReadyD[i]), .VMD, .Funct3D, .Funct6D,
                   .RegWriteD, .VRegWriteD, .VALUSrcAD, .VALUSrcBD, .VALUResultD,
                   .SrcAD, .SrcBD, .SrcCD, .v0D, .ForwardedSrcAE, .ForwardedSrcBE, .VtoIEUFPResultW(VtoIEUFPResultW[i]),
                   .VIEUResultW(VIEUResultW[i]));

  end

  for(i = 0; i < P.VPU_LSU_EU; i++) begin
    // *** add LSU IF
    assign ExecutionUnitReadyD[i+P.VPU_INT_EU] = '1;
    assign VWriteDataM = '0;
    assign VEUAdrM = '0;
  end

  for(i = 0; i < P.VPU_FP_EU; i++) begin
    // *** add FPU
    assign ExecutionUnitReadyD[i+P.VPU_INT_EU+P.VPU_LSU_EU] = '1;
  end


  // for now we will set EU 0 as the int EU and 1 as the float EU.  *** change the config so total
  // EU is a function of the int, fpu, and int mul EUs.

  assign VIEUFPResultFinalW = '0;
  assign VdFinalweW = '0;
  assign VdFinalW = '0;
  assign VResultFinalW = '0;

endmodule
