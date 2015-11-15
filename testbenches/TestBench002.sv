// TestBench001 for PDP8 Project
// Jonathan Waldrip

`ifndef CPU_DEF_PKG
     `include "CPU_Definitions.pkg"
`endif

`include "memory_utils.pkg"
     
/******************************** Declare Module Ports **********************************/

module TestBench002 ();
            
            
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
int          file, read_count1, read_count2;               
bit   [11:0] high_byte, low_byte;
word         word_value;
word         address = 0;
memory_element mem_image [`PAGES * `WORDS_PER_PAGE];

  
  
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
     
     // read compiled asm file from pal assembler using pal -o option
     file = $fopen("init_mem.obj", "r");
     for(;;) begin
          read_count1 = $fscanf(file, "%03o", high_byte);
          read_count2 = $fscanf(file, "%03o", low_byte);
          if(read_count1 == $eof || read_count2 == $eof) break;

          word_value = {high_byte[5:0], low_byte[5:0]};
          if(high_byte[6] === 1'b1) begin
             address = word_value;
          end
          else begin
             mem_image[address].data = word_value;
             mem_image[address].valid = 1'b1;
             address++;
         end    
        repeat(1) @ (negedge clk);
     end
     $fclose(file);                               // Close file       
     
     
     // Set program counter to 0
     repeat(10) @ (negedge clk); sw[11:0] = 0;
     repeat(10) @ (negedge clk); Load_PC = 1;
     repeat(10) @ (negedge clk); Load_PC = 0;  
     
     
     // Copy memory image to PDP8
     for(m = 0; m < `PAGES * `WORDS_PER_PAGE; m++) begin 
          if(mem_image[m].valid === 1'b0) continue;
          else begin
              repeat(10) @ (negedge clk); sw[11:0] = mem_image[m];
              repeat(10) @ (negedge clk); Deposit = 1;
              repeat(10) @ (negedge clk); Deposit = 0;
          end
     end
     
     // Set program counter to 200
     repeat(10) @ (negedge clk); sw[11:0] = 12'o0200;
     repeat(10) @ (negedge clk); Load_PC = 1;
     repeat(10) @ (negedge clk); Load_PC = 0;
     
     // Run program
      repeat(10) @ (negedge clk); sw[12] = 1;
     
     
end 
 
endmodule
