///////////////////////////////////////////
// fpgaTop.sv
//
// Written: rose@rosethompson.net November 17, 2021
// Modified: 
//
// Purpose: This is a top level for the fpga's implementation of wally.
//          Instantiates wallysoc, ddr4, abh lite to axi converters, pll, etc
// 
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021 Harvey Mudd College & Oklahoma State University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
// is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT 
// OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////

`include "config.vh"

import cvw::*;

module fpgaTop  #(parameter logic RVVI_SYNTH_SUPPORTED = 1)
  (input           default_250mhz_clk1_0_n,
   input              default_250mhz_clk1_0_p, 
   input              reset,
   input              south_rst,

   input [2:0]        GPI,
   output [4:0]       GPO,

   input              UARTSin,
   output             UARTSout,

   // SDC Signals connecting to an SPI peripheral
   input              SDCIn,
   output             SDCCLK,
   output             SDCCmd,
   output             SDCCS,
   input              SDCCD,
   input              SDCWP,


    /*
     * Ethernet: 1000BASE-T SGMII
     */
    input  logic       phy_sgmii_rx_p,
    input  logic       phy_sgmii_rx_n,
    output logic       phy_sgmii_tx_p,
    output logic       phy_sgmii_tx_n,
    input  logic       phy_sgmii_clk_p,
    input  logic       phy_sgmii_clk_n,
    output logic       phy_reset_n,
   
   output             cpu_reset,
   output             ahblite_resetn,

   output [16 : 0]    c0_ddr4_adr,
   output [1 : 0]     c0_ddr4_ba,
   output [0 : 0]     c0_ddr4_cke,
   output [0 : 0]     c0_ddr4_cs_n,
   inout [7 : 0]      c0_ddr4_dm_dbi_n,
   inout [63 : 0]     c0_ddr4_dq,
   inout [7 : 0]      c0_ddr4_dqs_c,
   inout [7 : 0]      c0_ddr4_dqs_t,
   output [0 : 0]     c0_ddr4_odt,
   output [0 : 0]     c0_ddr4_bg,
   output             c0_ddr4_reset_n,
   output             c0_ddr4_act_n,
   output [0 : 0]     c0_ddr4_ck_c,
   output [0 : 0]     c0_ddr4_ck_t
   );

  logic		   CPUCLK;
  logic		   c0_ddr4_ui_clk_sync_rst;
  logic		   bus_struct_reset;
  logic		   peripheral_reset;
  logic		   interconnect_aresetn;
  logic		   peripheral_aresetn;
  logic		   mb_reset;
  
  logic		   HCLKOpen;
  logic		   HRESETnOpen;
  logic [64-1:0]   HRDATAEXT;
  logic		   HREADYEXT;
  logic		   HRESPEXT;
  logic		   HSELEXT;
  logic [55:0]	   HADDR;
  logic [64-1:0]   HWDATA;
  logic [64/8-1:0] HWSTRB;
  logic		   HWRITE;
  logic [2:0]	   HSIZE;
  logic [2:0]	   HBURST;
  logic [1:0]	   HTRANS;
  logic		   HREADY;
  logic [3:0]	   HPROT;
  logic		   HMASTLOCK;

(* mark_debug = "true" *)  logic		   ExternalStall;

  logic [31:0]	   GPIOIN, GPIOOUT, GPIOEN;

  logic [3:0]	   m_axi_awid;
  logic [7:0]	   m_axi_awlen;
  logic [2:0]	   m_axi_awsize;
  logic [1:0]	   m_axi_awburst;
  logic [3:0]	   m_axi_awcache;
  logic [31:0]	   m_axi_awaddr;
  logic [2:0]	   m_axi_awprot;
  logic		   m_axi_awvalid;
  logic		   m_axi_awready;
  logic		   m_axi_awlock;
  logic [63:0]	   m_axi_wdata;
  logic [7:0]	   m_axi_wstrb;
  logic		   m_axi_wlast;
  logic		   m_axi_wvalid;
  logic		   m_axi_wready;
  logic [3:0]	   m_axi_bid;
  logic [1:0]	   m_axi_bresp;
  logic		   m_axi_bvalid;
  logic		   m_axi_bready;
  logic [3:0]	   m_axi_arid;
  logic [7:0]	   m_axi_arlen;
  logic [2:0]	   m_axi_arsize;
  logic [1:0]	   m_axi_arburst;
  logic [2:0]	   m_axi_arprot;
  logic [3:0]	   m_axi_arcache;
  logic		   m_axi_arvalid;
  logic [31:0]	   m_axi_araddr;
  logic		   m_axi_arlock;
  logic		   m_axi_arready;
  logic [3:0]	   m_axi_rid;
  logic [63:0]	   m_axi_rdata;
  logic [1:0]	   m_axi_rresp;
  logic		   m_axi_rvalid;
  logic		   m_axi_rlast;
  logic		   m_axi_rready;

  // Extra Bus signals
  logic [3:0]	   BUS_axi_arregion;
  logic [3:0]	   BUS_axi_arqos;
  logic [3:0]	   BUS_axi_awregion;
  logic [3:0]	   BUS_axi_awqos;

  // Bus signals
  logic [3:0]	   BUS_axi_awid;
  logic [7:0]	   BUS_axi_awlen;
  logic [2:0]	   BUS_axi_awsize;
  logic [1:0]	   BUS_axi_awburst;
  logic [3:0]	   BUS_axi_awcache;
  logic [30:0]	   BUS_axi_awaddr;
  logic [2:0]	   BUS_axi_awprot;
  logic		   BUS_axi_awvalid;
  logic		   BUS_axi_awready;
  logic		   BUS_axi_awlock;
  logic [63:0]	   BUS_axi_wdata;
  logic [7:0]	   BUS_axi_wstrb;
  logic		   BUS_axi_wlast;
  logic		   BUS_axi_wvalid;
  logic		   BUS_axi_wready;
  logic [3:0]	   BUS_axi_bid;
  logic [1:0]	   BUS_axi_bresp;
  logic		   BUS_axi_bvalid;
  logic		   BUS_axi_bready;
  logic [3:0]	   BUS_axi_arid;
  logic [7:0]	   BUS_axi_arlen;
  logic [2:0]	   BUS_axi_arsize;
  logic [1:0]	   BUS_axi_arburst;
  logic [2:0]	   BUS_axi_arprot;
  logic [3:0]	   BUS_axi_arcache;
  logic		   BUS_axi_arvalid;
  logic [30:0]	   BUS_axi_araddr;
  logic		   BUS_axi_arlock;
  logic		   BUS_axi_arready;
  logic [3:0]	   BUS_axi_rid;
  logic [63:0]	   BUS_axi_rdata;
  logic [1:0]	   BUS_axi_rresp;
  logic		   BUS_axi_rvalid;
  logic		   BUS_axi_rlast;
  logic		   BUS_axi_rready;

  logic		   BUSCLK;

  logic		   c0_init_calib_complete;
  logic		   dbg_clk;
  logic [511 : 0]  dbg_bus;

  logic		   CLK208;
  logic		   SDCCLKInternal;

  assign GPIOIN = {25'b0, SDCCD, SDCWP, 2'b0, GPI};
  assign GPO = GPIOOUT[4:0];
  assign ahblite_resetn = peripheral_aresetn;
  assign cpu_reset = bus_struct_reset;
  
  logic [3:0] SDCCSin;
  assign SDCCS = SDCCSin[0];

   
  // reset controller XILINX IP
  sysrst sysrst
    (.slowest_sync_clk(CPUCLK),
     .ext_reset_in(c0_ddr4_ui_clk_sync_rst),
     .aux_reset_in(south_rst),
     .mb_debug_sys_rst(1'b0),
     .dcm_locked(c0_init_calib_complete),
     .mb_reset(mb_reset),  //open
     .bus_struct_reset(bus_struct_reset),
     .peripheral_reset(peripheral_reset), //open
     .interconnect_aresetn(interconnect_aresetn), //open
     .peripheral_aresetn(peripheral_aresetn));

  `include "parameter-defs.vh"

  // Wally 
  wallypipelinedsoc  #(P) 
  wallypipelinedsoc(.clk(CPUCLK), .reset_ext(bus_struct_reset), .reset(), 
                    .HRDATAEXT, .HREADYEXT, .HRESPEXT, .HSELEXT,
                    .HCLK(HCLKOpen), .HRESETn(HRESETnOpen), 
                    .HADDR, .HWDATA, .HWSTRB, .HWRITE, .HSIZE, .HBURST, .HPROT,
                    .HTRANS, .HMASTLOCK, .HREADY, .TIMECLK(1'b0), 
                    .GPIOIN, .GPIOOUT, .GPIOEN,
                    .UARTSin, .UARTSout, .SDCIn, .SDCCmd, .SDCCS(SDCCSin), .SDCCLK(SDCCLK), .ExternalStall);


  // ahb lite to axi bridge
  ahbaxibridge ahbaxibridge
    (.s_ahb_hclk(CPUCLK),
     .s_ahb_hresetn(peripheral_aresetn),
     .s_ahb_hsel(HSELEXT),
     .s_ahb_haddr(HADDR),
     .s_ahb_hprot(HPROT),
     .s_ahb_htrans(HTRANS),
     .s_ahb_hsize(HSIZE),
     .s_ahb_hwrite(HWRITE),
     .s_ahb_hburst(HBURST),
     .s_ahb_hwdata(HWDATA),
     .s_ahb_hready_out(HREADYEXT),
     .s_ahb_hready_in(HREADY),
     .s_ahb_hrdata(HRDATAEXT),
     .s_ahb_hresp(HRESPEXT),
     .m_axi_awid(m_axi_awid),
     .m_axi_awlen(m_axi_awlen),
     .m_axi_awsize(m_axi_awsize),
     .m_axi_awburst(m_axi_awburst),
     .m_axi_awcache(m_axi_awcache),
     .m_axi_awaddr(m_axi_awaddr),
     .m_axi_awprot(m_axi_awprot),
     .m_axi_awvalid(m_axi_awvalid),
     .m_axi_awready(m_axi_awready),
     .m_axi_awlock(m_axi_awlock),
     .m_axi_wdata(m_axi_wdata),
     .m_axi_wstrb(m_axi_wstrb),
     .m_axi_wlast(m_axi_wlast),
     .m_axi_wvalid(m_axi_wvalid),
     .m_axi_wready(m_axi_wready),
     .m_axi_bid(m_axi_bid),
     .m_axi_bresp(m_axi_bresp),
     .m_axi_bvalid(m_axi_bvalid),
     .m_axi_bready(m_axi_bready),
     .m_axi_arid(m_axi_arid),
     .m_axi_arlen(m_axi_arlen),
     .m_axi_arsize(m_axi_arsize),
     .m_axi_arburst(m_axi_arburst),
     .m_axi_arprot(m_axi_arprot),
     .m_axi_arcache(m_axi_arcache),
     .m_axi_arvalid(m_axi_arvalid),
     .m_axi_araddr(m_axi_araddr),
     .m_axi_arlock(m_axi_arlock),
     .m_axi_arready(m_axi_arready),
     .m_axi_rid(m_axi_rid),
     .m_axi_rdata(m_axi_rdata),
     .m_axi_rresp(m_axi_rresp),
     .m_axi_rvalid(m_axi_rvalid),
     .m_axi_rlast(m_axi_rlast),
     .m_axi_rready(m_axi_rready));

  clkconverter clkconverter
    (.s_axi_aclk(CPUCLK),
     .s_axi_aresetn(peripheral_aresetn),
     .s_axi_awid(m_axi_awid),
     .s_axi_awlen(m_axi_awlen),
     .s_axi_awsize(m_axi_awsize),
     .s_axi_awburst(m_axi_awburst),
     .s_axi_awcache(m_axi_awcache),
     .s_axi_awaddr(m_axi_awaddr[30:0] ),
     .s_axi_awprot(m_axi_awprot),
     .s_axi_awregion(4'b0), // this could be a bug. bridge does not have these outputs
     .s_axi_awqos(4'b0),    // this could be a bug. bridge does not have these outputs
     .s_axi_awvalid(m_axi_awvalid),
     .s_axi_awready(m_axi_awready),
     .s_axi_awlock(m_axi_awlock),
     .s_axi_wdata(m_axi_wdata),
     .s_axi_wstrb(m_axi_wstrb),
     .s_axi_wlast(m_axi_wlast),
     .s_axi_wvalid(m_axi_wvalid),
     .s_axi_wready(m_axi_wready),
     .s_axi_bid(m_axi_bid),
     .s_axi_bresp(m_axi_bresp),
     .s_axi_bvalid(m_axi_bvalid),
     .s_axi_bready(m_axi_bready),
     .s_axi_arid(m_axi_arid),
     .s_axi_arlen(m_axi_arlen),
     .s_axi_arsize(m_axi_arsize),
     .s_axi_arburst(m_axi_arburst),
     .s_axi_arprot(m_axi_arprot),
     .s_axi_arregion(4'b0), // this could be a bug. bridge does not have these outputs
     .s_axi_arqos(4'b0),    // this could be a bug. bridge does not have these outputs
     .s_axi_arcache(m_axi_arcache),
     .s_axi_arvalid(m_axi_arvalid),
     .s_axi_araddr(m_axi_araddr[30:0]),
     .s_axi_arlock(m_axi_arlock),
     .s_axi_arready(m_axi_arready),
     .s_axi_rid(m_axi_rid),
     .s_axi_rdata(m_axi_rdata),
     .s_axi_rresp(m_axi_rresp),
     .s_axi_rvalid(m_axi_rvalid),
     .s_axi_rlast(m_axi_rlast),
     .s_axi_rready(m_axi_rready),

     .m_axi_aclk(BUSCLK),
     .m_axi_aresetn(~reset),
     .m_axi_awid(BUS_axi_awid),
     .m_axi_awlen(BUS_axi_awlen),
     .m_axi_awsize(BUS_axi_awsize),
     .m_axi_awburst(BUS_axi_awburst),
     .m_axi_awcache(BUS_axi_awcache),
     .m_axi_awaddr(BUS_axi_awaddr),
     .m_axi_awprot(BUS_axi_awprot),
     .m_axi_awregion(BUS_axi_awregion),
     .m_axi_awqos(BUS_axi_awqos),
     .m_axi_awvalid(BUS_axi_awvalid),
     .m_axi_awready(BUS_axi_awready),
     .m_axi_awlock(BUS_axi_awlock),
     .m_axi_wdata(BUS_axi_wdata),
     .m_axi_wstrb(BUS_axi_wstrb),
     .m_axi_wlast(BUS_axi_wlast),
     .m_axi_wvalid(BUS_axi_wvalid),
     .m_axi_wready(BUS_axi_wready),
     .m_axi_bid(BUS_axi_bid),
     .m_axi_bresp(BUS_axi_bresp),
     .m_axi_bvalid(BUS_axi_bvalid),
     .m_axi_bready(BUS_axi_bready),
     .m_axi_arid(BUS_axi_arid),
     .m_axi_arlen(BUS_axi_arlen),
     .m_axi_arsize(BUS_axi_arsize),
     .m_axi_arburst(BUS_axi_arburst),
     .m_axi_arprot(BUS_axi_arprot),
     .m_axi_arregion(BUS_axi_arregion),
     .m_axi_arqos(BUS_axi_arqos),
     .m_axi_arcache(BUS_axi_arcache),
     .m_axi_arvalid(BUS_axi_arvalid),
     .m_axi_araddr(BUS_axi_araddr),
     .m_axi_arlock(BUS_axi_arlock),
     .m_axi_arready(BUS_axi_arready),
     .m_axi_rid(BUS_axi_rid),
     .m_axi_rdata(BUS_axi_rdata),
     .m_axi_rresp(BUS_axi_rresp),
     .m_axi_rvalid(BUS_axi_rvalid),
     .m_axi_rlast(BUS_axi_rlast),
     .m_axi_rready(BUS_axi_rready));
   
  ddr4 ddr4
    (.c0_init_calib_complete(c0_init_calib_complete),
     .dbg_clk(dbg_clk), // open
     .c0_sys_clk_p(default_250mhz_clk1_0_p),
     .c0_sys_clk_n(default_250mhz_clk1_0_n),
     .sys_rst(reset),
     .dbg_bus(dbg_bus), // open

     // ddr4 I/O
     .c0_ddr4_adr(c0_ddr4_adr),
     .c0_ddr4_ba(c0_ddr4_ba),
     .c0_ddr4_cke(c0_ddr4_cke),
     .c0_ddr4_cs_n(c0_ddr4_cs_n),
     .c0_ddr4_dm_dbi_n(c0_ddr4_dm_dbi_n),
     .c0_ddr4_dq(c0_ddr4_dq),
     .c0_ddr4_dqs_c(c0_ddr4_dqs_c),
     .c0_ddr4_dqs_t(c0_ddr4_dqs_t),
     .c0_ddr4_odt(c0_ddr4_odt),
     .c0_ddr4_bg(c0_ddr4_bg),
     .c0_ddr4_reset_n(c0_ddr4_reset_n),
     .c0_ddr4_act_n(c0_ddr4_act_n),
     .c0_ddr4_ck_c(c0_ddr4_ck_c),
     .c0_ddr4_ck_t(c0_ddr4_ck_t),
     .c0_ddr4_ui_clk(BUSCLK),
     .c0_ddr4_ui_clk_sync_rst(c0_ddr4_ui_clk_sync_rst),
     .c0_ddr4_aresetn(~reset),

     // axi
     .c0_ddr4_s_axi_awid(BUS_axi_awid),
     .c0_ddr4_s_axi_awaddr(BUS_axi_awaddr[30:0]),
     .c0_ddr4_s_axi_awlen(BUS_axi_awlen),
     .c0_ddr4_s_axi_awsize(BUS_axi_awsize),
     .c0_ddr4_s_axi_awburst(BUS_axi_awburst),
     .c0_ddr4_s_axi_awlock(BUS_axi_awlock),
     .c0_ddr4_s_axi_awcache(BUS_axi_awcache),
     .c0_ddr4_s_axi_awprot(BUS_axi_awprot),
     .c0_ddr4_s_axi_awqos(BUS_axi_awqos),
     .c0_ddr4_s_axi_awvalid(BUS_axi_awvalid),
     .c0_ddr4_s_axi_awready(BUS_axi_awready),
     .c0_ddr4_s_axi_wdata(BUS_axi_wdata),
     .c0_ddr4_s_axi_wstrb(BUS_axi_wstrb),
     .c0_ddr4_s_axi_wlast(BUS_axi_wlast),
     .c0_ddr4_s_axi_wvalid(BUS_axi_wvalid),
     .c0_ddr4_s_axi_wready(BUS_axi_wready),
     .c0_ddr4_s_axi_bready(BUS_axi_bready),
     .c0_ddr4_s_axi_bid(BUS_axi_bid),
     .c0_ddr4_s_axi_bresp(BUS_axi_bresp),
     .c0_ddr4_s_axi_bvalid(BUS_axi_bvalid),
     .c0_ddr4_s_axi_arid(BUS_axi_arid),
     .c0_ddr4_s_axi_araddr(BUS_axi_araddr[30:0]),
     .c0_ddr4_s_axi_arlen(BUS_axi_arlen),
     .c0_ddr4_s_axi_arsize(BUS_axi_arsize),
     .c0_ddr4_s_axi_arburst(BUS_axi_arburst),
     .c0_ddr4_s_axi_arlock(BUS_axi_arlock),
     .c0_ddr4_s_axi_arcache(BUS_axi_arcache),
     .c0_ddr4_s_axi_arprot(BUS_axi_arprot),
     .c0_ddr4_s_axi_arqos(BUS_axi_arqos),
     .c0_ddr4_s_axi_arvalid(BUS_axi_arvalid),
     .c0_ddr4_s_axi_arready(BUS_axi_arready),
     .c0_ddr4_s_axi_rready(BUS_axi_rready),
     .c0_ddr4_s_axi_rlast(BUS_axi_rlast),
     .c0_ddr4_s_axi_rvalid(BUS_axi_rvalid),
     .c0_ddr4_s_axi_rresp(BUS_axi_rresp),
     .c0_ddr4_s_axi_rid(BUS_axi_rid),
     .c0_ddr4_s_axi_rdata(BUS_axi_rdata),

     .addn_ui_clkout1(CPUCLK),
     .addn_ui_clkout2(CLK208));


  (* mark_debug = "true" *)  logic IlaTrigger;
  

  if(RVVI_SYNTH_SUPPORTED) begin : rvvi_synth
    localparam MAX_CSRS = 3;
    localparam TOTAL_CSRS = 36;
    localparam [31:0] RVVI_INIT_TIME_OUT = 32'd100000000;
    localparam [31:0] RVVI_PACKET_DELAY = 32'd2;
    
    // pipeline controlls
    logic                                             StallE, StallM, StallW, FlushE, FlushM, FlushW;
    // required
    logic [P.XLEN-1:0]                                PCM;
    logic                                             InstrValidM;
    logic [31:0]                                      InstrRawD;
    logic [63:0]                                      Mcycle, Minstret;
    logic                                             TrapM;
    logic [1:0]                                       PrivilegeModeW;
    // registers gpr and fpr
    logic                                             GPRWen, FPRWen;
    logic [4:0]                                       GPRAddr, FPRAddr;
    logic [P.XLEN-1:0]                                GPRValue, FPRValue;
    logic [P.XLEN-1:0]                                CSRArray [TOTAL_CSRS-1:0];

    (* mark_debug = "true" *)    logic                                             valid;
    (* mark_debug = "true" *)    logic [72+(5*P.XLEN) + MAX_CSRS*(P.XLEN+16)-1:0] rvvi;

    (* mark_debug = "true" *)    logic					     RVVIStall, HostStall;
    
    logic [32*5-1:0]                                  TriggerString;
    logic [32*5-1:0]                                  SlowString;
    (* mark_debug = "true" *)    logic					     HostRequestSlowDown;

    (* mark_debug = "true" *)        logic [31:0]                     HostFiFoFillAmt;
    logic [4:0]                                       pcspma_config_vector;
    logic [15:0]                                      pcspma_an_config_vector;
    logic [15:0]                                       pcspma_status_vector;
    
    logic [7:0]                                       phy_rxd;
    logic                                             phy_rx_dv;
    logic                                             phy_rx_er;
    logic [7:0]                                       phy_txd;
    logic                                             phy_tx_en;
    logic                                             phy_tx_er;
    logic                                             pcspma_status_link_status;
    logic                                             pcspma_status_link_synchronization;
    logic                                             pcspma_status_rudi_c;
    logic                                             pcspma_status_rudi_i;
    logic                                             pcspma_status_rudi_invalid;
    logic                                             pcspma_status_rxdisperr;
    logic                                             pcspma_status_rxnotintable;
    logic                                             pcspma_status_phy_link_status;
    logic [1:0]                                       pcspma_status_remote_fault_encdg;
    logic [1:0]                                       pcspma_status_speed;
    logic                                             pcspma_status_duplex;
    logic                                             pcspma_status_remote_fault;
    logic [1:0]                                       pcspma_status_pause;
    logic                                             phy_gmii_clk_int;
    logic                                             phy_gmii_rst_int;
    logic                                             phy_gmii_clk_en;
    
    assign StallE         = fpgaTop.wallypipelinedsoc.core.StallE;
    assign StallM         = fpgaTop.wallypipelinedsoc.core.StallM;
    assign StallW         = fpgaTop.wallypipelinedsoc.core.StallW;
    assign FlushE         = fpgaTop.wallypipelinedsoc.core.FlushE;
    assign FlushM         = fpgaTop.wallypipelinedsoc.core.FlushM;
    assign FlushW         = fpgaTop.wallypipelinedsoc.core.FlushW;
    assign InstrValidM    = fpgaTop.wallypipelinedsoc.core.ieu.InstrValidM;
    assign InstrRawD      = fpgaTop.wallypipelinedsoc.core.ifu.InstrRawD;
    assign PCM            = fpgaTop.wallypipelinedsoc.core.ifu.PCM;
    assign Mcycle         = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.counters.counters.HPMCOUNTER_REGW[0];
    assign Minstret       = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.counters.counters.HPMCOUNTER_REGW[2];
    assign TrapM          = fpgaTop.wallypipelinedsoc.core.TrapM;
    assign PrivilegeModeW = fpgaTop.wallypipelinedsoc.core.priv.priv.privmode.PrivilegeModeW;
    assign GPRAddr        = fpgaTop.wallypipelinedsoc.core.ieu.dp.regf.a3;
    assign GPRWen         = fpgaTop.wallypipelinedsoc.core.ieu.dp.regf.we3;
    assign GPRValue       = fpgaTop.wallypipelinedsoc.core.ieu.dp.regf.wd3;
    assign FPRAddr        = fpgaTop.wallypipelinedsoc.core.fpu.fpu.fregfile.a4;
    assign FPRWen         = fpgaTop.wallypipelinedsoc.core.fpu.fpu.fregfile.we4;
    assign FPRValue       = fpgaTop.wallypipelinedsoc.core.fpu.fpu.fregfile.wd4;

    assign CSRArray[0] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MSTATUS_REGW; // 12'h300
    assign CSRArray[1] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MSTATUSH_REGW; // 12'h310
    assign CSRArray[2] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MTVEC_REGW; // 12'h305
    assign CSRArray[3] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MEPC_REGW; // 12'h341
    assign CSRArray[4] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MCOUNTEREN_REGW; // 12'h306
    assign CSRArray[5] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MCOUNTINHIBIT_REGW; // 12'h320
    assign CSRArray[6] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MEDELEG_REGW; // 12'h302
    assign CSRArray[7] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MIDELEG_REGW; // 12'h303
    assign CSRArray[8] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MIP_REGW; // 12'h344
    assign CSRArray[9] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MIE_REGW; // 12'h304
    assign CSRArray[10] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MISA_REGW; // 12'h301
    assign CSRArray[11] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MENVCFG_REGW; // 12'h30A
    assign CSRArray[12] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MHARTID_REGW; // 12'hF14
    assign CSRArray[13] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MSCRATCH_REGW; // 12'h340
    assign CSRArray[14] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MCAUSE_REGW; // 12'h342
    assign CSRArray[15] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MTVAL_REGW; // 12'h343
    assign CSRArray[16] = 0; // 12'hF11
    assign CSRArray[17] = 0; // 12'hF12
    assign CSRArray[18] = {{P.XLEN-12{1'b0}}, 12'h100}; //P.XLEN'h100; // 12'hF13
    assign CSRArray[19] = 0; // 12'hF15
    assign CSRArray[20] = 0; // 12'h34A
    // supervisor CSRs
    assign CSRArray[21] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrs.csrs.SSTATUS_REGW; // 12'h100
    assign CSRArray[22] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MIE_REGW & 12'h222; // 12'h104
    assign CSRArray[23] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrs.csrs.STVEC_REGW; // 12'h105
    assign CSRArray[24] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrs.csrs.SEPC_REGW; // 12'h141
    assign CSRArray[25] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrs.csrs.SCOUNTEREN_REGW; // 12'h106
    assign CSRArray[26] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrs.csrs.SENVCFG_REGW; // 12'h10A
    assign CSRArray[27] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrs.csrs.SATP_REGW; // 12'h180
    assign CSRArray[28] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrs.csrs.SSCRATCH_REGW; // 12'h140
    assign CSRArray[29] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrs.csrs.STVAL_REGW; // 12'h143
    assign CSRArray[30] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrs.csrs.SCAUSE_REGW; // 12'h142
    assign CSRArray[31] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MIP_REGW & 12'h222 & fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrm.MIDELEG_REGW; // 12'h144
    assign CSRArray[32] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csrs.csrs.STIMECMP_REGW; // 12'h14D
    // user CSRs
    assign CSRArray[33] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csru.csru.FFLAGS_REGW; // 12'h001
    assign CSRArray[34] = fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csru.csru.FRM_REGW; // 12'h002
    assign CSRArray[35] = {fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csru.csru.FRM_REGW, fpgaTop.wallypipelinedsoc.core.priv.priv.csr.csru.csru.FFLAGS_REGW}; // 12'h003

    acev #(P, MAX_CSRS, TOTAL_CSRS, RVVI_INIT_TIME_OUT, RVVI_PACKET_DELAY, "XILINX") acev(.clk(CPUCLK), .reset(bus_struct_reset), .StallE, .StallM, .StallW, .FlushE, .FlushM, .FlushW,
      .PCM, .InstrValidM, .InstrRawD, .Mcycle, .Minstret, .TrapM, 
      .PrivilegeModeW, .GPRWen, .FPRWen, .GPRAddr, .FPRAddr, .GPRValue, .FPRValue, .CSRArray,
      .phy_clk(phy_gmii_clk_int),
      .phy_rst(phy_gmii_rst_int),
      .phy_clk_en(phy_gmii_clk_en),
      .phy_rxd(phy_rxd),
      .phy_rx_dv(phy_rx_dv),
      .phy_rx_er(phy_rx_er),
      .phy_txd(phy_txd),
      .phy_tx_en(phy_tx_en),
      .phy_tx_er(phy_tx_er),
      .ExternalStall, .IlaTrigger);


    assign pcspma_config_vector[4] = 1'b1; // autonegotiation enable
    assign pcspma_config_vector[3] = 1'b0; // isolate
    assign pcspma_config_vector[2] = 1'b0; // power down
    assign pcspma_config_vector[1] = 1'b0; // loopback enable
    assign pcspma_config_vector[0] = 1'b0; // unidirectional enable
    assign pcspma_an_config_vector[15]    = 1'b1;    // SGMII link status
    assign pcspma_an_config_vector[14]    = 1'b1;    // SGMII Acknowledge
    assign pcspma_an_config_vector[13:12] = 2'b01;   // full duplex
    assign pcspma_an_config_vector[11:10] = 2'b10;   // SGMII speed
    assign pcspma_an_config_vector[9]     = 1'b0;    // reserved
    assign pcspma_an_config_vector[8:7]   = 2'b00;   // pause frames - SGMII reserved
    assign pcspma_an_config_vector[6]     = 1'b0;    // reserved
    assign pcspma_an_config_vector[5]     = 1'b0;    // full duplex - SGMII reserved
    assign pcspma_an_config_vector[4:1]   = 4'b0000; // reserved
    assign pcspma_an_config_vector[0]     = 1'b1;    // SGMII
    assign pcspma_status_link_status = pcspma_status_vector[0];
    assign pcspma_status_link_synchronization = pcspma_status_vector[1];
    assign pcspma_status_rudi_c = pcspma_status_vector[2];
    assign pcspma_status_rudi_i = pcspma_status_vector[3];
    assign pcspma_status_rudi_invalid = pcspma_status_vector[4];
    assign pcspma_status_rxdisperr = pcspma_status_vector[5];
    assign pcspma_status_rxnotintable = pcspma_status_vector[6];
    assign pcspma_status_phy_link_status = pcspma_status_vector[7];
    assign pcspma_status_remote_fault_encdg = pcspma_status_vector[9:8];
    assign pcspma_status_speed = pcspma_status_vector[11:10];
    assign pcspma_status_duplex = pcspma_status_vector[12];
    assign pcspma_status_remote_fault = pcspma_status_vector[13];
    assign pcspma_status_pause = pcspma_status_vector[15:14];
    
    sgmii_gmii sgmii_gmii(
       // SGMII
       .txp(phy_sgmii_tx_p),
       .txn(phy_sgmii_tx_n),
       .rxp(phy_sgmii_rx_p),
       .rxn(phy_sgmii_rx_n),
       // Ref clock from PHY
       .refclk625_p(phy_sgmii_clk_p),
       .refclk625_n(phy_sgmii_clk_n),
       // async reset
       //.reset(rst_125mhz_int),
                          .reset(~c0_init_calib_complete), // *** might need to be synced to 125Mhz clock
       // clock and reset outputs
       .clk125_out(phy_gmii_clk_int),
       .clk625_out(),
       .clk312_out(),
       .rst_125_out(phy_gmii_rst_int),
       .idelay_rdy_out(),
       .mmcm_locked_out(),
       // MAC clocking
       .sgmii_clk_r(),
       .sgmii_clk_f(),
       .sgmii_clk_en(phy_gmii_clk_en_int),
       // Speed control
       .speed_is_10_100(pcspma_status_speed != 2'b10),
       .speed_is_100(pcspma_status_speed == 2'b01),
       // Internal GMII
       .gmii_txd(phy_txd),
       .gmii_tx_en(phy_tx_en),
       .gmii_tx_er(phy_tx_er),
       .gmii_rxd(phy_rxd),
       .gmii_rx_dv(phy_rx_dv),
       .gmii_rx_er(phy_rx_er),
       .gmii_isolate(),
       // Configuration
       .configuration_vector(pcspma_config_vector),
       .an_interrupt(),
       .an_adv_config_vector(pcspma_an_config_vector),
       .an_restart_config(1'b0),
       // Status
       .status_vector(pcspma_status_vector),
       .signal_detect(1'b1));
    
    
  end else begin // if (P.RVVI_SYNTH_SUPPORTED)
    assign IlaTrigger = '0;
    assign ExternalStall = '0;
  end
   
  //assign phy_reset_n = ~bus_struct_reset;
   assign phy_reset_n = ~1'b0;
  

endmodule

