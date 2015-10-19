//ECE571 Project: PDP8 Simulator
// memory_controller_tb.sv

`include "memory_controller.sv"

`define SIMULATION

module memory_controller_tb();
    word address, write_data;
    logic read_enable, read_type, write_enable;
    word read_data;

    memory_controller controller1(
        .address(address),
        .write_data(write_data),
        .read_enable(read_enable),
        .read_type(read_type),
        .write_enable(write_enable),
        .read_data(read_data)
    );

    always @(read_data) begin
        $display("Read_data = %04o", read_data);
    end

    initial begin
        init_mem();
        trace_init();        

        address = 12'o 200;
        write_data = 12'o 133;
        write_enable = 1;
        #1;

        write_enable = 0;
        read_type = DATA_READ;
        read_enable = 1'b1;
        #1;

        print_valid_memory();
        trace_close();
    end

endmodule

