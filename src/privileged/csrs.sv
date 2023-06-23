///////////////////////////////////////////
// csrs.sv
//
// Written: David_Harris@hmc.edu 9 January 2021
// Modified: 
//          dottolia@hmc.edu 3 May 2021 - fix bug with stvec getting wrong value
//
// Purpose: Supervisor-Mode Control and Status Registers
//          See RISC-V Privileged Mode Specification 20190608 
//
// Documentation: RISC-V System on Chip Design Chapter 5
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

`include "wally-config.vh"

module csrs #(parameter 
  // Supervisor CSRs
  SSTATUS = 12'h100,
  SIE = 12'h104,
  STVEC = 12'h105,
  SCOUNTEREN = 12'h106,
  SSCRATCH = 12'h140,
  SEPC = 12'h141,
  SCAUSE = 12'h142,
  STVAL = 12'h143,
  SIP= 12'h144,
  STIMECMP = 12'h14D,
  STIMECMPH = 12'h15D,
  SATP = 12'h180) (
  input  logic             clk, reset, 
  input  logic             CSRSWriteM, STrapM,
  input  logic [11:0]      CSRAdrM,
  input  logic [`XLEN-1:0] NextEPCM, NextMtvalM, SSTATUS_REGW, 
  input  logic [4:0]       NextCauseM,
  input  logic             STATUS_TVM,
  input  logic             MCOUNTEREN_TM, // TM bit (1) of MCOUNTEREN; cause illegal instruction when trying to access STIMECMP if clear
  input  logic [`XLEN-1:0] CSRWriteValM,
  input  logic [1:0]       PrivilegeModeW,
  output logic [`XLEN-1:0] CSRSReadValM, STVEC_REGW,
  output logic [`XLEN-1:0] SEPC_REGW,      
  output logic [31:0]      SCOUNTEREN_REGW, 
  output logic [`XLEN-1:0] SATP_REGW,
  input  logic [11:0]      MIP_REGW, MIE_REGW, MIDELEG_REGW,
  input  logic [63:0]      MTIME_CLINT,
  input  logic              MENVCFG_STCE,
  output logic             WriteSSTATUSM,
  output logic             IllegalCSRSAccessM,
  output logic             STimerInt
);

  // Constants
  localparam ZERO = {(`XLEN){1'b0}};
  localparam SEDELEG_MASK = ~(ZERO | `XLEN'b111 << 9);

  logic                    WriteSTVECM;
  logic                    WriteSSCRATCHM, WriteSEPCM;
  logic                    WriteSCAUSEM, WriteSTVALM, WriteSATPM, WriteSCOUNTERENM;
  logic                    WriteSTIMECMPM, WriteSTIMECMPHM;
  logic                    WriteSENVCFGM;

  logic [`XLEN-1:0]       SSCRATCH_REGW, STVAL_REGW, SCAUSE_REGW;
  logic [`XLEN-1:0]       SENVCFG_REGW;
  logic [`XLEN-1:0]       SENVCFG_WriteValM;

  logic [63:0]             STIMECMP_REGW;
  
  // write enables
  assign WriteSSTATUSM = CSRSWriteM & (CSRAdrM == SSTATUS);
  assign WriteSTVECM = CSRSWriteM & (CSRAdrM == STVEC);
  assign WriteSSCRATCHM = CSRSWriteM & (CSRAdrM == SSCRATCH);
  assign WriteSEPCM = STrapM | (CSRSWriteM & (CSRAdrM == SEPC));
  assign WriteSCAUSEM = STrapM | (CSRSWriteM & (CSRAdrM == SCAUSE));
  assign WriteSTVALM = STrapM | (CSRSWriteM & (CSRAdrM == STVAL));
  assign WriteSATPM = CSRSWriteM & (CSRAdrM == SATP) & (PrivilegeModeW == `M_MODE | ~STATUS_TVM);
  assign WriteSCOUNTERENM = CSRSWriteM & (CSRAdrM == SCOUNTEREN);
  assign WriteSENVCFGM    = CSRSWriteM & (CSRAdrM == SENVCFG);
  assign WriteSTIMECMPM   = CSRSWriteM & (CSRAdrM == STIMECMP) & (PrivilegeModeW == `M_MODE | (MCOUNTEREN_TM & MENVCFG_STCE));
  assign WriteSTIMECMPHM  = CSRSWriteM & (CSRAdrM == STIMECMPH) & (PrivilegeModeW == `M_MODE | (MCOUNTEREN_TM & MENVCFG_STCE)) & (`XLEN == 32);

  // CSRs
  flopenr #(`XLEN) STVECreg(clk, reset, WriteSTVECM, {CSRWriteValM[`XLEN-1:2], 1'b0, CSRWriteValM[0]}, STVEC_REGW); 
  flopenr #(`XLEN) SSCRATCHreg(clk, reset, WriteSSCRATCHM, CSRWriteValM, SSCRATCH_REGW);
  flopenr #(`XLEN) SEPCreg(clk, reset, WriteSEPCM, NextEPCM, SEPC_REGW); 
  flopenr #(`XLEN) SCAUSEreg(clk, reset, WriteSCAUSEM, {NextCauseM[4], {(`XLEN-5){1'b0}}, NextCauseM[3:0]}, SCAUSE_REGW);
  flopenr #(`XLEN) STVALreg(clk, reset, WriteSTVALM, NextMtvalM, STVAL_REGW);
  if (`VIRTMEM_SUPPORTED)
    flopenr #(`XLEN) SATPreg(clk, reset, WriteSATPM, CSRWriteValM, SATP_REGW);
  else
    assign SATP_REGW = 0; // hardwire to zero if virtual memory not supported
  flopenr #(32)   SCOUNTERENreg(clk, reset, WriteSCOUNTERENM, CSRWriteValM[31:0], SCOUNTEREN_REGW);
  if (`SSTC_SUPPORTED) begin : sstc
    if (`XLEN == 64) begin : sstc64
      flopenl #(`XLEN) STIMECMPreg(clk, reset, WriteSTIMECMPM, CSRWriteValM, 64'hFFFFFFFFFFFFFFFF, STIMECMP_REGW);
    end else begin : sstc32
      flopenl #(`XLEN) STIMECMPreg(clk, reset, WriteSTIMECMPM, CSRWriteValM, 32'hFFFFFFFF, STIMECMP_REGW[31:0]);
      flopenl #(`XLEN) STIMECMPHreg(clk, reset, WriteSTIMECMPHM, CSRWriteValM, 32'hFFFFFFFF, STIMECMP_REGW[63:32]);
    end
  end else assign STIMECMP_REGW = 0;

  // Supervisor timer interrupt logic
  // Spec is a bit peculiar - Machine timer interrupts are produced in CLINT, while Supervisor timer interrupts are in CSRs
  if (`SSTC_SUPPORTED)
   assign STimerInt  = ({1'b0, MTIME_CLINT} >= {1'b0, STIMECMP_REGW}); // unsigned comparison
  else 
    assign STimerInt = 0;

  assign SENVCFG_WriteValM = {
    {(P.XLEN-8){1'b0}},
    CSRWriteValM[7]   & P.ZICBOZ_SUPPORTED,
    CSRWriteValM[6:4] & {3{P.ZICBOM_SUPPORTED}},
    3'b0,
    CSRWriteValM[0]   & P.S_SUPPORTED & P.VIRTMEM_SUPPORTED
  };

  flopenr #(P.XLEN) SENVCFGreg(clk, reset, WriteSENVCFGM, SENVCFG_WriteValM, SENVCFG_REGW);

  // Extract bit fields
  // Uncomment these other fields when they are defined
  // assign SENVCFG_PBMTE = SENVCFG_REGW[62];
  // assign SENVCFG_CBZE  =  SENVCFG_REGW[7];
  // assign SENVCFG_CBCFE = SENVCFG_REGW[6];
  // assign SENVCFG_CBIE  =  SENVCFG_REGW[5:4];
  // assign SENVCFG_FIOM  =  SENVCFG_REGW[0];
    
  // CSR Reads
  always_comb begin:csrr
    IllegalCSRSAccessM = 0;
    case (CSRAdrM) 
      SSTATUS:   CSRSReadValM = SSTATUS_REGW;
      STVEC:     CSRSReadValM = STVEC_REGW;
      SIP:       CSRSReadValM = {{(`XLEN-12){1'b0}}, MIP_REGW & 12'h222 & MIDELEG_REGW}; // only read supervisor fields  
      SIE:       CSRSReadValM = {{(`XLEN-12){1'b0}}, MIE_REGW & 12'h222 & MIDELEG_REGW}; // only read supervisor fields
      SSCRATCH:  CSRSReadValM = SSCRATCH_REGW;
      SEPC:      CSRSReadValM = SEPC_REGW;
      SCAUSE:    CSRSReadValM = SCAUSE_REGW;
      STVAL:     CSRSReadValM = STVAL_REGW;
      SATP:      if (`VIRTMEM_SUPPORTED & (PrivilegeModeW == `M_MODE | ~STATUS_TVM)) CSRSReadValM = SATP_REGW;
                 else begin
                   CSRSReadValM = 0;
                   IllegalCSRSAccessM = 1;
                 end
      SCOUNTEREN:CSRSReadValM = {{(P.XLEN-32){1'b0}}, SCOUNTEREN_REGW};
      SENVCFG:   CSRSReadValM = SENVCFG_REGW;
      STIMECMP:  if (`SSTC_SUPPORTED & (PrivilegeModeW == `M_MODE | (MCOUNTEREN_TM && MENVCFG_STCE))) 
                   CSRSReadValM = STIMECMP_REGW[`XLEN-1:0]; 
                 else begin 
                   CSRSReadValM = 0;
                   IllegalCSRSAccessM = 1;
                 end
      STIMECMPH: if (`SSTC_SUPPORTED & (`XLEN == 32) & (PrivilegeModeW == `M_MODE | (MCOUNTEREN_TM && MENVCFG_STCE))) 
                   CSRSReadValM[31:0] = STIMECMP_REGW[63:32];
                 else begin // not supported for RV64
                   CSRSReadValM = 0;
                   IllegalCSRSAccessM = 1;
                 end
      default: begin
                  CSRSReadValM = 0; 
                  IllegalCSRSAccessM = 1;  
               end       
    endcase
  end
endmodule
