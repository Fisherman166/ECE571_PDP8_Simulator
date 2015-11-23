----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:53:42 04/18/2015 
-- Design Name: 
-- Module Name:    State_Machine - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity State_Machine is
    Port (run : in  STD_LOGIC := '0';									-- Generate Inputs and Outputs
          dispsel : in  STD_LOGIC_VECTOR (1 downto 0):= (others => '0');
          loadpc : in  STD_LOGIC := '0';
          loadac : in  STD_LOGIC := '0';
          step : in  STD_LOGIC := '0';
          deposit : in  STD_LOGIC := '0';
          skip_flag : in  STD_LOGIC := '0';
          clearacc : in  STD_LOGIC := '0';
          mem_finished : in  STD_LOGIC := '0';
          clk : in STD_LOGIC := '0';
          i_reg : in STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
          temp_reg : in STD_LOGIC_VECTOR (11 downto 0) := (others => '0');	
          ea_reg_8_to_15 : in STD_LOGIC := '0';
          srchange : in  STD_LOGIC := '0';
          micro_g1 : in STD_LOGIC := '0';
          micro_g2 : in STD_LOGIC := '0';
          micro_g3 : in STD_LOGIC := '0';
          skip : in STD_LOGIC := '0';
          eae_fin : in STD_LOGIC := '0';
          halt : out  STD_LOGIC := '0';
          bit1_cp2 : out  STD_LOGIC := '0';
          bit2_cp3 : out  STD_LOGIC := '0';
          io_address : out  STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
          write_enable : out  STD_LOGIC := '0';
          read_enable : out  STD_LOGIC := '0';
          en_ac_sr : out  STD_LOGIC := '0';
          en_ac_and : out  STD_LOGIC := '0';
          en_ac_tad : out  STD_LOGIC := '0';
          en_read_isz : out  STD_LOGIC := '0';
          en_write_pcp1 : out STD_LOGIC := '0';
          en_write_temp : out  STD_LOGIC := '0';
          en_pc_p1 : out  STD_LOGIC := '0';
          en_pc_p2 : out  STD_LOGIC := '0';
          en_pc_sr : out  STD_LOGIC := '0';
          en_write_ac : out  STD_LOGIC := '0';
          en_ac_clear : out  STD_LOGIC := '0';
          en_add_pcp1 : out  STD_LOGIC := '0';
          en_add_pc : out  STD_LOGIC := '0';
          en_add_ea : out  STD_LOGIC := '0';
          en_write_ea : out  STD_LOGIC := '0';
          en_write_dep : out  STD_LOGIC := '0';
          en_pc_jmp : out  STD_LOGIC := '0';
          en_ac_micro : out  STD_LOGIC := '0';
          en_load_ea_zero : out  STD_LOGIC := '0';
          en_load_ea_current : out  STD_LOGIC := '0';
          en_load_ea_mem : out  STD_LOGIC := '0';
          en_load_ea_memp1 : out  STD_LOGIC := '0';
          en_mem_memp1 : out  STD_LOGIC := '0';
		en_ir_load : out STD_LOGIC := '0';
		en_disp_pc : out STD_LOGIC := '0';
		en_disp_ac : out STD_LOGIC := '0';
		en_disp_mq : out STD_LOGIC := '0';
		en_disp_mem : out STD_LOGIC := '0';
		en_ac_ord_datain : out STD_LOGIC := '0';
		en_dataout_ac : out STD_LOGIC := '0';
		en_add_sr : out STD_LOGIC := '0';
		en_ac_ord_sr : out STD_LOGIC := '0';
		en_ac_mul : out STD_LOGIC := '0';
		en_mq_mul : out STD_LOGIC := '0';
		en_ac_dvi : out STD_LOGIC := '0';
		en_mq_dvi : out STD_LOGIC := '0';
		en_ac_mq  : out STD_LOGIC := '0';
		en_mq_ac  : out STD_LOGIC := '0';
		en_ac_ord_mq : out STD_LOGIC := '0';
		eae_start : out STD_LOGIC := '0';
          CPU_idle  : out STD_LOGIC := '0');
end State_Machine;

