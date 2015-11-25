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
    generic (period    : time    := 10 ns);  -- Generic for clock period
end TestBenchVHDL;
            
architecture behavioral of TestBenchVHDL is 

-- Testbench signals
signal clk            : STD_LOGIC := '0';
signal led            : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal an             : STD_LOGIC_VECTOR ( 7 downto 0) := (others => '0');
signal seg            : STD_LOGIC_VECTOR ( 6 downto 0) := (others => '0');
signal dp             : STD_LOGIC := '0';
signal sw             : STD_LOGIC_VECTOR (12 downto 0) := (others => '0');
signal Display_Select, Step, Deposit, Load_PC, Load_AC, Run_LED, Idle_LED : STD_LOGIC := '0';

signal line_num: INTEGER range 0 to 4096 := 0; 
file   program_file, opcode_file, branch_file : text;

signal ac_reg, i_reg, mq_reg, pc_reg, temp_reg, ea_reg : STD_LOGIC_VECTOR (11 downto 0);
signal l_reg : STD_LOGIC := '0'; 

signal mem_ready, micro_cond_branch : STD_LOGIC := '0';

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

Run_LED <= led(12);
Idle_LED <= led(13);
micro_cond_branch <= '1' when ((i_reg(11 downto 8) = "1111" and i_reg(0) = '0') and
                               (i_reg(4) = '1' or i_reg(5) = '1' or i_reg(6) = '1')) else '0';               

-- Clock signal
process begin                                       
    clk <= not clk;
    wait for period/2;
end process;  
 
-- Monitor signals from lower level modules 
process begin
init_signal_spy("/TestBenchVHDL/TOP1/MEM/end_of_memory" ,"mem_ready"    ,1);
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
     file_open(program_file, "class3a.txt",  read_mode);
     file_open(opcode_file, "opcode_output.txt",  write_mode);
     file_open(branch_file, "branch_trace.txt",  write_mode);
     
     wait until mem_ready = '1'; -- Wait for memory initilaiziation to complete
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

-- Build opcode file
process(Idle_LED) 
     variable opcode_line : line;
     variable  i : bit_vector (8 downto 0);
     variable ac : bit_vector (11 downto 0);
     variable  l : integer range 0 to 1;
     variable ea : bit_vector (11 downto 0);
     variable mb : bit_vector (11 downto 0);
     variable pc : bit_vector (11 downto 0);
begin
     if (rising_edge(Idle_LED) and Run_LED = '1') then
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
     end if;
end process;

-- Build branch trace file
process 
     variable branch_line : line;
     variable branch_flag : bit := '0';
     variable cond_flag   : bit := '0';
     variable jms_flag    : bit := '0';
     variable pc_temp     : bit_vector(11 downto 0) := o"0000";
     variable pc          : bit_vector(11 downto 0) := o"0000";
     variable pcp1        : bit_vector(11 downto 0) := o"0000";
     variable pcp2        : bit_vector(11 downto 0) := o"0000";
     variable ea          : bit_vector(11 downto 0) := o"0000";
     variable eap1        : bit_vector(11 downto 0) := o"0000";
     variable opcode      : integer range 0 to 7;     
begin
     wait until (i_reg'EVENT and Run_LED = '1');    -- Change in IR while running
     wait for period;
     opcode  :=  conv_integer( i_reg(11 downto 9)); -- Store opcode
     pc_temp :=  TO_BITVECTOR(pc_reg(11 downto 0)); -- Store current PC
     pcp1    :=  TO_BITVECTOR(pc_reg(11 downto 0) + '1' ); -- Convert current PC + 1 to bitvector
     pcp2    :=  TO_BITVECTOR(pc_reg(11 downto 0) + "10"); -- Convert current PC + 2 to bitvector 
     if (opcode = 4) then  -- JMS
          branch_flag := '1';
          cond_flag   := '0';
          jms_flag    := '1'; 
     elsif (opcode = 5) then
          branch_flag := '1';
          cond_flag   := '0';
          jms_flag    := '0'; 
     elsif (opcode = 2 or (opcode = 7 and micro_cond_branch = '1')) then -- ISZ or Microcoded
          branch_flag := '1';
          cond_flag   := '1';
          jms_flag    := '0'; 
     else
          branch_flag := '0';
          cond_flag   := '0';
          jms_flag    := '0';           
     end if;

     wait until (Idle_LED = '1');  -- Wait until instruction completes
     if (branch_flag = '1') then   -- If instruction was some sort of branch
          pc   :=  TO_BITVECTOR(pc_reg(11 downto 0)      ); -- Convert current PC to bitvector
          ea   :=  TO_BITVECTOR(ea_reg(11 downto 0)      ); -- Convert current EA to bitvector
          eap1 :=  TO_BITVECTOR(ea_reg(11 downto 0) + '1'); -- Convert current EA + 1 to bitvector
          if (cond_flag = '0' and jms_flag = '0') then      -- If JMP
               write(branch_line, string'("Current PC: "));
               OWRITE(branch_line, pc_temp, right, 4);
               write(branch_line, string'(", Target: "));
               OWRITE(branch_line, ea, right, 4);
               if (ea = pc) then        -- If it worked
                    write(branch_line, string'(", Type: Unconditional, Result: Taken"));
               else write(branch_line, string'(", Type: Unconditional, Result: Error")); 
               end if;
          elsif (cond_flag = '0' and jms_flag = '1') then      -- If JMS
               write(branch_line, string'("Current PC: "));
               OWRITE(branch_line, pc_temp, right, 4);
               write(branch_line, string'(", Target: "));
               OWRITE(branch_line, eap1, right, 4);
               if (eap1 = pc) then        -- If it worked
                    write(branch_line, string'(", Type: Unconditional, Result: Taken"));
               else write(branch_line, string'(", Type: Unconditional, Result: Error")); 
               end if;     
          else -- If ISZ or Micro
               write(branch_line, string'("Current PC: "));
               OWRITE(branch_line, pc_temp, right, 4);
               write(branch_line, string'(", Target: "));
               OWRITE(branch_line, (pcp2), right, 4);
               if (pc = pcp2) then    -- If it was taken
                    write(branch_line, string'(", Type: Conditional,   Result: Taken"));
               elsif (pc = pcp1) then -- If it was not taken
                    write(branch_line, string'(", Type: Conditional,   Result: Not Taken"));
               else write(branch_line, string'(", Type: Conditional,   Result: Error"));  
               end if;
          end if;     
          writeline(branch_file, branch_line);
          branch_flag := '0';
          cond_flag   := '0';
     end if;
end process;



-- When program stops
process(Run_LED) begin
     if falling_edge(Run_LED) then
          file_close(program_file);
          file_close(opcode_file);
          file_close(branch_file);
     end if;

end process;

 
 
end behavioral;




