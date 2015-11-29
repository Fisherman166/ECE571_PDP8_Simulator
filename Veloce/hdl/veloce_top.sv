// Transactor for PDP8 Project and Veloce Emulator
// Jonathan Waldrip / Sean Koppenhafer

`include "CPU_Definitions.pkg"
`include "memory_utils.pkg"

/******************************** Declare Module Ports **********************************/

module veloce_top ();

   
/********************************** Declare Signals ************************************/

// Interfaces for internal modules
main_bus bus();

// Testbench signals
logic        clk              ;
logic        rst              ;
logic [15:0] led              ;
logic [12:0] sw               ;
logic        deposit_btn      ;
logic        load_pc_btn      ;
logic [ 7:0] an               ;
logic [ 6:0] seg              ;
logic        dp               ;
logic        btnc             ;
logic        btnu             ;
logic        btnr             ;
// Signals for send_word_to_HDL
bit [11:0]   mem_address      ;
bit [11:0]   mem_data         ;
bit          mem_done = 0     ;
// Signal for write_mem_trace
logic [1:0]  mem_type         ;
 
/********************************* Instatiate Modules **********************************/

Front_Panel FP0 (.clock(clk),.resetN(rst),.btnd(deposit_btn),.btnl(load_pc_btn),.*);    
CPU CPU0 (.clock(clk),.resetN(rst),.bus(bus));
Controller FSM0 (.clock(clk),.resetN(rst),.bus(bus));
EAE EAE0 (.clock(clk),.resetN(rst),.bus(bus));
memory_controller MEM0 (.clk,.read_type('1),.bus(bus));


//clock generator
//tbx clkgen
initial
begin
	clk = 0;
	forever
	begin
		#10 clk = ~clk;
	end
end

//reset generator
//tbx clkgen
initial
begin
	rst = 0;
	#20 rst = 1;
end

//DPI import functions
import "DPI-C" task init_tracefiles();
import "DPI-C" task init_temp_mem();
import "DPI-C" task send_word_to_hdl(output bit [11:0] mem_address,
                                     output bit [11:0] mem_data,
                                     output bit mem_done);
import "DPI-C" task write_mem_trace(input logic [1:0] mem_type, input word trace_address, 
                                    input word data_bus, input word data_mem);
import "DPI-C" task close_tracefiles();
     
initial begin

     // Initialize Front Panel Buttons to Inactive
     btnc  = 0;
     btnu  = 0;     
     btnr  = 0; 
     load_pc_btn = 0;     
     deposit_btn = 0;
     
     // Initalize files
     $display("before reset");
     @(posedge rst); init_tracefiles();
     $display("after reset");
     
     // Initialize temp memory image
     repeat(10) @(negedge clk); init_temp_mem();
     $display("before init_temp_mem");
     repeat(10) @(negedge clk); Load_PC(12'o0200); 
     $display("PC is %o", bus.curr_reg.pc);
     
     // Copy memory image to PDP8
     while (!mem_done) begin
          send_word_to_hdl(mem_address, mem_data, mem_done);
          Load_PC(mem_address);
          repeat(30) @(negedge clk); Deposit(mem_data);
     end
     $display("after init_temp_mem");
     
     // Set program counter to 200
     repeat(10) @(negedge clk); Load_PC(12'o0200);
     $display("pc set to %o"  , bus.curr_reg.pc);
     
     // Run program
     repeat(10) @(negedge clk); sw[12] = 1;
     $display("run switch set to on");     
 
end

// Write memory trace file
always @(posedge bus.mem_finished) begin
     if (led[12] == 1) begin
          $display("writing memory trace"); 
          if (bus.read_enable) begin
               $display("writing memory trace for read"); 
               if (bus.Curr_State == FETCH_2) mem_type = 2'b01;   
               else mem_type = '0;
               write_mem_trace(mem_type, bus.address, bus.read_data, bus.memory[bus.address].data);     
          end
          if (bus.write_enable) begin
               $display("writing memory trace for write"); 
               mem_type = 2'b10;
               write_mem_trace(mem_type, bus.address, bus.write_data, bus.memory[bus.address].data);     
          end
     end     
end

// End
always @(negedge led[12]) begin
    close_tracefiles();
    print_valid_memory();
    $display("after print memory");
    $finish();
end
 
task Load_PC(input bit [11:0] pc);
    static word pc_value;
    $cast(pc_value, pc);
    $display("Before PC: %o, input: %o", bus.curr_reg.pc, pc);
    repeat(10) @ (negedge clk); sw[11:0] = pc_value;
    repeat(10) @ (negedge clk); load_pc_btn = 1;
    repeat(10) @ (negedge clk); load_pc_btn = 0; 
    $display("After PC: %o", bus.curr_reg.pc);
endtask

task Deposit(input bit [11:0] data);
    static word data_value;
    $cast(data_value, data);
    repeat(10) @ (negedge clk); sw[11:0] = data_value;
    repeat(10) @ (negedge clk); deposit_btn = 1;
    repeat(10) @ (negedge clk); deposit_btn = 0;
endtask 

 function void print_valid_memory();
        automatic integer file = $fopen("valid_memory_sv.txt", "w");

            if(!file) $display ("Error opening valid_memory_sv.txt file");

		$fdisplay(file, "Address    Contents");
		$fdisplay(file, "-------    --------");

		for(int i = 0; i < 4096; i++) begin
			//if(bus.memory[i].valid === 1'b1) begin
				$fdisplay(file, "%04o        %04o", i, bus.memory[i].data);
			//end //if
		end //for

        $fclose(file);
	endfunction
	
endmodule

//
