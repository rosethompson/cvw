`timescale 1ns / 1ns
module stimulus ();

   logic  clk;
   logic  tms;   
   logic  reset;

   logic  test_logic_reset; 
   logic run_test_idle;
   logic select_dr_scan; 
   logic capture_dr; 
   logic shift_dr; 
   logic exit1_dr; 
   logic pause_dr; 
   logic exit2_dr; 
   logic update_dr;
   logic select_ir_scan; 
   logic capture_ir; 
   logic shift_ir; 
   logic exit1_ir; 
   logic pause_ir; 
   logic exit2_ir; 
   logic update_ir;

   integer handle3;
   integer desc3;
   
   // Instantiate DUTx
   tap_fsm dut (clk, reset, tms, 
		test_logic_reset, run_test_idle, select_dr_scan, capture_dr, shift_dr,          
		exit1_dr, pause_dr, exit2_dr, update_dr, select_ir_scan, capture_ir,        
		shift_ir, exit1_ir, pause_ir, exit2_ir, update_ir);

   // Setup the clock to toggle every 1 time units 
   initial 
     begin	
	clk = 1'b1;
	forever #5 clk = ~clk;
     end

   initial
     begin
	// Gives output file name
	handle3 = $fopen("tap.out");
	// Tells when to finish simulation
	#1000 $finish;		
     end

   initial //play around with delays!!!
     begin  
	#0   reset = 1'b1;
	#41  reset = 1'b0;	
	#0   tms = 1'b1;
	#10  tms = 1'b0;
	#10  tms = 1'b0;
	#10  tms = 1'b1; //testing DR
	#10  tms = 1'b0;
	#10  tms = 1'b1;
	#10  tms = 1'b1;
	#10  tms = 1'b0;
	#10  tms = 1'b1;
	#10  tms = 1'b1;
	#10  tms = 1'b0;
	#10  tms = 1'b0;
	#10  tms = 1'b1; //testing IR
	#10  tms = 1'b0;
	#10  tms = 1'b1;
	#10  tms = 1'b1; 
	#10  tms = 1'b1;
	#10  tms = 1'b0;
	#10  tms = 1'b1;
	#10  tms = 1'b1;
	#10  tms = 1'b1; //this point onwards is just random
	#10  tms = 1'b1;
	#10  tms = 1'b0;
	#10  tms = 1'b1;
	#10  tms = 1'b1;
	#10  tms = 1'b0;
	#10  tms = 1'b1;
	#10  tms = 1'b0;
	#10  tms = 1'b1;
	#10  tms = 1'b0;	
     end

endmodule // TAP_tb

