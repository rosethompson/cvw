//////////////////////////////////////////
// wally-config.vh
//
// Written: David_Harris@hmc.edu 4 January 2021
// Modified: 
//
// Purpose: Specify which features are configured
//          Macros to determine which modes are supported based on MISA
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

`include "BranchPredictorType.vh"

localparam FPGA = 0;
localparam QEMU = 0;

// RV32 or RV64: XLEN = 32 or 64
localparam XLEN = 32'd64;

// IEEE 754 compliance
localparam IEEE754 = 0;

// MISA RISC-V configuration per specification
localparam MISA = (32'h00000104);
localparam ZICSR_SUPPORTED = 0;
localparam ZIFENCEI_SUPPORTED = 0;
localparam COUNTERS = 0;
localparam ZICNTR_SUPPORTED = 0;
localparam ZIHPM_SUPPORTED = 0;
localparam ZFH_SUPPORTED = 0;
localparam SSTC_SUPPORTED = 0;
localparam ZICBOM_SUPPORTED = 0;
localparam ZICBOZ_SUPPORTED = 0;
localparam ZICBOP_SUPPORTED = 0;
localparam SVPBMT_SUPPORTED = 0;

// LSU microarchitectural Features
localparam BUS_SUPPORTED = 0;
localparam DCACHE_SUPPORTED = 0;
localparam ICACHE_SUPPORTED = 0;
localparam VIRTMEM_SUPPORTED = 0;
localparam VECTORED_INTERRUPTS_SUPPORTED = 1;
localparam BIGENDIAN_SUPPORTED = 0;

// TLB configuration.  Entries should be a power of 2
localparam ITLB_ENTRIES = 32'd0;
localparam DTLB_ENTRIES = 32'd0;

// Cache configuration.  Sizes should be a power of two
// typical configuration 4 ways, 4096 bytes per way, 256 bit or more lines
localparam DCACHE_NUMWAYS = 32'd4;
localparam DCACHE_WAYSIZEINBYTES = 32'd4096;
localparam DCACHE_LINELENINBITS = 32'd512;
localparam ICACHE_NUMWAYS = 32'd4;
localparam ICACHE_WAYSIZEINBYTES = 32'd4096;
localparam ICACHE_LINELENINBITS = 32'd512;

// Integer Divider Configuration
// IDIV_BITSPERCYCLE must be 1, 2, or 4
localparam IDIV_BITSPERCYCLE = 32'd4;
localparam IDIV_ON_FPU = 0;

// Legal number of PMP entries are 0, 16, or 64
localparam PMP_ENTRIES = 32'd0;

// Address space
localparam RESET_VECTOR = 64'h0000000080000000;

// Bus Interface width
localparam AHBW = (XLEN);

// WFI Timeout Wait
localparam WFI_TIMEOUT_BIT = 32'd16;

// Peripheral Physiccal Addresses
// Peripheral memory space extends from BASE to BASE+RANGE
// Range should be a thermometer code with 0's in the upper bits and 1s in the lower bits

// *** each of these is `PA_BITS wide. is this paramaterizable INSIDE the config file?
localparam DTIM_SUPPORTED = 1'b1;
localparam DTIM_BASE =       64'h80000000;
localparam DTIM_RANGE =      64'h007FFFFF;
localparam IROM_SUPPORTED = 1'b1;
localparam IROM_BASE =       64'h80000000;
localparam IROM_RANGE =      64'h007FFFFF;
localparam BOOTROM_SUPPORTED = 1'b0;
localparam BOOTROM_BASE =   64'h00001000; // spec had been 0x1000 to 0x2FFF, but dh truncated to 0x1000 to 0x1FFF because upper half seems to be all zeros and this is easier for decoder
localparam BOOTROM_RANGE =  64'h00000FFF;
localparam UNCORE_RAM_SUPPORTED = 1'b0;
localparam UNCORE_RAM_BASE =       64'h80000000;
localparam UNCORE_RAM_RANGE =      64'h7FFFFFFF;
localparam EXT_MEM_SUPPORTED = 1'b0;
localparam EXT_MEM_BASE =       64'h80000000;
localparam EXT_MEM_RANGE =      64'h07FFFFFF;
localparam CLINT_SUPPORTED = 1'b0;
localparam CLINT_BASE =  64'h02000000;
localparam CLINT_RANGE = 64'h0000FFFF;
localparam GPIO_SUPPORTED = 1'b0;
localparam GPIO_BASE =   64'h10060000;
localparam GPIO_RANGE =  64'h000000FF;
localparam UART_SUPPORTED = 1'b0;
localparam UART_BASE =   64'h10000000;
localparam UART_RANGE =  64'h00000007;
localparam PLIC_SUPPORTED = 1'b0;
localparam PLIC_BASE =   64'h0C000000;
localparam PLIC_RANGE =  64'h03FFFFFF;
localparam SDC_SUPPORTED = 1'b0;
localparam SDC_BASE =   64'h00012100;
localparam SDC_RANGE =  64'h0000001F;

// Test modes

// Tie GPIO outputs back to inputs
localparam GPIO_LOOPBACK_TEST = 1;

// Hardware configuration
localparam UART_PRESCALE = 32'd1;

// Interrupt configuration
localparam PLIC_NUM_SRC = 32'd10;
// comment out the following if >=32 sources
localparam PLIC_NUM_SRC_LT_32 = (PLIC_NUM_SRC < 32);
localparam PLIC_GPIO_ID = 32'd3;
localparam PLIC_UART_ID = 32'd10;

localparam BPRED_SUPPORTED = 0;
localparam BranchPredictorType BPRED_TYPE = BP_GSHARE; // BP_GSHARE_BASIC, BP_GLOBAL, BP_GLOBAL_BASIC, BP_TWOBIT
localparam BPRED_SIZE = 32'd10;
localparam BPRED_NUM_LHR = 32'd6;
localparam BTB_SIZE = 32'd10;

localparam SVADU_SUPPORTED = 0;
localparam ZMMUL_SUPPORTED = 0;

// FPU division architecture
localparam RADIX = 32'h4;
localparam DIVCOPIES = 32'h4;

// bit manipulation
localparam ZBA_SUPPORTED = 0;
localparam ZBB_SUPPORTED = 0;
localparam ZBC_SUPPORTED = 0;
localparam ZBS_SUPPORTED = 0;

// Memory synthesis configuration
localparam USE_SRAM = 0;

`include "test-shared.vh"
