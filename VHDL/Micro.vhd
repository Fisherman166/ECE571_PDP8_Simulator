-- Microcoded Group 1 and 2 Module for PDP8 Project
-- Jonathan Waldrip

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL; -- for + operator

entity Micro is 
     Port(i_reg     : in  STD_LOGIC_VECTOR ( 8 downto 0);  -- instruction register in
          ac_reg    : in  STD_LOGIC_VECTOR (11 downto 0);  -- accumulator register in
          l_reg     : in  STD_LOGIC                     ;  -- link register
          ac_micro  : out STD_LOGIC_VECTOR (11 downto 0);  -- instruction register out
          l_micro   : out STD_LOGIC                     ;  -- accumulator register out
          skip      : out STD_LOGIC                     ;  -- skip flag to SM for Group 2         
          micro_g1  : out STD_LOGIC                     ;  -- flag to SM, indicates group 1
          micro_g2  : out STD_LOGIC                     ;  -- flag to SM, indicates group 2
          micro_g3  : out STD_LOGIC                        -- flag to SM, indicates group 3                   
         );      
end Micro;

architecture Behavioral of Micro is

signal ac0      : STD_LOGIC_VECTOR (11 downto 0) := (others =>'0'); -- wire between logic block 0 and 1 (group1)
signal link0    : STD_LOGIC := '0';                      -- wire between logic block 0 and 1 (group1)
signal ac1      : STD_LOGIC_VECTOR (11 downto 0) := (others =>'0'); -- wire between logic block 1 and 2 (group1)
signal link1    : STD_LOGIC := '0';                      -- wire between logic block 1 and 2 (group1)
signal ac2      : STD_LOGIC_VECTOR (11 downto 0) := (others =>'0'); -- wire between logic block 2 and output (group1)
signal link2    : STD_LOGIC := '0';                      -- wire between logic block 2 and output (group1)
signal ac3      : STD_LOGIC_VECTOR (11 downto 0) := (others =>'0'); -- wire between logic block 3 and output (group1)
signal link3    : STD_LOGIC := '0';                      -- wire between logic block 3 and output (group1)

signal micro_g2_OR  : STD_LOGIC;  -- group 2 OR instruction detected
signal micro_g2_AND : STD_LOGIC;  -- group 2 AND instruction detected

-- bit for group 1, 2, and 3
signal CLA : STD_LOGIC;

-- bits for group 1
signal CLL, CMA, CML, RAR, RAL, BSW, IAC : STD_LOGIC;

signal g1_block3 : STD_LOGIC_VECTOR ( 2 downto 0):= (others =>'0');
signal l_and_ac  : STD_LOGIC_VECTOR (12 downto 0) := (others =>'0');
signal l_and_acp1: STD_LOGIC_VECTOR (12 downto 0):= (others =>'0'); 

-- bits for group 2 OR group
signal SMA, SZA, SNL : STD_LOGIC;
signal g2_OR_select  : STD_LOGIC_VECTOR (2 downto 0);
signal skip_or       : STD_LOGIC;

-- bits for group 2 AND group
signal SPA, SNA, SZL : STD_LOGIC;
signal g2_AND_select : STD_LOGIC_VECTOR (2 downto 0);
signal skip_and      : STD_LOGIC;

-- bits for group select
signal gSelect: STD_LOGIC_VECTOR (2 downto 0); 
 
begin

-- Assign bits from instruction register
-- bit for group 1, 2
CLA <= i_reg(7);

-- bits for group 1
CLL <= i_reg(6);
CMA <= i_reg(5);
CML <= i_reg(4);
RAR <= i_reg(3);
RAL <= i_reg(2);
BSW <= i_reg(1);
IAC <= i_reg(0);

-- bits for group 2 OR group
SMA <= i_reg(6);
SZA <= i_reg(5);
SNL <= i_reg(4);

-- bits for group 2 AND group
SPA <= i_reg(6);
SNA <= i_reg(5);
SZL <= i_reg(4);



-- bits for group select
gSelect <= i_reg(8) & i_reg(3) & i_reg(0);

-- which group?
micro_g2 <= '1' when (micro_g2_OR = '1' or micro_g2_AND = '1') else '0';
process (gSelect) begin
     micro_g1     <= '0';
     micro_g2_OR  <= '0';
     micro_g2_AND <= '0';
     micro_g3     <= '0';
     case (gSelect) is
          when ("000") => micro_g1     <= '1';
          when ("001") => micro_g1     <= '1'; 
          when ("010") => micro_g1     <= '1';
          when ("011") => micro_g1     <= '1';
          when ("100") => micro_g2_OR  <= '1';
          when ("101") => micro_g3     <= '1';
          when ("110") => micro_g2_AND <= '1';
          when ("111") => micro_g3     <= '1';
	     when others  => micro_g1     <= '0';
     end case;
end process;

-- group 1 instructions
ac_micro <= ac3;
l_micro  <= link3;

