// ECE571 Project: PDP8 Simulator
// memory_controller.sv

`ifndef MEMORY_H
`define MEMORY_H

`include "memory_utils.pkg"

import memory_utils::*;

module memory_controller(
	input word address,
	input word write_data,
    input logic clk,
	input logic read_enable,
	input logic read_type,
	input logic write_enable,
	output word read_data,
    output logic operation_done
);
    states current_state = IDLE;
    states next_state;

    always_ff @(posedge clk) begin
        current_state <= next_state;
        //FIXME - this display is needed for some reason
        //otherwise current_state never updates to next_state
        $display("no idea = %b", next_state);
    end

    //Next state logic
    always_comb begin
        unique case (current_state)
            IDLE: if(write_enable) next_state = WRITE;
                  else if(read_enable) next_state = READ;
                  else next_state = IDLE;
            READ: next_state = DONE;
            WRITE: next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

    //Output logic
    always_comb begin
        read_data = read_data;
        operation_done = 1'b0;

        unique case (current_state)
            IDLE: operation_done = 1'b0;
            READ: read_data = read_memory(address, read_type);
            WRITE: write_memory(address, write_data);
            DONE: operation_done = 1'b1;
        endcase
    end

	function word read_memory(input word address, input logic read_type);
		word retval;
		
		if(memory[address].valid === `INVALID) begin
			`ifdef SIMULATION
				$display("Attempting to read from invalid address %04o", address);
			`endif
			retval = 12'h0;
		end
		else if( (read_type === `DATA_READ) || (read_type === `INSTRUCTION_FETCH) ) begin
			retval = memory[address].data;

			`ifdef SIMULATION
				if(read_type === `DATA_READ) $fdisplay(memory_trace_file, "DR %04o", address);
				else $fdisplay(memory_trace_file, "IF %04o\n", address);
			`endif
		end
		else begin
			`ifdef SIMULATION	
				$fdisplay(memory_trace_file, "Read type not recongized at address %04o", address);
			`endif
			retval = 12'h0;
		end

		return retval;
	endfunction

	function void write_memory(input word address, input word data);
		`ifdef SIMULATION
			$fdisplay(memory_trace_file, "DW %04o", address);
		`endif

		memory[address].data = data;
		memory[address].valid = 1'b1;
	endfunction
endmodule

`endif

