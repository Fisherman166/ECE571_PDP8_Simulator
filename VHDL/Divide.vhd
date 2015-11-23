-- divide
-- Jonathan Waldrip
-- Code duplicated from example in class by Tom Almay


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL; -- for + operator
use IEEE.std_logic_arith.ALL;    -- for conv_std_logic_vector

entity divide is
     Generic (N : integer := 12);  
     Port    (clk          : in  STD_LOGIC;
              dividend     : in  STD_LOGIC_VECTOR (2*N-1 downto 0);
              divisor      : in  STD_LOGIC_VECTOR (  N-1 downto 0);          
              start        : in  STD_LOGIC                        ;          
              quotient     : out STD_LOGIC_VECTOR (  N-1 downto 0); 
              remainder    : out STD_LOGIC_VECTOR (  N-1 downto 0);
              link_out     : out STD_LOGIC := '0';
              finished     : out STD_LOGIC                        
             );      
end divide;

architecture Behavioral of divide is

signal regp       : STD_LOGIC_VECTOR (2*N-1 downto 0) := (others => '0'); 
signal regm       : STD_LOGIC_VECTOR (  N-1 downto 0) := (others => '0');
signal load       : STD_LOGIC                        ;
signal shift      : STD_LOGIC                        ;
signal sub        : STD_LOGIC                        ;
signal dosub      : STD_LOGIC                        ;
signal subtractor : STD_LOGIC_VECTOR (  N   downto 0) := (others => '0');
signal counter    : INTEGER range 0 to N := 0        ;
signal en_cnt     : STD_LOGIC                        ;
signal cntnm1     : STD_LOGIC                        ;

type STATE_TYPE is (S0, S1, S2, S3);
signal current_state : STATE_TYPE := S0              ;
signal next_state    : STATE_TYPE                    ;

begin

quotient   <= regp(N-1 downto 0);
remainder  <= regp(2*N-1 downto N);
subtractor <= regp(2*N-1 downto N-1) - ("0" & regm);
dosub <= not subtractor(N);

process (clk) -- regm
begin
     if rising_edge(clk) then
          if load = '1' then
          regm <= divisor;
          end if;
     end if;   
end process;     

process (clk) -- regp
begin
     if rising_edge(clk) then
          if load = '1' then
               regp <= dividend;
          elsif shift = '1' then
               if (regp(2*N-1) = '1') then
                    link_out <= '1';
               else
                    link_out <= '0';
               end if;
               regp <= regp(2*N-2 downto 0) & '0';
          elsif sub = '1' then
               regp <= subtractor(n-1 downto 0) & regp(N-2 downto 0) & '1';
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

process (dosub, start, cntnm1, current_state) -- Next state logic
begin
     load     <= '0';  -- default
     sub      <= '0';
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
               if (dosub = '1') then
                    sub <= '1';
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