-- block 0 Clear
ac0   <= o"0000" when CLA = '1' else ac_reg;  
link0 <= '0'     when CLL = '1' else  l_reg; 

-- block 1 Complement
ac1   <= not ac0   when CMA = '1' else ac0;  
link1 <= not link0 when CML = '1' else link0;

-- block 2 Increment
l_and_ac   <= link1 & ac1;
l_and_acp1 <= l_and_ac + '1';
ac2   <= l_and_acp1(11 downto 0) when IAC = '1' else ac1;  
link2 <= l_and_acp1(12         ) when IAC = '1' else link1;

-- block 3 Shift
g1_block3 <= RAR & RAL & BSW;
process (g1_block3, i_reg, ac2, link2) begin
ac3   <= ac2;
link3 <= link2;
     case (g1_block3) is
          when ("001") => -- byte swap AC 
               ac3   <= ac2(5 downto 0) & ac2(11 downto 6);
               
          when ("010") => -- L:AC to the left by 1
               link3 <= ac2(11);
               ac3   <= ac2(10 downto 0) & link2;
               
          when ("011") => -- L:AC to the left by 2
               link3 <= ac2(10);
               ac3   <= ac2(9 downto 0) & link2 & ac2(11);
               
          when ("100") => -- L:AC to the right by 1
               link3 <= ac2(0);
               ac3   <= link2 & ac2(11 downto 1);
               
          when ("101") => -- L:AC to the right by 2
               link3 <= ac2(1);
               ac3   <= ac2(0) & link2 & ac2(11 downto 2);
                               
          when others   =>     
               ac3   <= ac2;
               link3 <= link2;
     end case;
end process;
    
    
  
-- group 2 OR instructions
g2_OR_select <= SMA & SZA & SNL;
process (g2_OR_select, i_reg, ac_reg, l_reg) begin
skip_or <= '0';
if (i_reg(8)='1' and i_reg(3)='0') then
     case (g2_OR_select) is
          when ("001") => -- skip if L /= 0
               if (l_reg /= '0') then
                    skip_or <= '1';
               end if;
     
          when ("010") => -- skip if AC = 0
               if (ac_reg = o"0000") then
                    skip_or <= '1';
               end if;
            
          when ("011") => -- skip if AC = 0 or L /= 0
               if ((l_reg /= '0') or (ac_reg = o"0000")) then
                    skip_or <= '1';
               end if;
            
          when ("100") => -- skip if AC is (-)
               if (ac_reg(11) = '1') then
                    skip_or <= '1';
               end if;
            
          when ("101") => -- skip if AC is (-) or L /= 0
               if ((ac_reg(11) = '1') or (l_reg /= '0')) then
                    skip_or <= '1';
               end if;
            
          when ("110") => -- skip if AC is (-) or AC = 0
               if ((ac_reg(11) = '1') or (ac_reg = o"0000")) then
                    skip_or <= '1';
               end if;

          when ("111") => -- skip if AC is (-), AC = 0, or L /= 0
               if ((ac_reg(11) = '1') or (ac_reg = o"0000") or (l_reg /= '0')) then
                    skip_or <= '1';
               end if;               
               
          when others   =>     
               skip_or <= '0';
     end case;
end if;	 
end process;


-- group 2 AND instructions
g2_AND_select <= SPA & SNA & SZL;
process (g2_AND_select, i_reg, ac_reg, l_reg) begin
skip_and <= '0';
if (i_reg(8)='1' and i_reg(3)='1') then  --if and group
     case (g2_AND_select) is
         when ("000") => -- Skip Unconditionally
			   skip_and <= '1';
		 when ("001") => -- skip if L = 0
               if (l_reg = '0') then
                    skip_and <= '1';
               end if;
     
          when ("010") => -- skip if AC /= 0
               if (ac_reg /= o"0000") then
                    skip_and <= '1';
               end if;
            
          when ("011") => -- skip if AC /= 0 and L = 0
               if ((l_reg = '0') and (ac_reg /= o"0000")) then
                    skip_and <= '1';
               end if;
            
          when ("100") => -- skip if AC is /(-)
               if (ac_reg(11) /= '1') then
                    skip_and <= '1';
               end if;
            
          when ("101") => -- skip if AC is /(-) and L = 0
               if ((ac_reg(11) /= '1') and (l_reg = '0')) then
                    skip_and <= '1';
               end if;
            
          when ("110") => -- skip if AC is /(-) and AC /= 0
               if ((ac_reg(11) /= '1') and (ac_reg /= o"0000")) then
                    skip_and <= '1';
               end if;

          when ("111") => -- skip if AC is /(-), AC /= 0, and L = 0
               if ((ac_reg(11) /= '1') and (ac_reg /= o"0000") and (l_reg = '0')) then
                    skip_and <= '1';
               end if;               
               
          when others   =>     
               skip_and <= '0';
     end case;   
end if;	 
end process;
    
-- skip from AND or OR group
skip <= skip_and or skip_or;     
    
end Behavioral;