architecture Behavioral of State_Machine is
---------------------------------- Declare all of the states including the dead delay states
type STATE_TYPE is (S0, S1, S2, S2b, S2c, S2d, S2e, S2f, S3, S3a, S3b, S3c, S4, S5, S6, S6_1, S_calculate_ea,
								S_indirect_ea,S_indirect_auto, S7, S7a, S7aa, S7aaa, S7b, S7c, S7d, S7e, S7f,
								S7g, S7h, S7a_1, S7a_2, S7a_3, S7a_4, S7a_5, S7a_6, S7b_1, S7b_2, S7b_3, S7b_4, S7b_5, S7b_6,
								S7c_1, S7c_2, S7c_3, S7c_4, S7c_5, S7c_6, S7c_7, S7c_8, S7c_9, S7c_10, S7d_1, S7d_2, 
								S7d_3, S7d_4, S7d_5, S7d_6, S7e_1, S7e_2, S7e_3, S7e_4, S7e_5, S7e_6, S7f_1, S7f_2,
								S7f_3, S7f_4, S7f_5, S7g_1, S7g_2, S7g_3, S7g_4, S7g_5, S7g_6, S7g_7, S7g_8, S7h_1,
								S7h_2, S7h_3, S7h_4, S7h_5, S7h_6, S7h_6_1, S7h_7, S7h_8, S7h_9, S_srchange, S_srchange_1a, S_srchange_1b,
								S_indirect_auto_1, S_indirect_auto_1a, S_indirect_auto_1b, S_indirect_auto_1c, S_indirect_auto_1d,
                                S_indirect_auto_1e, S_indirect_norm, S_indirect_norm_1, S_indirect_norm_2, S_indirect_auto_11,
								S_indirect_auto_1dd, S7c_66, S7d_11, S7b_11, S7c_11, S_indirect_ea_1, S7h_6_11);	

signal cur_state : STATE_TYPE := S0;		-- Declare current State Variable
signal next_state : STATE_TYPE;				-- Declare next state variable

begin

process (clk) -- State Register
begin
	if rising_edge(clk) then
		cur_state <= next_state;
	end if;
end process;
---------------------------- Sensetivity List and Beginning of State Machine------------------------
process (run, dispsel, loadpc, loadac, step, deposit, skip_flag,
				clearacc, mem_finished, i_reg, temp_reg, ea_reg_8_to_15, 
					srchange, micro_g1, micro_g2, micro_g3, skip, eae_fin, cur_state) -- Next state logic
begin
-----------------------Default Values ---------------------------------------------------
next_state <= cur_state;
write_enable <= '0';
en_write_pcp1 <= '0';
en_add_pc <= '0';
halt <= '0';
bit1_cp2 <= '0';
bit2_cp3 <= '0';
io_address <= "000";
read_enable <= '0';
en_ac_sr <= '0';
en_ac_and <= '0';
en_ac_tad <= '0';
en_read_isz <= '0';
en_write_temp <= '0';
en_pc_p1 <= '0';
en_pc_p2 <= '0';
en_pc_sr <= '0';
en_write_ac <= '0';
en_ac_clear <= '0';
en_add_pcp1 <= '0';
en_add_ea <= '0';
en_write_dep <= '0';
en_write_ea <= '0';
en_pc_jmp <= '0';
en_ac_micro <= '0';
en_load_ea_zero <= '0';
en_load_ea_current <= '0';
en_load_ea_mem <= '0';
en_load_ea_memp1 <= '0';
en_mem_memp1 <= '0';
en_ir_load <= '0';
en_disp_pc <= '0';
en_disp_ac <= '0';
en_disp_mq <= '0';
en_disp_mem <= '0';
en_ac_ord_datain <= '0';
en_dataout_ac <= '0';
en_ac_mul <= '0';
en_mq_mul <= '0';
en_ac_dvi <= '0';
en_mq_dvi <= '0';
en_add_sr <= '0';
en_ac_ord_sr <= '0';
eae_start <= '0';
en_ac_mq <= '0';
en_mq_ac <= '0';
en_ac_ord_mq <= '0';
CPU_idle <= '0';
------------------------------------------------------------------------------------	
	case cur_state is
		when S0 =>     CPU_idle <= '1';
                         if run = '1' then					-- Idle or halted state
						next_state <= S2;					-- Run Switch Check
					  elsif step = '1' then
						next_state <= S2;					-- Step Button Check
					  elsif srchange = '1' then
						next_state <= S_srchange;
					  elsif loadpc = '1' then			-- Check for Load PC button
						next_state <= S4;
					  elsif loadac = '1' then			-- Check for Load Ac Buttton
						next_state <= S5;
					  elsif deposit = '1' then			-- Check for Deposit Button
						next_state <= S6;
					  elsif dispsel = "00" then		-- Display selection checked last
						en_disp_pc <= '1';
					  elsif dispsel = "01" then
						en_disp_ac <= '1';
					  elsif dispsel = "10" then
						en_disp_mq <= '1';
					  elsif dispsel = "11" then
						en_disp_mem <= '1';
					  end if;
