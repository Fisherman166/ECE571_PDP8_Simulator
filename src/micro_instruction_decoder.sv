// ECE571 Project: PDP8 Simulator
// micro_instruction_decoder.sv

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
    logic [`SELECT_SIZE-1:0] group2_or_select;
    logic [`SELECT_SIZE-1:0] group2_and_select;
    logic [`SELECT_SIZE-1:0] group1_block3_select;
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

        micro_g2 = group2_or_select | group2_and_select;
    end

    //Group1 inustrctions
    always_comb begin
        //Block 0 - Clear
        if(group1_instruction_bits.CLA === 1'b1) block_connection[0].accumlator = '0;
        else block_connection[0].accumlator = ac_reg;

        if(group1_instruction_bits.CLL === 1'b1) block_connection[0].link = '0;
        else block_connection[0].link = l_reg;

        //Block 1 - Complement
        if(group1_instruction_bits.CMA === 1'b1) begin
            block_connection[1].accumlator = ~block_connection[0].accumlator;
        end
        else block_connection[1].accumlator = block_connection[0].accumlator;

        if(group1_instruction_bits.CML === 1'b1) begin
            block_connection[1].link = ~block_connection[0].link;
        end
        else block_connection[1].link = block_connection[0].link;

        //Block 2 - increment
        link_and_accumulator = {block_connection[1].link, block_connection[1].accumlator} + 1'b1;

        if(group1_instruction_bits.IAC === 1'b1) begin
            block_connection[2].accumlator = link_and_accumulator[`ACCUMLATOR_AND_LINK_SIZE-2:0];
            block_connection[2].link = link_and_accumulator[`ACCUMLATOR_AND_LINK_SIZE-1];
        end
        else begin
            block_connection[2].accumlator = block_connection[1].accumlator;
            block_connection[2].link = block_connection[1].link;
        end

        //Block 3 - shift
        group1_block3_select = {group1_instruction_bits.RAR,
                                group1_instruction_bits.RAL,
                                group1_instruction_bits.BSW};
        
        case(group1_block3_select)
            `BYTE_SWAP: begin
                        block_connection[3].accumlator = {block_connection[2].accumlator[5:0],
                                                          block_connection[2].accumlator[11:6]};
                        end
            `LEFT_SHIFT1: begin
                          block_connection[3].link = block_connection[2].accumlator[11];
                          block_connection[3].accumlator = {block_connection[2].accumlator[10:0],
                                                            block_connection[2].link};
                          end
            `LEFT_SHIFT2: begin
                          block_connection[3].link = block_connection[2].accumlator[10];
                          block_connection[3].accumlator = {block_connection[2].accumlator[9:0],
                                                            block_connection[2].link,
                                                            block_connection[2].accumlator[11]};
                          end
            `RIGHT_SHIFT1: begin
                           block_connection[3].link = block_connection[2].accumlator[0];
                           block_connection[3].accumlator = {block_connection[2].link,
                                                             block_connection[2].accumlator[11:1]};
                           end
            `RIGHT_SHIFT2: begin
                           block_connection[3].link = block_connection[2].accumlator[1];
                           block_connection[3].accumlator = {block_connection[2].accumlator[0],
                                                             block_connection[2].link,
                                                             block_connection[2].accumlator[11:2]};
                           end
            default: begin
                     block_connection[3].link = block_connection[2].link;
                     block_connection[3].accumlator = block_connection[2].accumlator;
                     end
        endcase
    end

    //Group2 OR instructions
    always_comb begin
        automatic logic [`SELECT_SIZE-1:0] instructions_dectected = {group2_instruction_bits.SMA,
                                                                     group2_instruction_bits.SZA,
                                                                     group2_instruction_bits.SNL};

        if(group_select[2:1] === `OR_INSTRUCTION) begin
            case(instructions_dectected)
                3'b001: if(l_reg !== 1'b0) skip_or = 1'b1;
                        else skip_or = 1'b0;
                3'b010: if(ac_reg === '0) skip_or = 1'b1;
                        else skip_or = 1'b0;
                3'b011: if( (ac_reg === '0) || (l_reg !== 1'b0) ) skip_or = 1'b1;
                        else skip_or = 1'b0;
                3'b100: if(ac_reg[11] === 1'b1) skip_or = 1'b1;
                        else skip_or = 1'b0;
                3'b101: if( (ac_reg[11] === 1'b1) || (l_reg !== 1'b0) ) skip_or = 1'b1;
                        else skip_or = 1'b0;
                3'b110: if( (ac_reg[11] === 1'b1) || (ac_reg === '0) ) skip_or = 1'b1;
                        else skip_or = 1'b0;
                3'b111: if( (ac_reg[11] === 1'b1) || (ac_reg === '0) || (l_reg !== 1'b0) ) skip_or = 1'b1;
                        else skip_or = 1'b0;
               default: skip_or = 1'b0;
            endcase
        end
        else skip_or = 1'b0;
    end

    //Group2 AND instructions
    always_comb begin
        automatic logic [`SELECT_SIZE-1:0] instructions_dectected = {group2_instruction_bits.SPA,
                                                                     group2_instruction_bits.SNA,
                                                                     group2_instruction_bits.SZL};

        if(group_select[2:1] === `AND_INSTRUCTION) begin
            case(instructions_dectected)
                3'b000: skip_and = 1'b1;
                3'b001: if(l_reg === 1'b0) skip_and = 1'b1;
                        else skip_and = 1'b0;
                3'b010: if(ac_reg !== '0) skip_and = 1'b1;
                        else skip_and = 1'b0;
                3'b011: if( (ac_reg !== '0) && (l_reg === 1'b0) ) skip_and = 1'b1;
                        else skip_and = 1'b0;
                3'b100: if(ac_reg[11] === 1'b0) skip_and = 1'b1;
                        else skip_and = 1'b0;
                3'b101: if( (ac_reg[11] === 1'b0) && (l_reg === 1'b0) ) skip_and = 1'b1;
                        else skip_and = 1'b0;
                3'b110: if( (ac_reg[11] === 1'b0) && (ac_reg !== '0) ) skip_and = 1'b1;
                        else skip_and = 1'b0;
                3'b111: if( (ac_reg[11] === 1'b0) && (ac_reg !== '0) && (l_reg === 1'b0) ) skip_and = 1'b1;
                        else skip_and = 1'b0;
               default: skip_and = 1'b0;
            endcase
        end
        else skip_and = 1'b0;
    end

    assign skip = skip_or | skip_and;

    function void set_group_output_flags(input logic [`GROUP_FLAG_SIZE-1:0] group_flags);
        {micro_g1, group2_or_select, group2_and_select, micro_g3} = group_flags;
    endfunction

endmodule

`endif

