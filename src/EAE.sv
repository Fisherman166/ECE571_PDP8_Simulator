// EAE for PDP8 Project
// Jonathan Waldrip

`include "CPU_Definitions.pkg"


/******************************** Declare Module Ports **********************************/

module EAE (input logic clock, 
            input logic resetN,
            eae_pins.slave cpu
            );

           
           
           
/********************************** Declare Signals ************************************/   
          
logic        start     ;
logic        finished  ;
logic        fin_div   ;
logic [23:0] product  ;
logic [23:0] dividend ;
logic [11:0] quotient ;
logic [11:0] remainder;

/********************************* Instatiate Modules **********************************/

Multiply MUL0 (.clock                        ,    
               .multiplier(cpu.curr_reg.mq)  ,
               .multiplicand(cpu.curr_reg.mb),
               .start(cpu.eae_start)         ,
               .product                      ,
               .finished        
               );
                 
Divide DIV0   (.clock                        ,
               .dividend                     ,
               .divisor(cpu.curr_reg.mb)     ,
               .start(cpu.eae_start)         ,
               .quotient                     ,
               .remainder                    ,
               .link_out(cpu.link_dvi)       ,
               .finished(fin_div)   
               );                 
                       

/************************************** Main Body **************************************/


assign start = cpu.eae_start;
assign dividend = {cpu.curr_reg.ac, cpu.curr_reg.mq};
assign cpu.eae_fin = finished;

always_ff @(posedge clock) begin
     if (finished === 1) begin
          cpu.ac_mul <= product[23:12];
          cpu.mq_mul <= product[11: 0];
     end
     
     if (fin_div === 1) begin
          cpu.ac_dvi <= remainder;
          cpu.mq_dvi <= quotient ;
     end
end 

endmodule
