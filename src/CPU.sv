// CPU for PDP8 Project
// Jonathan Waldrip

`include "CPU_Definitions.pkg"
`include "memory_utils.pkg"


/******************************** Declare Module Ports **********************************/

module CPU (input logic clock, 
            input logic resetN,
            main_bus.cpu bus
            );
            
            
/********************************** Declare Signals ************************************/

// Outputs of comb blocks to update registers
PDP8_Registers_t next_reg;

// Outputs of comb blocks to update memory, front panel, and IOT distributor
logic [11:0] next_write_data       ;
logic [11:0] next_address          ;
logic [11:0] next_dispout          ;
logic [11:0] next_dataout          ;

// Signals for managing ISZ and auto increment
MB_ctrl_t MB_ctrl_temp             ;
logic [11:0] mb_p1                 ;  

// Signals for Output of Microcoded Module
logic [11:0] ac_micro              ;
logic        l_micro               ;            

// Signals for Adder/Carry Out for TAD
logic [12:0] tad_sum               ;
logic        Cout                  ;

// Signal for switch register change detection 
logic [11:0] swreg_temp            ;
logic        swreg_change          ;


/********************************* Instatiate Modules **********************************/

micro_instruction_decoder MIC0 (.ac_micro,
                                .l_micro,
                                .i_reg   (bus.curr_reg.ir ),
                                .ac_reg  (bus.curr_reg.ac ),
                                .l_reg   (bus.curr_reg.lk ),
                                .skip    (bus.skip    ),
                                .micro_g1(bus.micro_g1),
                                .micro_g2(bus.micro_g2),
                                .micro_g3(bus.micro_g3)
                               );       

/************************************** Main Body **************************************/

// Update main registers, memory, front panel, and IOT distubutor     
always_ff @(posedge clock) begin
          bus.curr_reg  <= next_reg        ;
          bus.write_data  <= next_write_data ;
          bus.address     <= next_address    ;
          bus.dispout     <= next_dispout    ;
          bus.linkout     <= next_reg.lk ;
          bus.dataout     <= next_dataout    ;
end
  
