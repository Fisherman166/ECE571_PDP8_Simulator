// ECE571 Project: PDP8 Simulator
// memory_controller.sv

`ifndef MEMORY_H
`define MEMORY_H

`include "memory_utils.pkg"
`include "CPU_Definitions.pkg"

module memory_controller(
    input logic clk,
    input logic read_type,
    memory_pins.slave pins
);
    states current_state = IDLE;
    states next_state;

    always_ff @(posedge clk) begin
        current_state <= next_state;
    end

    //Next state logic
    always_comb begin
        unique case (current_state)
            IDLE: if(pins.write_enable) next_state = WRITE;
                  else if(pins.read_enable) next_state = READ;
                  else next_state = IDLE;
            READ: next_state = DONE;
            WRITE: next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

    //Output logic
    always_comb begin
        pins.read_data = pins.read_data;
        pins.mem_finished = 1'b0;

        unique case (current_state)
            IDLE: pins.mem_finished = 1'b0;
            READ: pins.read_data = read_memory(pins.address, read_type);
            WRITE: write_memory(pins.address, pins.write_data);
            DONE: pins.mem_finished = 1'b1;
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