------------------------------ Does the Switch register update if CPU detects changed Swreg---------
		
          when S_srchange =>       en_add_sr <= '1';                       -- Load sw_reg to mem address			          	
                                   next_state <= S_srchange_1a;

          when S_srchange_1a =>    next_state <= S_srchange_1b;            -- wait                                 
                                   
          when S_srchange_1b =>    read_enable <= '1';					-- Fetch from Memory
                                   if mem_finished = '1' then
                                        next_state <= S0;                  -- wait
                                   end if;
                               
----------------------------- Fetch Next Instruction ------------------------------------------------
   
		when S2 =>     en_add_pc <= '1';				-- move PC to EA
                         next_state <= S2b;
          
          
          
		when S2b =>    next_state <= S2c;                 -- wait    
          
          
          when S2c =>    read_enable <= '1';                -- read
					if mem_finished = '1' then		-- wait
                              next_state <= S2d;
					end if;	
                         
		when S2d =>    next_state <= S2e;          
                         en_ir_load <= '1';				-- load IR with Read Datae
       
		when S2e => next_state <= S2f;                    -- wait
          
		when S2f => next_state <= S_calculate_ea;		-- Goto effective address calculation
          
---------------------------------Load Program Counter-----------------------------------
		when S4 => en_pc_sr <= '1';
						next_state <= S0;
--------------------------------- Load Accumulator -------------------------------------
		when S5 => en_ac_sr <= '1';
					  next_state <= S0;
--------------------------------- Deposit Function --------------------------------------
		when S6 =>    en_add_pc <= '1';
					  en_write_dep <= '1';
					  next_state <= S6_1;
		
		when S6_1 =>  write_enable <= '1';
					  if mem_finished = '1' then			-- Memory Write
						en_pc_p1 <= '1';
						next_state <= S0;
					  end if;
---------------------------- Getting Effective Address -----------------------------------
		when S_calculate_ea => if i_reg(7) = '0' then
										en_load_ea_zero <= '1';
										 if i_reg(8) = '0' then
										  next_state <= S7;
										 else 
										   next_state <= S_indirect_ea;
										 end if;
									  else
										en_load_ea_current <= '1';
										 if i_reg(8) = '0' then
										  next_state <= S7;
										 else 
										   next_state <= S_indirect_ea;
										 end if;
									  end if;
		when S_indirect_ea =>         en_add_ea <= '1';
									 if ea_reg_8_to_15 = '0' then
										next_state <= S_indirect_ea_1;
									 else
										next_state <= S_indirect_auto;
									 end if;
		when S_indirect_ea_1 =>		next_state <= S_indirect_norm;
                                              
		when S_indirect_norm =>       read_enable <= '1';                     -- read vlaue stored at location                    
                                        if mem_finished = '1' then
                                             next_state <= S_indirect_norm_1;
                                        end if;
          
          when S_indirect_norm_1 =>     en_load_ea_mem <= '1';                  -- value becomes EA
                                        next_state <= S7;                       -- process instruction
                              
		when S_indirect_auto =>         en_add_ea <= '1';                       -- Get value stored at address
										next_state <= S_indirect_auto_11;
										
		when S_indirect_auto_11 =>        read_enable <= '1';                     
                                        if mem_finished = '1' then
                                             next_state <= S_indirect_auto_1;
                                        end if;
                                        
		when S_indirect_auto_1 => 		en_read_isz <= '1';                     -- Increment temp_reg
                                        next_state <= S_indirect_auto_1a;
          
          when S_indirect_auto_1a =>    en_read_isz <= '1';                    
                                        en_write_temp <= '1';                   -- Move temp_reg to write_data          
                                        next_state <= S_indirect_auto_1b;
           
          when S_indirect_auto_1b =>    en_read_isz <= '1';                    
                                        en_write_temp <= '1';                   -- wait       
                                        next_state <= S_indirect_auto_1c;
           
          when S_indirect_auto_1c => 	en_read_isz <= '1';                     -- wait
                                        en_write_temp <= '1';
                                        next_state <= S_indirect_auto_1d;
          
          when S_indirect_auto_1d => 	en_read_isz <= '1';
										next_state <= S_indirect_auto_1dd;
										
		  when S_indirect_auto_1dd =>   write_enable <= '1';                    -- Write back to same memory location
										if mem_finished = '1' then
                                             next_state <= S_indirect_auto_1e;  -- wait
										end if; 
                                        
          when S_indirect_auto_1e => 	en_read_isz <= '1';
                                        en_load_ea_mem <= '1';                  -- place incremented value in EA
                                        next_state <= S7;                       -- Process instruction
                                
                                        
