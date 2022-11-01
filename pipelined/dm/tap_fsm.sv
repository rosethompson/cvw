///////////////////////////////////////////
// tap_fsm.sv
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

module tap_fsm (clk, reset, tms, 
		test_logic_reset, run_test_idle, select_dr_scan, capture_dr, shift_dr,          
		exit1_dr, pause_dr, exit2_dr, update_dr, select_ir_scan, capture_ir,        
		shift_ir, exit1_ir, pause_ir, exit2_ir, update_ir);

   input logic  clk;
   input logic  reset;
   input logic 	tms;

   output logic test_logic_reset; 
   output logic run_test_idle;
   output logic select_dr_scan; 
   output logic capture_dr; 
   output logic shift_dr; 
   output logic exit1_dr; 
   output logic pause_dr; 
   output logic exit2_dr; 
   output logic update_dr;
   output logic select_ir_scan; 
   output logic capture_ir; 
   output logic shift_ir; 
   output logic exit1_ir; 
   output logic pause_ir; 
   output logic exit2_ir; 
   output logic update_ir;         

   typedef enum logic [3:0] {testLogicReset, runTestIdle, 
			     selectDRScan, captureDR, shiftDR, 
			     exit1DR, pauseDR, exit2DR, updateDR, 
			     selectIRScan, captureIR, shiftIR, 
			     exit1IR, pauseIR, exit2IR, updateIR} statetype;

   statetype state, nextstate;
   
   // state register
   always_ff @(posedge clk, negedge reset)
     if (reset) begin
	state <= runTestIdle;
     end   
     else begin
	state <= nextstate;
     end
   
   // next state logic
   always_comb
     case (state)
       testLogicReset: begin
	  if (tms) nextstate = testLogicReset;
          else nextstate = runTestIdle;
       end       
       runTestIdle: begin
          if (tms) nextstate = selectDRScan;
          else nextstate = runTestIdle;
       end
       selectDRScan: begin
          if (tms) nextstate = selectIRScan;
          else nextstate = captureDR; 
       end
       captureDR: begin
          if (tms) nextstate = exit1DR;
          else nextstate = shiftDR;
       end       
       shiftDR: begin
          if (tms) nextstate = exit1DR;
          else nextstate = shiftDR;
       end
       exit1DR: begin
          if (tms) nextstate = updateDR;
          else nextstate = pauseDR;
       end
       pauseDR: begin
          if (tms) nextstate = exit2DR;
          else nextstate = pauseDR;
       end
       exit2DR: begin
          if (tms) nextstate = updateDR;
          else nextstate = shiftDR;
       end
       updateDR: begin
          if (tms) nextstate = selectDRScan;
          else nextstate = runTestIdle;
       end
       selectIRScan: begin
          if (tms) nextstate = testLogicReset;
          else nextstate = captureIR; 
       end
       captureIR: begin
          if (tms) nextstate = exit1IR;
          else nextstate = shiftIR;
       end       
       shiftIR: begin
          if (tms) nextstate = exit1IR;
          else nextstate = shiftIR;
       end
       exit1IR: begin
          if (tms) nextstate = updateIR;
          else nextstate = pauseIR;
       end
       pauseIR: begin
          if (tms) nextstate = exit2IR;
          else nextstate = pauseIR;
       end
       exit2IR: begin
          if (tms) nextstate = updateIR;
          else nextstate = shiftIR;
       end
       updateIR: begin
          if (tms) nextstate = selectDRScan;
          else nextstate = runTestIdle;
       end
       default: nextstate = testLogicReset;       
     endcase // case (state)

   assign test_logic_reset = (state == testLogicReset);
   assign run_test_idle = (state == runTestIdle);
   assign select_dr_scan = (state == selectDRScan);
   assign capture_dr = (state == captureDR);
   assign shift_dr = (state == captureDR);
   assign exit1_dr = (state == exit1DR);
   assign pause_dr = (state == pauseDR);
   assign exit2_dr = (state == exit2DR);
   assign update_dr = (state == updateDR);
   assign select_ir_scan = (state == selectIRScan);
   assign capture_ir = (state == captureIR);
   assign shift_ir = (state == shiftIR);
   assign exit1_ir = (state == exit1IR);
   assign pause_ir = (state == pauseIR);
   assign exit2_ir = (state == exit2IR);
   assign update_ir = (state == updateIR);
   
endmodule // tap_fsm
