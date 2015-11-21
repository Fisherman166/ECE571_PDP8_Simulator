// TestBench001 for PDP8 Project
// Jonathan Waldrip

`ifndef CPU_DEF_PKG
     `include "CPU_Definitions.pkg"
`endif
     
/******************************** Declare Module Ports **********************************/

module TestBench001 ();
            
            
/********************************** Declare Signals ************************************/

bit   clk         ;
logic btnCpuReset = 1 ;
logic [15:0] led  ;
logic [ 7:0] an   ;
logic [ 6:0] seg  ;
logic        dp   ;
logic [12:0] sw   = 0;
logic        Display_Select = 0 ;
logic        Step    = 0 ;
logic        Deposit = 0 ;
logic        Load_PC = 0 ;
logic        Load_AC = 0 ;
int          m;  
int          line_count = 0;
int          file,c;               
bit   [11:0] temp;
bit   [11:0] mem_image [4096];
int          reg_file;
  
  
/********************************* Instatiate Modules **********************************/

Top TOP0 (.btnc(Display_Select) ,
          .btnu(Step          ) ,
          .btnd(Deposit       ) ,
          .btnl(Load_PC       ) ,
          .btnr(Load_AC       ) ,             
          .*);    
 
/************************************** Main Body **************************************/
 
// Generate clock signal
always #10 clk = ~clk;  
 
// Run test
initial begin
     // Hold reset low on DUT for 5 clock cycles
     btnCpuReset = 0;
     repeat(5) @ (negedge clk); btnCpuReset = 1;
     
     // Open File
     reg_file = $fopen("opcode_output.txt", "w");
     if(!reg_file) $display ("Error opening valid_memory_sv.txt file");
     
     // read compiled asm file
     file = $fopen("-class3a.txt", "r");           // Open file compiled asm file
     while (!$feof(file)) begin                   // Read line by line
          c = $fscanf(file, "%b", temp);          // Each line has contents of a memory location
          mem_image [line_count] = temp;          // write each line to memory image
          line_count ++;                          // Count number of calculations
          repeat(1) @ (negedge clk);
     end
     $fclose(file);                               // Close file       
     
     
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

// Print all valid memeory when halt instuction executes
always @(negedge led[12]) begin
      print_valid_memory();
      $fclose(reg_file); 
end

// Print contenets of each register after every instruction


always @(posedge led[13]) begin

     

     if(led[12] == 1)
          $fdisplay(reg_file, "Opcode: %03o, AC: %o, Link: %b, MB: %o, PC: %o, CPMA: %o", 
               TOP0.bus.curr_reg.ir[11:9], TOP0.bus.curr_reg.ac, TOP0.bus.curr_reg.lk,
               TOP0.bus.curr_reg.mb, TOP0.bus.curr_reg.pc, TOP0.bus.curr_reg.ea);
     
end


 
endmodule