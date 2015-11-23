-- File Name: TestBenchVHDL.vhd
-- Module Name: TestBenchVHDL
-- Jonathan Waldrip
-- 2015.11.22
-- This module is a testbench for the PDP8

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

library ieee, modelsim_lib;
use modelsim_lib.util.all;

library ieee_proposed;
use ieee_proposed.standard_additions;
use ieee_proposed.standard_textio_additions.all;

entity TestBenchVHDL is
    generic (period    : time    := 10 ns);  -- Generic for number of test cycles to perform
end TestBenchVHDL;
            
architecture behavioral of TestBenchVHDL is 

-- Testbench signals
signal clk            : STD_LOGIC := '0';
signal led            : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal an             : STD_LOGIC_VECTOR ( 7 downto 0) := (others => '0');
signal seg            : STD_LOGIC_VECTOR ( 6 downto 0) := (others => '0');
signal dp             : STD_LOGIC := '0';
signal sw             : STD_LOGIC_VECTOR (12 downto 0) := (others => '0');
signal Display_Select, Step, Deposit, Load_PC, Load_AC : STD_LOGIC := '0';

signal line_num: INTEGER range 0 to 4096 := 0; 
file   program_file, opcode_file : text;

type MEM_STATE_TYPE is (S_Init_Start, S_Init_Write, S_Init_Stop, S_Init_Inc, S_Init_End,
                        S_Idle, 
                        S_Wr_Start, S_Write,
                        S_Read_Reg, S_Read);
signal Memory_State    : MEM_STATE_TYPE;

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
signal Current_State : STATE_TYPE;

signal ac_reg, i_reg, mq_reg, pc_reg, temp_reg, ea_reg : STD_LOGIC_VECTOR (11 downto 0);
signal l_reg : STD_LOGIC := '0';                                 

-- Declare device under test (DUT) 
component Top_VHDL                
port( clk      : in  STD_LOGIC                      ;  -- On Board 10 MHz Clock 
      led      : out STD_LOGIC_VECTOR (15 downto 0) ;  -- LED's
      an       : out STD_LOGIC_VECTOR ( 7 downto 0) ;  -- 7 Segment anodes
      seg      : out STD_LOGIC_VECTOR ( 6 downto 0) ;  -- 7 Segment cathodes
      dp       : out STD_LOGIC                      ;  -- decimal point cathode
      sw       : in  STD_LOGIC_VECTOR (12 downto 0) ;  -- 13 switches
      btnc     : in  STD_LOGIC                      ;  -- Center button
      btnu     : in  STD_LOGIC                      ;  -- Up button
      btnd     : in  STD_LOGIC                      ;  -- Down button
      btnl     : in  STD_LOGIC                      ;  -- Left button
      btnr     : in  STD_LOGIC                         -- Right button
     );      
end component;

begin  
        
-- Instantiate top level module        
TOP1: Top_VHDL port map (
     clk    =>   clk            ,
     led    =>   led            ,
     an     =>   an             ,
     seg    =>   seg            ,
     dp     =>   dp             ,
     sw     =>   sw             ,
     btnc   =>   Display_Select ,
     btnu   =>   Step           ,
     btnd   =>   Deposit        ,
     btnl   =>   Load_PC        ,
     btnr   =>   Load_AC
);

-- Clock signal
process begin                                       
    clk <= not clk;
    wait for period/2;
end process;  
 
-- Monitor signals from lower level modules 
process begin
init_signal_spy("/TestBenchVHDL/TOP1/MEM/current_state" ,"Memory_State" ,1);
init_signal_spy("/TestBenchVHDL/TOP1/CPU0/SM0/cur_state","Current_State",1);
init_signal_spy("/TestBenchVHDL/TOP1/CPU0/ac_reg"       ,"ac_reg"       ,1);
init_signal_spy("/TestBenchVHDL/TOP1/CPU0/l_reg"        ,"l_reg"        ,1);
init_signal_spy("/TestBenchVHDL/TOP1/CPU0/i_reg"        ,"i_reg"        ,1);
init_signal_spy("/TestBenchVHDL/TOP1/CPU0/mq_reg"       ,"mq_reg"       ,1);
init_signal_spy("/TestBenchVHDL/TOP1/CPU0/pc_reg"       ,"pc_reg"       ,1);
init_signal_spy("/TestBenchVHDL/TOP1/CPU0/temp_reg"     ,"temp_reg"     ,1);
init_signal_spy("/TestBenchVHDL/TOP1/CPU0/ea_reg"       ,"ea_reg"       ,1);
wait;
end process; 
 
