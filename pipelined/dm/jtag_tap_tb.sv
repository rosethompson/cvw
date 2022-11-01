`timescale 1ns / 1ns
module stimulus ();


   logic 			 tck;    
   logic 			 tms;    
   logic 			 trst;   
   logic 			 tdi;    
   logic 			 tdo;   
   logic 			 dmi_tdo;
   logic 			 dtmcs_tdo;   
   logic 			 dmi_select;
   logic 			 test_logic_reset;   
   logic 			 update_dr;
   logic 			 shift_dr;
   logic 			 capture_dr;
   logic 			 dtmcs_select;
   logic 			 tck_output;
   logic 			 tdi_output;
   logic 			 tdo_oe;
   logic 			 testmode;   
   
   integer 			 handle3;
   integer 			 desc3;
   integer 			 j;   
   
   // Instantiate DUTx
   jtag_tap #(5, 32'h00000001) dut (tck, tms, trst, tdi, tdo, 
				    test_logic_reset, update_dr, capture_dr, shift_dr, 
				    dtmcs_select, dtmcs_tdo, dmi_select, dmi_tdo,
				    tck_output, tdi_output, tdo_oe, testmode);

   // Setup the clock to toggle every 1 time units 
   initial 
     begin	
	tck = 1'b1;
	forever #5 tck = ~tck;
     end

   initial
     begin
	// Gives output file name
	handle3 = $fopen("tap.out");
	// Tells when to finish simulation
	#1000 $finish;		
     end

   // Randomize tdi for fun
   initial
     begin
	for (j=0; j < 256; j=j+1)
	  begin
	     // Put vectors before beginning of clk
	     @(posedge tck)
	       begin
		  tdi = $random;
	       end
	  end // for (j=0; j < 4; j=j+1)
     end // initial begin   


   initial //play around with delays!!!
     begin
	#0   testmode = 1'b0;	
	#0   trst = 1'b1;
	#41  trst = 1'b0;	
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

endmodule // stimulus


