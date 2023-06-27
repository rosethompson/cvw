///////////////////////////////////////////
// controller.sv
//
// Written: David_Harris@hmc.edu, Sarah.Harris@unlv.edu, kekim@hmc.edu
// Created: 9 January 2021
// Modified: 3 March 2023
//
// Purpose: Top level controller module
// 
// Documentation: RISC-V System on Chip Design Chapter 4 (Section 4.1.4, Figure 4.8, Table 4.5)
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


module controller(
  input  logic        clk, reset,
  // Decode stage control signals
  input  logic        StallD, FlushD,          // Stall, flush Decode stage
  input  logic [31:0] InstrD,                  // Instruction in Decode stage
  output logic [2:0]  ImmSrcD,                 // Type of immediate extension
  input  logic        IllegalIEUFPUInstrD,     // Illegal IEU and FPU instruction
  output logic        IllegalBaseInstrD,       // Illegal I-type instruction, or illegal RV32 access to upper 16 registers
  output logic        JumpD,                   // Jump instruction
  output logic        BranchD,                 // Branch instruction
   // Execute stage control signals             
  input  logic        StallE, FlushE,          // Stall, flush Execute stage
  input  logic [1:0]  FlagsE,                  // Comparison flags ({eq, lt})
  input  logic        FWriteIntE,              // Write integer register, coming from FPU controller
  output logic        PCSrcE,                  // Select signal to choose next PC (for datapath and Hazard unit)
  output logic        ALUSrcAE, ALUSrcBE,      // ALU operands
  output logic        ALUResultSrcE,           // Selects result to pass on to Memory stage
  output logic [2:0]  ALUSelectE,              // ALU mux select signal
  output logic        MemReadE, CSRReadE,      // Instruction reads memory, reads a CSR (needed for Hazard unit)
  output logic [2:0]  Funct3E,                 // Instruction's funct3 field
  output logic        IntDivE,                 // Integer divide
  output logic        MDUE,                    // MDU (multiply/divide) operatio
  output logic        W64E,                    // RV64 W-type operation
  output logic        SubArithE,               // Subtraction or arithmetic shift
  output logic        JumpE,                   // jump instruction
  output logic        BranchE,                 // Branch instruction
  output logic        SCE,                     // Store Conditional instruction
  output logic        BranchSignedE,           // Branch comparison operands are signed (if it's a branch)
  output logic [1:0]  BSelectE,                // One-Hot encoding of if it's ZBA_ZBB_ZBC_ZBS instruction
  output logic [2:0]  ZBBSelectE,              // ZBB mux select signal in Execute stage
  output logic [2:0]  BALUControlE,            // ALU Control signals for B instructions in Execute Stage
  output logic        BMUActiveE,              // Bit manipulation instruction being executed
  output logic        MDUActiveE,              // Mul/Div instruction being executed

  // Memory stage control signals
  input  logic        StallM, FlushM,          // Stall, flush Memory stage
  output logic [1:0]  MemRWM,                  // Mem read/write: MemRWM[1] = 1 for read, MemRWM[0] = 1 for write 
  output logic        CSRReadM, CSRWriteM, PrivilegedM, // CSR read, write, or privileged instruction
  output logic [1:0]  AtomicM,                 // Atomic (AMO) instruction
  output logic [2:0]  Funct3M,                 // Instruction's funct3 field
  output logic        RegWriteM,               // Instruction writes a register (needed for Hazard unit)
  output logic        InvalidateICacheM, FlushDCacheM, // Invalidate I$, flush D$
  output logic        InstrValidD, InstrValidE, InstrValidM, // Instruction is valid
  output logic        FWriteIntM,              // FPU controller writes integer register file
  // Writeback stage control signals
  input  logic        StallW, FlushW,          // Stall, flush Writeback stage
  output logic        RegWriteW, IntDivW,      // Instruction writes a register, is an integer divide
  output logic [2:0]  ResultSrcW,              // Select source of result to write back to register file
  // Stall during CSRs
  output logic        CSRWriteFenceM,          // CSR write or fence instruction; needs to flush the following instructions
  output logic        StoreStallD              // Store (memory write) causes stall
);

  logic [6:0] OpD;                             // Opcode in Decode stage
  logic [2:0] Funct3D;                         // Funct3 field in Decode stage
  logic [6:0] Funct7D;                         // Funct7 field in Decode stage
  logic [4:0] Rs1D;                            // Rs1 source register in Decode stage

  `define CTRLW 23

  // pipelined control signals
  logic        RegWriteD, RegWriteE;           // RegWrite (register will be written)
  logic [2:0]  ResultSrcD, ResultSrcE, ResultSrcM; // Select which result to write back to register file
  logic [1:0]  MemRWD, MemRWE;                 // Store (write to memory)
  logic        ALUOpD;                         // 0 for address generation, 1 for all other operations (must use Funct3)
  logic        BaseW64D;                       // W64 for Base instructions specifically
  logic        BaseRegWriteD;                  // Indicates if Base instruction register write instruction
  logic        BaseSubArithD;                  // Indicates if Base instruction subtracts, sra, slt, sltu
  logic        BaseALUSrcBD;                   // Base instruction ALU B source select signal
  logic [2:0]  ALUControlD;                    // Determines ALU operation
  logic        ALUSrcAD, ALUSrcBD;             // ALU inputs
  logic        ALUResultSrcD, W64D, MDUD;      // ALU result, is RV64 W-type, is multiply/divide instruction
  logic        CSRZeroSrcD;                    // Ignore setting and clearing zeros to CSR
  logic        CSRReadD;                       // CSR read instruction
  logic [1:0]  AtomicD;                        // Atomic (AMO) instruction
  logic        FenceXD;                        // Fence instruction
  logic        InvalidateICacheD, FlushDCacheD;// Invalidate I$, flush D$
  logic        CSRWriteD, CSRWriteE;           // CSR write
  logic        PrivilegedD, PrivilegedE;       // Privileged instruction
  logic        InvalidateICacheE, FlushDCacheE;// Invalidate I$, flush D$
  logic [`CTRLW-1:0] ControlsD;                // Main Instruction Decoder control signals
  logic        SubArithD;                      // TRUE for R-type subtracts and sra, slt, sltu or B-type ext clr, andn, orn, xnor
  logic        subD, sraD, sltD, sltuD;        // Indicates if is one of these instructions
  logic        ALUOpE;                         // 0 for address generationm 1 for ALU operations
  logic        BranchTakenE;                   // Branch is taken
  logic        eqE, ltE;                       // Comparator outputs
  logic        unused; 
  logic        BranchFlagE;                    // Branch flag to use (chosen between eq or lt)
  logic        IEURegWriteE;                   // Register write 
  logic        BRegWriteE;                     // Register write from BMU controller in Execute Stage
  logic        IllegalERegAdrD;                // RV32E attempts to write upper 16 registers
  logic [1:0]  AtomicE;                        // Atomic instruction 
  logic        FenceD, FenceE;                 // Fence instruction
  logic        SFenceVmaD;                     // sfence.vma instruction
  logic        IntDivM;                        // Integer divide instruction
  logic [1:0]  BSelectD;                       // One-Hot encoding if it's ZBA_ZBB_ZBC_ZBS instruction in decode stage
  logic [2:0]  ZBBSelectD;                     // ZBB Mux Select Signal
  logic        IFunctD, RFunctD, MFunctD;      // Detect I, R, and M-type RV32IM/Rv64IM instructions
  logic        LFunctD, SFunctD, BFunctD;      // Detect load, store, branch instructions
  logic        JFunctD;                        // detect jalr instruction
  logic        FenceM;                         // Fence.I or sfence.VMA instruction in memory stage
  logic [2:0]  ALUSelectD;                     // ALU Output selection mux control
  logic        IWValidFunct3D;                 // Detects if Funct3 is valid for IW instructions

  // Extract fields
  assign OpD = InstrD[6:0];
  assign Funct3D = InstrD[14:12];
  assign Funct7D = InstrD[31:25];
  assign Rs1D = InstrD[19:15];

  // Funct 7 checking
  // Be rigorous about detecting illegal instructions if CSRs or bit manipulation is supported
  // otherwise be cheap

  if (`ZICSR_SUPPORTED | `ZBA_SUPPORTED | `ZBB_SUPPORTED | `ZBC_SUPPORTED | `ZBS_SUPPORTED) begin:legalcheck // Exact integer decoding
    logic Funct7ZeroD, Funct7b5D, IShiftD, INoShiftD;
    logic Funct7ShiftZeroD, Funct7Shiftb5D;

    assign Funct7ZeroD      = (Funct7D == 7'b0000000); // most R-type instructions
    assign Funct7b5D        = (Funct7D == 7'b0100000); // srai, sub
    assign Funct7ShiftZeroD = (`XLEN==64) ? (Funct7D[6:1] == 6'b000000) : Funct7ZeroD;
    assign Funct7Shiftb5D   = (`XLEN==64) ? (Funct7D[6:1] == 6'b010000) : Funct7b5D;
    assign IShiftD          = (Funct3D == 3'b001 & Funct7ShiftZeroD) | (Funct3D == 3'b101 & (Funct7ShiftZeroD | Funct7Shiftb5D)); // slli, srli, srai, or w forms
    assign INoShiftD        = ((Funct3D != 3'b001) & (Funct3D != 3'b101));
    assign IFunctD          = IShiftD | INoShiftD;
    assign RFunctD          = ((Funct3D == 3'b000 | Funct3D == 3'b101) & Funct7b5D) | Funct7ZeroD;
    assign MFunctD          = (Funct7D == 7'b0000001) & (`M_SUPPORTED | (`ZMMUL_SUPPORTED & ~Funct3D[2])); // muldiv
    assign LFunctD          = Funct3D == 3'b000 | Funct3D == 3'b001 | Funct3D == 3'b010 | Funct3D == 3'b100 | Funct3D == 3'b101 | 
                              ((`XLEN == 64) & (Funct3D == 3'b011 | Funct3D == 3'b110));
    assign SFunctD          = Funct3D == 3'b000 | Funct3D == 3'b001 | Funct3D == 3'b010 | 
                              ((`XLEN == 64) & (Funct3D == 3'b011));
    assign BFunctD          = (Funct3D[2:1] != 2'b01); // legal branches
    assign JFunctD          = (Funct3D == 3'b000);
    assign IWValidFunct3D   = Funct3D == 3'b000 | Funct3D == 3'b001 | Funct3D == 3'b101;
  end else begin:legalcheck2
    assign IFunctD = 1; // Don't bother to separate out shift decoding
    assign RFunctD = ~Funct7D[0]; // Not a multiply
    assign MFunctD = Funct7D[0] & (`M_SUPPORTED | (`ZMMUL_SUPPORTED & ~Funct3D[2])); // muldiv
    assign LFunctD = 1; // don't bother to check Funct3 for loads
    assign SFunctD = 1; // don't bother to check Funct3 for stores
    assign BFunctD = 1; // don't bother to check Funct3 for branches
    assign JFunctD = 1; // don't bother to check Funct3 for jumps
    assign IWValidFunct3D = 1;
  end

  // Main Instruction Decoder
  /* verilator lint_off CASEINCOMPLETE */
  always_comb begin
    ControlsD = `CTRLW'b0_000_00_00_000_0_0_0_0_0_0_0_0_0_00_1; // default: Illegal instruction
    case(OpD)
    // RegWrite_ImmSrc_ALUSrc_MemRW_ResultSrc_Branch_ALUOp_Jump_ALUResultSrc_W64_CSRRead_Privileged_Fence_MDU_Atomic_Illegal
     7'b0000011: if (LFunctD) 
                      ControlsD = `CTRLW'b1_000_01_10_001_0_0_0_0_0_0_0_0_0_00_0; // loads
      7'b0000111:     ControlsD = `CTRLW'b0_000_01_10_001_0_0_0_0_0_0_0_0_0_00_1; // flw - only legal if FP supported
      7'b0001111: if (`ZIFENCEI_SUPPORTED)
                      ControlsD = `CTRLW'b0_000_00_00_000_0_0_0_0_0_0_0_1_0_00_0; // fence
                  else
                      ControlsD = `CTRLW'b0_000_00_00_000_0_0_0_0_0_0_0_0_0_00_0; // fence treated as nop
      7'b0010011: if (IFunctD)    
                      ControlsD = `CTRLW'b1_000_01_00_000_0_1_0_0_0_0_0_0_0_00_0; // I-type ALU
      7'b0010111:     ControlsD = `CTRLW'b1_100_11_00_000_0_0_0_0_0_0_0_0_0_00_0; // auipc
      7'b0011011: if (IFunctD & IWValidFunct3D & `XLEN == 64)
                      ControlsD = `CTRLW'b1_000_01_00_000_0_1_0_0_1_0_0_0_0_00_0; // IW-type ALU for RV64i
      7'b0100011: if (SFunctD) 
                      ControlsD = `CTRLW'b0_001_01_01_000_0_0_0_0_0_0_0_0_0_00_0; // stores
      7'b0100111:     ControlsD = `CTRLW'b0_001_01_01_000_0_0_0_0_0_0_0_0_0_00_1; // fsw - only legal if FP supported
      7'b0101111: if (`A_SUPPORTED) begin
                    if (InstrD[31:27] == 5'b00010)
                      ControlsD = `CTRLW'b1_000_00_10_001_0_0_0_0_0_0_0_0_0_01_0; // lr
                    else if (InstrD[31:27] == 5'b00011)
                      ControlsD = `CTRLW'b1_101_01_01_100_0_0_0_0_0_0_0_0_0_01_0; // sc
                    else 
                      ControlsD = `CTRLW'b1_101_01_11_001_0_0_0_0_0_0_0_0_0_10_0; // amo
                 end
      7'b0110011: if (RFunctD)
                      ControlsD = `CTRLW'b1_000_00_00_000_0_1_0_0_0_0_0_0_0_00_0; // R-type 
                  else if (MFunctD)
                      ControlsD = `CTRLW'b1_000_00_00_011_0_0_0_0_0_0_0_0_1_00_0; // Multiply/divide
      7'b0110111:     ControlsD = `CTRLW'b1_100_01_00_000_0_0_0_1_0_0_0_0_0_00_0; // lui
      7'b0111011: if (RFunctD & (`XLEN == 64))
                      ControlsD = `CTRLW'b1_000_00_00_000_0_1_0_0_1_0_0_0_0_00_0; // R-type W instructions for RV64i
                  else if (MFunctD & (`XLEN == 64))
                      ControlsD = `CTRLW'b1_000_00_00_011_0_0_0_0_1_0_0_0_1_00_0; // W-type Multiply/Divide
      7'b1100011: if (BFunctD)   
                      ControlsD = `CTRLW'b0_010_11_00_000_1_0_0_0_0_0_0_0_0_00_0; // branches
      7'b1100111: if (JFunctD)
                      ControlsD = `CTRLW'b1_000_01_00_000_0_0_1_1_0_0_0_0_0_00_0; // jalr
      7'b1101111:     ControlsD = `CTRLW'b1_011_11_00_000_0_0_1_1_0_0_0_0_0_00_0; // jal
      7'b1110011: if (`ZICSR_SUPPORTED) begin
                   if (Funct3D == 3'b000)
                      ControlsD = `CTRLW'b0_000_00_00_000_0_0_0_0_0_0_1_0_0_00_0; // privileged; decoded further in priveleged modules
                   else
                      ControlsD = `CTRLW'b1_000_00_00_010_0_0_0_0_0_1_0_0_0_00_0; // csrs
                  end
    endcase
  end
  /* verilator lint_on CASEINCOMPLETE */

  // Unswizzle control bits
  // Squash control signals if coming from an illegal compressed instruction
  // On RV32E, can't write to upper 16 registers.  Checking reads to upper 16 is more costly so disregard them.
  assign IllegalERegAdrD = `E_SUPPORTED & `ZICSR_SUPPORTED & ControlsD[`CTRLW-1] & InstrD[11]; 
  //assign IllegalBaseInstrD = 1'b0;
  assign {BaseRegWriteD, ImmSrcD, ALUSrcAD, BaseALUSrcBD, MemRWD,
          ResultSrcD, BranchD, ALUOpD, JumpD, ALUResultSrcD, BaseW64D, CSRReadD, 
          PrivilegedD, FenceXD, MDUD, AtomicD, unused} = IllegalIEUFPUInstrD ? `CTRLW'b0 : ControlsD;
  
  assign CSRZeroSrcD = InstrD[14] ? (InstrD[19:15] == 0) : (Rs1D == 0); // Is a CSR instruction using zero as the source?
  assign CSRWriteD = CSRReadD & !(CSRZeroSrcD & InstrD[13]);            // Don't write if setting or clearing zeros
  assign SFenceVmaD = PrivilegedD & (InstrD[31:25] ==  7'b0001001);
  assign FenceD = SFenceVmaD | FenceXD; // possible sfence.vma or fence.i
  
  // ALU Decoding is lazy, only using func7[5] to distinguish add/sub and srl/sra
  assign sltuD = (Funct3D == 3'b011); 
  assign subD = (Funct3D == 3'b000 & Funct7D[5] & OpD[5]);  // OpD[5] needed to distinguish sub from addi
  assign sraD = (Funct3D == 3'b101 & Funct7D[5]);
  assign BaseSubArithD = ALUOpD & (subD | sraD | sltD | sltuD);

  // bit manipulation Configuration Block
  if (`ZBS_SUPPORTED | `ZBA_SUPPORTED | `ZBB_SUPPORTED | `ZBC_SUPPORTED) begin: bitmanipi //change the conditional expression to OR any Z supported flags
    logic IllegalBitmanipInstrD;          // Unrecognized B instruction
    logic BRegWriteD;                     // Indicates if it is a R type BMU instruction in decode stage
    logic BW64D;                          // Indicates if it is a W type BMU instruction in decode stage
    logic BSubArithD;                     // TRUE for BMU ext, clr, andn, orn, xnor
    logic BALUSrcBD;                      // BMU alu src select signal

    bmuctrl bmuctrl(.clk, .reset, .StallD, .FlushD, .InstrD, .ALUOpD, .BSelectD, .ZBBSelectD, 
      .BRegWriteD, .BALUSrcBD, .BW64D, .BSubArithD, .IllegalBitmanipInstrD, .StallE, .FlushE, 
      .ALUSelectD, .BSelectE, .ZBBSelectE, .BRegWriteE, .BALUControlE, .BMUActiveE);
    if (`ZBA_SUPPORTED) begin
      // ALU Decoding is more comprehensive when ZBA is supported. slt and slti conflicts with sh1add, sh1add.uw
      assign sltD = (Funct3D == 3'b010 & (~(Funct7D[4]) | ~OpD[5])) ;
    end else assign sltD = (Funct3D == 3'b010);

    // Combine base and bit manipulation signals
    // coverage off: IllegalERegAdr can't occur in rv64gc; only applicable to E mode
    assign IllegalBaseInstrD = (ControlsD[0] & IllegalBitmanipInstrD) | IllegalERegAdrD ;
    // coverage on
    assign RegWriteD = BaseRegWriteD | BRegWriteD; 
    assign W64D = BaseW64D | BW64D;
    assign ALUSrcBD = BaseALUSrcBD | BALUSrcBD;
    assign SubArithD = BaseSubArithD | BSubArithD; // TRUE If BMU or R-type instruction involves inverted operand

  end else begin: bitmanipi
    assign ALUSelectD = ALUOpD ? Funct3D : 3'b000; // add for address generation when not doing ALU operation
    assign sltD = (Funct3D == 3'b010);
    assign IllegalBaseInstrD = ControlsD[0] | IllegalERegAdrD ;
    assign RegWriteD = BaseRegWriteD; 
    assign W64D = BaseW64D;
    assign ALUSrcBD = BaseALUSrcBD;
    assign SubArithD = BaseSubArithD; // TRUE If B-type or R-type instruction involves inverted operand

    // tie off unused bit manipulation signals
    assign BSelectE = 2'b00;
    assign BSelectD = 2'b00;
    assign ZBBSelectE = 3'b000;
    assign BALUControlE = 3'b0;
    assign BMUActiveE = 1'b0;
  end

  // Fences
  // Ordinary fence is presently a nop
  // fence.i flushes the D$ and invalidates the I$ if Zifencei is supported and I$ is implemented
  if (`ZIFENCEI_SUPPORTED & `ICACHE_SUPPORTED) begin:fencei
    logic FenceID;
    assign FenceID = FenceXD & (Funct3D == 3'b001); // is it a FENCE.I instruction?
    assign InvalidateICacheD = FenceID;
    assign FlushDCacheD = FenceID;
  end else begin:fencei
    assign InvalidateICacheD = 0;
    assign FlushDCacheD = 0;
  end
 
  // Decode stage pipeline control register
  flopenrc #(1)  controlregD(clk, reset, FlushD, ~StallD, 1'b1, InstrValidD);

  // Execute stage pipeline control register and logic
  flopenrc #(29) controlregE(clk, reset, FlushE, ~StallE,
                           {ALUSelectD, RegWriteD, ResultSrcD, MemRWD, JumpD, BranchD, ALUSrcAD, ALUSrcBD, ALUResultSrcD, CSRReadD, CSRWriteD, PrivilegedD, Funct3D, W64D, SubArithD, MDUD, AtomicD, InvalidateICacheD, FlushDCacheD, FenceD, InstrValidD},
                           {ALUSelectE, IEURegWriteE, ResultSrcE, MemRWE, JumpE, BranchE, ALUSrcAE, ALUSrcBE, ALUResultSrcE, CSRReadE, CSRWriteE, PrivilegedE, Funct3E, W64E, SubArithE, MDUE, AtomicE, InvalidateICacheE, FlushDCacheE, FenceE, InstrValidE});

  // Branch Logic
  //  The comparator handles both signed and unsigned branches using BranchSignedE
  //  Hence, only eq and lt flags are needed
  assign BranchSignedE = (~(Funct3E[2:1] == 2'b11) & BranchE);
  assign {eqE, ltE} = FlagsE;
  mux2 #(1) branchflagmux(eqE, ltE, Funct3E[2], BranchFlagE);
  assign BranchTakenE = BranchFlagE ^ Funct3E[0];
  assign PCSrcE = JumpE | BranchE & BranchTakenE;

  // Other execute stage controller signals
  assign MemReadE = MemRWE[1];
  assign SCE = (ResultSrcE == 3'b100);
  assign MDUActiveE = (ResultSrcE == 3'b011);
  assign RegWriteE = IEURegWriteE | FWriteIntE; // IRF register writes could come from IEU or FPU controllers
  assign IntDivE = MDUE & Funct3E[2]; // Integer division operation
  
  // Memory stage pipeline control register
  flopenrc #(20) controlregM(clk, reset, FlushM, ~StallM,
                         {RegWriteE, ResultSrcE, MemRWE, CSRReadE, CSRWriteE, PrivilegedE, Funct3E, FWriteIntE, AtomicE, InvalidateICacheE, FlushDCacheE, FenceE, InstrValidE, IntDivE},
                         {RegWriteM, ResultSrcM, MemRWM, CSRReadM, CSRWriteM, PrivilegedM, Funct3M, FWriteIntM, AtomicM, InvalidateICacheM, FlushDCacheM, FenceM, InstrValidM, IntDivM});
  
  // Writeback stage pipeline control register
  flopenrc #(5) controlregW(clk, reset, FlushW, ~StallW,
                         {RegWriteM, ResultSrcM, IntDivM},
                         {RegWriteW, ResultSrcW, IntDivW});  

  // Flush F, D, and E stages on a CSR write or Fence.I or SFence.VMA
  assign CSRWriteFenceM = CSRWriteM | FenceM;

  // the synchronous DTIM cannot read immediately after write
  // a cache cannot read or write immediately after a write
  assign StoreStallD = MemRWE[0] & ((MemRWD[1] | (MemRWD[0] & `DCACHE_SUPPORTED)) | (|AtomicD));
endmodule
