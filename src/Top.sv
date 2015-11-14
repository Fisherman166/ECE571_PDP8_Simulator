// Top Level for PDP8 Project
// Jonathan Waldrip

`include "CPU_Definitions.pkg"


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
            input  logic        btnr              
            );
            
            
/********************************** Declare Signals ************************************/


// Interfaces for internal modules
front_panel_pins fp ();
iot_pins         iot();
memory_pins      mem();
  
  
/********************************* Instatiate Modules **********************************/

Front_Panel FP0 (.*,.clock(clk),.resetN(btnCpuReset), .fp(fp));    
CPU CPU0 (.*,.clock(clk),.resetN(btnCpuReset), .fp(fp));
memory_controller MEM0 (.*,.read_type('1),.pins(mem));
 
endmodule