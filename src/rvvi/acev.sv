///////////////////////////////////////////
// acev.sv
//
// Written: Rose Thompson rosethompson.net
// Created: 24 October 2024
// Modified: 24 October 2024
//
// Purpose: top level hardware tracer
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

module acev import cvw::*; #(parameter cvw_t P,
                             parameter integer MAX_CSRS = 5, 
                             parameter integer TOTAL_CSRS = 36,
                             parameter integer RVVI_INIT_TIME_OUT = 32'd100000000,
                             parameter integer RVVI_PACKET_DELAY = 32'd2,
                             parameter integer ETH_WIDTH = 4, // speed, 4 is 10/100M/s, 8 is 1G/s
                             parameter string  TARGET = "GENERIC"
)(
  input logic              clk, reset,
  input logic              StallE, StallM, StallW, FlushE, FlushM, FlushW,
  // required
  input logic [P.XLEN-1:0] PCM,
  input logic              InstrValidM,
  input logic [31:0]       InstrRawD,
  input logic [63:0]       Mcycle, Minstret,
  input logic              TrapM,
  input logic [1:0]        PrivilegeModeW,
  // registers gpr and fpr
  input logic              GPRWen, FPRWen,
  input logic [4:0]        GPRAddr, FPRAddr,
  input logic [P.XLEN-1:0] GPRValue, FPRValue,
  input var [P.XLEN-1:0]   CSRArray [TOTAL_CSRS-1:0],
  
  // ethernet phy
  input logic               phy_rx_clk, // separate for mii, phy_rx_clk and phy_tx_clk
  input logic               phy_tx_clk, // separate for mii, phy_rx_clk and phy_tx_clk
  input logic               phy_rx_rst, // not present for mii
  input logic               phy_tx_rst, // not present for mii
  input logic               phy_rx_clk_en, // not present for mii
  input logic               phy_tx_clk_en, // not present for mii
  input logic [ETH_WIDTH-1:0]         phy_rxd,    // only 4 bits for mii
  input logic               phy_rx_dv,
  input logic               phy_rx_er,
(* mark_debug = "true" *)  output logic [ETH_WIDTH-1:0]        phy_txd,   // only 4 bits for mii
(* mark_debug = "true" *)  output logic              phy_tx_en,
(* mark_debug = "true" *)  output logic              phy_tx_er,

  // feedback
  output logic             ExternalStall,
  output logic             IlaTrigger
  );

  localparam               RVVI_WIDTH = 64+(4*P.XLEN) + MAX_CSRS*(P.XLEN+16);
  localparam               ETH_HEADER_WIDTH = 48*2 + 16;
  localparam               FRAME_COUNT_WIDTH = 16;
  
  (* mark_debug = "true" *)    logic [RVVI_WIDTH-1:0] DutRvvi;

  (* mark_debug = "true" *)    logic					     RVVIStall, HostStall;
  

  
  // axi 4 write data channel
  (* mark_debug = "true" *)    logic [31:0]                                      RvviAxiWdata;
  logic [3:0]              RvviAxiWstrb;
  (* mark_debug = "true" *)    logic                                             RvviAxiWlast;
  (* mark_debug = "true" *)    logic                                             RvviAxiWvalid;
  (* mark_debug = "true" *)    logic                                             RvviAxiWready;

  (* mark_debug = "true" *)    logic [31:0] RvviAxiRdata;
  (* mark_debug = "true" *)    logic [3:0]                                       RvviAxiRstrb;
  (* mark_debug = "true" *)    logic RvviAxiRlast;
  (* mark_debug = "true" *)    logic RvviAxiRvalid;

  logic                    tx_error_underflow, tx_fifo_overflow, tx_fifo_bad_frame, tx_fifo_good_frame, rx_error_bad_frame;
  logic                    rx_error_bad_fcs, rx_fifo_overflow, rx_fifo_bad_frame, rx_fifo_good_frame;

  logic                    HostInstrValid;
  logic [31:0]             HostInterPacketDelay;
  logic [P.XLEN-1:0]       HostMinstr;

  logic [47:0]             SrcMac, DstMac;
  logic [15:0]             EthType;
  (* mark_debug = "true" *) logic                    SelActiveList, PacketizerRvviValid;
  (* mark_debug = "true" *) logic [RVVI_WIDTH-1:0]   ActiveListRvvi, PacketizerRvvi;
  logic                    ActiveListStall;
  logic [31:0]             HostInterPacketDelayD;
  logic [FRAME_COUNT_WIDTH-1:0] DutFrameCount;
  logic [FRAME_COUNT_WIDTH-1:0] HostFrameCount, PacketizerFrameCount, ActiveListFrameCount;
  (* mark_debug = "true" *) logic                         DutValid;
  
      
  // *** fix me later
  assign DstMac = 48'h8F54_0000_1654; // made something up
  assign SrcMac = 48'h4502_1111_6843;
  assign EthType = 16'h005c;

  rvvisynth #(P, MAX_CSRS, TOTAL_CSRS) rvvisynth(.clk, .reset, .StallE, .StallM, .StallW, .FlushE, .FlushM, .FlushW,
      .PCM, .InstrValidM, .InstrRawD, .Mcycle, .Minstret, .TrapM, 
      .PrivilegeModeW, .GPRWen, .FPRWen, .GPRAddr, .FPRAddr, .GPRValue, .FPRValue, .CSRArray,
      .DutValid, .DutRvvi, .DutFrameCount);
  
  rvviactivelist #(.Entries(4), .WIDTH(RVVI_WIDTH+FRAME_COUNT_WIDTH), .FRAME_COUNT_WIDTH(FRAME_COUNT_WIDTH)) 
  rvviactivelist (.clk, .reset, .DutValid, .DutData({DutRvvi, DutFrameCount}),
                  .HostInstrValid, .HostFrameCount,
                  .ActiveListData({ActiveListRvvi, ActiveListFrameCount}), .SelActiveList, .RVVIStall, 
                  .ActiveListStall);

  assign {PacketizerRvvi, PacketizerFrameCount} = SelActiveList ? {ActiveListRvvi, ActiveListFrameCount} : {DutRvvi, DutFrameCount};
  assign PacketizerRvviValid = SelActiveList ? SelActiveList : DutValid;
  

  inversepacketizer #(P, FRAME_COUNT_WIDTH) inversepacketizer (.clk, .reset, .RvviAxiRdata, .RvviAxiRstrb, .RvviAxiRlast, .RvviAxiRvalid,
    .Valid(HostInstrValid), .Minstr(HostMinstr), .InterPacketDelay(HostInterPacketDelay), .FrameCount(HostFrameCount), .DstMac(SrcMac), .SrcMac(DstMac), .EthType);

  flopenl #(32) hostinterpacketdelayreg(clk, reset, HostInstrValid, HostInterPacketDelay, RVVI_PACKET_DELAY, HostInterPacketDelayD);

  packetizer #(P, MAX_CSRS, RVVI_INIT_TIME_OUT, RVVI_PACKET_DELAY, RVVI_WIDTH, ETH_HEADER_WIDTH, FRAME_COUNT_WIDTH) packetizer(.rvvi(PacketizerRvvi), .valid(PacketizerRvviValid), .m_axi_aclk(clk),
     .m_axi_aresetn(~reset), .RVVIStall,
    .RvviAxiWdata, .RvviAxiWstrb, .RvviAxiWlast, .RvviAxiWvalid, .RvviAxiWready, .SrcMac, .DstMac, .EthType, 
    .InnerPktDelay(HostInterPacketDelayD), .FrameCount(PacketizerFrameCount));

  assign ExternalStall = RVVIStall | ActiveListStall;

  if (ETH_WIDTH == 8) begin : eth
    // this is the version of 1g/s ethernet
    eth_mac_1g_fifo #( .AXIS_DATA_WIDTH(32), .TX_FIFO_DEPTH(1024), .RX_FIFO_DEPTH(1024)) 
    ethernet(.logic_clk(clk), .logic_rst(reset),
             .tx_axis_tdata(RvviAxiWdata), .tx_axis_tkeep(RvviAxiWstrb), .tx_axis_tvalid(RvviAxiWvalid), .tx_axis_tready(RvviAxiWready),
             .tx_axis_tlast(RvviAxiWlast), .tx_axis_tuser('0), .rx_axis_tdata(RvviAxiRdata),
             .rx_axis_tkeep(RvviAxiRstrb), .rx_axis_tvalid(RvviAxiRvalid), .rx_axis_tready(1'b1),
             .rx_axis_tlast(RvviAxiRlast), .rx_axis_tuser(),
             .rx_clk(phy_rx_clk), .rx_rst(phy_rx_rst), .tx_clk(phy_tx_clk), .tx_rst(phy_tx_rst),
             .gmii_rxd(phy_rxd),
             .gmii_rx_dv(phy_rx_dv),
             .gmii_rx_er(phy_rx_er),
             .gmii_txd(phy_txd),
             .gmii_tx_en(phy_tx_en),
             .gmii_tx_er(phy_tx_er),
             .rx_clk_enable(phy_rx_clk_en), 
             .tx_clk_enable(phy_tx_clk_en), 
             .rx_mii_select(1'b0),
             .tx_mii_select(1'b0),
             // status
             .tx_error_underflow, .tx_fifo_overflow, .tx_fifo_bad_frame, .tx_fifo_good_frame, .rx_error_bad_frame,
             .rx_error_bad_fcs, .rx_fifo_overflow, .rx_fifo_bad_frame, .rx_fifo_good_frame, 
             .cfg_ifg(8'd12), .cfg_tx_enable(1'b1), .cfg_rx_enable(1'b1)
             );
    end else if (ETH_WIDTH == 4) begin : eth

      // 10/100 Mb/s ethernet
      eth_mac_mii_fifo #(.TARGET(TARGET), .CLOCK_INPUT_STYLE("BUFG"), .AXIS_DATA_WIDTH(32), .TX_FIFO_DEPTH(1024), .RX_FIFO_DEPTH(1024)) 
      ethernet(.rst(reset), .logic_clk(clk), .logic_rst(reset),
               .tx_axis_tdata(RvviAxiWdata), .tx_axis_tkeep(RvviAxiWstrb), .tx_axis_tvalid(RvviAxiWvalid), .tx_axis_tready(RvviAxiWready),
               .tx_axis_tlast(RvviAxiWlast), .tx_axis_tuser('0), .rx_axis_tdata(RvviAxiRdata),
               .rx_axis_tkeep(RvviAxiRstrb), .rx_axis_tvalid(RvviAxiRvalid), .rx_axis_tready(1'b1),
               .rx_axis_tlast(RvviAxiRlast), .rx_axis_tuser(),
               .mii_rx_clk(phy_rx_clk),
               .mii_rxd(phy_rxd),
               .mii_rx_dv(phy_rx_dv),
               .mii_rx_er(phy_rx_er),
               .mii_tx_clk(phy_tx_clk),
               .mii_txd(phy_txd),
               .mii_tx_en(phy_tx_en),
               .mii_tx_er(phy_tx_er),
               // status
               .tx_error_underflow, .tx_fifo_overflow, .tx_fifo_bad_frame, .tx_fifo_good_frame, .rx_error_bad_frame,
               .rx_error_bad_fcs, .rx_fifo_overflow, .rx_fifo_bad_frame, .rx_fifo_good_frame, 
               .cfg_ifg(8'd12), .cfg_tx_enable(1'b1), .cfg_rx_enable(1'b1)
               );
    end

  
endmodule
