// CPU for PDP8 Project
// Jonathan Waldrip

`include "CPU_Definitions.pkg"

/******************************** Declare Module Ports **********************************/

module CPU (input logic clock, 
            input logic resetN,
            front_panel_pins.master fp,
            iot_pins.master        iot,
            memory_pins.master     mem,
            controller_pins.master fsm   
            );
            
            
/********************************** Declare Signals ************************************/

// Main Registers
PDP8_Registers_t curr_reg;

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

// Signals for output of EAE Module
logic [11:0] mq_mul                ;
logic [11:0] ac_mul                ;
logic [11:0] mq_dvi                ;
logic [11:0] ac_dvi                ;
logic        link_dvi              ;

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
Controller SM0 (.*);
EAE EAE0 (.*); 
Micro MIC0 (.*);       

/************************************** Main Body **************************************/

// Update main registers, memory, front panel, and IOT distubutor     
always_ff @(posedge clock) begin
          curr_reg        <= next_reg        ;
          mem.write_data  <= next_write_data ;
          mem.address     <= next_address    ;
          fp.dispout      <= next_dispout    ;
          fp.linkout      <= curr_reg.lk     ;
          iot.dataout     <= next_dataout    ;
end
   
// ac_reg (Accumulator)
always_comb begin: AC
     unique case (fsm.AC_ctrl)
          AC_SWREG : next_reg.ac = fp.swreg;                          // load switch register 
          AC_AND   : next_reg.ac = curr_reg.ac & curr_reg.mb      ;   // AND instruction
          AC_TAD   : next_reg.ac = tad_sum                        ;   // TAD instruction
          AC_CLEAR : next_reg.ac = 0                              ;   // Clear 
          AC_MICRO : next_reg.ac = ac_micro                       ;   // Group 1 Microcoded Instruction
          AC_OR_SR : next_reg.ac = curr_reg.ac | fp.swreg         ;   // OR switch register into AC
          AC_OR_MQ : next_reg.ac = curr_reg.ac | curr_reg.mq      ;   // OR MQ into AC
          AC_OR_DI : next_reg.ac = curr_reg.ac | {4'h0,iot.datain};   // OR datain from IOT into AC 
          AC_LD_MQ : next_reg.ac = curr_reg.mq                    ;   // Load MQ register (for swap) 
          AC_MUL   : next_reg.ac = ac_mul                         ;   // Result from EAE for multiply 
          AC_DVI   : next_reg.ac = ac_dvi                         ;   // Result from EAE for divide
          AC_NC    : next_reg.ac = curr_reg.ac                    ;   // No change
     endcase     
end

// lk_reg (Link bit)
always_comb begin: LK
     unique case (fsm.LK_ctrl)
          LK_TAD   : next_reg.lk = curr_reg.lk ^ Cout  ;    // TAD instruction
          LK_MICRO : next_reg.lk = l_micro             ;    // Group 1 Microcoded Instruction
          LK_MUL   : next_reg.lk = 0                   ;    // Clear for multiply 
          LK_DVI   : next_reg.lk = link_dvi            ;    // Result from EAE for divide
          LK_NC    : next_reg.lk = curr_reg.lk         ;    // No change
     endcase     
end

// mq_reg (For MUL and DVI instructions using EAE component)
always_comb begin: MQ
     unique case (fsm.MQ_ctrl)
          MQ_AC    : next_reg.mq = curr_reg.ac    ;    // TAD instruction
          MQ_MUL   : next_reg.mq = mq_mul         ;    // Group 1 Microcoded Instruction
          MQ_DVI   : next_reg.mq = mq_dvi         ;    // Clear for multiply 
          MQ_NC    : next_reg.mq = curr_reg.mq    ;    // No change
     endcase     
end

// pc_reg (Program counter)
always_comb begin: PC
     unique case (fsm.PC_ctrl)
          PC_P1    : next_reg.pc = curr_reg.pc + 1     ;    // Normal PC increment
          PC_P2    : next_reg.pc = curr_reg.pc + 2     ;    // Skip
          PC_SR    : next_reg.pc = fp.swreg            ;    // Load from front panel
          PC_JMP   : next_reg.pc = curr_reg.ea         ;    // Load from effective address 
          PC_NC    : next_reg.pc = curr_reg.mq         ;    // No change
     endcase     
end

// i_reg (Instruction register)
always_comb begin: IR
     unique case (fsm.IR_ctrl)
          IR_LD    : next_reg.ir = mem.read_data       ;    // Load instruction from memory
          IR_MEM_P1: next_reg.ir = curr_reg.mb + 1     ;    // for auto increment
          IR_NC    : next_reg.ir = curr_reg.ir         ;    // No change
     endcase     
end
  
// ea_reg (Effective address to memory module)
always_comb begin: EA
     unique case (fsm.EA_ctrl)
          EA_PGE   : next_reg.ea = {curr_reg.pc[11:7],curr_reg.ir[6:0]}; // Change page with upper 5 of PC 
          EA_SMP   : next_reg.ea = {5'd0,curr_reg.ir[6:0]};           // Simple address
          EA_IND   : next_reg.ea = curr_reg.mb            ;           // for indirection
          EA_INC   : next_reg.ea = curr_reg.mb + 1        ;           // for auto-increment indirection    
          EA_NC    : next_reg.ea = curr_reg.mb            ;           // No change
     endcase     
end

// mb_reg (Memory buffer register)
always_comb begin: MB
     unique case (fsm.MB_ctrl)
          MB_ISZ    : next_reg.mb = mb_p1         ;    // for auto increment and ISZ instruction
          MB_RD     : next_reg.mb = mem.read_data ;    // Load read data from memory
     endcase     
end

// write data (Data to memory module)
always_comb begin: WD
     unique case (fsm.WD_ctrl)
          WD_MB     : next_write_data = curr_reg.mb         ;    // Contents of memory buffer
          WD_AC     : next_write_data = curr_reg.ac         ;    // Contents of accumulator
          WD_EA     : next_write_data = curr_reg.ea         ;    // Contents of effective address register
          WD_PCP1   : next_write_data = curr_reg.pc + 1     ;    // Program counter plus 1     
          MB_NC     : next_write_data = mem.write_data      ;    // No change
     endcase     
end

// address (Address to memory module)
always_comb begin: AD
     unique case (fsm.AD_ctrl)
          AD_PC     : next_address = curr_reg.pc       ;    // Program counter 
          AD_PCP1   : next_address = curr_reg.pc + 1   ;    // Program counter plus 1
          AD_EA     : next_address = curr_reg.ea       ;    // Contents of effective address register
          AD_SR     : next_address = fp.swreg          ;    // Switch register from front panel     
          AD_NC     : next_address = mem.address       ;    // No change
     endcase     
end

// dispout (Display out to front panel)
always_comb begin: DO
     unique case (fsm.DO_ctrl)
          DO_PC     : next_dispout = curr_reg.pc  ;    // Display program counter
          DO_MQ     : next_dispout = curr_reg.mq  ;    // Display MQ register
          DO_MB     : next_dispout = curr_reg.mb  ;    // Display memory location contents
          DO_AC     : next_dispout = curr_reg.ac  ;    // Display accumulator
          DO_NC     : next_dispout = fp.dispout   ;    // No change
     endcase     
end

// dataout (Data out to IOT distributor)
always_comb begin: DT
     unique case (fsm.DT_ctrl)
          DT_AC     : next_dataout = curr_reg.ac[7:0]  ;    // Output lower 8 bits of AC
          DT_NC     : next_dataout = iot.dataout       ;    // No change
     endcase     
end


// Adder for TAD instruction
assign tad_sum = curr_reg.ac + curr_reg.mb;
assign Cout    = tad_sum[12]; 
     
// Signal for controller to know when in auto-incrementing memory locations
assign ea_reg_8_to_15 = (curr_reg.ea[11:3] === 9'b000000001) ? 1 : 0;

// Detect change in switch register
always_comb begin
     if (fp.swreg !== swreg_temp) swreg_change = 1;
     else swreg_change = 0;
end

always_ff @(posedge clock) begin
     swreg_temp <= fp.swreg;
     if (swreg_change === 1) fsm.srchange <= 1;
     else                    fsm.srchange <= 0;     
end

// Increment for ISZ instruction and auto increment effective address
always_ff @(posedge clock) begin
     MB_ctrl_temp <= fsm.MB_ctrl;
     if ((MB_ctrl_temp !== fsm.MB_ctrl) &&
         (fsm.MB_ctrl  === MB_ISZ     )) mb_p1 <= curr_reg.mb + 1;                    
     else mb_p1 <= curr_reg.mb;
end

endmodule

