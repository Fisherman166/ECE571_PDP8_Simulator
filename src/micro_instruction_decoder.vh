// ECE571 Project: PDP8 Simulator
// micro_instruction_decoder.vh

`ifndef MICRO_INSTRUCTION_DECODER
`define MICRO_INSTRUCTION_DECODER

`include "memory_utils.pkg"

`define INSTRUCTION_SIZE 9
`define SELECT_SIZE 3
`define ACCUMLATOR_AND_LINK_SIZE 13
`define GROUP_FLAG_SIZE 4
`define NUM_BLOCKS 4

//Group 1 instruction bits
`define CLA_BIT 7
`define CLL_BIT 6
`define CMA_BIT 5
`define CML_BIT 4
`define RAR_BIT 3
`define RAL_BIT 2
`define BSW_BIT 1
`define IAC_BIT 0

//Group 2 instruction bits
`define SMA_BIT 6
`define SZA_BIT 5
`define SNL_BIT 4
`define SPA_BIT 6
`define SNA_BIT 5
`define SZL_BIT 4

//For group output bits
`define GROUP1_FLAG_OUTPUT `GROUP_FLAG_SIZE'b1000
`define GROUP2_OR_FLAG_OUTPUT `GROUP_FLAG_SIZE'b0100
`define GROUP2_AND_FLAG_OUTPUT `GROUP_FLAG_SIZE'b0010
`define GROUP3_FLAG_OUTPUT `GROUP_FLAG_SIZE'b0001

//For shift case statement
`define BYTE_SWAP `SELECT_SIZE'b001
`define LEFT_SHIFT1 `SELECT_SIZE'b010
`define LEFT_SHIFT2 `SELECT_SIZE'b011
`define RIGHT_SHIFT1 `SELECT_SIZE'b100
`define RIGHT_SHIFT2 `SELECT_SIZE'b101

//For group2 OR and AND indentification
`define OR_INSTRUCTION 2'b10
`define AND_INSTRUCTION 2'b11

module micro_instruction_decoder(
    input logic [`INSTRUCTION_SIZE-1:0] i_reg,
    input word ac_reg,
    input logic l_reg,
    output word ac_micro,
    output logic l_micro,
    output logic skip,
    output logic micro_g1,
    output logic micro_g2,
    output logic micro_g3
);
endmodule

`endif

