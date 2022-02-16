///////////////////////////////////////////
// mul.sv
//
// Written: David_Harris@hmc.edu 16 February 2021
// Modified: 
//
// Purpose: Multiply instructions
// 
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021 Harvey Mudd College & Oklahoma State University
//
// MIT LICENSE
// Permission is hereby granted, free of charge, to any person obtaining a copy of this 
// software and associated documentation files (the "Software"), to deal in the Software 
// without restriction, including without limitation the rights to use, copy, modify, merge, 
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
// to whom the Software is furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all copies or 
//   substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//   INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
//   PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
//   BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
//   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE 
//   OR OTHER DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////////

`include "wally-config.vh"

module mul (
  // Execute Stage interface
  input  logic             clk, reset,
  input  logic             StallM, FlushM,
    //    input logic [`XLEN-1:0] 	SrcAE, SrcBE,
  input logic [`XLEN-1:0] ForwardedSrcAE, ForwardedSrcBE, // *** these are the src outputs before the mux choosing between them and PCE to put in srcA/B
  input  logic [2:0]       Funct3E,
  output logic [`XLEN*2-1:0] ProdM);
  logic [`XLEN*2-1:0] ProdE;

  // Add Lab 5 code here to compute ProdE
  assign ProdE = 0; // This isn't right!

  //////////////////////////////
  // Memory Stage Register
  //////////////////////////////
	 flopenrc #(`XLEN*2) ProdMReg(clk, reset, FlushM, ~StallM, ProdE, ProdM); 
 endmodule

