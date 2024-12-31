///////////////////////////////////////////
// loggers.sv
//
// Written: Rose Thompson rose@rosethompson.net
// Modified: 24 July 2024
// 
// Purpose: Wraps all the synthesizable rvvi hardware into a single module for the testbench.
// 
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021 Harvey Mudd College & Oklahoma State University
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

module rvvitbwrapper import cvw::*; #(parameter cvw_t P,
                                      parameter              MAX_CSRS = 5,
                                      parameter logic [31:0] RVVI_INIT_TIME_OUT = 32'd4,
                                      parameter logic [31:0] RVVI_PACKET_DELAY = 32'd2,
                                      parameter ETH_WIDTH = 4
)(
  input  logic clk,
  input  logic reset,
  output logic ExternalStall,
  input  logic phy_tx_clk,
  output logic [ETH_WIDTH-1:0] phy_txd,
  output logic phy_tx_en, phy_tx_er,
  input  logic phy_rx_clk,
  input  logic [ETH_WIDTH-1:0] phy_rxd,
  input  logic phy_rx_dv,
  input  logic phy_rx_er,
  input logic               phy_rx_clk_en, // not present for mii
  input logic               phy_tx_clk_en, // not present for mii
  input logic               phy_rx_rst, // not present for mii
  input logic               phy_tx_rst // not present for mii
);

  logic        valid;
  logic [72+(5*P.XLEN) + MAX_CSRS*(P.XLEN+16)-1:0] rvvi;

  localparam TOTAL_CSRS = 36;
  
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

  // axi 4 write data channel
  logic [31:0]                                      RvviAxiWdata;
  logic [3:0]                                       RvviAxiWstrb;
  logic                                             RvviAxiWlast;
  logic                                             RvviAxiWvalid;
  logic                                             RvviAxiWready;
  logic [31:0]                                      RvviAxiRdata;
  logic [3:0]                                       RvviAxiRstrb;
  logic                                             RvviAxiRlast;
  logic                                             RvviAxiRvalid;

  logic                                             tx_error_underflow, tx_fifo_overflow, tx_fifo_bad_frame, tx_fifo_good_frame, rx_error_bad_frame;
  logic                                             rx_error_bad_fcs, rx_fifo_overflow, rx_fifo_bad_frame, rx_fifo_good_frame;

  logic                                             MiiTxEnDelay;
  logic                                             EthernetTXCounterEn;
  logic [31:0]                                      EthernetTXCount;
  logic                                             IlaTrigger;
  logic                                             mii_tx_en;
  
  assign StallE         = dut.core.StallE;
  assign StallM         = dut.core.StallM;
  assign StallW         = dut.core.StallW;
  assign FlushE         = dut.core.FlushE;
  assign FlushM         = dut.core.FlushM;
  assign FlushW         = dut.core.FlushW;
  assign InstrValidM    = dut.core.ieu.InstrValidM;
  assign InstrRawD      = dut.core.ifu.InstrRawD;
  assign PCM            = dut.core.ifu.PCM;
  assign Mcycle         = dut.core.priv.priv.csr.counters.counters.HPMCOUNTER_REGW[0];
  assign Minstret       = dut.core.priv.priv.csr.counters.counters.HPMCOUNTER_REGW[2];
  assign TrapM          = dut.core.TrapM;
  assign PrivilegeModeW = dut.core.priv.priv.privmode.PrivilegeModeW;
  assign GPRAddr        = dut.core.ieu.dp.regf.a3;
  assign GPRWen         = dut.core.ieu.dp.regf.we3;
  assign GPRValue       = dut.core.ieu.dp.regf.wd3;
  assign FPRAddr        = dut.core.fpu.fpu.fregfile.a4;
  assign FPRWen         = dut.core.fpu.fpu.fregfile.we4;
  assign FPRValue       = dut.core.fpu.fpu.fregfile.wd4;

  assign CSRArray[0] = dut.core.priv.priv.csr.csrm.MSTATUS_REGW; // 12'h300
  assign CSRArray[1] = dut.core.priv.priv.csr.csrm.MSTATUSH_REGW; // 12'h310
  assign CSRArray[2] = dut.core.priv.priv.csr.csrm.MTVEC_REGW; // 12'h305
  assign CSRArray[3] = dut.core.priv.priv.csr.csrm.MEPC_REGW; // 12'h341
  assign CSRArray[4] = dut.core.priv.priv.csr.csrm.MCOUNTEREN_REGW; // 12'h306
  assign CSRArray[5] = dut.core.priv.priv.csr.csrm.MCOUNTINHIBIT_REGW; // 12'h320
  assign CSRArray[6] = dut.core.priv.priv.csr.csrm.MEDELEG_REGW; // 12'h302
  assign CSRArray[7] = dut.core.priv.priv.csr.csrm.MIDELEG_REGW; // 12'h303
  assign CSRArray[8] = dut.core.priv.priv.csr.csrm.MIP_REGW; // 12'h344
  assign CSRArray[9] = dut.core.priv.priv.csr.csrm.MIE_REGW; // 12'h304
  assign CSRArray[10] = dut.core.priv.priv.csr.csrm.MISA_REGW; // 12'h301
  assign CSRArray[11] = dut.core.priv.priv.csr.csrm.MENVCFG_REGW; // 12'h30A
  assign CSRArray[12] = dut.core.priv.priv.csr.csrm.MHARTID_REGW; // 12'hF14
  assign CSRArray[13] = dut.core.priv.priv.csr.csrm.MSCRATCH_REGW; // 12'h340
  assign CSRArray[14] = dut.core.priv.priv.csr.csrm.MCAUSE_REGW; // 12'h342
  assign CSRArray[15] = dut.core.priv.priv.csr.csrm.MTVAL_REGW; // 12'h343
  assign CSRArray[16] = 0; // 12'hF11
  assign CSRArray[17] = 0; // 12'hF12
  assign CSRArray[18] = {{P.XLEN-12{1'b0}}, 12'h100}; //P.XLEN'h100; // 12'hF13
  assign CSRArray[19] = 0; // 12'hF15
  assign CSRArray[20] = 0; // 12'h34A
  // supervisor CSRs
  assign CSRArray[21] = dut.core.priv.priv.csr.csrs.csrs.SSTATUS_REGW; // 12'h100
  assign CSRArray[22] = dut.core.priv.priv.csr.csrm.MIE_REGW & 12'h222; // 12'h104
  assign CSRArray[23] = dut.core.priv.priv.csr.csrs.csrs.STVEC_REGW; // 12'h105
  assign CSRArray[24] = dut.core.priv.priv.csr.csrs.csrs.SEPC_REGW; // 12'h141
  assign CSRArray[25] = dut.core.priv.priv.csr.csrs.csrs.SCOUNTEREN_REGW; // 12'h106
  assign CSRArray[26] = dut.core.priv.priv.csr.csrs.csrs.SENVCFG_REGW; // 12'h10A
  assign CSRArray[27] = dut.core.priv.priv.csr.csrs.csrs.SATP_REGW; // 12'h180
  assign CSRArray[28] = dut.core.priv.priv.csr.csrs.csrs.SSCRATCH_REGW; // 12'h140
  assign CSRArray[29] = dut.core.priv.priv.csr.csrs.csrs.STVAL_REGW; // 12'h143
  assign CSRArray[30] = dut.core.priv.priv.csr.csrs.csrs.SCAUSE_REGW; // 12'h142
  assign CSRArray[31] = dut.core.priv.priv.csr.csrm.MIP_REGW & 12'h222 & dut.core.priv.priv.csr.csrm.MIDELEG_REGW; // 12'h144
  assign CSRArray[32] = dut.core.priv.priv.csr.csrs.csrs.STIMECMP_REGW; // 12'h14D
  // user CSRs
  assign CSRArray[33] = dut.core.priv.priv.csr.csru.csru.FFLAGS_REGW; // 12'h001
  assign CSRArray[34] = dut.core.priv.priv.csr.csru.csru.FRM_REGW; // 12'h002
  assign CSRArray[35] = {dut.core.priv.priv.csr.csru.csru.FRM_REGW, dut.core.priv.priv.csr.csru.csru.FFLAGS_REGW}; // 12'h003

    acev #(P, MAX_CSRS, TOTAL_CSRS, RVVI_INIT_TIME_OUT, RVVI_PACKET_DELAY, ETH_WIDTH, "GENERIC") acev(.clk, .reset, .StallE, .StallM, .StallW, .FlushE, .FlushM, .FlushW,
      .PCM, .InstrValidM, .InstrRawD, .Mcycle, .Minstret, .TrapM, 
      .PrivilegeModeW, .GPRWen, .FPRWen, .GPRAddr, .FPRAddr, .GPRValue, .FPRValue, .CSRArray,
      .phy_rx_clk,
      .phy_rxd,
      .phy_rx_rst,
      .phy_tx_rst,
      .phy_rx_dv,
      .phy_rx_er,
      .phy_tx_clk,
      .phy_rx_clk_en, // not present for mii
      .phy_tx_clk_en, // not present for mii
      .phy_txd,
      .phy_tx_en,
      .phy_tx_er,
      .ExternalStall, .IlaTrigger);

  flopr #(1) txedgereg(clk, reset, mii_tx_en, MiiTxEnDelay);
  assign EthernetTXCounterEn = ~mii_tx_en & MiiTxEnDelay;
  counter #(32) ethernexttxcounter(clk, reset, EthernetTXCounterEn, EthernetTXCount);


  // receive the rvvi packets from acev. Remove instruction's data except for Minstret. Then add 32-bit kind of random value which represents the load on the host computer.
  // Finally drop some frames.

    // axi 4 write data channel

  if (ETH_WIDTH == 8) begin : eth
    // this is the version of 1g/s ethernet
    eth_mac_1g_fifo #( .AXIS_DATA_WIDTH(32), .TX_FIFO_DEPTH(1024), .RX_FIFO_DEPTH(1024)) 
    ethernet(.logic_clk(clk), .logic_rst(reset),
             .tx_axis_tdata(RvviAxiWdata), .tx_axis_tkeep(RvviAxiWstrb), .tx_axis_tvalid(RvviAxiWvalid), .tx_axis_tready(RvviAxiWready),
             .tx_axis_tlast(RvviAxiWlast), .tx_axis_tuser('0), .rx_axis_tdata(RvviAxiRdata),
             .rx_axis_tkeep(RvviAxiRstrb), .rx_axis_tvalid(RvviAxiRvalid), .rx_axis_tready(1'b1),
             .rx_axis_tlast(RvviAxiRlast), .rx_axis_tuser(),
             .rx_clk(phy_tx_clk), .rx_rst(phy_tx_rst), .tx_clk(phy_rx_clk), .tx_rst(phy_rx_rst),
             .gmii_rxd(phy_txd),
             .gmii_rx_dv(phy_tx_en),
             .gmii_rx_er(phy_tx_er),
             .gmii_txd(phy_rxd),
             .gmii_tx_en(phy_rx_dv),
             .gmii_tx_er(phy_rx_er),
             .rx_clk_enable(phy_tx_clk_en), 
             .tx_clk_enable(phy_rx_clk_en), 
             .rx_mii_select(1'b0),
             .tx_mii_select(1'b0),
             // status
             .tx_error_underflow(), .tx_fifo_overflow(), .tx_fifo_bad_frame(), .tx_fifo_good_frame(), .rx_error_bad_frame(),
             .rx_error_bad_fcs(), .rx_fifo_overflow(), .rx_fifo_bad_frame(), .rx_fifo_good_frame(), 
             .cfg_ifg(8'd12), .cfg_tx_enable(1'b1), .cfg_rx_enable(1'b1)
             );
    end else if (ETH_WIDTH == 4) begin : eth

      // 10/100 Mb/s ethernet
      eth_mac_mii_fifo #(.TARGET("GENERIC"), .CLOCK_INPUT_STYLE("BUFG"), .AXIS_DATA_WIDTH(32), .TX_FIFO_DEPTH(1024), .RX_FIFO_DEPTH(1024)) 
      ethernet(.rst(reset), .logic_clk(clk), .logic_rst(reset),
               .tx_axis_tdata(RvviAxiWdata), .tx_axis_tkeep(RvviAxiWstrb), .tx_axis_tvalid(RvviAxiWvalid), .tx_axis_tready(RvviAxiWready),
               .tx_axis_tlast(RvviAxiWlast), .tx_axis_tuser('0), .rx_axis_tdata(RvviAxiRdata),
               .rx_axis_tkeep(RvviAxiRstrb), .rx_axis_tvalid(RvviAxiRvalid), .rx_axis_tready(1'b1),
               .rx_axis_tlast(RvviAxiRlast), .rx_axis_tuser(),
               .mii_rx_clk(phy_tx_clk),
               .mii_rxd(phy_txd),
               .mii_rx_dv(phy_tx_en),
               .mii_rx_er(phy_tx_er),
               .mii_tx_clk(phy_rx_clk),
               .mii_txd(phy_rxd),
               .mii_tx_en(phy_rx_dv),
               .mii_tx_er(phy_rx_er),
               // status
               .tx_error_underflow(), .tx_fifo_overflow(), .tx_fifo_bad_frame(), .tx_fifo_good_frame(), .rx_error_bad_frame(),
               .rx_error_bad_fcs(), .rx_fifo_overflow(), .rx_fifo_bad_frame(), .rx_fifo_good_frame(), 
               .cfg_ifg(8'd12), .cfg_tx_enable(1'b1), .cfg_rx_enable(1'b1)
               );
    end

  typedef enum {STATE_IDLE, STATE_CAPTURE, STATE_CAPTURE_DONE, STATE_DONE} RecvStateType;
  RecvStateType RecvCurrState, RecvNextState;
  
  logic        RecvCounterEn, RecvCounterReset;
  logic [3:0]  RecvCounter;
  logic [31:0] mem [11:0];
  logic        RecvDone;
  

  always_ff @(posedge clk)
    if (reset) RecvCurrState <= STATE_IDLE;
    else RecvCurrState <= RecvNextState;

  always_comb begin
    case(RecvCurrState)
      STATE_IDLE: if(RvviAxiRvalid) RecvNextState = STATE_CAPTURE;
      else RecvNextState = STATE_IDLE;
      STATE_CAPTURE: if(RecvDone) RecvNextState = STATE_CAPTURE_DONE;
      else RecvNextState = STATE_CAPTURE;
      STATE_CAPTURE_DONE: if(RvviAxiRlast) RecvNextState = STATE_DONE;
      else RecvNextState = STATE_CAPTURE_DONE;
      STATE_DONE: if(RvviAxiRvalid) RecvNextState = STATE_CAPTURE;
      else RecvNextState = STATE_IDLE;
      default: RecvNextState = STATE_IDLE;
    endcase
  end

  assign RecvCounterEn = RvviAxiRvalid & RecvCurrState != STATE_CAPTURE_DONE;
  assign RecvCounterReset = (RecvCurrState == STATE_IDLE | RecvCurrState == STATE_DONE) & ~RvviAxiRvalid;
  counter #(4) recvcounterreg(clk, RecvCounterReset, RecvCounterEn, RecvCounter);
  assign RecvDone = RecvCounter == 4'd11 & RvviAxiRvalid;
  
  always_ff @(posedge clk) begin
    if(RecvCounterEn) begin
      mem[RecvCounter] <= RvviAxiRdata;
    end
  end

  // now that the frame is captured send it back with the random 32-bit system load estimation

  typedef enum {STATE_RDY, STATE_TRANS, STATE_WAIT, STATE_FINISHED} TransStateType;
  TransStateType TransCurrState, TransNextState;

  logic        TransCounterEn, TransCounterReset;
  logic [2:0]  TransCounter;
  logic [31:0] TransMem [6:0];
  logic        TransCounterThreshold;

  always_ff @(posedge clk)
    if (reset) TransCurrState <= STATE_RDY;
    else TransCurrState <= TransNextState;

  always_comb begin
    case(TransCurrState)
      STATE_RDY: if(RecvDone & RvviAxiWready) TransNextState = STATE_TRANS;
      else if(RecvDone & ~RvviAxiWready) TransNextState = STATE_WAIT;
      else TransNextState = STATE_RDY;
      STATE_WAIT: if(RvviAxiWready) TransNextState = STATE_TRANS;
      else TransNextState = STATE_WAIT;
      STATE_TRANS: if (TransCounterThreshold & RvviAxiWready) TransNextState = STATE_FINISHED;
      else TransNextState = STATE_TRANS;
      STATE_FINISHED: TransNextState = STATE_RDY;
      default: TransNextState = STATE_RDY;
    endcase
  end

  assign TransCounterThreshold = TransCounter == 3'd6;
  assign TransCounterEn = RvviAxiWready & TransCurrState == STATE_TRANS;
  assign TransCounterReset = TransCurrState == STATE_RDY;
  counter #(3) transcounterreg(clk, TransCounterReset, TransCounterEn, TransCounter);
  assign TransMem[0] = mem[0];
  assign TransMem[1] = mem[1];
  assign TransMem[2] = mem[2];
  //assign TransMem[3] = mem[3];
  assign TransMem[3][15:0] = mem[3][15:0];
  assign TransMem[3][31:16] = mem[8][31:16];
  assign TransMem[4] = mem[9];
  assign TransMem[5][15:0] = mem[10][15:0];
  assign TransMem[5][31:16] = 16'b1;// 32-bit system load lower bits
  assign TransMem[6][15:0] = '0; // 32-bit system load  uppwer bits 
  assign TransMem[6][31:16] = '0;

  assign RvviAxiWdata = TransMem[TransCounter];
  assign RvviAxiWstrb = '1;
  assign RvviAxiWlast = TransCounterThreshold & TransCurrState == STATE_TRANS;
  assign RvviAxiWvalid = TransCurrState == STATE_TRANS;
    
endmodule  



