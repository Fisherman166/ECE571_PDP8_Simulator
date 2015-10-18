// ECE571 Project: PDP8 Simulator
// memory_controller.sv

`ifndef MEMORY_H
`define MEMORY_H

`include "memory_utils.pkg"

import memory_utils::*;

module memory_controller(
	input word address,
	input word write_data,
	input logic read_enable,
	input logic read_type,
	input logic write_enable,
	output word read_data
);

	always_ff @(address, write_data, read_enable, write_enable) begin
		if( (read_enable === 1'b1) && (write_enable === 1'b1) ) begin
			`ifdef SIMULATION
				$display("memory controller ERROR: read enable and write enable high");
			`endif
			read_data <= read_data;
		end
		else if(read_enable === 1'b1) begin
			read_data <= read_memory(address, read_type);
		end
		else
			write_memory(address, write_data);
			read_data <= read_data;
		end
	end

	function word read_memory(word address, logic read_type);
		word retval;
		
		if(memory[address].valid === INVALID) begin
			`ifdef SIMULATION
				$display("Attempting to read from invalid address %04o", address);
			`endif
			retval <= 12'h0;
		end
		else if( (read_type === READ_DATA) || (read_type === INSTRUCTION_FETCH) ) begin
			retval = memory[address];

			`ifdef SIMULATION
				if(read_type === READ_DATA) $fdisplay(memory_trace_file, "DR %04o\n", address);
				else $fdisplay(memory_trace_file, "IF %04o\n", address);
			`endif
		end
		else begin
			`ifdef SIMULATION	
				$fdisplay(memory_trace_file, "Read type not recongized at address %04o\n", address);
			`endif
			retval <= 12'h0;
		end

		return retval;
	endfunction

	function write_memory(word address, word data);
		`ifdef SIMULATION
			$fdisplay(memory_trace_file, "DW %04o\n", address);
		`endif

		memory[address].data = data;
		memory[address].valid = 1'b1;
	endfunction
endmodule

