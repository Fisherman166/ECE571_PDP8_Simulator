// Top Level for PDP8 Project
// Jonathan Waldrip

//`include "CPU_Definitions.pkg"


/******************************** Declare Module Ports **********************************/

module Top (input logic clk           ,
            input logic btnCpuReset   ,
            output logic [15:0] led   ,
            output logic [ 7:0] an    ,
            output logic [ 6:0] seg   ,
            output logic        dp    ,
            input  logic [12:0] sw    ,
            input  logic        btnc  ,
            input  logic        btnu  ,
            input  logic        btnd  ,
            input  logic        btnl  ,
            input  logic        btnr  ,
		  output logic        read_data ,   
		  output logic        mem_finished ,		  
	       output memory_element [`PAGES * `WORDS_PER_PAGE] memory,    		  
		  output PDP8_Registers_t curr_reg  ,   		  
	       output Controller_states_t Curr_State,		  
		  output logic [11:0] address,      		  
		  output logic [11:0] write_data ,  		  
		  output logic 	  write_enable, 		  
		  output logic        read_enable , 		  
		  output logic        read_type    		  
            );
            
            
/********************************** Declare Signals ************************************/


// Interfaces for internal modules
main_bus wires();

 
/********************************* Instatiate Modules **********************************/

Front_Panel FP0 (.*,.clock(clk),.resetN(btnCpuReset),.bus(wires));    
CPU CPU0 (.clock(clk),.resetN(btnCpuReset),.bus(wires));
Controller FSM0 (.clock(clk),.resetN(btnCpuReset),.bus(wires));
EAE EAE0 (.clock(clk),.resetN(btnCpuReset),.bus(wires));
memory_controller MEM0 (.clk,.read_type('1),.bus(wires));

//Signals for TBX testbench
assign read_type    = wires.read_type   ;
assign mem_finished = wires.mem_finished;
assign read_data    = wires.read_data   ;
assign memory      	= wires.memory      ;
assign curr_reg     = wires.curr_reg    ;	  
assign Curr_State 	= wires.Curr_State 	;	  
assign address      = wires.address     ;		  
assign write_data   = wires.write_data  ;		  
assign write_enable = wires.write_enable;		  
assign read_enable  = wires.read_enable ;		  		  



 
endmodule