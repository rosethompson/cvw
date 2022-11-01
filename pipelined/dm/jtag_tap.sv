///////////////////////////////////////////
// jtag_tap.sv
//
// Written: Juliette Reeder/James Stine
// Modified: 
//
// Purpose: 1149.1 tap controller
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

module jtag_tap #(parameter int unsigned IrLength = 5,
		  parameter logic [31:0] IdcodeValue = 32'h00000001) 
   (tck, tms, trst, tdi, tdo, 
    test_logic_reset, update_dr, capture_dr, shift_dr, 
    dtmcs_select, dtmcs_tdo, dmi_select, dmi_tdo,
    tck_output, tdi_output, tdo_oe, testmode);
   
   input  logic 			 tck;    // JTAG test clock pad
   input  logic 			 tms;    // JTAG test mode select pad
   input  logic 			 trst;   // JTAG test reset pad
   input  logic 			 tdi;    // JTAG test data input pad
   output logic 			 tdo;    // JTAG test data output pad
   
   input logic 				 dmi_tdo;
   input logic 				 dtmcs_tdo;
   
   output logic 			 dmi_select;
   output logic 			 test_logic_reset;   
   output logic 			 update_dr;
   output logic 			 shift_dr;
   output logic 			 capture_dr;
   output logic				 dtmcs_select;

   output logic 			 tck_output;
   output logic 			 tdi_output;
   output logic 			 tdo_oe;
   input logic				 testmode;   

   // DM : Table 6.1 (page 63)
   typedef enum 			 logic [IrLength-1:0] {BYPASS0   = 'h0,
							       IDCODE    = 'h1,
							       DTMCSR    = 'h10,
							       DMIACCESS = 'h11,
							       BYPASS1   = 'h1f
							       } ir_reg_e;

   logic 				 capture_ir, shift_ir, update_ir;
   logic [31:0] 			 idcode_d, idcode_q;
   logic 				 idcode_select;
   logic 				 bypass_select;
   logic 				 bypass_d, bypass_q;
   logic 				 tdo_mux;   
   logic [IrLength-1:0] 		 jtag_ir_shift_d;
   logic [IrLength-1:0] 		 jtag_ir_shift_q;
   
   // IR register -> this gets captured from shift register upon update_ir
   ir_reg_e jtag_ir_d;
   ir_reg_e jtag_ir_q;
   
   // For daisy chaining for multiple JTAG
   assign tck_output = tck;
   assign tdi_output = tdi;  

   // FIXME: get rid of if-then-else
   always_comb begin

      // not needed?
      idcode_d = idcode_q;
      bypass_d = bypass_q;      
      
      if (shift_dr) begin
	 if (idcode_select)  idcode_d = {tdi, 31'(idcode_q >> 1)};
	 if (bypass_select)  bypass_d = tdi;
      end
      
      if (test_logic_reset) begin
	 // Bring all TAP state to the initial value.
	 idcode_d = IdcodeValue;
	 bypass_d = 1'b0;
      end
   end
   
   always_comb begin : p_jtag

      // ?
      jtag_ir_shift_d = jtag_ir_shift_q;
      jtag_ir_d       = jtag_ir_q;
      
      // IR shift register
      if (shift_ir) begin
	 jtag_ir_shift_d = {tdi, jtag_ir_shift_q[IrLength-1:1]};
      end
      
      // capture IR register
      if (capture_ir) begin
	 jtag_ir_shift_d =  IrLength'(4'b0101);
      end
      
      // update IR register
      if (update_ir) begin
	 jtag_ir_d = ir_reg_e'(jtag_ir_shift_q);
      end
      
      if (test_logic_reset) begin
	 // Bring all TAP state to the initial value.
	 jtag_ir_shift_d = '0;
	 jtag_ir_d = IDCODE;
      end
   end

   // Data reg select
   always_comb begin : p_data_reg_sel
      dmi_select   = 1'b0;
      dtmcs_select = 1'b0;
      idcode_select  = 1'b0;
      bypass_select  = 1'b0;
      unique case (jtag_ir_q)
	BYPASS0:   bypass_select  = 1'b1;
	IDCODE:    idcode_select  = 1'b1;
	DTMCSR:    dtmcs_select = 1'b1;
	DMIACCESS: dmi_select   = 1'b1;
	BYPASS1:   bypass_select  = 1'b1;
	default:   bypass_select  = 1'b1;
      endcase
   end
   
   always_comb begin : p_out_sel
      // we are shifting out the IR register
      if (shift_ir) begin
	 tdo_mux = jtag_ir_shift_q[0];
	 // here we are shifting the DR register
      end else begin
	 unique case (jtag_ir_q)
           IDCODE:         tdo_mux = idcode_q[0];   // Reading ID code
           DTMCSR:         tdo_mux = dtmcs_tdo;     // Read from DTMCS TDO
           DMIACCESS:      tdo_mux = dmi_tdo;       // Read from DMI TDO
           default:        tdo_mux = bypass_q;      // BYPASS instruction
	 endcase
      end
   end // block: p_out_sel

   // Is there a better way of doing this?
   always_ff @(posedge tck, negedge trst) begin 
      if (!trst) begin
	 jtag_ir_q   <= IDCODE;
	 idcode_q    <= IdcodeValue;
      end else begin
	 jtag_ir_q   <= jtag_ir_d;
	 idcode_q    <= idcode_d;
      end
   end

   // Instatiate TAP controller
   tap_fsm ieeetap (tck, trst, tms, 
		    test_logic_reset, run_test_idle, select_dr_scan, capture_dr, shift_dr,          
		    exit1_dr, pause_dr, exit2_dr, update_dr, select_ir_scan, capture_ir,        
		    shift_ir, exit1_ir, pause_ir, exit2_ir, update_ir);   

   // JTAG registers
   flopr #(IrLength) jtag_ir_shiftreg (tck, trst, jtag_ir_shift_d, jtag_ir_shift_q);
   flopr #(1) tdoreg (tck, trst, tdo_mux, tdo);
   flopr #(1) tdooereg (tck, trst, (shift_ir | shift_dr), tdo_oe);
   flopr #(1) bypassreg (tck, trst, bypass_d, bypass_q);
   
endmodule // TAP
