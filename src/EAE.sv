// EAE for PDP8 Project
// Jonathan Waldrip

`include "CPU_Definitions.pkg"
`include "memory_utils.pkg"


/******************************** Declare Module Ports **********************************/

module EAE (input logic clock, 
            input logic resetN,
            main_bus.eae bus
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
               .multiplier(bus.curr_reg.mq)  ,
               .multiplicand(bus.curr_reg.mb),
               .start(bus.eae_start)         ,
               .product                      ,
               .finished        
               );
                 
Divide DIV0   (.clock                        ,
               .dividend                     ,
               .divisor(bus.curr_reg.mb)     ,
               .start(bus.eae_start)         ,
               .quotient                     ,
               .remainder                    ,
               .link_out(bus.link_dvi)       ,
               .finished(fin_div)   
               );                 
                       

/************************************** Main Body **************************************/


assign start = bus.eae_start;
assign dividend = {bus.curr_reg.ac, bus.curr_reg.mq};
assign bus.eae_fin = finished;

always_ff @(posedge clock) begin
     if (finished == 1) begin
          bus.ac_mul <= product[23:12];
          bus.mq_mul <= product[11: 0];
     end
     
     if (fin_div == 1) begin
          bus.ac_dvi <= remainder;
          bus.mq_dvi <= quotient ;
     end
end 

endmodule
