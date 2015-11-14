// Controller.sv
// Jonathan Waldrip



`include "CPU_Definitions.pkg"


/******************************** Declare Module Ports **********************************/

module Controller (input logic clock, 
                   input logic resetN,
                   controller_pins.slave cpu
                   );

/********************************** Declare Signals ************************************/

Controller_states_t Curr_State = CPU_IDLE, Next_State;


/************************************** Main Body **************************************/                
                   
// State register w/ asynchronous active-low reset                  
always_ff @(posedge clock, negedge resetN)
     if (!resetN) Curr_State <= CPU_IDLE;           // If reset, go to NORMAL state
     else         Curr_State <= Next_State;       // Else current state gets next state
     
     

// Next state logic     
always_comb begin: Next_State_Logic
     Next_State = Curr_State;                     // Default to stay in current state
     unique case (Curr_State)
          CPU_IDLE: Next_State = 
                    (cpu.fp.run     === 1) ? FETCH_1     :    
                    (cpu.fp.step    === 1) ? FETCH_1     : 
                    (cpu.srchange   === 1) ? SR_CHG_1    : 
                    (cpu.fp.loadpc  === 1) ? LD_PC_1     :
                    (cpu.fp.loadac  === 1) ? LD_AC_1     :
                    (cpu.fp.deposit === 1) ? DEP_1       : CPU_IDLE;
                         
          SR_CHG_1: Next_State = SR_CHG_2;
          
          SR_CHG_2: if (cpu.mem.mem_finished === 1)
                         Next_State = CPU_IDLE;
                              
          FETCH_1:  Next_State = FETCH_2;
          FETCH_2:  if (cpu.mem.mem_finished === 1)
                         Next_State = FETCH_3;
          FETCH_3:  Next_State = CAL_EA_1;

          LD_PC_1:  Next_State = CPU_IDLE;

          LD_AC_1:  Next_State = CPU_IDLE;

          DEP_1:    Next_State = DEP_2; 
          DEP_2:    if (cpu.mem.mem_finished === 1)
                         Next_State = CPU_IDLE;          

          CAL_EA_1: if (cpu.curr_reg.ir[8] === 0)
                         Next_State = DECODE;
                    else Next_State = EA_IND_1;
                           
          EA_IND_1: if (cpu.ea_reg_8_to_15 === 0)
                         Next_State = EA_IND_2;
                    else Next_State = EA_AUT_1;         
          EA_IND_2: if (cpu.mem.mem_finished === 1)
                         Next_State = DECODE;
                              
          EA_AUT_1: Next_State = EA_AUT_2; 
          EA_AUT_2: if (cpu.mem.mem_finished === 1)
                         Next_State = EA_AUT_3;  
          EA_AUT_3: Next_State = EA_AUT_4;
          EA_AUT_4: Next_State = EA_AUT_5;
          EA_AUT_5: if (cpu.mem.mem_finished === 1)
                         Next_State = EA_AUT_6;
          EA_AUT_6: Next_State = DECODE;

          DECODE:   case (cpu.curr_reg.ir[11:9])
                         3'b000 : Next_State = AND_1;
                         3'b001 : Next_State = TAD_1;
                         3'b010 : Next_State = ISZ_1;
                         3'b011 : Next_State = DCA_1;
                         3'b100 : Next_State = JMS_1;
                         3'b101 : Next_State = JMP_1;
                         3'b110 : Next_State = IOT_1;
                         default: Next_State = MIC_1;
                    endcase     
          
          AND_1:    if (cpu.mem.mem_finished === 1)
                         Next_State = AND_2;
          AND_2:    Next_State = CPU_IDLE;                          
               
          TAD_1:    if (cpu.mem.mem_finished === 1)
                         Next_State = TAD_2;
          TAD_2:    Next_State = CPU_IDLE;   
               
          ISZ_1:    Next_State = ISZ_2;
          ISZ_2:    Next_State = ISZ_3;
          ISZ_3:    Next_State = ISZ_4;
          ISZ_4:    if (cpu.mem.mem_finished === 1)
                         Next_State = ISZ_5;
          ISZ_5:    Next_State = CPU_IDLE;          
               
          DCA_1:    Next_State = DCA_1;  
          DCA_2:    if (cpu.mem.mem_finished === 1)
                         Next_State = DCA_3;  
          DCA_3:    Next_State = CPU_IDLE;            
               
          JMS_1:    Next_State = JMS_2;
          JMS_2:    if (cpu.mem.mem_finished === 1)
                         Next_State = JMS_3;
          JMS_3:    Next_State = CPU_IDLE;       
               
          JMP_1:    Next_State = CPU_IDLE;  
               
          IOT_1:    if (cpu.curr_reg.ir[0] === 1)   
                         Next_State = IOT_6;
                    else Next_State = IOT_2;
          IOT_2:    Next_State = IOT_3;
          IOT_3:    if (cpu.iot.clearacc === 1)
                         Next_State = IOT_4;   
                    else Next_State = IOT_5;
          IOT_4:    Next_State = IOT_5;
          IOT_5:    Next_State = IOT_6;
          IOT_6:    Next_State = CPU_IDLE; 
               
          MIC_1:    Next_State = MIC_2;
          MIC_2:    if ({cpu.micro_g2,cpu.curr_reg.ir[1]} === 2'b11)
                         Next_State = CPU_IDLE;
                    else Next_State = MIC_3;   
          MIC_3:    Next_State = MIC_4;
          MIC_4:    Next_State = MIC_5;
          MIC_5:    if ({cpu.micro_g3,cpu.curr_reg.ir[2]} === 2'b11)
                         Next_State = MIC_6;
                    else Next_State = MIC_9;
          MIC_6:    Next_State = MIC_7;
          MIC_7:    if (cpu.mem.mem_finished === 1)
                         Next_State = MIC_8;
          MIC_8:    if (cpu.eae_fin === 1)
                         Next_State = MIC_9;
          MIC_9:    Next_State = CPU_IDLE;        
     endcase     
end: Next_State_Logic


// Output control (Moore Machine)
always_comb begin: Output_Logic
     cpu.eae_start    = 0    ;     // Default to 0   
     cpu.AC_ctrl      = AC_NC;     // Default no change to accumulator
     cpu.LK_ctrl      = LK_NC;     // Default no change to link
     cpu.MQ_ctrl      = MQ_NC;     // Default no change to MQ register
     cpu.PC_ctrl      = PC_NC;     // Default no change to program counter
     cpu.IR_ctrl      = IR_NC;     // Default no change to instruction register
     cpu.EA_ctrl      = EA_NC;     // Default no change to effective address register
     cpu.MB_ctrl      = MB_RD;     // Default cpu.memory buffer to store current read data
     cpu.WD_ctrl      = WD_NC;     // Default no change to write data
     cpu.AD_ctrl      = AD_NC;     // Default no change to cpu.memeory address
     cpu.DO_ctrl      = DO_NC;     // Default no change to front panel display out
     cpu.DT_ctrl      = DT_NC;     // Default no change to IOT distrubutor dataout
     cpu.mem.write_enable = 0;         // Default write enable for cpu.memory
     cpu.mem.read_enable  = 0;         // Default write enable for cpu.memory
     cpu.iot.bit1_cp2     = 0;         // Default control signal to IOT distributor
     cpu.iot.bit2_cp3     = 0;         // Default control signal to IOT distributor
     cpu.iot.io_address   = 0;         // Default IO address for IOT distributor
     cpu.fp.halt          = 0;         // Default Halt signal to front panel
     cpu.eae_start        = 0;         // Deafult control signal for EAE module
     

     unique case (Curr_State)
          CPU_IDLE: case (cpu.fp.dispsel)
                         2'b00 : cpu.DO_ctrl = DO_PC;
                         2'b01 : cpu.DO_ctrl = DO_AC;
                         2'b10 : cpu.DO_ctrl = DO_MQ;
                         2'b11 : cpu.DO_ctrl = DO_MB;
                    endcase
                         
          SR_CHG_1: cpu.AD_ctrl = AD_SR;
          SR_CHG_2: cpu.mem.read_enable = 1;

          FETCH_1:  cpu.AD_ctrl = AD_PC;    
          FETCH_2:  cpu.mem.read_enable = 1;         
          FETCH_3:  cpu.IR_ctrl = IR_LD;

          LD_PC_1:  cpu.PC_ctrl = PC_SR;

          LD_AC_1:  cpu.AC_ctrl = AC_SWREG;

          DEP_1:    begin
                         cpu.AD_ctrl = AD_PC;
                         cpu.WD_ctrl = WD_SR;
                    end   
                    
          DEP_2:    begin
                         cpu.mem.write_enable = 1;                            
                         if (cpu.mem.mem_finished === 1)
                              cpu.PC_ctrl = PC_P1;
                    end        
                   
          CAL_EA_1: if (cpu.curr_reg.ir[7] === 0)
                         cpu.EA_ctrl = EA_SMP;
                    else cpu.EA_ctrl = EA_PGE;
                    
          EA_IND_1: cpu.AD_ctrl = AD_EA;
          EA_IND_2: begin
                         cpu.mem.write_enable = 1;                            
                         if (cpu.mem.mem_finished === 1)
                              cpu.EA_ctrl = EA_IND;
                    end   
                              
          EA_AUT_1: cpu.AD_ctrl = AD_EA;
          EA_AUT_2: begin end                               
          EA_AUT_3: cpu.MB_ctrl = MB_ISZ;
          EA_AUT_4: begin
                         cpu.MB_ctrl = MB_ISZ;
                         cpu.WD_ctrl = WD_MB;
                    end
          EA_AUT_5: begin
                         cpu.WD_ctrl = WD_MB;
                         cpu.mem.write_enable = 1;
                    end
          EA_AUT_6: begin
                         cpu.MB_ctrl = MB_ISZ;
                         cpu.EA_ctrl = EA_IND;
                    end
                           
          DECODE:   if (cpu.curr_reg.ir[11:9] === 3'b110)
                         cpu.iot.io_address = cpu.curr_reg.ir[5:3];
          
          AND_1:    begin
                         cpu.AD_ctrl = AD_EA;  
                         cpu.mem.read_enable = 1;  
                    end
          AND_2:    begin
                         cpu.AC_ctrl = AC_AND;  
                         cpu.PC_ctrl = PC_P1;  
                    end     
          TAD_1:    begin
                         cpu.AD_ctrl = AD_EA;  
                         cpu.mem.read_enable = 1;  
                    end
          TAD_2:    begin 
                         cpu.AC_ctrl = AC_TAD;  
                         cpu.PC_ctrl = PC_P1;                           
                    end
                    
          ISZ_1:    begin
                         cpu.AD_ctrl = AD_EA;  
                         cpu.mem.read_enable = 1;  
                    end
          ISZ_2:    cpu.MB_ctrl = MB_ISZ;  
          ISZ_3:    cpu.WD_ctrl = WD_MB; 
          ISZ_4:    cpu.mem.write_enable = 1;
          ISZ_5:    if (cpu.curr_reg.mb === 0)
                         cpu.PC_ctrl = PC_P2;
                    else cpu.PC_ctrl = PC_P1;  
               
          DCA_1:    begin
                         cpu.AD_ctrl = AD_EA;
                         cpu.WD_ctrl = WD_AC;
                    end
          DCA_2:    cpu.mem.write_enable = 1;
          DCA_3:    begin 
                         cpu.AC_ctrl = AC_CLEAR;  
                         cpu.PC_ctrl = PC_P1;
                    end
               
          JMS_1:    begin 
                         cpu.AD_ctrl = AD_EA;
                         cpu.WD_ctrl = WD_PCP1;
                    end 
          JMS_2:    begin 
                         cpu.mem.write_enable = 1;
                         cpu.PC_ctrl = PC_JMP;
                    end
          JMS_3:    cpu.PC_ctrl = PC_P1; 
               
          JMP_1:    cpu.PC_ctrl = PC_JMP; 
               
          IOT_1:    begin
                         cpu.iot.io_address = cpu.curr_reg.ir[5:3];
                         if ({cpu.curr_reg.ir[0],cpu.iot.skip_flag} === 2'b11)
                              cpu.PC_ctrl = PC_P1;
                    end          
          IOT_2:    begin 
                         cpu.iot.io_address = cpu.curr_reg.ir[5:3];
                         if (cpu.curr_reg.ir[1] === 1)  
                              cpu.iot.bit1_cp2 = 1;
                              if (cpu.iot.clearacc === 1)
                                   cpu.AC_ctrl = AC_CLEAR;
                              else cpu.DO_ctrl = DO_AC;     
                    end  
          IOT_3:    begin 
                         cpu.iot.io_address = cpu.curr_reg.ir[5:3];
                         if (cpu.curr_reg.ir[2] === 1)   
                              cpu.iot.bit2_cp3 = 1;    
                         if (cpu.iot.clearacc === 1)
                              cpu.AC_ctrl = AC_OR_DI;
                         else cpu.DO_ctrl = DO_AC;   
                    end
                    
          IOT_4:    cpu.AC_ctrl = AC_OR_DI;
          IOT_5:    cpu.DO_ctrl = DO_AC;     
          IOT_6:    cpu.PC_ctrl = PC_P1;
                    
          MIC_1:    if (cpu.micro_g1 === 1) 
                         cpu.AC_ctrl = AC_MICRO;
     
          MIC_2:    if ({cpu.micro_g2,cpu.skip} === 2'b11) 
                         cpu.PC_ctrl = PC_P1;                              
                    else if ({cpu.micro_g2,cpu.curr_reg.ir[7:2]} === 7'b11????1)
                         cpu.AC_ctrl = AC_SWREG;
                    else if ({cpu.micro_g2,cpu.curr_reg.ir[2]} === 2'b11)
                         cpu.AC_ctrl = AC_OR_SR;
                    else if ({cpu.micro_g2,cpu.curr_reg.ir[1]} === 2'b11)
                         cpu.fp.halt = 1;
          MIC_3:    if ({cpu.micro_g3,cpu.curr_reg.ir[7]} === 2'b11) 
                         cpu.AC_ctrl = AC_CLEAR;
          MIC_4:    if ({cpu.micro_g3,cpu.curr_reg.ir[6:4]} === 4'b11?1) begin
                         cpu.AC_ctrl = AC_LD_MQ;
                         cpu.MQ_ctrl = MQ_AC;                              
                    end
                    else if ({cpu.micro_g3,cpu.curr_reg.ir[6]} === 2'b11) 
                         cpu.AC_ctrl = AC_OR_MQ;
                    else if ({cpu.micro_g3,cpu.curr_reg.ir[4]} === 2'b11) begin 
                         cpu.MQ_ctrl = MQ_AC;
                         cpu.AC_ctrl = AC_CLEAR; 
                    end
          MIC_5:    cpu.PC_ctrl = PC_P1;
          MIC_6:    cpu.AD_ctrl = AD_PC;
          MIC_7:    cpu.mem.read_enable = 1;    
          MIC_8:    cpu.eae_start = 1;    
          MIC_9:    begin
                         if ({cpu.curr_reg.ir[2:1]} === 2'b10) begin
                              cpu.AC_ctrl = AC_MUL;
                              cpu.MQ_ctrl = MQ_MUL;                              
                         end
                         else if ({cpu.curr_reg.ir[2:1]} === 2'b11) begin
                              cpu.AC_ctrl = AC_DVI;
                              cpu.MQ_ctrl = MQ_DVI;                              
                         end
                         cpu.PC_ctrl = PC_P1;
                    end                
     endcase
end: Output_Logic

endmodule
