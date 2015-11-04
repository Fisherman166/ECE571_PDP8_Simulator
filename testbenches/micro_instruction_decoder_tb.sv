// ECE571 Project: PDP8 Simulator
// micro_instruction_decoder_tb.sv

`include "../src/micro_instruction_decoder.vh"
`include "../src/memory_utils.pkg"

module micro_instruction_decoder_tb ();
    logic [`INSTRUCTION_SIZE-1:0] i_reg;
    word ac_reg;
    logic l_reg;
    word ac_micro, expected_ac;
    logic l_micro, expected_link;
    logic skip, micro_g1, micro_g2, micro_g3;
    logic clk = 1'b1;
    integer file_ptr;
    logic expected_skip, expected_micro_g1, expected_micro_g2, expected_micro_g3, stop;
    logic error_flag = 0;

    initial begin
        forever #1 clk = ~clk;
        file_ptr = $fopen("micro_test_input.txt", r);
    end

    always @(posedge clk) begin
       if(ac_micro !== expected_ac) $display("Accumulator result = %0o, Expected = %0o", ac_micro, expected_ac);
       if(l_micro !== expected_link) $display("link result = %b, Expected = %b", l_micro, expected_link);
       if(skip !== expected_skip) $display("skip result = %b, Expected = %b", skip, expected_skip);
       if(micro_g1 !== expected_micro_g1) $display("micro_g1 result = %b, Expected = %b", micro_g1, expected_micro_g1);
       if(micro_g2 !== expected_micro_g2) $display("micro_g2 result = %b, Expected = %b", micro_g2, expected_micro_g2);
       if(micro_g3 !== expected_micro_g3) $display("micro_g3 result = %b, Expected = %b", micro_g3, expected_micro_g3);
    end

    always @(negedge clk) begin
        automatic logic [`INSTRUCTION_SIZE-1:0] temp_i_reg;
        automatic word temp_ac;
        automatic logic temp_i;

        $fscanf("%o %o %b %o %b %b %b %b %b %b", temp_i_reg,
                                                 temp_ac,
                                                 temp_l,
                                                 expected_ac,
                                                 expected_link,
                                                 expected_skip,
                                                 expected_micro_g1,
                                                 expected_micro_g2,
                                                 expected_micro_g3,
                                                 stop);
        if(stop) begin
            $fclose(file_ptr);
            if(error_flag) $display("Some tests FAILED.\n");
            else $display("All tests PASSED\n");
            $finish();
        end

        apply_inputs(temp_i_reg, temp_ac, temp_l);
    end

    task apply_inputs(input logic [`INSTRUCTION_SIZE-1:0] instruction_register,
                      input word accumulator,
                      input link);
        i_reg = instruction_register;
        ac_reg = accumulator;
        l_reg = link;
    endtask

endmodule

