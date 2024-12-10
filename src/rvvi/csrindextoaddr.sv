///////////////////////////////////////////
// csrindextoaddr.sv
//
// Written: Rose Thompson rose@rosethompson.net
// Created: 24 January 2024
// Modified: 24 January 2024
//
// Purpose: Converts the rvvi CSR index into the CSR address
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

module csrindextoaddr #(parameter TOTAL_CSRS = 36) (
  input logic [TOTAL_CSRS-1:0]  CSRWen,
  output logic [11:0] CSRAddr);

  if (TOTAL_CSRS == 36) begin 
    always_comb begin
      case(CSRWen) 
	36'h0_0000_0000: CSRAddr = 12'h000;

	36'h0_0000_0001: CSRAddr = 12'h300;
	36'h0_0000_0002: CSRAddr = 12'h310;
	36'h0_0000_0004: CSRAddr = 12'h305;      
	36'h0_0000_0008: CSRAddr = 12'h341;
      
	36'h0_0000_0010: CSRAddr = 12'h306;      
	36'h0_0000_0020: CSRAddr = 12'h320;      
	36'h0_0000_0040: CSRAddr = 12'h302;      
	36'h0_0000_0080: CSRAddr = 12'h303;
      
	36'h0_0000_0100: CSRAddr = 12'h344;      
	36'h0_0000_0200: CSRAddr = 12'h304;      
	36'h0_0000_0400: CSRAddr = 12'h301;      
	36'h0_0000_0800: CSRAddr = 12'h30A;
      
	36'h0_0000_1000: CSRAddr = 12'hF14;      
	36'h0_0000_2000: CSRAddr = 12'h340;
	36'h0_0000_4000: CSRAddr = 12'h342;
	36'h0_0000_8000: CSRAddr = 12'h343;

	36'h0_0001_0000: CSRAddr = 12'hF11;
	36'h0_0002_0000: CSRAddr = 12'hF12;
	36'h0_0004_0000: CSRAddr = 12'hF13;
	36'h0_0008_0000: CSRAddr = 12'hF15;

	36'h0_0010_0000: CSRAddr = 12'h34A;
	36'h0_0020_0000: CSRAddr = 12'h100;
	36'h0_0040_0000: CSRAddr = 12'h104;
	36'h0_0080_0000: CSRAddr = 12'h105;

	36'h0_0100_0000: CSRAddr = 12'h141;
	36'h0_0200_0000: CSRAddr = 12'h106;
	36'h0_0400_0000: CSRAddr = 12'h10A;
	36'h0_0800_0000: CSRAddr = 12'h180;

	36'h0_1000_0000: CSRAddr = 12'h140;
	36'h0_2000_0000: CSRAddr = 12'h143;
	36'h0_4000_0000: CSRAddr = 12'h142;
	36'h0_8000_0000: CSRAddr = 12'h144;

	36'h1_0000_0000: CSRAddr = 12'h14D;
	36'h2_0000_0000: CSRAddr = 12'h001;
	36'h4_0000_0000: CSRAddr = 12'h002;
	36'h8_0000_0000: CSRAddr = 12'h003;

	default        : CSRAddr = 12'h000;
      endcase // case (CSRWen)
    end
  end else if (TOTAL_CSRS == 54) begin // always_comb
    always_comb begin
      case(CSRWen)
	54'h00_0000_0000_0000: CSRAddr = 12'h000;

	54'h00_0000_0000_0001: CSRAddr = 12'h300;
	54'h00_0000_0000_0002: CSRAddr = 12'h310;
	54'h00_0000_0000_0004: CSRAddr = 12'h305;
	54'h00_0000_0000_0008: CSRAddr = 12'h341;

	54'h00_0000_0000_0010: CSRAddr = 12'h306;
	54'h00_0000_0000_0020: CSRAddr = 12'h320;
	54'h00_0000_0000_0040: CSRAddr = 12'h302;
	54'h00_0000_0000_0080: CSRAddr = 12'h303;

	54'h00_0000_0000_0100: CSRAddr = 12'h344;
	54'h00_0000_0000_0200: CSRAddr = 12'h304;
	54'h00_0000_0000_0400: CSRAddr = 12'h301;
	54'h00_0000_0000_0800: CSRAddr = 12'h30A;

	54'h00_0000_0000_1000: CSRAddr = 12'hF14;
	54'h00_0000_0000_2000: CSRAddr = 12'h340;
	54'h00_0000_0000_4000: CSRAddr = 12'h342;
	54'h00_0000_0000_8000: CSRAddr = 12'h343;

	54'h00_0000_0001_0000: CSRAddr = 12'hF11;
	54'h00_0000_0002_0000: CSRAddr = 12'hF12;
	54'h00_0000_0004_0000: CSRAddr = 12'hF13;
	54'h00_0000_0008_0000: CSRAddr = 12'hF15;

	54'h00_0000_0010_0000: CSRAddr = 12'h34A;
	54'h00_0000_0020_0000: CSRAddr = 12'h100;
	54'h00_0000_0040_0000: CSRAddr = 12'h104;
	54'h00_0000_0080_0000: CSRAddr = 12'h105;

	54'h00_0000_0100_0000: CSRAddr = 12'h141;
	54'h00_0000_0200_0000: CSRAddr = 12'h106;
	54'h00_0000_0400_0000: CSRAddr = 12'h10A;
	54'h00_0000_0800_0000: CSRAddr = 12'h180;

	54'h00_0000_1000_0000: CSRAddr = 12'h140;
	54'h00_0000_2000_0000: CSRAddr = 12'h143;
	54'h00_0000_4000_0000: CSRAddr = 12'h142;
	54'h00_0000_8000_0000: CSRAddr = 12'h144;

	54'h00_0001_0000_0000: CSRAddr = 12'h14D;
	54'h00_0002_0000_0000: CSRAddr = 12'h001;
	54'h00_0004_0000_0000: CSRAddr = 12'h002;
	54'h00_0008_0000_0000: CSRAddr = 12'h003;

	// pmp addr only 16 supported
	54'h00_0010_0000_0000: CSRAddr = 12'h3B0;
	54'h00_0020_0000_0000: CSRAddr = 12'h3B1;
	54'h00_0040_0000_0000: CSRAddr = 12'h3B2;
	54'h00_0080_0000_0000: CSRAddr = 12'h3B3;

	54'h00_0100_0000_0000: CSRAddr = 12'h3B4;
	54'h00_0200_0000_0000: CSRAddr = 12'h3B5;
	54'h00_0400_0000_0000: CSRAddr = 12'h3B6;
	54'h00_0800_0000_0000: CSRAddr = 12'h3B7;

	54'h00_1000_0000_0000: CSRAddr = 12'h3B8;
	54'h00_2000_0000_0000: CSRAddr = 12'h3B9;
	54'h00_4000_0000_0000: CSRAddr = 12'h3BA;
	54'h00_8000_0000_0000: CSRAddr = 12'h3BB;

	54'h01_0000_0000_0000: CSRAddr = 12'h3BC;
	54'h02_0000_0000_0000: CSRAddr = 12'h3BD;
	54'h04_0000_0000_0000: CSRAddr = 12'h3BE;
	54'h08_0000_0000_0000: CSRAddr = 12'h3BF;

	// pmp cmf only 16 supported so 2 regs only the even ones for 64-bit
	54'h10_0000_0000_0000: CSRAddr = 12'h3A0;
	54'h20_0000_0000_0000: CSRAddr = 12'h3A2;
	default        : CSRAddr = 12'h000;
      endcase // case (CSRWen)
    end
  end
endmodule
  
