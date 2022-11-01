///////////////////////////////////////////
// jtag.sv
//
// Written: Juliette Reeder/James Stine
// Modified: 
//
// Purpose: Main JTAG DM module
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

module jtag #(parameter logic [31:0] IdcodeValue = 32'h00000001) 
   (clk, reset, testmode, 
    dmi_rst_o, dmi_req_o, dmi_req_valid_o, dmi_req_ready_i,
    dmi_resp_i, dmi_resp_ready_o, dmi_resp_valid_i,
    tck_i, tms_i, trst_i, tdi_i, tdo_o, tdo_oe_o);

   input logic         clk;
   input logic 	       reset;
   input logic 	       testmode;
   
   output logic        dmi_rst_o;
   output logic [40:0] dmi_req_o;
   output logic        dmi_req_valid_o;
   input logic 	       dmi_req_ready_i;
   
   input logic 	       dmi_resp_i;
   output logic        dmi_resp_ready_o;
   input logic 	       dmi_resp_valid_i;
   
   input  logic        tck_input;   
   input  logic        tms_input;   
   input  logic        trst_input;  
   input  logic        tdi_input;   
   output logic        tdo_output;  
   output logic        tdo_oe_output;
   
   typedef enum        logic [1:0] {DMINoError = 2'h0, 
				    DMIReservedError = 2'h1,
				    DMIOPFailed = 2'h2, 
				    DMIBusy = 2'h3
				    } dmi_error_e;
   
   dmi_error_e error_d, error_q;
   
   logic 	              tck;
   logic 		      jtag_dmi_clear; 
   logic 		      dmi_clear; 
   logic 		      update;
   logic 		      capture;
   logic 		      shift;
   logic 		      tdi;
   logic 		      dmihardreset;   
   
   logic 		      dtmcs_select;
   
   // struct : 7 + IrLength + 32 = 39+IrLength
   // logic [6:0]  addr;
   // dtm_op_e     op;
   // logic [31:0] data;
   //} dmi_req_t;
   // struct: 32 + 2 = 34
   //  logic [31:0] data;
   //  logic [1:0]  resp;
   //} dmi_resp_t;
   // struct: 7 + 32 + 2 = 41
   //   logic [6:0] address;
   //   logic [31:0] data;
   //   logic [1:0]  op;
   //} dmi_t;
   
   logic 		      dmi_select;
   logic 		      dmi_tdo;
   logic [39+IrLength-1:0]    dmi_req_t;
   logic 		      dmi_req_ready;
   logic 		      dmi_req_valid;
   
   logic [33:0] 	      dmi_resp_t;
   logic 		      dmi_resp_valid;
   logic 		      dmi_resp_ready;
   logic [40:0] 	      dmi_t;
   logic 		      DTM_WRITE;
   logic 		      DTM_READ;   
   
   typedef enum 	      logic [2:0] {Idle, Read, WaitReadValid, Write, WaitWriteValid} state_e;
   state_e state_d, state_q;
   
   logic [40:0] 	      dr_d, dr_q;
   logic [6:0] 		      address_d, address_q;
   logic [31:0] 	      data_d, data_q;
   
   logic [40:0] 	      dmi;
   logic 		      error_dmi_busy;
   
   // struct
   //   logic [31:18] zero1;
   //   logic         dmihardreset;
   //  logic         dmireset;
   //  logic         zero0;
   //  logic [14:12] idle;
   //  logic [11:10] dmistat;
   //  logic [9:4]   abits;
   //  logic [3:0]   version;
   //} dtmcs_t;   
   logic [31:0] dtmcs_d, dtmcs_q;

   assign dmi          = {3'h0, dr_q};
   assign DTM_WRITE = 2'h2;
   assign DTM_READ = 2'h1;   
   assign dmi_req = {address_q,  data_q, (state_q == Write) ? DTM_WRITE : DTM_READ};
   assign dmi_resp_ready = 1'b1;
   assign dmi_clear = jtag_dmi_clear || (dtmcs_select && update && dmihardreset);
   
   always_comb begin
      dtmcs_d = dtmcs_q;
      if (capture) begin
	 if (dtmcs_select) begin
	    // What? (fixme)
            //dtmcs_d  = '{1'b0, 1'b0, 1'b0, 1'b0, 3'd1, error_q, 6'd7, 4'd1}';
	 end
      end      
      if (shift) begin
	 if (dtmcs_select) 
	   dtmcs_d  = {tdi, 31'(dtmcs_q >> 1)};
      end
   end
   
   // Insert new FSM
   
   // shift register
   assign dmi_tdo = dr_q[0];
   always_comb begin 
      dr_d    = dr_q;
      if (dmi_clear) begin
	 dr_d = '0;
      end else begin
	 if (capture) begin
            if (dmi_select) begin
               if (error_q == DMINoError && !error_dmi_busy) begin
		  dr_d = {address_q, data_q, DMINoError};
		  // DMI was busy, report an error
               end else if (error_q == DMIBusy || error_dmi_busy) begin
		  dr_d = {address_q, data_q, DMIBusy};
               end
            end
	 end
	 
	 if (shift) begin
            if (dmi_select) begin
               dr_d = {tdi, dr_q[$bits(dr_q)-1:1]};
            end
	 end
      end
   end // always_comb

   flopr #(32) dtmcsreg (tck, trst, dtmcs_d, tdmcs_q);
   
   
   

   
endmodule // jtag

