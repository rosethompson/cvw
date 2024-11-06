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
  input logic               phy_clk, // separate for mii, phy_rx_clk and phy_tx_clk
  input logic               phy_rst, // not present for mii
  input logic               phy_clk_en, // not present for mii
  input logic [7:0]         phy_rxd,    // only 4 bits for mii
  input logic               phy_rx_dv,
  input logic               phy_rx_er,
  output logic [7:0]        phy_txd,   // only 4 bits for mii
  output logic              phy_tx_en,
  output logic              phy_tx_er,

  // feedback
  output logic             ExternalStall,
  output logic             IlaTrigger
  );

  (* mark_debug = "true" *)    logic                                             valid;
  (* mark_debug = "true" *)    logic [72+(5*P.XLEN) + MAX_CSRS*(P.XLEN+16)-1:0] rvvi;

  (* mark_debug = "true" *)    logic					     RVVIStall, HostStall;
    
    logic [32*5-1:0]				     TriggerString;
    logic [32*5-1:0]				     SlowString;
  (* mark_debug = "true" *)    logic					     HostRequestSlowDown;

  (* mark_debug = "true" *)        logic [31:0]                     HostFiFoFillAmt;
  
    // axi 4 write data channel
(* mark_debug = "true" *)    logic [31:0]                                      RvviAxiWdata;
    logic [3:0]                                       RvviAxiWstrb;
(* mark_debug = "true" *)    logic                                             RvviAxiWlast;
(* mark_debug = "true" *)    logic                                             RvviAxiWvalid;
(* mark_debug = "true" *)    logic                                             RvviAxiWready;

    logic [31:0] RvviAxiRdata;
    logic [3:0]                                       RvviAxiRstrb;
(* mark_debug = "true" *)    logic RvviAxiRlast;
(* mark_debug = "true" *)    logic RvviAxiRvalid;

    logic                                             tx_error_underflow, tx_fifo_overflow, tx_fifo_bad_frame, tx_fifo_good_frame, rx_error_bad_frame;
    logic                                             rx_error_bad_fcs, rx_fifo_overflow, rx_fifo_bad_frame, rx_fifo_good_frame;

    rvvisynth #(P, MAX_CSRS) rvvisynth(.clk, .reset, .StallE, .StallM, .StallW, .FlushE, .FlushM, .FlushW,
      .PCM, .InstrValidM, .InstrRawD, .Mcycle, .Minstret, .TrapM, 
      .PrivilegeModeW, .GPRWen, .FPRWen, .GPRAddr, .FPRAddr, .GPRValue, .FPRValue, .CSRArray,
      .valid, .rvvi);


  packetizer #(P, MAX_CSRS, RVVI_INIT_TIME_OUT, RVVI_PACKET_DELAY) packetizer(.rvvi, .valid, .m_axi_aclk(clk), .m_axi_aresetn(~reset), .RVVIStall,
      .RvviAxiWdata, .RvviAxiWstrb, .RvviAxiWlast, .RvviAxiWvalid, .RvviAxiWready);

  eth_mac_1g_gmii_fifo #( .AXIS_DATA_WIDTH(32), .TX_FIFO_DEPTH(1024)) 
  ethernet(.rst(reset), .logic_clk(clk), .logic_rst(reset),
      .tx_axis_tdata(RvviAxiWdata), .tx_axis_tkeep(RvviAxiWstrb), .tx_axis_tvalid(RvviAxiWvalid), .tx_axis_tready(RvviAxiWready),
      .tx_axis_tlast(RvviAxiWlast), .tx_axis_tuser('0), .rx_axis_tdata(RvviAxiRdata),
      .rx_axis_tkeep(RvviAxiRstrb), .rx_axis_tvalid(RvviAxiRvalid), .rx_axis_tready(1'b1),
      .rx_axis_tlast(RvviAxiRlast), .rx_axis_tuser(),
           .rx_clk(phy_clk), .rx_rst(phy_rst), .tx_clk(phy_clk) .tx_rst(phy_rst),
           .gmii_rxd(phy_rxd),
           .gmii_rx_dv(phy_rx_dv),
           .gmii_rx_er(phy_rx_er),
           .gmii_tx_clk(phy_tx_clk),
           .gmii_txd(phy_txd),
           .gmii_tx_en(phy_tx_en),
           .gmii_tx_er(phy_tx_er),
           .rx_clk_enable(phy_clk_en), 
           .tx_clk_enable(phy_clk_en), 
           .rx_mii_select(1'b0),
           .tx_mii_select(1'b0),

      // status
      .tx_error_underflow, .tx_fifo_overflow, .tx_fifo_bad_frame, .tx_fifo_good_frame, .rx_error_bad_frame,
      .rx_error_bad_fcs, .rx_fifo_overflow, .rx_fifo_bad_frame, .rx_fifo_good_frame, 
      .cfg_ifg(8'd12), .cfg_tx_enable(1'b1), .cfg_rx_enable(1'b1)
      );

    // "igin" (trigin)__"rt", ether type 005c__src mac [47:16]__src mac [15:0], dst mac [47:32]__dst mac [31:0]
    assign TriggerString = 160'h6e69_6769__7274_005c__8f54_0000__1654_4502__1111_6843;
    // "emwo" (slowme)__"ls", ether type 005c__src mac [47:16]__src mac [15:0], dst mac [47:32]__dst mac [31:0]
    assign SlowString = 160'h656D_776F__6C73_005c__8f54_0000__1654_4502__1111_6843;
			  
    triggergen triggergen(.clk, .reset, .CompareString(TriggerString), .RvviAxiRdata,
      .RvviAxiRstrb, .RvviAxiRlast, .RvviAxiRvalid, .IlaTrigger, .TriggerMessage());

    triggergen slowdown(.clk, .reset, .CompareString(SlowString), .RvviAxiRdata,
      .RvviAxiRstrb, .RvviAxiRlast, .RvviAxiRvalid, .IlaTrigger(HostRequestSlowDown), .TriggerMessage(HostFiFoFillAmt));

    genslowframe genslowframe(.clk, .reset, .HostRequestSlowDown, .RVVIStall, .HostFiFoFillAmt, .HostStall);
    
    assign ExternalStall = RVVIStall | HostStall;



  
endmodule