// ac_reg (Accumulator)
always_comb begin: AC
     unique case (bus.AC_ctrl)
          AC_SWREG : next_reg.ac = bus.swreg;                         // load switch register 
          AC_AND   : next_reg.ac = bus.curr_reg.ac & bus.curr_reg.mb      ;   // AND instruction
          AC_TAD   : next_reg.ac = tad_sum                        ;   // TAD instruction
          AC_CLEAR : next_reg.ac = 0                              ;   // Clear 
          AC_MICRO : next_reg.ac = ac_micro                       ;   // Group 1 Microcoded Instruction
          AC_OR_SR : next_reg.ac = bus.curr_reg.ac | bus.swreg        ;   // OR switch register into AC
          AC_OR_MQ : next_reg.ac = bus.curr_reg.ac | bus.curr_reg.mq      ;   // OR MQ into AC
          AC_OR_DI : next_reg.ac = bus.curr_reg.ac | {4'h0,bus.datain};   // OR datain from IOT into AC 
          AC_LD_MQ : next_reg.ac = bus.curr_reg.mq                    ;   // Load MQ register (for swap) 
          AC_MUL   : next_reg.ac = bus.ac_mul                     ;   // Result from EAE for multiply 
          AC_DVI   : next_reg.ac = bus.ac_dvi                     ;   // Result from EAE for divide
          AC_NC    : next_reg.ac = bus.curr_reg.ac                    ;   // No change
     endcase     
end

// lk_reg (Link bit)
always_comb begin: LK
     unique case (bus.LK_ctrl)
          LK_TAD   : next_reg.lk = bus.curr_reg.lk ^ Cout  ;    // TAD instruction
          LK_MICRO : next_reg.lk = l_micro             ;    // Group 1 Microcoded Instruction
          LK_MUL   : next_reg.lk = 0                   ;    // Clear for multiply 
          LK_DVI   : next_reg.lk = bus.link_dvi        ;    // Overflow indicator for DVI instruction
          LK_ZERO  : next_reg.lk = 0                   ;    // Zero Link bit
          LK_NC    : next_reg.lk = bus.curr_reg.lk         ;    // No change
     endcase     
end

// mq_reg (For MUL and DVI instructions using EAE component)
always_comb begin: MQ
     unique case (bus.MQ_ctrl)
          MQ_AC    : next_reg.mq = bus.curr_reg.ac    ;    // For MQ/AC swap operation
          MQ_MUL   : next_reg.mq = bus.mq_mul     ;    // For multiplication
          MQ_DVI   : next_reg.mq = bus.mq_dvi     ;    // For divisiond
          MQ_ZERO  : next_reg.mq = 0              ;    // Zero out   
          MQ_NC    : next_reg.mq = bus.curr_reg.mq    ;    // Default, no change     
     endcase     
end

// pc_reg (Program counter)
always_comb begin: PC
     unique case (bus.PC_ctrl)
          PC_P1    : next_reg.pc = bus.curr_reg.pc + 1     ;    // Normal PC increment
          PC_P2    : next_reg.pc = bus.curr_reg.pc + 2     ;    // Skip
          PC_SR    : next_reg.pc = bus.swreg           ;    // Load from front panel
          PC_JMP   : next_reg.pc = bus.curr_reg.ea         ;    // Load from effective address 
          PC_NC    : next_reg.pc = bus.curr_reg.pc         ;    // No change
     endcase     
end

// i_reg (Instruction register)
always_comb begin: IR
     unique case (bus.IR_ctrl)
          IR_LD    : next_reg.ir = bus.read_data       ;    // Load instruction from memory
          IR_MEM_P1: next_reg.ir = bus.curr_reg.mb + 1     ;    // for auto increment
          IR_NC    : next_reg.ir = bus.curr_reg.ir         ;    // No change
     endcase     
end
  
// ea_reg (Effective address to memory module)
always_comb begin: EA
     unique case (bus.EA_ctrl)
          EA_PGE   : next_reg.ea = {bus.curr_reg.pc[11:7],bus.curr_reg.ir[6:0]}; // Change page with upper 5 of PC 
          EA_SMP   : next_reg.ea = {5'd0,bus.curr_reg.ir[6:0]};           // Simple address
          EA_IND   : next_reg.ea = bus.curr_reg.mb            ;           // for indirection
          EA_INC   : next_reg.ea = bus.curr_reg.mb + 1        ;           // for auto-increment indirection    
          EA_NC    : next_reg.ea = bus.curr_reg.ea            ;           // No change
     endcase     
end

// mb_reg (Memory buffer register)
always_comb begin: MB
     unique case (bus.MB_ctrl)
          MB_INC    : next_reg.mb = bus.curr_reg.mb + 1    ;         // for auto increment and ISZ instruction
          MB_RD     : next_reg.mb = bus.read_data      ;         // Load read data from memory
          MB_NC     : next_reg.mb = bus.curr_reg.mb        ;         // No change
     endcase     
end

// write data (Data to memory module)
always_comb begin: WD
     unique case (bus.WD_ctrl)
          WD_MB     : next_write_data = bus.curr_reg.mb         ;    // Contents of memory buffer
          WD_AC     : next_write_data = bus.curr_reg.ac         ;    // Contents of accumulator
          WD_EA     : next_write_data = bus.curr_reg.ea         ;    // Contents of effective address register
          WD_PCP1   : next_write_data = bus.curr_reg.pc + 1     ;    // Program counter plus 1  
          WD_SR     : next_write_data = bus.swreg            ;   // Deposit switch reg into memory     
          WD_NC     : next_write_data = bus.write_data      ;    // No change
     endcase     
end

// address (Address to memory module)
always_comb begin: AD
     unique case (bus.AD_ctrl)
          AD_PC     : next_address = bus.curr_reg.pc       ;    // Program counter 
          AD_PCP1   : next_address = bus.curr_reg.pc + 1   ;    // Program counter plus 1
          AD_EA     : next_address = bus.curr_reg.ea       ;    // Contents of effective address register
          AD_SR     : next_address = bus.swreg         ;    // Switch register from front panel     
          AD_NC     : next_address = bus.address       ;    // No change
     endcase     
end

// dispout (Display out to front panel)
always_comb begin: DO
     unique case (bus.DO_ctrl)
          DO_PC     : next_dispout = bus.curr_reg.pc  ;    // Display program counter
          DO_MQ     : next_dispout = bus.curr_reg.mq  ;    // Display MQ register
          DO_MB     : next_dispout = bus.curr_reg.mb  ;    // Display memory location contents
          DO_AC     : next_dispout = bus.curr_reg.ac  ;    // Display accumulator
          DO_NC     : next_dispout = bus.dispout  ;    // No change
     endcase     
end

// dataout (Data out to IOT distributor)
always_comb begin: DT
     unique case (bus.DT_ctrl)
          DT_AC     : next_dataout = bus.curr_reg.ac[7:0]  ;    // Output lower 8 bits of AC
          DT_NC     : next_dataout = bus.dataout       ;    // No change
     endcase     
end


// Adder for TAD instruction
assign tad_sum = bus.curr_reg.ac + bus.curr_reg.mb;
assign Cout    = tad_sum[12]; 
     
// Signal for controller to know when in auto-incrementing memory locations
assign bus.ea_in_auto = (bus.curr_reg.ea[11:3] == 9'b000000001) ? 1 : 0;

// Detect change in switch register
always_comb begin
     if (bus.swreg !== swreg_temp) swreg_change = 1;
     else swreg_change = 0;
end

always_ff @(posedge clock) begin
     swreg_temp <= bus.swreg;
     if (swreg_change == 1) bus.srchange <= 1;
     else                   bus.srchange <= 0;     
end

endmodule

