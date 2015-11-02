// ECE571 Project: PDP8 Simulator
// micro_instruction_decoder.sv

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

    logic [`ACCUMLATOR_AND_LINK_SIZE-1:0] link_and_accumulator;
    logic [`SELECT_SIZE-1:0] group_select;
    logic [`SELECT_SIZE-1:0] or_select;
    logic [`SELECT_SIZE-1:0] and_select;
    logic skip_or;
    logic skip_and;

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

        group2_instruction_bits.SMA = i_reg[`SMA_BIT];
        group2_instruction_bits.SZA = i_reg[`SZA_BIT];
        group2_instruction_bits.SNL = i_reg[`SNL_BIT];
        group2_instruction_bits.SPA = i_reg[`SPA_BIT];
        group2_instruction_bits.SNA = i_reg[`SNA_BIT];
        group2_instruction_bits.SZL = i_reg[`SZL_BIT];

        //Grabs the bits needed to figure out what group the instruction
        //is in
        group_select = {i_reg[8], i_reg[3], i_reg[0]};
    end


    //Set group output bit to the selected group
    always_comb begin
        unique case(group_select)
            `SELECT_SIZE'b0??: set_group_output_flags(`GROUP1_FLAG_OUTPUT);
            `SELECT_SIZE'b100: set_group_output_flags(`GROUP2_OR_FLAG_OUTPUT);
            `SELECT_SIZE'b110: set_group_output_flags(`GROUP2_AND_FLAG_OUTPUT);
            `SELECT_SIZE'b1?1: set_group_output_flags(`GROUP3_FLAG_OUTPUT);
        endcase
    end

    function void set_group_output_flags(input logic [`GROUP_FLAG_SIZE-1:0] group_flags);
        {micro_g1, or_select, and_select, micro_g3} = group_flags;
    endfunction

endmodule

