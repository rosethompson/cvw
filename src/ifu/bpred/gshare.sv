///////////////////////////////////////////
// gshare.sv
//
// Written:  Rose Thompson rose@rosethompson.net, Shreya Sanghai ssanghai@hmc.edu 16 March 2021
// Modified:
//
// Purpose: Gshare / global-history direction predictor.
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwfoundation/cvw
//
// Copyright (C) 2021-26 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
////////////////////////////////////////////////////////////////////////////////////////////////


module gshare import cvw::*; #(parameter cvw_t P,
                               parameter XLEN,
                               parameter k = 10,
                               parameter integer TYPE = 1) (
  input  logic            clk,
  input  logic            reset,
  input  logic            StallF, StallD, StallE, StallM, StallW,
  input  logic            FlushD, FlushE, FlushM, FlushW,
  output logic [1:0]      BPDirF,
  output logic            BPDirWrongE,
  // update
  input  logic [XLEN-1:0] PCNextF, PCF, PCD, PCE, PCM,
  input  logic            BPBranchF, BranchD, BranchE, BranchM, BranchW, PCSrcE
);

  logic                   MatchD, MatchE, MatchM, MatchW;
  logic                   MatchX;

  logic [1:0]             PHTBPDirF, BPDirD, BPDirE, FwdNewBPDirF;
  logic [1:0]             NewBPDirE, NewBPDirM, NewBPDirW;

  logic [k-1:0]           IndexNextF, IndexF, IndexD, IndexE, IndexM, IndexW;

  logic [k-1:0]           GHRF, GHRD, GHRE, GHRM;
  logic [k-1:0]           GHRNextM, GHRNextF;
  logic                   PCSrcM;
  logic                   WriteGshareM;

  if (TYPE == 1) begin // gshare: index is global history XOR PC
    assign IndexNextF = GHRNextF ^ {PCNextF[k+1] ^ PCNextF[1], PCNextF[k:2]};
    assign IndexF = GHRF ^ {PCF[k+1] ^ PCF[1], PCF[k:2]};
    assign IndexD = GHRD ^ {PCD[k+1] ^ PCD[1], PCD[k:2]};
    assign IndexE = GHRE ^ {PCE[k+1] ^ PCE[1], PCE[k:2]};
    assign IndexM = GHRM ^ {PCM[k+1] ^ PCM[1], PCM[k:2]};
  end else if (TYPE == 0) begin // global: index is global history only
    assign IndexNextF = GHRNextF;
    assign IndexF = GHRF;
    assign IndexD = GHRD;
    assign IndexE = GHRE;
    assign IndexM = GHRM;
  end

  flopenrc #(k) IndexWReg(clk, reset, FlushW, ~StallW, IndexM, IndexW);

  assign MatchD = BranchD & ~FlushE & (IndexF == IndexD);
  assign MatchE = BranchE & ~FlushM & (IndexF == IndexE);
  assign MatchM = BranchM & ~FlushW & (IndexF == IndexM);
  assign MatchW = BranchW & ~FlushW & (IndexF == IndexW);
  assign MatchX = MatchD | MatchE | MatchM | MatchW;

  assign FwdNewBPDirF = MatchD ? {2{BPDirD[1]}} :
                        MatchE ? {NewBPDirE} :
                        MatchM ? {NewBPDirM} :
                        NewBPDirW;

  assign BPDirF = MatchX ? FwdNewBPDirF : PHTBPDirF;

  assign WriteGshareM = BranchM & ~NewBPDirSameM;

  if (P.ONE_PORT_BP_SRAM) begin
    logic WriteGshareW;
    logic [k-1:0] RAMIndex;
    logic [1:0]   PHTBPRawDirF;

    mux2 #(k) adrmux(IndexNextF, IndexM, WriteGshareM, RAMIndex);
    flopenrc #(1) gsharewrongwreg(clk, reset, FlushW, ~StallW, WriteGshareM, WriteGshareW);
    assign PHTBPDirF = WriteGshareW ? {1'b0, GHRF[0]} : PHTBPRawDirF; // *** not sure what the best prediction is when we don't predict

    ram1p1rwbe #(.USE_SRAM(P.USE_SRAM), .DEPTH(2**k), .WIDTH(2)) PHT(
      .clk(clk),
      .ce(~StallF | (~StallW & ~FlushW)),
      .addr(RAMIndex),
      .dout(PHTBPRawDirF),
      .din(NewBPDirM),
      .we(WriteGshareW),
      .bwe(1'b1));

  end else begin
    ram2p1r1wbe #(.USE_SRAM(P.USE_SRAM), .DEPTH(2**k), .WIDTH(2)) PHT(.clk(clk),
      .ce1(~StallF), .ce2(~StallW & ~FlushW),
      .ra1(IndexNextF),
      .rd1(PHTBPDirF),
      .wa2(IndexM),
      .wd2(NewBPDirM),
      .we2(WriteGshareM),
      .bwe2(1'b1));
  end

  flopenrc #(2) PredictionRegD(clk, reset, FlushD, ~StallD, BPDirF, BPDirD);
  flopenrc #(2) PredictionRegE(clk, reset, FlushE, ~StallE, BPDirD, BPDirE);

  satCounter2 BPDirUpdateE(.BrDir(PCSrcE), .OldState(BPDirE), .NewState(NewBPDirE));
  flopenrc #(2) NewPredictionRegM(clk, reset, FlushM, ~StallM, NewBPDirE, NewBPDirM);
  flopenrc #(2) NewPredictionRegW(clk, reset, FlushW, ~StallW, NewBPDirM, NewBPDirW);

  logic NewBPDirSameE, NewBPDirSameM;
  assign NewBPDirSameE = BPDirE == NewBPDirE;
  flopenrc #(1) NewPredSameRegM(clk, reset, FlushM, ~StallM, NewBPDirSameE, NewBPDirSameM);


  assign BPDirWrongE = PCSrcE != BPDirE[1] & BranchE;

  // Speculative global history: shift in the predicted direction of branches in F and D
  // and the resolved direction of branches in E and M
  assign GHRNextF = BPBranchF ? {BPDirF[1], GHRF[k-1:1]} : GHRF;
  assign GHRF = BranchD ? {BPDirD[1], GHRD[k-1:1]} : GHRD;
  assign GHRD = BranchE ? {PCSrcE, GHRE[k-1:1]} : GHRE;
  assign GHRE = BranchM ? {PCSrcM, GHRM[k-1:1]} : GHRM;

  assign GHRNextM = {PCSrcM, GHRM[k-1:1]};

  flopenr #(k) GHRReg(clk, reset, ~StallW & ~FlushW & BranchM, GHRNextM, GHRM);
  flopenrc #(1) PCSrcMReg(clk, reset, FlushM, ~StallM, PCSrcE, PCSrcM);

endmodule