-- Initialize memory from file and run program
-- Code Source: http://www.nandland.com/vhdl/examples/example-file-io.html
process
     variable program_line : line;
     variable line_data : std_logic_vector(11 downto 0) := o"0000";     
begin
     file_open(program_file, "-class3a.txt",  read_mode);
     file_open(opcode_file, "opcode_output.txt",  write_mode);
     
     wait until Memory_State = S_Idle; -- Wait for memory initilaiziation to complete
     while not endfile(program_file) loop
          readline(program_file, program_line);
          read(program_line, line_data);
          wait for period;
          if (line_data /= o"0000") then
               sw(11 downto 0) <= std_logic_vector(to_unsigned(line_num, sw'length - 1));
               wait for 1*period;
               Load_PC <= '1';
               wait for 5*period;
               Load_PC <= '0';
               wait for 1*period;
               sw(11 downto 0) <= line_data;
               wait for 1*period;
               Deposit <= '1';
               wait for 5*period;
               Deposit <= '0';
               wait for 5*period;
          end if;
          line_num <= line_num + 1;
     end loop; 

     -- Run program
     sw(11 downto 0) <= o"0200";
     wait for 5*period;
     Load_PC <= '1';
     wait for 5*period;
     Load_PC <= '0';
     wait for 5*period;
     sw(12) <= '1';
     
     wait;     
     
end process;

-- Each time program reached idle state
process(led(13)) 
     variable opcode_line : line;
     variable i  : bit_vector (8 downto 0);
     variable ac : bit_vector (11 downto 0);
     variable  l : integer range 0 to 1;
     variable ea : bit_vector (11 downto 0);
     variable mb : bit_vector (11 downto 0);
     variable pc : bit_vector (11 downto 0);
     
begin
     if (rising_edge(led(13)) and led(12) = '1') then
     
          l  :=  conv_integer(l_reg);
          i  :=  "000000" & (TO_BITVECTOR(   i_reg(11 downto 9)));
          ac :=  TO_BITVECTOR(  ac_reg(11 downto 0));
          ea :=  TO_BITVECTOR(  ea_reg(11 downto 0));
          mb :=  TO_BITVECTOR(temp_reg(11 downto 0));
          pc :=  TO_BITVECTOR(  pc_reg(11 downto 0));
          
          
          write(opcode_line, string'("Opcode: "));
          OWRITE(opcode_line, i, right, 3);
          write(opcode_line, string'(", AC: "));
          OWRITE(opcode_line, ac, right, 4);
          write(opcode_line, string'(", Link: ") & integer'IMAGE(l));
          write(opcode_line, string'(", MB: "));
          OWRITE(opcode_line, mb, right, 4);
          write(opcode_line, string'(", PC: "));
          OWRITE(opcode_line, pc, right, 4);
          write(opcode_line, string'(", CPMA: "));
          OWRITE(opcode_line, ea, right, 4);
          
          writeline(opcode_file, opcode_line);
          
         -- $fdisplay(reg_file, "Opcode: %03o, AC: %o, Link: %b, MB: %o, PC: %o, CPMA: %o", 
         --      TOP0.bus.curr_reg.ir[11:9], TOP0.bus.curr_reg.ac, TOP0.bus.curr_reg.lk,
         --      TOP0.bus.curr_reg.mb, TOP0.bus.curr_reg.pc, TOP0.bus.curr_reg.ea);
               
               
               
     end if;
end process;


-- When program stops
process(led(12)) begin
     if falling_edge(led(12)) then
          file_close(program_file);
          file_close(opcode_file);
     end if;

end process;

 
 
end behavioral;




