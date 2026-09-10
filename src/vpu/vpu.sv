///////////////////////////////////////////
// vpu.sv
//
// Written: Rose Thompson rose.thompson@skyworksinc.com
// Modified: 8/24/2026
//
// Purpose: Vector Processing Unit
//
// Documentation: RISC-V System on Chip Design Vol. 2
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwgroup/cvw
//
// Copyright (C) 2021-26 Harvey Mudd College & Oklahoma State University & Skyworks Solutions Inc
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

module vpu import cvw::*;  #(parameter cvw_t P) (
  input  logic                 clk,
  input  logic                 reset,
  // Hazards
  input  logic                 StallD, StallE, StallM, StallW,      // stall signals (from HZU)
  input  logic                 FlushD, FlushE, FlushM, FlushW,      // flush signals (from HZU)
  output logic                 VPUFrontEndBusyD,                    // Stall the decode stage (To HZU)


  // TODO ***
  // Add CSRs between priv and VPU

  // Decode stage
  input  logic [31:0]          InstrD,                             // instruction (from IFU)
  input  logic VectorD,                                            // This instruction is a vector
  // Execute state
  input  logic [P.XLEN-1:0]    ForwardedSrcAE, ForwardedSrcBE,     // Integer/FP input for convert, move (from IEU)
  // Memory stage
  // TODO *** Cannot use decoded control from IEU because the there are overlapping vector instructions?
  output logic [P.VPU_LSU_BLEN-1:0]    VWriteDataM,          // Data to be written to memory (to LSU)
  output logic [P.XLEN-1:0]            VEUAdrM    ,          // Data to be written to memory (to LSU)
  input  logic [P.VPU_LSU_BLEN-1:0]    VReadDataM , // Read data (from LSU)
  output logic                 IllegalVectorInstructionD,                   // Is the instruction an illegal fpu instruction (to IFU)
  // Writeback stage
  output logic [P.XLEN-1:0] VIEUFPResultFinalW                            // Int or FP result for X or F regs.
);

  logic [4:0] Vs1FinalD, Vs2FinalD;               // Vector Source 1 and 2
  logic [4:0] VdFinalD;                      // Vector Destination read (overwrite)
  logic       VMD;                            // 0 = mask enabled; 1 mask disabled
  logic [5:0] Funct6D;
  logic [2:0] Funct3D;
  logic       RegWriteD;
  logic       VRegWriteD;
  logic [1:0] VALUSrcAD;
  logic       VALUSrcBD;
  logic       VALUResultD;
  logic [P.VLEN-1:0] SrcAD, SrcBD, SrcCD;
  logic [P.VLEN-1:0] v0D;
  logic [P.VLEN-1:0] VResultFinalW;

  logic [P.VLEN-1:0] VIEUResultW [P.VPU_INT_EU-1:0];
  logic [P.XLEN-1:0] VtoIEUFPResultW [P.VPU_INT_EU-1:0];

  //logic       IllegalVectorInstructionD;

  logic [P.VPU_MAX_EU-1:0] ControllerValidD;
  logic [P.VPU_MAX_EU-1:0] ExecutionUnitReadyD;

  logic            VdFinalweW;
  logic [4:0]      VdFinalW;
  genvar i;


  // divide into control and data path

  // decoder inputs
  // InstrD and VectorD
  // outputs the controls and a valid for this specific vector instruction

  // some of the comments shall move to the hazard unit when implemented.
  // the controller directs this vector instruction to a vector Execution Unit (EU) and reads the VRF.
  // If all the EUs are currently operating on an instruction and cannot take a new instruction, then
  // the controller waits by asserting VPUFrontEndBusyD.
  // VPUFrontEndBusyD is used by the hazard unit to stall the front end.
  // When transitioning from scalar to vector instructions, if the scalar takes a long time such as div or load miss,
  // the VPU must be delayed to ensure inorder commit.  StallE, StallM, and StallW need to post pone the progress of
  // vector instruction progress under this condiction.


  assign VPUFrontEndBusyD = '0; // *** vcontroller needs to drive VPUFrontEndBusyD when all the EUs are busy

  vcontroller #(P) vcontroller(.clk, .reset, .StallD, .FlushD,
                               .InstrD, .VectorD, .Vs1FinalD, .Vs2FinalD, .VdFinalD,
                               .VMD, .Funct6D, .Funct3D, .RegWriteD, .VRegWriteD, .VALUSrcAD, .VALUSrcBD,
                               .VALUResultD, .IllegalVectorInstructionD, .ControllerValidD, .ExecutionUnitReadyD);



  vregfile #(P.VLEN) vregfile(clk, reset, VdFinalweW, Vs1FinalD, Vs2FinalD, VdFinalD, VdFinalW,
                              VResultFinalW, SrcAD, SrcBD, SrcCD, v0D);


  for(i = 0; i < P.VPU_INT_EU; i++) begin
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
