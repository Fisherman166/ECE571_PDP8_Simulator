// ECE571 Project: PDP8 Simulator
// memory_controller.sv

`ifndef MEMORY_H
`define MEMORY_H

`include "memory_utils.pkg"

module memory_controller(
    input logic clk,
    input logic read_type,
    main_bus.mem bus
);
    states current_state = IDLE;
    states next_state;
	memory_element [`PAGES * `WORDS_PER_PAGE] memory;

    always_ff @(posedge clk) begin
        current_state <= next_state;
    end

    //Next state logic
    always_comb begin
        unique case (current_state)
            IDLE: if(bus.write_enable) next_state = WRITE;
                  else if(bus.read_enable) next_state = READ;
                  else next_state = IDLE;
            READ: next_state = DONE;
            WRITE: next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

    //Output logic
    always_comb begin
        bus.read_data = bus.read_data;
        bus.mem_finished = 1'b0;

        unique case (current_state)
            IDLE: bus.mem_finished = 1'b0;
            READ: bus.read_data = read_memory(bus.address, read_type);
            WRITE: write_memory(bus.address, bus.write_data);
            DONE: bus.mem_finished = 1'b1;
        endcase
    end

	function word read_memory(input word address, input logic read_type);
		word retval;
		
		if(memory[address].valid == `INVALID) begin
			retval = 12'h0;
		end
		else if( (read_type == `DATA_READ) || (read_type == `INSTRUCTION_FETCH) ) begin
			retval = memory[address].data;
		end
		else begin
			retval = 12'h0;
		end

		return retval;
	endfunction

	function void write_memory(input word address, input word data);
		memory[address].data = data;
		memory[address].valid = 1'b1;
	endfunction
endmodule

`endif
