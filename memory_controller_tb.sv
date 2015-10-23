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

    typedef struct packed {
        word address, data;
    } inputs_container;

    inputs_container inputs;

    always @(read_data) begin
        if(inputs.data !== read_data) begin
            $display("Expected to read = %04o from address %04o, actually read =%04o",
                     inputs.data, inputs.address, read_data);
        end
    end

    task apply_stimulus(input word address_to_write, input word data_to_write);
        address = address_to_write;
        write_data = data_to_write;
        write_enable = 1'b1;
        #1;
        write_enable = 1'b0;
        #1;
    endtask

    task read_from_memory(input word address_to_read);
        address = address_to_read;
        read_type = `DATA_READ;
        read_enable = 1'b1;
        #1;
        read_enable = 1'b0;
        #1;
    endtask

    task write_all_addresses;
        automatic word address_to_write = 12'o0;
        automatic word data_to_write = 12'o0;

        for(int i = 0; i < 12'o7777; i++) begin
            inputs.address = address_to_write;
            inputs.data = data_to_write;
            apply_stimulus(address_to_write, data_to_write);
            read_from_memory(address_to_write);
            address_to_write += 1'b1;
            data_to_write += 1'b1;
        end
    endtask

    initial begin
        init_mem();
        trace_init();        
        read_enable = 1'b0;
        write_enable = 1'b0;
        #1;

        //Directed test just to write then read
        inputs.address = 12'o200;
        inputs.data = 12'o333;
        apply_stimulus(inputs.address, inputs.data);
        read_from_memory(inputs.address);

        //Algorithimic test
        write_all_addresses();

        print_valid_memory();
        trace_close();
    end

endmodule

