// Controller.sv
// Jonathan Waldrip

`include "CPU_Definitions.pkg"
`include "memory_utils.pkg"

/******************************** Declare Module Ports **********************************/

module Controller (input logic clock, 
                   input logic resetN,
                   main_bus.fsm bus
                   );

/********************************** Declare Signals ************************************/

Controller_states_t Curr_State = CPU_IDLE, Next_State, Inst_State;


/************************************** Main Body **************************************/                
                   
// State register w/ asynchronous active-low reset                  
always_ff @(posedge clock, negedge resetN)
     if (!resetN) Curr_State <= REG_INIT;         // If reset, go to NORMAL state
     else         Curr_State <= Next_State;       // Else current state gets next state
     
     

// Next state logic     
always_comb begin: Next_State_Logic
     Next_State = Curr_State;                     // Default to stay in current state
     unique case (Curr_State)
          REG_INIT: Next_State = CPU_IDLE;
      
          CPU_IDLE: Next_State = 
                    (bus.run       == 1) ? FETCH_1     :    
                    (bus.step      == 1) ? FETCH_1     : 
                    (bus.srchange  == 1) ? SR_CHG_1    : 
                    (bus.loadpc    == 1) ? LD_PC_1     :
                    (bus.loadac    == 1) ? LD_AC_1     :
                    (bus.deposit   == 1) ? DEP_1       : CPU_IDLE;
                         
          SR_CHG_1: Next_State = SR_CHG_2;
          
          SR_CHG_2: if (bus.mem_finished == 1)
                         Next_State = CPU_IDLE;
                              
          FETCH_1:  Next_State = FETCH_2;
          FETCH_2:  if (bus.mem_finished == 1)
                         Next_State = FETCH_3;
          FETCH_3:  Next_State = DECODE;
          
          DECODE:   begin
                         if (bus.curr_reg.ir == 12'o7402) Next_State = HALT;
                         else begin 
                              case (bus.curr_reg.ir[11:9])
                                   3'b000 : Inst_State = AND_1;
                                   3'b001 : Inst_State = TAD_1;
                                   3'b010 : Inst_State = ISZ_1;
                                   3'b011 : Inst_State = DCA_1;
                                   3'b100 : Inst_State = JMS_1;
                                   3'b101 : Inst_State = JMP_1;
                                   3'b110 : Inst_State = IOT_1;
                                   default: Inst_State = MIC_1;
                              endcase
                              if (bus.curr_reg.ir [11:9] <= 5) Next_State = CAL_EA_1;
                              else if (bus.curr_reg.ir [11:9] == 3'b110) Next_State = IOT_1;
                              else Next_State = MIC_1;                        
                         end                    
                    end
                         
          LD_PC_1:  Next_State = CPU_IDLE;

          LD_AC_1:  Next_State = CPU_IDLE;

          DEP_1:    Next_State = DEP_2; 
          DEP_2:    if (bus.mem_finished == 1)
                         Next_State = CPU_IDLE;          

          CAL_EA_1: if (bus.curr_reg.ir[8] == 0)
                         Next_State = Inst_State;
                    else Next_State = EA_IND_1;
                           
          EA_IND_1: if (bus.ea_in_auto == 0)
                         Next_State = EA_IND_2;
                    else Next_State = EA_AUT_1;         
          EA_IND_2: if (bus.mem_finished == 1)
                         Next_State = Inst_State;
                              
          EA_AUT_1: Next_State = EA_AUT_2; 
          EA_AUT_2: if (bus.mem_finished == 1)
                         Next_State = EA_AUT_3;  
          EA_AUT_3: Next_State = EA_AUT_4;
          EA_AUT_4: Next_State = EA_AUT_5;
          EA_AUT_5: if (bus.mem_finished == 1)
                         Next_State = EA_AUT_6;
          EA_AUT_6: Next_State = Inst_State;

          AND_1:    Next_State = AND_2;
          AND_2:    if (bus.mem_finished == 1)
                         Next_State = AND_3;
          AND_3:    Next_State = CPU_IDLE;
          
          TAD_1:    Next_State = TAD_2; 
          TAD_2:    if (bus.mem_finished == 1)
                         Next_State = TAD_3;
          TAD_3:    Next_State = CPU_IDLE; 
          
          
          ISZ_1:    Next_State = ISZ_2;          
          ISZ_2:    if (bus.mem_finished == 1)
                         Next_State = ISZ_3;
          ISZ_3:    Next_State = ISZ_4;
          ISZ_4:    Next_State = ISZ_5;
          ISZ_5:    if (bus.mem_finished == 1)
                         Next_State = ISZ_6;
          ISZ_6:    Next_State = CPU_IDLE;
         
          DCA_1:    Next_State = DCA_2;  
          DCA_2:    if (bus.mem_finished == 1)
                         Next_State = DCA_3;  
          DCA_3:    Next_State = CPU_IDLE;            
               
          JMS_1:    Next_State = JMS_2;
          JMS_2:    if (bus.mem_finished == 1)
                         Next_State = JMS_3;
          JMS_3:    Next_State = CPU_IDLE;       
               
          JMP_1:    Next_State = CPU_IDLE;  
               
          IOT_1:    if (bus.curr_reg.ir[0] == 1)   
                         Next_State = IOT_6;
                    else Next_State = IOT_2;
          IOT_2:    Next_State = IOT_3;
          IOT_3:    if (bus.clearacc == 1)
                         Next_State = IOT_4;   
                    else Next_State = IOT_5;
          IOT_4:    Next_State = IOT_5;
          IOT_5:    Next_State = IOT_6;
          IOT_6:    Next_State = CPU_IDLE; 
               
          MIC_1:    if (bus.micro_g1 == 1)
                         Next_State = CPU_IDLE;
                    else Next_State = MIC_2;     
          MIC_2:    if ({bus.micro_g2,bus.curr_reg.ir[1]} == 2'b11)
                         Next_State = CPU_IDLE;
                    else Next_State = MIC_3;   
          MIC_3:    Next_State = MIC_4;
          MIC_4:    Next_State = MIC_5;
          MIC_5:    if ({bus.micro_g3,bus.curr_reg.ir[2]} == 2'b11)
                         Next_State = MIC_6;
                    else Next_State = MIC_9;
          MIC_6:    Next_State = MIC_7;
          MIC_7:    if (bus.mem_finished == 1)
                         Next_State = MIC_8;
          MIC_8:    if (bus.eae_fin == 1)
                         Next_State = MIC_9;
          MIC_9:    Next_State = CPU_IDLE; 

          HALT :    Next_State = CPU_IDLE;     
          
     endcase     
end: Next_State_Logic


// Output control (Moore Machine)
always_comb begin: Output_Logic
     bus.eae_start    = 0    ;     // Default to 0   
     bus.AC_ctrl      = AC_NC;     // Default no change to accumulator
     bus.LK_ctrl      = LK_NC;     // Default no change to link
     bus.MQ_ctrl      = MQ_NC;     // Default no change to MQ register
     bus.PC_ctrl      = PC_NC;     // Default no change to program counter
     bus.IR_ctrl      = IR_NC;     // Default no change to instruction register
     bus.EA_ctrl      = EA_NC;     // Default no change to effective address register
     bus.MB_ctrl      = MB_NC;     // Default no change to memory buffer
     bus.WD_ctrl      = WD_NC;     // Default no change to write data
     bus.AD_ctrl      = AD_NC;     // Default no change to bus.memeory address
     bus.DO_ctrl      = DO_NC;     // Default no change to front panel display out
     bus.DT_ctrl      = DT_NC;     // Default no change to IOT distrubutor dataout
     bus.write_enable = 0    ;     // Default write enable for bus.memory
     bus.read_enable  = 0    ;     // Default write enable for bus.memory
     bus.bit1_cp2     = 0    ;     // Default control signal to IOT distributor
     bus.bit2_cp3     = 0    ;     // Default control signal to IOT distributor
     bus.io_address   = 0    ;     // Default IO address for IOT distributor
     bus.halt         = 0    ;     // Default Halt signal to front panel
     bus.eae_start    = 0    ;     // Deafult control signal for EAE module
     bus.read_type = `DATA_READ;   // Default read type
     bus.CPU_idle     = 0    ;     // Default CPU_idle to low
     

     unique case (Curr_State)
          REG_INIT: begin
                         bus.AC_ctrl = AC_CLEAR;
                         bus.LK_ctrl = LK_ZERO;
                         bus.MQ_ctrl = MQ_ZERO;
                         bus.EA_ctrl = EA_ZERO;
                         bus.MB_ctrl = MB_ZERO;
                         
                         
                    end
                    
          CPU_IDLE: begin
                         bus.CPU_idle = 1;
                         case (bus.dispsel)
                              2'b00 : bus.DO_ctrl = DO_PC;
                              2'b01 : bus.DO_ctrl = DO_AC;
                              2'b10 : bus.DO_ctrl = DO_MQ;
                              2'b11 : bus.DO_ctrl = DO_MB;
                         endcase
                         end
                         
          SR_CHG_1: bus.AD_ctrl = AD_SR;
          SR_CHG_2: bus.read_enable = 1;
                         
          FETCH_1:  bus.AD_ctrl = AD_PC;    
          FETCH_2:  begin
                         bus.read_enable = 1; 
                         bus.read_type = `INSTRUCTION_FETCH;
                    end               
          FETCH_3:  bus.IR_ctrl = IR_LD;

          LD_PC_1:  bus.PC_ctrl = PC_SR;

          LD_AC_1:  bus.AC_ctrl = AC_SWREG;

          DEP_1:    begin
                         bus.AD_ctrl = AD_PC;
                         bus.WD_ctrl = WD_SR;
                    end   
                    
          DEP_2:    begin
                         bus.write_enable = 1;                            
                         if (bus.mem_finished == 1)
                              bus.PC_ctrl = PC_P1;
                    end        

          DECODE:   if (bus.curr_reg.ir[11:9] == 3'b110)
                         bus.io_address = bus.curr_reg.ir[5:3];                    
                              
          CAL_EA_1: if (bus.curr_reg.ir[7] == 0)
                         bus.EA_ctrl = EA_SMP;
                    else bus.EA_ctrl = EA_PGE;

          EA_IND_1: bus.AD_ctrl = AD_EA;
          EA_IND_2: begin
                         bus.read_enable = 1;
                         bus.MB_ctrl = MB_RD;
                         if (bus.mem_finished == 1)
                              bus.EA_ctrl = EA_IND;
                    end   
                              
          EA_AUT_1: begin
                         bus.AD_ctrl = AD_EA;
                         bus.MB_ctrl = MB_RD;
                    end     
          EA_AUT_2: begin
                         bus.read_enable = 1;
                         bus.MB_ctrl = MB_RD;
                    end               
          EA_AUT_3: bus.MB_ctrl = MB_INC;
          EA_AUT_4: begin
                         bus.MB_ctrl = MB_NC;
                         bus.WD_ctrl = WD_MB;
                    end
          EA_AUT_5: begin
                         bus.MB_ctrl = MB_NC; 
                         bus.write_enable = 1;
                    end
          EA_AUT_6: begin
                         bus.MB_ctrl = MB_NC;
                         bus.EA_ctrl = EA_IND;
                    end 
                    
          AND_1:    bus.AD_ctrl = AD_EA;
          AND_2:    begin
                         bus.read_enable = 1; 
                         bus.MB_ctrl = MB_RD;
                    end          
          AND_3:    begin
                         bus.AC_ctrl = AC_AND;  
                         bus.PC_ctrl = PC_P1;                         
                    end     
          TAD_1:    bus.AD_ctrl = AD_EA;
          TAD_2:    begin
                         bus.read_enable = 1; 
                         bus.MB_ctrl = MB_RD;
                    end    
          TAD_3:    begin 
                         bus.AC_ctrl = AC_TAD;  
                         bus.PC_ctrl = PC_P1;                           
                    end
                    
          ISZ_1:    bus.AD_ctrl = AD_EA;  
          ISZ_2:    begin
                         bus.read_enable = 1; 
                         bus.MB_ctrl = MB_RD;
                    end   
          ISZ_3:    bus.MB_ctrl = MB_INC;          
          ISZ_4:    begin
                         bus.MB_ctrl = MB_NC; 
                         bus.WD_ctrl = WD_MB; 
                    end          
          ISZ_5:    begin
                         bus.MB_ctrl = MB_NC;
                         bus.write_enable = 1;
                    end               
          ISZ_6:    if (bus.curr_reg.mb == 0)
                         bus.PC_ctrl = PC_P2;
                    else bus.PC_ctrl = PC_P1;  
               
          DCA_1:    begin
                         bus.AD_ctrl = AD_EA;
                         bus.WD_ctrl = WD_AC;
                    end
          DCA_2:    begin
                         bus.write_enable = 1; 
                         bus.MB_ctrl = MB_WD;
                    end  
          DCA_3:    begin 
                         bus.AC_ctrl = AC_CLEAR;  
                         bus.PC_ctrl = PC_P1;
                    end
               
          JMS_1:    begin 
                         bus.AD_ctrl = AD_EA;
                         bus.WD_ctrl = WD_PCP1;
                    end 
          JMS_2:    begin 
                         bus.MB_ctrl = MB_NC;
                         bus.write_enable = 1;
                         bus.PC_ctrl = PC_JMP;
                    end
          JMS_3:    bus.PC_ctrl = PC_P1; 
               
          JMP_1:    bus.PC_ctrl = PC_JMP; 
               
          IOT_1:    begin
                         bus.io_address = bus.curr_reg.ir[5:3];
                         if ({bus.curr_reg.ir[0],bus.skip_flag} == 2'b11)
                              bus.PC_ctrl = PC_P1;
                    end          
          IOT_2:    begin 
                         bus.io_address = bus.curr_reg.ir[5:3];
                         if (bus.curr_reg.ir[1] == 1)  
                              bus.bit1_cp2 = 1;
                              if (bus.clearacc == 1)
                                   bus.AC_ctrl = AC_CLEAR;
                              else bus.DO_ctrl = DO_AC;     
                    end  
          IOT_3:    begin 
                         bus.io_address = bus.curr_reg.ir[5:3];
                         if (bus.curr_reg.ir[2] == 1)   
                              bus.bit2_cp3 = 1;    
                         if (bus.clearacc == 1)
                              bus.AC_ctrl = AC_OR_DI;
                         else bus.DO_ctrl = DO_AC;   
                    end
                    
          IOT_4:    bus.AC_ctrl = AC_OR_DI;
          IOT_5:    bus.DO_ctrl = DO_AC;     
          IOT_6:    bus.PC_ctrl = PC_P1;
                    
          MIC_1:    if (bus.micro_g1 == 1) begin
                         bus.AC_ctrl = AC_MICRO;
                         bus.PC_ctrl = PC_P1;
                    end     
     
          MIC_2:    if ({bus.micro_g2,bus.skip} == 2'b11) 
                         bus.PC_ctrl = PC_P1;                              
                    else if ({bus.micro_g2,bus.curr_reg.ir[7:2]} == 7'b11????1)
                         bus.AC_ctrl = AC_SWREG;
                    else if ({bus.micro_g2,bus.curr_reg.ir[2]} == 2'b11)
                         bus.AC_ctrl = AC_OR_SR;
                    else if ({bus.micro_g2,bus.curr_reg.ir[1]} == 2'b11)
                         bus.halt = 1;
          MIC_3:    if ({bus.micro_g3,bus.curr_reg.ir[7]} == 2'b11) 
                         bus.AC_ctrl = AC_CLEAR;
          MIC_4:    if ({bus.micro_g3,bus.curr_reg.ir[6:4]} == 4'b11?1) begin
                         bus.AC_ctrl = AC_LD_MQ;
                         bus.MQ_ctrl = MQ_AC;                              
                    end
                    else if ({bus.micro_g3,bus.curr_reg.ir[6]} == 2'b11) 
                         bus.AC_ctrl = AC_OR_MQ;
                    else if ({bus.micro_g3,bus.curr_reg.ir[4]} == 2'b11) begin 
                         bus.MQ_ctrl = MQ_AC;
                         bus.AC_ctrl = AC_CLEAR; 
                    end
          MIC_5:    begin end
          MIC_6:    begin
                         bus.AD_ctrl = AD_PCP1;
                         bus.PC_ctrl = PC_P1;
                    end     
          MIC_7:    bus.read_enable = 1;
          MIC_8:    bus.eae_start = 1;    
          MIC_9:    begin
                         if ({bus.curr_reg.ir[2:1]} == 2'b10) begin
                              bus.AC_ctrl = AC_MUL;
                              bus.MQ_ctrl = MQ_MUL;
                              bus.LK_ctrl = LK_MUL;
                         end
                         else if ({bus.curr_reg.ir[2:1]} == 2'b11) begin
                              bus.AC_ctrl = AC_DVI;
                              bus.MQ_ctrl = MQ_DVI;
                              bus.LK_ctrl = LK_DVI;
                         end
                         bus.PC_ctrl = PC_P1;
                    end
                    
          HALT :    begin
                         bus.halt = 1; 
                         bus.CPU_idle = 1;
                         bus.PC_ctrl = PCP1;
                    end               
                    
     endcase
end: Output_Logic

endmodule
