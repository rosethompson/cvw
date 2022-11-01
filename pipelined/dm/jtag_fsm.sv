///////////////////////////////////////////
// jtag_fsm.sv
//
// Written: Juliette Reeder/James Stine
// Modified: 
//
// Purpose: FSM to control 1149.1 JTAG module
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

module jtag_fsm (clk, reset, 
		 dmi_req_ready, dmi_resp_valid, dmi_op, dmi_select, dmi_resp,
		 update, error,
		 address, data, dmi_req_valid, error_dmi_busy, error_dmi_op_failed);

   input logic  clk;
   input logic  reset;
   input logic 	dmi_req_ready;
   input logic 	dmi_resp_valid;
   input logic 	dmi_op;
   input logic 	dmi_select;
   input logic 	dmi_resp;   
   input logic 	update;
   input logic 	error;   

   output logic address;
   output logic data;
   output logic dmi_req_valid;
   output logic error_dmi_busy;
   output logic error_dmi_op_failed;

   typedef enum logic [2:0] {Idel, Read, WaitReadValid, Write, 
			     WaitWriteValid} statetype;

   logic [1:0] 	DMINoError = 2'h0;
   logic [1:0] 	DMIReservedError = 2'h1;
   logic [1:0] 	DMIOPFailed = 2'h2;
   logic [1:0] 	DMIBusy = 2'h3;
   
   logic [1:0] 	DTM_NOP = 2'h0;
   logic [1:0] 	DTM_READ = 2'h1;
   logic [1:0] 	DTM_WRITE = 2'h2;
   
   logic [1:0] 	DTM_SUCCESS = 2'h0;
   logic [1:0] 	DTM_ERR = 2'h1;
   logic [1:0] 	DTM_BUSY = 2'h2;   

   statetype state, nextstate;
   
   // state register
   always_ff @(posedge clk, negedge reset)
     if (reset) begin
	state <= Idle;
     end   
     else begin
	state <= nextstate;
     end
   
   // next state logic
   always_comb
     case (state)
       Idle: begin
          if (dmi_select and update and (error == DMINoError) and (dtm_op == DTM_READ))
	    nextstate = Read;
	  if (dmi_select and update and (error == DMINoError) and (dtm_op == DTM_WRITE))
	    nextstate = Write;
          else nextstate = Idle;
       end
       Read: begin
	  if (dmi_req_ready)
	    nextstate = WaitReadValid;
	  else
	    nextstate = Read;
       end
       WaitReadValid: begin
	  nextstate = Idle;
       end
       Write: begin
	  if (dmi_req_ready)
	    nextstate = WaitWriteValid;
	  else
	    nextstate = Write;
       end
       WaitWriteValid: begin
	  nextstate = Idle;
       end       	  
       default: nextstate = Idle;
     endcase // case (state)

   assign test_logic_reset = (state == testLogicReset);

   
endmodule // jtag_fsm
