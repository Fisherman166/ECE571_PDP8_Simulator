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
import "DPI-C" task write_branch_trace(input word current_pc, input word target_pc, 
                                       input bit [1:0] branch_type, input bit taken);
import "DPI-C" task close_tracefiles();

initial begin
     // Initalize files
     @(posedge rst); init_tracefiles();
end
     
initial begin
     // Initialize Front Panel Buttons to Inactive
     btnc  = 0;
     btnu  = 0;     
     btnr  = 0; 
     load_pc_btn = 0;     
     deposit_btn = 0;
     
     
     // Initialize temp memory image
     repeat(10) @(negedge clk); init_temp_mem();
     repeat(10) @(negedge clk); Load_PC(12'o0200); 
     
     // Copy memory image to PDP8
     while (!mem_done) begin
          send_word_to_hdl(mem_address, mem_data, mem_done);
          Load_PC(mem_address);
          repeat(30) @(negedge clk); Deposit(mem_data);
     end
     
     // Set program counter to 200
     repeat(10) @(negedge clk); Load_PC(12'o0200);
     
     // Run program
     repeat(10) @(negedge clk); sw[12] = 1;
 
end

// Write memory trace file
always @(posedge bus.mem_finished) begin
     if (led[12] == 1) begin
          if (bus.read_enable) begin
               if (bus.Curr_State == FETCH_2) mem_type = 2'b01;   
               else mem_type = '0;
               write_mem_trace(mem_type, bus.address, bus.read_data, bus.memory[bus.address].data);     
          end
          if (bus.write_enable) begin
               mem_type = 2'b10;
               write_mem_trace(mem_type, bus.address, bus.write_data, bus.memory[bus.address].data);     
          end
     end     
end

// End
always @(negedge led[12]) begin
    close_tracefiles();
    $finish();
end
 
task Load_PC(input bit [11:0] pc);
    static word pc_value;
    $cast(pc_value, pc);
    repeat(10) @ (negedge clk); sw[11:0] = pc_value;
    repeat(10) @ (negedge clk); load_pc_btn = 1;
    repeat(10) @ (negedge clk); load_pc_btn = 0; 
endtask

task Deposit(input bit [11:0] data);
    static word data_value;
    $cast(data_value, data);
    repeat(10) @ (negedge clk); sw[11:0] = data_value;
    repeat(10) @ (negedge clk); deposit_btn = 1;
    repeat(10) @ (negedge clk); deposit_btn = 0;
endtask 

endmodule

//
