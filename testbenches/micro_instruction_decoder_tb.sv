// ECE571 Project: PDP8 Simulator
// micro_instruction_decoder_tb.sv

`include "../src/micro_instruction_decoder.sv"

`define NULL 0

module micro_instruction_decoder_tb ();
    parameter FILENAME = "../test_cases/micro_instructions.txt";
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

    micro_instruction_decoder decoder1( .i_reg,
                                        .ac_reg,
                                        .l_reg,
                                        .ac_micro,
                                        .l_micro,
                                        .skip,
                                        .micro_g1,
                                        .micro_g2,
                                        .micro_g3
                                      );


    initial begin
        file_ptr = $fopen("../test_cases/micro_instructions.txt", "r");
        if(file_ptr == `NULL) begin
            $display("Can't open the file for reading");
            $finish();
        end

        forever #1 clk = ~clk;
    end

    `ifdef CHECK_PASS
    always @(posedge clk) begin
        automatic int local_error = 0;

        if(ac_micro === expected_ac) begin
            $display("PASS: Accumulator result = %0o, Expected = %0o", ac_micro, expected_ac);
        end
        if(l_micro === expected_link) begin
            $display("PASS: link result = %b, Expected = %b", l_micro, expected_link);
        end
        if(skip === expected_skip) begin
            $display("PASS: skip result = %b, Expected = %b", skip, expected_skip);
        end
        if(micro_g1 === expected_micro_g1) begin
            $display("PASS: micro_g1 result = %b, Expected = %b", micro_g1, expected_micro_g1);
        end
        if(micro_g2 === expected_micro_g2) begin
            $display("PASS: micro_g2 result = %b, Expected = %b", micro_g2, expected_micro_g2);
        end
        if(micro_g3 === expected_micro_g3) begin
            $display("PASS: micro_g3 result = %b, Expected = %b", micro_g3, expected_micro_g3);
        end

        $display("Inputs were: i_reg = %o, ac_reg = %o, l_reg = %b\n",
        i_reg, ac_reg, l_reg);
    end
    `endif

    always @(posedge clk) begin
        automatic int local_error = 0;

        if(ac_micro !== expected_ac) begin
            $display("ERROR: Accumulator result = %0o, Expected = %0o", ac_micro, expected_ac);
            local_error = 1;
            error_flag = 1;
        end
        if(l_micro !== expected_link) begin
            $display("ERROR: link result = %b, Expected = %b", l_micro, expected_link);
            local_error = 1;
            error_flag = 1;
        end
        if(skip !== expected_skip) begin
            $display("ERROR: skip result = %b, Expected = %b", skip, expected_skip);
            local_error = 1;
            error_flag = 1;
        end
        if(micro_g1 !== expected_micro_g1) begin
            $display("ERROR: micro_g1 result = %b, Expected = %b", micro_g1, expected_micro_g1);
            local_error = 1;
            error_flag = 1;
        end
        if(micro_g2 !== expected_micro_g2) begin
            $display("ERROR: micro_g2 result = %b, Expected = %b", micro_g2, expected_micro_g2);
            local_error = 1;
            error_flag = 1;
        end
        if(micro_g3 !== expected_micro_g3) begin
            $display("ERROR: micro_g3 result = %b, Expected = %b", micro_g3, expected_micro_g3);
            local_error = 1;
            error_flag = 1;
        end

        if(local_error) begin
            $display("Inputs were: i_reg = %o, ac_reg = %o, l_reg = %b",
            i_reg, ac_reg, l_reg);
        end
    end

    always @(negedge clk) begin
        automatic logic [`INSTRUCTION_SIZE-1:0] temp_i_reg;
        automatic word temp_ac;
        automatic logic temp_l;
        automatic int num_read;
        const int num_expected = 9;

        if($feof(file_ptr)) begin
            
        end
        else begin
            num_read = $fscanf(file_ptr, "%03o %04o %b %04o %b %b %b %b %b", temp_i_reg,
                                                           temp_ac,
                                                           temp_l,
                                                           expected_ac,
                                                           expected_link,
                                                           expected_skip,
                                                           expected_micro_g1,
                                                           expected_micro_g2,
                                                           expected_micro_g3);
            if(num_read == -1) begin //eof
                $fclose(file_ptr);
                if(error_flag) $display("\nSome tests FAILED.\n");
                else $display("\nAll tests PASSED\n");
                $finish();
            end
            else if(num_read != num_expected) begin
                $display("READ WRONG NUMBER OF INPUTS");
                $fclose(file_ptr);
                $finish();
            end

            apply_inputs(temp_i_reg, temp_ac, temp_l);
        end
    end

    task apply_inputs(input logic [`INSTRUCTION_SIZE-1:0] instruction_register,
                      input word accumulator,
                      input logic link);
        i_reg = instruction_register;
        ac_reg = accumulator;
        l_reg = link;
    endtask

endmodule

