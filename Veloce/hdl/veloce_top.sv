// Transactor for PDP8 Project and Veloce Emulator
// Jonathan Waldrip / Sean Koppenhafer

`include "CPU_Definitions.pkg"
`include "memory_utils.pkg"

//Defines for easy access to signals
`define READ_ENABLE     bus.read_enable
`define WRITE_ENABLE    bus.write_enable
`define MEM_FINISHED    bus.mem_finished
`define MEM_ADDRESS     bus.address
`define MEM_VALID       bus.memory[bus.address].valid
`define MEM_READ_DATA   bus.read_data
`define MEM_DATA        bus.memory[bus.address].data
`define MEM_WRITE_DATA  bus.write_data
`define AC_REG          bus.curr_reg.ac
`define PC_REG          bus.curr_reg.pc
`define IR_REG          bus.curr_reg.ir
`define MB_REG          bus.curr_reg.mb
`define EA_REG          bus.curr_reg.ea
`define LINK            bus.curr_reg.lk
`define CURR_STATE      bus.Curr_State
`define RUN_LED         led[12]
`define IDLE_LED        led[13]
`define RUN_SWITCH      sw[12]
`define ON              1
`define OFF             0

//Opcodes for instruction text
`define OPCODE_AND     3'o0
`define OPCODE_TAD     3'o1
`define OPCODE_ISZ     3'o2
`define OPCODE_DCA     3'o3
`define OPCODE_JMS     3'o4
`define OPCODE_JMP     3'o5

// Group 1 micro instructions
`define MICRO_INSTRUCTION_CLA 12'o7200
`define MICRO_INSTRUCTION_CLL 12'o7100
`define MICRO_INSTRUCTION_CMA 12'o7040
`define MICRO_INSTRUCTION_CML 12'o7020
`define MICRO_INSTRUCTION_IAC 12'o7001
`define MICRO_INSTRUCTION_RAR 12'o7010
`define MICRO_INSTRUCTION_RTR 12'o7012
`define MICRO_INSTRUCTION_RAL 12'o7004
`define MICRO_INSTRUCTION_RTL 12'o7006

// Group 2 micro instructions
`define MICRO_INSTRUCTION_SMA 12'o7500
`define MICRO_INSTRUCTION_SZA 12'o7440
`define MICRO_INSTRUCTION_SNL 12'o7420
`define MICRO_INSTRUCTION_SPA 12'o7510
`define MICRO_INSTRUCTION_SNA 12'o7450
`define MICRO_INSTRUCTION_SZL 12'o7430
`define MICRO_INSTRUCTION_SKP 12'o7410
`define MICRO_INSTRUCTION_CLA2 12'o7600
`define MICRO_INSTRUCTION_OSR 12'o7404
`define MICRO_INSTRUCTION_HLT 12'o7402

//Group 3 micro instructions
`define MICRO_INSTRUCTION_CLA3 12'o7601
`define MICRO_INSTRUCTION_MQL 12'o7421
`define MICRO_INSTRUCTION_MQA 12'o7501
`define MICRO_INSTRUCTION_SWP 12'o7521
`define MICRO_INSTRUCTION_CAM 12'o7621

//Memory Trace
`define D_READ      2'b00
`define I_FETCH     2'b01 
`define D_WRITE     2'b10

//Write branch trace file
`define UNCONDITIONAL    2'b00 
`define CONDITIONAL      2'b01 
`define SUBROUTINE       2'b10 
`define TAKEN            1'b1  
`define NOT_TAKEN        1'b0

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
bit [11:0]   mem_address      ;
bit [11:0]   mem_data         ;
bit          mem_done = 0     ;
// Signal for write_mem_trace
logic [1:0]  mem_type         ;
// Signals for write_branch_trace
word            pc_temp                 ;
bit             cond_skip_flag          ;

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
	rst = 0;
	#20 rst = 1;
end

//DPI import functions
import "DPI-C" task init_tracefiles();
import "DPI-C" task init_temp_mem();
import "DPI-C" task send_word_to_hdl(output bit [11:0] mem_address,
                                     output bit [11:0] mem_data,
                                     output bit mem_done);
import "DPI-C" task write_mem_trace(input logic [1:0] mem_type, input word trace_address, 
                                    input word data_bus, input word data_mem);
import "DPI-C" task write_branch_trace(input word current_pc, input word target_pc, 
                                       input bit [1:0] branch_type, input bit taken);