-------------------------------- Decoding Operation ----------------------------------------										
		when S7 => if i_reg(11 downto 9) = "000" then
						next_state <= S7a;   -- AND Operation
					  elsif i_reg (11 downto 9) = "001" then
						next_state <= S7b;   -- TAD Operation
					  elsif i_reg (11 downto 9) = "010" then
						next_state <= S7c;   -- ISZ Operation
					  elsif i_reg (11 downto 9) = "011" then
						next_state <= S7d;   -- DCA Operation
					  elsif i_reg (11 downto 9) = "100" then
						next_state <= S7e;   -- JMS Operation
					  elsif i_reg (11 downto 9) = "101" then
						next_state <= S7f;   -- JMP Operation
					  elsif i_reg (11 downto 9) = "110" then
						next_state <= S7g;   -- IOT Operation
							io_address <= i_reg(5 downto 3);
					  else
					   next_state <= S7h;	-- Microcoded Operation
					  end if;	
----------------- AND Instruction ----------------------------------
		when S7a => 	en_add_ea <= '1';
						next_state <= S7aa;
		when S7aa =>    next_state <= S7aaa;
						
		when S7aaa =>	read_enable <= '1';
						if mem_finished = '1' then		-- Memory Fetch
						next_state <= S7a_1;
                              end if;
		when S7a_1 => next_state <= S7a_2;
		when S7a_2 => next_state <= S7a_3;
		when S7a_3 => en_ac_and <= '1';
						  next_state <= S7a_4;
		when S7a_4 => next_state <= S7a_5;
		when S7a_5 => next_state <= S7a_6;
		when S7a_6 => en_pc_p1 <= '1';
						  next_state <= S0;
----------------- TAD Instruction ---------------------------------
	   when S7b =>  en_add_ea <= '1';
                    next_state <= s7b_11;
		when S7b_11 => next_state <= S7b_1;
		when S7b_1 => 
                    read_enable <= '1';
                    if mem_finished = '1' then			-- Memory Fetch
						next_state <= S7b_2;
				end if;
		when S7b_2 => next_state <= S7b_3;
		when S7b_3 => en_ac_tad <= '1';
						  next_state <= S7b_4;
		when S7b_4 => next_state <= S7b_5;
		when S7b_5 => next_state <= S7b_6;
		when S7b_6 => en_pc_p1 <= '1';
						  next_state <= S0;
