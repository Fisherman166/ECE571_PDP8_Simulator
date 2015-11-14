// EAE for PDP8 Project
// Jonathan Waldrip

`include "CPU_Definitions.pkg"


/******************************** Declare Module Ports **********************************/

module EAE (input logic clock, 
            input logic resetN,
            eae_pins.slave cpu
            );

           
           
           
/********************************** Declare Signals ************************************/   
          
logic       start     ;
logic       finished  ;
logic       fin_div   ;
logic [23:0] product  ;
logic [23:0] dividend ;
logic [11:0] quotient ;
logic [11:0] remainder;                       

/************************************** Main Body **************************************/


assign start = cpu.eae_start;
assign dividend = {cpu.curr_reg.ac, cpu.curr_reg.mq};

//temp
assign cpu.mq_mul   = 0;
assign cpu.ac_mul   = 0;
assign cpu.mq_dvi   = 0;
assign cpu.ac_dvi   = 0;
assign cpu.link_dvi = 0;



endmodule
