//
// File name : tb.v
// Title     : stimulus
// project   : ECEN3233
// Library   : test
// Author(s) : James E. Stine, Jr.
// Purpose   : definition of modules for testbench 
// notes :   
//
// Copyright Oklahoma State University
//

module stimulus();

   logic clk;  

   // Declare variables for stimulating input
   logic [31:0] rdata;   
   logic        wfull;
   logic        rempty;
   
   logic [31:0] wdata;   
   logic 	winc, wclk, wrst_n;   
   logic 	rinc, rclk, rrst_n;
   
   logic [31:0] vectornum;
   logic [31:0] errors;

   integer 	handle3;
   integer 	desc3;
   integer 	i;  
   integer 	j;
   
   // Instantiate the design block counter
   fifo #(32,4) dut (rdata, wfull, rempty,
		     wdata, winc, clk, wrst_n,
		     rinc, clk, rrst_n);
   
   // Setup the clock to toggle every 1 time units 
   initial 
     begin	
	clk = 1'b1;
	forever #5 clk = ~clk;
     end
   
   initial
     begin
	// Gives output file name
	handle3 = $fopen("test.out");
	rrst_n = 1'b0;
	wrst_n = 1'b0;	
     end
   
    initial
      begin
	 #43 rrst_n = 1'b1;
	 #0  wrst_n = 1'b1;	 	 
	for (j=0; j < 16; j=j+1)
	  begin
	     // Put vectors before beginning of clk
	     @(posedge clk)
	       begin
		  wdata = $random;
		  winc = $random;
	       end
	     @(negedge clk)
	       begin
		  vectornum = vectornum + 1;		       
	       end // @(negedge clk)		  
	  end // for (i=0; i < 16; i=i+1)
	$display("%d tests completed with %d errors", vectornum, errors);
	$finish;	
     end // initial begin   


endmodule // stimulus