---------------- ISZ Instruction ---------------------------------
		when S7c =>    en_add_ea <= '1';                  -- set memery address
                         next_state <= S7c_11;
		when S7c_11 => next_state <= S7c_1;
        when S7c_1 =>  read_enable <= '1';                -- Read
                         if mem_finished = '1' then		-- Wait
                              next_state <= S7c_2;
					end if; 

		when S7c_2 =>  en_read_isz <= '1';                -- Inc value in temp_reg
                         next_state <= S7c_3;
                         
		when S7c_3 =>  en_read_isz <= '1';
                         next_state <= S7c_4;               -- Wait

		when S7c_4 =>  en_read_isz <= '1';
                         next_state <= S7c_5;               -- wait          
                        
		when S7c_5 =>  en_read_isz <= '1'; 
                         en_write_temp <= '1';              -- move temp_reg to write_data
                         next_state <= S7c_6;
                         
		when S7c_6 =>  en_read_isz <= '1';
					   next_state <= S7c_66;
       
	   when S7c_66 =>   write_enable <= '1';               -- Write back to same memory location
                         if mem_finished = '1' then	     -- wait
                              next_state <= S7c_7;
                         end if;
                         
		when S7c_7 =>  en_read_isz <= '1';
                         next_state <= S7c_8;
                         if temp_reg = "000000000000" then	-- Check temp for a zero
                              en_pc_p1 <= '1';
                         end if;
                         
		when S7c_8 => next_state <= S7c_9;
		when S7c_9 => next_state <= S7c_10; 
		when S7c_10 => en_pc_p1 <= '1';
						   next_state <= S0;
---------------------- DCA Instruction --------------------------------
		when S7d => en_add_ea <= '1';
					next_state <= S7d_11;					
		when S7d_11 => en_write_ac <= '1';
                      next_state <= S7d_1;
		when S7d_1 => next_state <= S7d_2;
		when S7d_2 => write_enable <= '1';
				     if mem_finished = '1' then			--  Memory Write
                              next_state <= S7d_3;
				     end if;         
		when S7d_3 => next_state <= S7d_4;
		when S7d_4 => next_state <= S7d_5;
		when S7d_5 => en_ac_clear <= '1';
						  next_state <= S7d_6;
		when S7d_6 => en_pc_p1 <= '1';
						  next_state <= S0;
--------------------- JMS Instruction --------------------------------
		when S7e =>    en_add_ea <= '1';        -- EA to mem address
                         next_state <= S7e_1;

		when S7e_1 =>  en_write_pcp1 <= '1';    -- move return location to write data
                         next_state <= S7e_2;                         
          
          when s7e_2 =>  next_state <= s7e_3;     -- wait          
         
		when S7e_3 =>  write_enable <= '1';          -- store return address
					if mem_finished = '1' then    -- wait
                              next_state <= S7e_4;
					end if;          
          
		when S7e_4 =>  en_pc_jmp <= '1';         -- PC jumps to address before subroutine
                         next_state <= S7e_5;      
                    
		when S7e_5 =>  en_pc_p1 <= '1';          -- Inc PC
                         next_state <= S7e_6;
                         
		when S7e_6 =>  next_state <= S0; 
                       
                         
-------------------- JMP Instruction ------------------------------------
		when S7f => en_pc_jmp <= '1';
						next_state <= S7f_1;
		when S7f_1 => next_state <= S7f_2;
		when S7f_2 => next_state <= S7f_3;
		when S7f_3 => next_state <= S7f_4;
		when S7f_4 => next_state <= S7f_5;
		when S7f_5 => next_state <= S0;	
-------------------- IOT Instruction ------------------------------------
		
          -- T1
          when S7g =>    io_address <= i_reg(5 downto 3);             -- set address
					if (i_reg(0) = '1' and skip_flag = '1') then -- if T1 and skip flag, then skip
                              en_pc_p1 <= '1';
                              next_state <= S7g_5;
                         elsif (i_reg(0) = '1') then
                              next_state <= S7g_5; 
                         else next_state <= S7g_1;    
                         end if;          
           
          -- T2 
		when S7g_1 =>  next_state <= S7g_2;  
                         io_address <= i_reg(5 downto 3);
					if (i_reg(1) = '1') then                     -- if T2 then clear flag
                              bit1_cp2 <= '1';
                              if clearacc = '1' then	               -- if input device,
                                   en_ac_clear <= '1';                -- clear AC
                              else en_dataout_ac <= '1';              -- Else pass AC to dataout
                              end if;    
                         end if;  
          -- T3	
		when S7g_2 =>  io_address <= i_reg(5 downto 3);
                         if i_reg(2) = '1' then			          -- If T3 bit is set
                              bit2_cp3 <= '1';
					end if;
                         
                         if clearacc = '1' then	                    -- if input device,
                              en_ac_ord_datain <= '1';                -- OR datain into AC
                              next_state <= S7g_3;
                         else en_dataout_ac <= '1';                   -- Else pass AC to dataout
                              next_state <= S7g_4;     
                         end if;                              

                                   
                                   
		when S7g_3 =>  en_ac_ord_datain <= '1';                     -- Wait for data to come in
                         next_state <= S7g_5;
                              
		when S7g_4 =>  en_dataout_ac <= '1';                        -- Wait for data to go out
                         next_state <= S7g_5;
						
		when S7g_5 =>  next_state <= S7g_6;
 						                            
		when S7g_6 =>  next_state <= S7g_7;
						
		when S7g_7 =>  next_state <= S7g_8;
						
		when S7g_8 =>  en_pc_p1 <= '1';
                         next_state <= S0;
                         
