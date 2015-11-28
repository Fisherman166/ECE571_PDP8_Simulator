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
word         address          ;
word         data             ;
logic        done             ;
// Signal for write_mem_trace
integer      mem_type         ;
 
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
	rst = 1;
	#20 rst = 0;
end

//DPI import functions
import "DPI-C" task init_tracefiles();
import "DPI-C" task init_temp_mem();
import "DPI-C" task send_word_to_hdl(output word address, output word data, output logic done);
import "DPI-C" task write_mem_trace(input integer mem_type, input word trace_address, 
                                    input word data_bus, input word data_mem);
import "DPI-C" task close_tracefiles();
     
initial begin
     
     // Initalize files
     @(negedge rst); init_tracefiles();
     
     // Initialize temp memory image
     repeat(10) @(negedge clk); init_temp_mem();
     
     // Set program counter to 0
     repeat(10) @(negedge clk); Load_PC(0); 
     
     // Copy memory image to PDP8
     while (done != 1) begin
          send_word_to_hdl(address, data, done);
          Deposit(data);
     end
     
     // Set program counter to 200
     repeat(10) @(negedge clk); Load_PC(12'o0200); 
     
     // Run program
     repeat(10) @(negedge clk); sw[12] = 1;
     
     // Write memory trace file
     while (led[12] == 1) begin
     @(posedge bus.mem_finished);
          if (bus.read_enable) begin
               if (bus.Curr_State == FETCH_2) mem_type = 1;   
               else mem_type = 0;
          write_mem_trace(mem_type, bus.address, bus.read_data, bus.memory[bus.address]);     
          end
          if (bus.write_enable) begin
          mem_type = 2;
          write_mem_trace(mem_type, bus.address, bus.write_data, bus.memory[bus.address]);     
          end
     end
     
     // End
     @(negedge led[12]); close_tracefiles();
     @(negedge clk);
     $finish;
     

end
 
 
task Load_PC(input word pc);
    repeat(10) @ (negedge clk); sw[11:0] = pc;
    repeat(10) @ (negedge clk); load_pc_btn = 1;
    repeat(10) @ (negedge clk); load_pc_btn = 0; 
endtask

task Deposit(input word data);
    repeat(10) @ (negedge clk); sw[11:0] = data;
    repeat(10) @ (negedge clk); deposit_btn = 1;
    repeat(10) @ (negedge clk); deposit_btn = 0;
endtask 
     
	
endmodule