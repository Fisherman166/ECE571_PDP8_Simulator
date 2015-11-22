// TestBench001 for PDP8 Project
// Jonathan Waldrip


`include "CPU_Definitions.pkg"

     
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
int          line_count = 0;
int          file,c,m,reg_file,branch_file;               
bit   [11:0] temp;
bit   [11:0] mem_image [4096];
Controller_states_t CPU_State;
logic [11:0] pc_temp;
logic        cond_skip_flag = 0;


  
  
/********************************* Instatiate Modules **********************************/

Top TOP0 (.btnc(Display_Select) ,
          .btnu(Step          ) ,
          .btnd(Deposit       ) ,
          .btnl(Load_PC       ) ,
          .btnr(Load_AC       ) ,             
          .*);    
 
/************************************** Main Body **************************************/
 
// Monitor CPU state machine current state
assign CPU_State = TOP0.FSM0.Curr_State; 

 
// Generate clock signal
always #10 clk = ~clk;  
 
// Run test
initial begin
     // Hold reset low on DUT for 5 clock cycles
     btnCpuReset = 0;
     repeat(5) @ (negedge clk); btnCpuReset = 1;
     
     // Open files for trace outputs
     reg_file = $fopen("opcode_output.txt", "w");
     if(!reg_file) $display ("Error opening opcode_output.txt file");
     
     branch_file = $fopen("branch_trace.txt", "w");
     if(!branch_file) $display ("Error opening branch_trace.txt file");
     
     // read compiled asm file
     file = $fopen("-class3a.txt", "r");           // Open file compiled asm file
     if(!file) $display ("Error opening program file");
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

// Print contenets of each register to file after every instruction
always @(posedge led[13]) begin
     if(led[12] == 1)
          $fdisplay(reg_file, "Opcode: %03o, AC: %o, Link: %b, MB: %o, PC: %o, CPMA: %o", 
               TOP0.bus.curr_reg.ir[11:9], TOP0.bus.curr_reg.ac, TOP0.bus.curr_reg.lk,
               TOP0.bus.curr_reg.mb, TOP0.bus.curr_reg.pc, TOP0.bus.curr_reg.ea);
end

// Print branch trace file
always_comb begin
      // JMP and JMS
     if (CPU_State === JMP_1 || CPU_State === JMS_1)
          $fdisplay(branch_file, "Current PC: %04o, Target: %04o, Type: Unconditional, Result: Taken",
                    TOP0.bus.curr_reg.pc, TOP0.bus.curr_reg.ea);
                    
     // If microcoded group2 or ISZ, record current PC to temp and set flag              
     if ((CPU_State === MIC_2) || (CPU_State === ISZ_1)) begin 
          pc_temp = TOP0.bus.curr_reg.pc;
          cond_skip_flag = 1;
     end 
     // If returned to idle state and flag is 1, print trace info
     else if ((CPU_State === CPU_IDLE) && (cond_skip_flag === 1) && led[12] === 1) begin
          cond_skip_flag = 0;
          if ((TOP0.bus.curr_reg.pc - pc_temp) > 1) 
          $fdisplay(branch_file, "Current PC: %04o, Target: %04o, Type: Conditional,   Result: Taken",
                    pc_temp, pc_temp + 2);
          else
          $fdisplay(branch_file, "Current PC: %04o, Target: %04o, Type: Conditional,   Result: Not Taken",
                    pc_temp, pc_temp + 2);
     end     
end

// At end of program
always @(negedge led[12]) begin
      print_valid_memory();        // Print all valid memeory to file
      $fclose(reg_file);           // Close file for regisiter log 
      $fclose(branch_file);        // Close file for regisiter log    
end
 
endmodule