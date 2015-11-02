// ECE571 Project: PDP8 Simulator
// micro_instruction_decoder.sv

`include "memory_utils.pkg"

`define INSTRUCTION_SIZE 9
`define SELECT_SIZE 3
`define ACCUMLATOR_AND_LINK_SIZE 13
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

    struct packed {
        word accumlator;
        logic link;
    } block_connection[`NUM_BLOCKS];

    struct packed {
        logic CLA;  //This will act as the CLA bit for both groups
        logic CLL;
        logic CMA;
        logic CML;
        logic RAR;
        logic RAL;
        logic BSW;
        logic IAC;
        logic [`SELECT_SIZE-1:0] shift_and_swap_selection;
    } group1_instruction_bits;

    struct packed {
        logic SMA;
        logic SZA;
        logic SNL;
        logic SPA;
        logic SNA;
        logic SZL;
    } group2_instruction_bits;

    struct packed {
        logic [`SELECT_SIZE-1:0] or_select;
        logic [`SELECT_SIZE-1:0] and_select;
        logic skip_or;
        logic skip_and;
    } group2_select_bits;

    //For intermediate calculation in shifts
    logic [`ACCUMLATOR_AND_LINK_SIZE-1:0] link_and_accumulator;

    //Decode instruction register
    always_comb begin
        group1_instruction_bits.CLA = i_reg[`CLA_BIT];
        group1_instruction_bits.CLL = i_reg[`CLL_BIT];
        group1_instruction_bits.CMA = i_reg[`CMA_BIT];
        group1_instruction_bits.CML = i_reg[`CML_BIT];
        group1_instruction_bits.RAR = i_reg[`RAR_BIT];
        group1_instruction_bits.RAL = i_reg[`RAL_BIT];
        group1_instruction_bits.BSW = i_reg[`BSW_BIT];
        group1_instruction_bits.IAC = i_reg[`IAC_BIT];
    end

endmodule

