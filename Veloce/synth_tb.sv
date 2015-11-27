// Synthesizable testbench for PDP8 project - ECE 571
// Jonathan Waldrip and Sean Koppenhafer

`include "CPU_Definitions.pkg"
`include "memory_utils.pkg"

/******************************** Declare Module Ports **********************************/

module synth_tb ();

logic          clk                 ;
logic          btnCpuReset = 1     ;
logic [15:0]   led                 ;
logic [ 7:0]   an                  ;
logic [ 6:0]   seg                 ;
logic          dp                  ;
logic [12:0]   sw   = 0            ;
logic          Display_Select = 0  ;
logic          Step    = 0         ;
logic          Deposit = 0         ;
logic          Load_PC = 0         ;
logic          Load_AC = 0         ;
bit   [11:0]   mem_image [4096]    ;
int            m                   ;     
  
/********************************* Instatiate Modules **********************************/

Top TOP0 (.btnc(Display_Select) ,
          .btnu(Step          ) ,
          .btnd(Deposit       ) ,
          .btnl(Load_PC       ) ,
          .btnr(Load_AC       ) ,             
          .*);    
 
/************************************** Main Body **************************************/
// Generate clock signal
    
//tbx clkgen
initial begin
     clk = 0;
     forever begin
         #10 clk = ~clk;  
     end
end

// Run test
initial begin
     // Hold reset low on DUT for 5 clock cycles
     btnCpuReset = 0;
     repeat(5) @ (negedge clk); btnCpuReset = 1;
     
     
     // Load test file to memory
     $readmemb("class3a.txt", mem_image);
     
     
     // Set program counter to 0
     repeat(10) @ (negedge clk); sw[11:0] = 0;
     repeat(10) @ (negedge clk); Load_PC = 1;
     repeat(10) @ (negedge clk); Load_PC = 0;  
     
     
     // Copy memory image to PDP8
     for(m = 0; m < 4096; m++) begin 
          repeat(10) @ (negedge clk); sw[11:0] = mem_image[m];
          repeat(10) @ (negedge clk); Deposit = 1;
          repeat(10) @ (negedge clk); Deposit = 0;
     end
     
     // Set program counter to 200
     repeat(10) @ (negedge clk); sw[11:0] = 12'o0200;
     repeat(10) @ (negedge clk); Load_PC = 1;
     repeat(10) @ (negedge clk); Load_PC = 0;
     
     // Run program
     repeat(10) @ (negedge clk); sw[12] = 1;
     
     
end 
    
// When program completes
always @(negedge led[12]) begin
     for(m = 0; m < 4096; m++) begin 
          mem_image[m] =  TOP0.MEM0.memory [12:1];
     end

     $writememb("mem_out.txt", mem_image);
     //$finish();
end  

endmodule