------------------- Microcoded Instruction ------------------------------
-- We designed the CPU to always decode the microcoded instructions and always send out a signal as if it was going
-- to process one.  The State machine will use the CPUs signals to determine which signals need to be enabled
-- if it detects that a microcoded instruction is needed.
		when S7h => if micro_g1 = '1' then			
						   en_ac_micro <= '1';
					 	   next_state <= S7h_1;
						else
							next_state <= S7h_1;
						end if;
		when S7h_1 => if micro_g2 = '1' and skip = '1' then
						   en_pc_p1 <= '1';
						   next_state <= S7h_2;
						  elsif micro_g2 = '1' and i_reg(2) = '1' and i_reg(7) = '1' then
						   en_ac_sr <= '1';
							next_state <= S7h_2;
						  elsif micro_g2 = '1' and i_reg(2) = '1' then
						   en_ac_ord_sr <= '1';
							next_state <= S7h_2;
						  elsif micro_g2 = '1' and i_reg(1) = '1' then
						   halt <= '1';
							next_state <= S0;
						  else
							next_state <= S7h_2;
						  end if;	
                                
		when S7h_2 =>       next_state <= S7h_3;
                              if micro_g3 = '1' and i_reg(7) = '1' then  
						   en_ac_clear <= '1';
                              end if;
                         
		when S7h_3 => next_state <= S7h_4;
          
          
		when S7h_4 => if micro_g3 = '1' and i_reg(6) = '1' and i_reg(4) = '1' then
						   en_ac_mq <= '1';
						   en_mq_ac <= '1';
							next_state <= S7h_5;
						  elsif micro_g3 = '1' and i_reg(6) = '1' then
						   en_ac_ord_mq <= '1';
							next_state <= S7h_5;
						  elsif micro_g3 = '1' and i_reg(4) = '1' then
						   en_mq_ac <= '1';
						   en_ac_clear <= '1';
							next_state <= S7h_5;
						  else
							next_state <= S7h_5;
						  end if;
	  
		when S7h_5 => if micro_g3 = '1' and i_reg(2 downto 1) = "10" then
							en_pc_p1 <= '1';
							next_state <= S7h_6;
						  elsif micro_g3 = '1' and i_reg(2 downto 1) = "11" then
						   en_pc_p1 <= '1';
							next_state <= S7h_6;
						  else 
								next_state <= S7h_9;
						  end if;	
          
		when S7h_6 =>       en_add_pc <= '1';
						    next_state <= S7h_6_11;
		when S7h_6_11 =>    next_state <= S7h_6_1;
	
		when S7h_6_1 => read_enable <= '1';
							 if mem_finished = '1' then		-- Mem fetch
								next_state <= S7h_7;
					       end if;
		when S7h_7 => eae_start <= '1';			-- Start EAE and wait for finished handshake
						   if eae_fin = '1' then
								next_state <= S7h_8;
					      end if;
		when S7h_8 => if i_reg(2 downto 1) = "10" then
							en_ac_mul <= '1';					-- Process Multiplication
							en_mq_mul <= '1';
							next_state <= S7h_9;
						  elsif i_reg(2 downto 1) = "11" then
						    en_ac_dvi <= '1';					-- Process Division
							en_mq_dvi <= '1';
							next_state <= S7h_9;
						  else
							next_state <= S7h_9;
						  end if;
		when S7h_9 => en_pc_p1 <= '1';
						 next_state <= S0;
		when others => next_state <= S0;
	end case;
end process;

end Behavioral;

