///////////////////////////////////////////
// bpred.sv
//
// Written: Ross Thomposn ross1728@gmail.com
// Created: 12 February 2021
// Modified: 19 January 2023
//
// Purpose: Branch direction prediction and jump/branch target prediction.
//          Prediction made during the fetch stage and corrected in the execution stage.
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

`define INSTR_CLASS_PRED 1

module bpred (
  input  logic             clk, reset,
  input  logic             StallF, StallD, StallE, StallM, StallW,
  input  logic             FlushD, FlushE, FlushM, FlushW,
  // Fetch stage
  // the prediction
  input  logic [31:0]      InstrD,                    // Decompressed decode stage instruction. Used to decode instruction class
  input  logic [`XLEN-1:0] PCNextF,                   // Next Fetch Address
  input  logic [`XLEN-1:0] PCPlus2or4F,               // PCF+2/4
  output logic [`XLEN-1:0] PC1NextF,                  // Branch Predictor predicted or corrected fetch address on miss prediction
  output logic [`XLEN-1:0] NextValidPCE,              // Address of next valid instruction after the instruction in the Memory stage

  // Update Predictor
  input  logic [`XLEN-1:0] PCF,                       // Fetch stage instruction address
  input  logic [`XLEN-1:0] PCD,                       // Decode stage instruction address. Also the address the branch predictor took
  input  logic [`XLEN-1:0] PCE,                       // Execution stage instruction address
  input  logic [`XLEN-1:0] PCM,                       // Memory stage instruction address

  input  logic [31:0]      PostSpillInstrRawF,        // Instruction

  // Branch and jump outcome
  input  logic             InstrValidD, InstrValidE,
  input  logic             BranchD, BranchE,
  input  logic             JumpD, JumpE,
  input  logic             PCSrcE,                    // Executation stage branch is taken
  input  logic [`XLEN-1:0] IEUAdrE,                   // The branch/jump target address
  input  logic [`XLEN-1:0] IEUAdrM,                   // The branch/jump target address
  input  logic [`XLEN-1:0] PCLinkE,                   // The address following the branch instruction. (AKA Fall through address)
  output logic [3:0]       InstrClassM,               // The valid instruction class. 1-hot encoded as call, return, jr (not return), j, br

  // Report branch prediction status
  output logic             BPWrongE,                  // Prediction is wrong
  output logic             BPWrongM,                  // Prediction is wrong
  output logic             BPDirPredWrongM,           // Prediction direction is wrong
  output logic             BTAWrongM,                 // Prediction target wrong
  output logic             RASPredPCWrongM,           // RAS prediction is wrong
  output logic             IClassWrongM               // Class prediction is wrong
  );

  logic [1:0]              BPDirPredF;

  logic [`XLEN-1:0]        BPBTAF, RASPCF;
  logic                    BPPCWrongE;
  logic                    IClassWrongE;
  logic                    BPDirPredWrongE;
  
  logic                    BPPCSrcF;
  logic [`XLEN-1:0]        BPPCF;
  logic [`XLEN-1:0]        PC0NextF;
  logic [`XLEN-1:0]        PCCorrectE;
  logic [3:0]              WrongPredInstrClassD;

  logic                    BTBTargetWrongE;
  logic                    RASTargetWrongE;

  logic [`XLEN-1:0]        BPBTAD;

  logic                    BTBCallF, BTBReturnF, BTBJumpF, BTBBranchF;
  logic                    BPBranchF, BPJumpF, BPReturnF, BPCallF;
  logic                    BPBranchD, BPJumpD, BPReturnD, BPCallD;
  logic                    ReturnD, CallD;
  logic                    ReturnE, CallE;
  logic                    BranchM, JumpM, ReturnM, CallM;
  logic                    BranchW, JumpW, ReturnW, CallW;
  logic                    BPReturnWrongD;
  logic [`XLEN-1:0]        BPBTAE;
  
  // Part 1 branch direction prediction
  // look into the 2 port Sram model. something is wrong. 
  if (`BPRED_TYPE == "BP_TWOBIT") begin:Predictor
    twoBitPredictor #(`BPRED_SIZE) DirPredictor(.clk, .reset, .StallF, .StallD, .StallE, .StallM, .StallW, 
      .FlushD, .FlushE, .FlushM, .FlushW,
      .PCNextF, .PCM, .BPDirPredF, .BPDirPredWrongE,
      .BranchE, .BranchM, .PCSrcE);

  end else if (`BPRED_TYPE == "BP_GSHARE") begin:Predictor
    gshare #(`BPRED_SIZE) DirPredictor(.clk, .reset, .StallF, .StallD, .StallE, .StallM, .StallW, .FlushD, .FlushE, .FlushM, .FlushW,
      .PCNextF, .PCF, .PCD, .PCE, .PCM, .BPDirPredF, .BPDirPredWrongE,
      .BPBranchF, .BranchD, .BranchE, .BranchM, .BranchW, 
      .PCSrcE);

  end else if (`BPRED_TYPE == "BP_GLOBAL") begin:Predictor
    gshare #(`BPRED_SIZE, 0) DirPredictor(.clk, .reset, .StallF, .StallD, .StallE, .StallM, .StallW, .FlushD, .FlushE, .FlushM, .FlushW,
      .PCNextF, .PCF, .PCD, .PCE, .PCM, .BPDirPredF, .BPDirPredWrongE,
      .BPBranchF, .BranchD, .BranchE, .BranchM, .BranchW,
      .PCSrcE);

  end else if (`BPRED_TYPE == "BP_GSHARE_BASIC") begin:Predictor
    gsharebasic #(`BPRED_SIZE) DirPredictor(.clk, .reset, .StallF, .StallD, .StallE, .StallM, .StallW, .FlushD, .FlushE, .FlushM, .FlushW,
      .PCNextF, .PCM, .BPDirPredF, .BPDirPredWrongE,
      .BranchE, .BranchM, .PCSrcE);

  end else if (`BPRED_TYPE == "BP_GLOBAL_BASIC") begin:Predictor
    gsharebasic #(`BPRED_SIZE, 0) DirPredictor(.clk, .reset, .StallF, .StallD, .StallE, .StallM, .StallW, .FlushD, .FlushE, .FlushM, .FlushW,
      .PCNextF, .PCM, .BPDirPredF, .BPDirPredWrongE,
      .BranchE, .BranchM, .PCSrcE);
  
  end else if (`BPRED_TYPE == "BP_LOCAL_BASIC") begin:Predictor
    localbpbasic #(`BPRED_NUM_LHR, `BPRED_SIZE) DirPredictor(.clk, .reset, 
      .StallF, .StallD, .StallE, .StallM, .StallW, .FlushD, .FlushE, .FlushM, .FlushW,
      .PCNextF, .PCM, .BPDirPredF, .BPDirPredWrongE,
      .BranchE, .BranchM, .PCSrcE);
  end else if (`BPRED_TYPE == "BP_LOCAL_AHEAD") begin:Predictor
    localaheadbp #(`BPRED_NUM_LHR, `BPRED_SIZE) DirPredictor(.clk, .reset, 
      .StallF, .StallD, .StallE, .StallM, .StallW, .FlushD, .FlushE, .FlushM, .FlushW,
      .PCNextF, .PCM, .BPDirPredD(BPDirPredF), .BPDirPredWrongE,
      .BranchE, .BranchM, .PCSrcE);
  end else if (`BPRED_TYPE == "BP_LOCAL_REPAIR") begin:Predictor
    localrepairbp #(`BPRED_NUM_LHR, `BPRED_SIZE) DirPredictor(.clk, .reset, 
      .StallF, .StallD, .StallE, .StallM, .StallW, .FlushD, .FlushE, .FlushM, .FlushW,
      .PCNextF, .PCE, .PCM, .BPDirPredD(BPDirPredF), .BPDirPredWrongE,
      .BranchD, .BranchE, .BranchM, .PCSrcE);
  end 

  // Part 2 Branch target address prediction
  // BTB contains target address for all CFI

  btb #(`BTB_SIZE) 
    TargetPredictor(.clk, .reset, .StallF, .StallD, .StallE, .StallM, .StallW, .FlushD, .FlushE, .FlushM, .FlushW,
      .PCNextF, .PCF, .PCD, .PCE, .PCM,
      .BPBTAF, .BPBTAD, .BPBTAE,
      .BTBIClassF({BTBCallF, BTBReturnF, BTBJumpF, BTBBranchF}),
      .IClassWrongM, .IClassWrongE,
      .IEUAdrE, .IEUAdrM,
      .InstrClassD({CallD, ReturnD, JumpD, BranchD}), 
      .InstrClassE({CallE, ReturnE, JumpE, BranchE}), 
      .InstrClassM({CallM, ReturnM, JumpM, BranchM}),
      .InstrClassW({CallW, ReturnW, JumpW, BranchW}));

  icpred #(`INSTR_CLASS_PRED) icpred(.clk, .reset, .StallF, .StallD, .StallE, .StallM, .StallW, .FlushD, .FlushE, .FlushM, .FlushW,
    .PostSpillInstrRawF, .InstrD, .BranchD, .BranchE, .JumpD, .JumpE, .BranchM, .BranchW, .JumpM, .JumpW,
    .CallD, .CallE, .CallM, .CallW, .ReturnD, .ReturnE, .ReturnM, .ReturnW, .BTBCallF, .BTBReturnF, .BTBJumpF,
    .BTBBranchF, .BPCallF, .BPReturnF, .BPJumpF, .BPBranchF, .IClassWrongM, .IClassWrongE, .BPReturnWrongD);

  // Part 3 RAS
  RASPredictor RASPredictor(.clk, .reset, .StallF, .StallD, .StallE, .StallM, .FlushD, .FlushE, .FlushM,
    .BPReturnF, .ReturnD, .ReturnE, .CallE,
    .BPReturnWrongD, .RASPCF, .PCLinkE);

  // Check the prediction
  // if it is a CFI then check if the next instruction address (PCD) matches the branch's target or fallthrough address.
  // if the class prediction is wrong a regular instruction may have been predicted as a taken branch
  // this will result in PCD not being equal to the fall through address PCLinkE (PCE+4).
  // The next instruction is always valid as no other flush would occur at the same time as the branch and not
  // also flush the branch.  This will change in a superscaler cpu. 
  // branch is wrong only if the PC does not match and both the Decode and Fetch stages have valid instructions.
  assign BPWrongE = (PCCorrectE != PCD) & InstrValidE & InstrValidD;
  flopenrc #(1) BPWrongMReg(clk, reset, FlushM, ~StallM, BPWrongE, BPWrongM);
  
  // Output the predicted PC or corrected PC on miss-predict.
  assign BPPCSrcF = (BPBranchF & BPDirPredF[1]) | BPJumpF;
  mux2 #(`XLEN) pcmuxbp(BPBTAF, RASPCF, BPReturnF, BPPCF);
  // Selects the BP or PC+2/4.
  mux2 #(`XLEN) pcmux0(PCPlus2or4F, BPPCF, BPPCSrcF, PC0NextF);
  // If the prediction is wrong select the correct address.
  mux2 #(`XLEN) pcmux1(PC0NextF, PCCorrectE, BPWrongE, PC1NextF);  
  // Correct branch/jump target.
  mux2 #(`XLEN) pccorrectemux(PCLinkE, IEUAdrE, PCSrcE, PCCorrectE);
  
  // If the fence/csrw was predicted as a taken branch then we select PCF, rather than PCE.
  // Effectively this is PCM+4 or the non-existant PCLinkM
  if(`INSTR_CLASS_PRED) mux2 #(`XLEN) pcmuxBPWrongInvalidateFlush(PCE, PCF, BPWrongM, NextValidPCE);
  else  assign NextValidPCE = PCE;

  if(`ZICNTR_SUPPORTED) begin
    logic [`XLEN-1:0]       RASPCD, RASPCE;
    logic                   BTAWrongE, RASPredPCWrongE;  
    // performance counters
    // 1. class         (class wrong / minstret) (IClassWrongM / csr)                    // Correct now
    // 2. target btb    (btb target wrong / class[0,1,3])  (btb target wrong / (br + j + jal)
    // 3. target ras    (ras target wrong / class[2])
    // 4. direction     (br dir wrong / class[0])

    // Unfortunately we can't use PCD to infer the correctness of the BTB or RAS because the class prediction 
    // could be wrong or the fall through address selected for branch predict not taken.
    // By pipeline the BTB's PC and RAS address through the pipeline we can measure the accuracy of
    // both without the above inaccuracies.
    // **** use BPBTAWrongM from BTB.
    assign BTAWrongE = (BPBTAE != IEUAdrE) & (BranchE | JumpE & ~ReturnE) & PCSrcE;
    assign RASPredPCWrongE = (RASPCE != IEUAdrE) & ReturnE & PCSrcE;

    flopenrc #(`XLEN) RASTargetDReg(clk, reset, FlushD, ~StallD, RASPCF, RASPCD);
    flopenrc #(`XLEN) RASTargetEReg(clk, reset, FlushE, ~StallE, RASPCD, RASPCE);
    flopenrc #(3) BPPredWrongRegM(clk, reset, FlushM, ~StallM, 
      {BPDirPredWrongE, BTAWrongE, RASPredPCWrongE},
      {BPDirPredWrongM, BTAWrongM, RASPredPCWrongM});
    
  end else begin
    assign {BTAWrongM, RASPredPCWrongM} = '0;
  end

  // **** Fix me
  assign InstrClassM = {CallM, ReturnM, JumpM, BranchM};
  
endmodule
