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
  input logic [P.VLEN-1:0]          SrcAD, SrcBD, SrcCD,
  input logic [P.VLEN-1:0]          v0D,
   //
  // from/to the scalar core
  input logic [P.XLEN-1:0]          ForwardedSrcAE, ForwardedSrcBE, // Integer/FP input for convert, move (from IEU)
  output logic [P.XLEN-1:0]         VtoIEUFPResultW,                  // Int or FP result for
  output logic [P.VLEN-1:0]         VIEUResultW
);

  assign ExecutionUnitReadyD = '1;
  assign VIEUResultW = '0;

  assign VtoIEUFPResultW = '0;

endmodule