import "DPI-C" task write_valid_memory(input word address, input word data);
import "DPI-C" task write_opcode(input word ir_reg, input word ac_reg,
                                 input bit link   , input word mb_reg,
                                 input word pc_reg, input word ea_reg);
import "DPI-C" task close_tracefiles();

initial begin
     // Initalize files
     @(posedge rst); init_tracefiles();
end
     
initial begin
     // Initialize Front Panel Buttons to Inactive
     btnc  = 0;
     btnu  = 0;     
     btnr  = 0; 
     load_pc_btn = 0;     
     deposit_btn = 0;
     
     
     // Initialize temp memory image
     repeat(10) @(negedge clk); init_temp_mem();
     repeat(10) @(negedge clk); Load_PC(12'o0200); 
     
     // Copy memory image to PDP8
     while (!mem_done) begin
          send_word_to_hdl(mem_address, mem_data, mem_done);
          Load_PC(mem_address);
          repeat(30) @(negedge clk); Deposit(mem_data);
     end
     
     // Set program counter to 200
     repeat(10) @(negedge clk); Load_PC(12'o0200);
     
     // Run program
     repeat(10) @(negedge clk); `RUN_SWITCH = `ON;
 
end

// Generates memory trace file
always @(posedge `MEM_FINISHED) begin
     if (`RUN_LED == `ON) begin
          if (`READ_ENABLE) begin
               if (`CURR_STATE == FETCH_2) mem_type = `I_FETCH;   
               else mem_type = `D_READ;
               write_mem_trace(mem_type, `MEM_ADDRESS, `MEM_READ_DATA, `MEM_DATA);     
          end
          if (`WRITE_ENABLE) begin
               mem_type = `D_WRITE;
               write_mem_trace(mem_type, `MEM_ADDRESS, `MEM_WRITE_DATA, `MEM_DATA);      
          end
     end     
end

// Generates branch trace file
always @(posedge clk) begin
     if (`CURR_STATE === JMS_1)
          write_branch_trace(`PC_REG, (`EA_REG + 1), `SUBROUTINE, `TAKEN); 
     if (`CURR_STATE === JMP_1)
          write_branch_trace(`PC_REG, `EA_REG,  `UNCONDITIONAL, `TAKEN); 
     if (`CURR_STATE === MIC_2 || `CURR_STATE === ISZ_1) begin
          pc_temp = `PC_REG;
          if (`IR_REG[2]) cond_skip_flag = 0; // for OSR instruction
          else cond_skip_flag = 1;
     end     
     // If returned to idle state and flag is 1, print trace info
     else if (((`CURR_STATE === CPU_IDLE) || (`CURR_STATE === HALT))  && cond_skip_flag && `RUN_LED) begin
          cond_skip_flag = 0;
          if(`IR_REG === `MICRO_INSTRUCTION_SKP) // skip instruction
               write_branch_trace(pc_temp, pc_temp + 1,  `UNCONDITIONAL, `TAKEN); 
          else if ((`PC_REG - pc_temp) !== 0)
               write_branch_trace(pc_temp, pc_temp + 1,  `CONDITIONAL  , `TAKEN); 
          else
               write_branch_trace(pc_temp, pc_temp + 1,  `CONDITIONAL  , `NOT_TAKEN); 
    end     
end

// Print contents of all registers after each instruction
always @(posedge `IDLE_LED) begin
     //Only print this 
     if(`RUN_LED === `ON) begin
          write_opcode(`IR_REG[11:9], `AC_REG, `LINK, `MB_REG, `PC_REG, `EA_REG);
     end
end

// End
always @(negedge `RUN_LED) begin
    print_valid_memory();
    close_tracefiles();
    $finish();
end
 
task Load_PC(input bit [11:0] pc);
    static word pc_value;
    $cast(pc_value, pc);
    repeat(10) @ (negedge clk); sw[11:0] = pc_value;
    repeat(10) @ (negedge clk); load_pc_btn = 1;
    repeat(10) @ (negedge clk); load_pc_btn = 0; 
endtask

task Deposit(input bit [11:0] data);
    static word data_value;
    $cast(data_value, data);
    repeat(10) @ (negedge clk); sw[11:0] = data_value;
    repeat(10) @ (negedge clk); deposit_btn = 1;
    repeat(10) @ (negedge clk); deposit_btn = 0;
endtask 

task print_valid_memory();
     for(int i = 0; i < 4096; i++) begin
          `MEM_ADDRESS = i;
          if(`MEM_VALID) begin
               write_valid_memory(`MEM_ADDRESS, `MEM_DATA);
		end // if
	end //for
endtask

endmodule

//
