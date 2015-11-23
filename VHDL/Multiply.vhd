-- Multiply
-- Jonathan Waldrip
-- Code duplicated from example in class by Tom Almay


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL; -- for + operator
use IEEE.std_logic_arith.ALL;    -- for conv_std_logic_vector

entity multiply is
     Generic (N : integer := 12);  
     Port    (clk          : in  STD_LOGIC;
              multiplier   : in  STD_LOGIC_VECTOR (  N-1 downto 0);
              multiplicand : in  STD_LOGIC_VECTOR (  N-1 downto 0);          
              start        : in  STD_LOGIC                        ;          
              product      : out STD_LOGIC_VECTOR (2*N-1 downto 0); 
              finished     : out STD_LOGIC                        
             );      
end multiply;

architecture Behavioral of multiply is

signal regp    : STD_LOGIC_VECTOR (2*N-1 downto 0) := (others => '0'); 
signal regm    : STD_LOGIC_VECTOR (  N-1 downto 0) := (others => '0');
signal load    : STD_LOGIC                        ;
signal shift   : STD_LOGIC                        ;
signal add     : STD_LOGIC                        ;
signal doadd   : STD_LOGIC                        ;
signal adder   : STD_LOGIC_VECTOR (  N   downto 0) := (others => '0');
signal counter : INTEGER range 0 to N := 0        ;
signal en_cnt  : STD_LOGIC                        ;
signal cntnm1  : STD_LOGIC                        ;

type STATE_TYPE is (S0, S1, S2, S3);
signal current_state : STATE_TYPE := S0            ;
signal next_state    : STATE_TYPE                  ;

begin

product <= regp;
adder <= ("0" & regp(2*N-1 downto N)) + ("0" & regm);
doadd <= regp(0);

process (clk) -- regm
begin
     if rising_edge(clk) then
          if load = '1' then
          regm <= multiplier;
          end if;
     end if;   
end process;     

process (clk) -- regp
begin
     if rising_edge(clk) then
          if load = '1' then
               regp <= conv_std_logic_vector(0, N) & multiplicand;
          elsif shift = '1' then
               regp <= '0' & regp(2*N-1 downto 1);
          elsif add = '1' then
               regp <= adder & regp(N-1 downto 1);
          end if;
     end if;   
end process;

process (clk) -- counter
begin
     if rising_edge(clk) then
          if en_cnt = '1' then
               counter <= counter + 1;
          else
               counter <= 0;
          end if;
     end if;   
end process;        

cntnm1 <= '1' when counter = N-1 else '0';

process (clk) -- State Register
begin
     if rising_edge(clk) then
          current_state <= next_state;
     end if;
end process;

process (doadd, start, cntnm1, current_state) -- Next state logic
begin
     load     <= '0';  -- default
     add      <= '0';
     shift    <= '0';
     en_cnt   <= '0';
     finished <= '0';
     next_state <= current_state;
	case current_state is
		when S0 =>
               if (start = '1') then
                    load <= '1';
                    next_state <= S1;
               end if;
		when S1 =>
               en_cnt <= '1';
               if (doadd = '1') then
                    add <= '1';
               else
                    shift <= '1';
               end if;
               if cntnm1 = '1' then
                    next_state <= S2;     
               end if;
		when S2 =>
               finished <= '1';
               if (start = '0') then
                    next_state <= S0;
               else
                    next_state <= S3;
               end if;  
		when S3 =>
               next_state <= S0;
          when others =>
               next_state <= S0;                  
	end case;
end process;
         
end Behavioral;

