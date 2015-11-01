//ECE571 Project: PDP8 Simulator
// memory_controller_tb.sv

`include "memory_controller.sv"
`include "memory_utils.pkg"

`define SIMULATION

module memory_controller_tb();
    parameter CLK_PERIOD = 10;
    word address;
    word write_data;
    logic clk = 0;
    logic read_enable = 1'b0;
    logic read_type;
    logic write_enable = 1'b0;
    word read_data;
    logic operation_done;

    memory_controller controller1(
        .address(address),
        .write_data(write_data),
        .clk(clk),
        .read_enable(read_enable),
        .read_type(read_type),
        .write_enable(write_enable),
        .read_data(read_data),
        .operation_done(operation_done)
    );

    typedef struct packed {
        word address, data;
        logic was_read;
    } inputs_container;

    inputs_container inputs;

    always @(posedge operation_done) begin
        if(inputs.was_read && (inputs.data !== read_data)) begin
            $display("Expected to read = %04o from address %04o, actually read =%04o",
                     inputs.data, inputs.address, read_data);
        end
    end

    task write_to_memory(input word address_to_write, input word data_to_write);
        address = address_to_write;
        write_data = data_to_write;
        inputs.was_read = 1'b0;
        write_enable = 1'b1;
        #CLK_PERIOD
        write_enable = 1'b0;
        #(CLK_PERIOD * 3);
    endtask

    task read_from_memory(input word address_to_read);
        address = address_to_read;
        read_type = `DATA_READ;
        inputs.was_read = 1'b1;
        read_enable = 1'b1;
        #CLK_PERIOD;
        read_enable = 1'b0;
        #(CLK_PERIOD * 3);
    endtask

    task write_all_addresses;
        automatic word address_to_write = 12'o0;
        automatic word data_to_write = 12'o0;

        for(int i = 0; i < 13'o10000; i++) begin
            inputs.address = address_to_write;
            inputs.data = data_to_write;
            write_to_memory(address_to_write, data_to_write);
            read_from_memory(address_to_write);
            address_to_write += 1'b1;
            data_to_write += 1'b1;
        end
    endtask

    initial
    begin
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        init_mem();
        trace_init();        
        #(CLK_PERIOD / 2);
        #CLK_PERIOD;

        //Directed test just to write then read
        inputs.address = 12'o200;
        inputs.data = 12'o333;
        write_to_memory(inputs.address, inputs.data);
        read_from_memory(inputs.address);

        //Algorithimic test
        write_all_addresses();

        print_valid_memory();
        trace_close();
        $finish;
    end
endmodule

