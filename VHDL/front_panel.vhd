----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:23:32 04/10/2015 
-- Design Name: 
-- Module Name:    front_panel - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL; -- added use statements
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity front_panel is
    Port ( clk : in  STD_LOGIC;
		     led : out  STD_LOGIC_VECTOR (15 downto 0) := (others=>'0');
           an : out  STD_LOGIC_VECTOR (7 downto 0) := (others=>'0');
           seg : out  STD_LOGIC_VECTOR (6 downto 0) := (others=>'0');
			  dp : out  STD_LOGIC := '0';
           sw : in  STD_LOGIC_VECTOR (12 downto 0) := (others=>'0');
			  btnc : in  STD_LOGIC := '0';
           btnu : in  STD_LOGIC := '0';
           btnd : in  STD_LOGIC := '0';
           btnl : in  STD_LOGIC := '0';
           btnr : in  STD_LOGIC := '0';
           swreg : out  STD_LOGIC_VECTOR (11 downto 0) := (others=>'0');
           dispsel : out  STD_LOGIC_VECTOR (1 downto 0) := (others=>'0');
           run : out  STD_LOGIC := '0';
           loadpc : out  STD_LOGIC := '0';
           loadac : out  STD_LOGIC := '0';
           step : out  STD_LOGIC := '0';
           deposit : out  STD_LOGIC := '0';
           dispout : in  STD_LOGIC_VECTOR (11 downto 0) := (others=>'0');
           linkout : in  STD_LOGIC := '0';
           halt : in  STD_LOGIC := '0' ;
           CPU_idle : in STD_LOGIC := '0');
end front_panel;

architecture Behavioral of front_panel is

signal digit_mux_counter : std_logic_vector(20 downto 0) := (others=>'0');
signal digit_mux : std_logic_vector(2 downto 0) := (others=>'0');
signal digit_drive : std_logic_vector(2 downto 0) := (others=>'0');
signal m1counter : integer range 0 to 9 := 0;  --999999
signal count0, disp_d, running : std_logic := '0';

type DEB_STATE is (b0, b1, b2, b3);
type POW_STATE is (p0, p1, p2, p3, p4);
type DISP_STATE is (d0, d1, d2, d3);
signal cur_state_disp : DISP_STATE := d0;
signal next_state_disp : DISP_STATE;
signal cur_state_deb : DEB_STATE := b0;
signal next_state_deb : DEB_STATE;
signal cur_state_pow : POW_STATE := p0;
signal next_state_pow : POW_STATE;

begin

swreg <= sw (11 downto 0);
dp <= not(linkout) when digit_mux = "011" else '1';
count0 <= '1' when m1counter = 0 else '0';
led (13) <= CPU_idle;
led (12) <= running;
run <= running;
led (15 downto 14) <= (others=>'0'); -- turn off unused leds
led (11 downto 4) <= (others=>'0'); -- turn off unused leds

process (clk) -- divide by 1,000,000 counter
begin
	if rising_edge(clk) then
		if m1counter = 2 then   --2 for sims
			m1counter <= 0;
		else
			m1counter <= m1counter + 1;
		end if;
	end if;
end process;


-- 7 Segment output description
	-- /2tothe20th counter
	process (clk) begin
		if rising_edge(clk) then
			digit_mux_counter <= digit_mux_counter + '1';
		end if;
	end process;

	digit_mux <= digit_mux_counter(20 downto 18);

	-- 1 of 8 decoder
	an(7 downto 0)  <=  "11111110" when digit_mux = "000" 
						else "11111101" when digit_mux = "001"
						else "11111011" when digit_mux = "010"
						else "11110111" when digit_mux = "011"
						else "11101111" when digit_mux = "100"
						else "11011111" when digit_mux = "101"
						else "10111111" when digit_mux = "110"
						else "01111111"; -- The remaining posibility

	-- 12 to 4 multiplexer + unused digits
	digit_drive <= dispout (2 downto 0) when digit_mux = "000"
			else dispout (5 downto 3) when digit_mux = "001"
			else dispout (8 downto 6) when digit_mux = "010"
			else dispout (11 downto 9) when digit_mux = "011"
			else "000";-- the remaining posibility - '0'

	-- digit to cathode mappping function
	process (digit_drive) begin
		case digit_drive is
			when "000" => seg <= "1000000";
			when "001" => seg <= "1111001";
			when "010" => seg <= "0100100";
			when "011" => seg <= "0110000";
			when "100" => seg <= "0011001";
			when "101" => seg <= "0010010";
			when "110" => seg <= "0000010";
			when "111" => seg <= "1111000";
			when others => seg <= "0000000";
		end case;
	end process;

process (clk) -- State Register
begin
	if rising_edge(clk) then
		cur_state_disp <= next_state_disp;
		cur_state_deb <= next_state_deb;
		cur_state_pow <= next_state_pow;
	end if;
end process;

--Display selection state machine
process (cur_state_disp, disp_d)
begin
	dispsel <= "01";
	led (3 downto 0) <= "0000";
	next_state_disp <= cur_state_disp;
	case cur_state_disp is
		when d0 =>  dispsel <= "00";
						led (3 downto 0) <= "0001";
						if disp_d = '1' then
							next_state_disp <= d1;
						end if;
		when d1 =>  dispsel <= "01";
						led (3 downto 0) <= "0010";
						if disp_d = '1' then
							next_state_disp <= d2;
						end if;
		when d2 =>  dispsel <= "10";
						led (3 downto 0) <= "0100";
						if disp_d = '1' then
							next_state_disp <= d3;
						end if;
		when d3 =>  dispsel <= "11";
						led (3 downto 0) <= "1000";
						if disp_d = '1' then
							next_state_disp <= d0;
						end if;
		when others => next_state_disp <= d0; --just to make vhdl happy
	end case;
end process;

--Oneshot state machine
process (cur_state_deb, count0, btnl, btnr, btnu, btnd, btnc)
begin
	loadac <= '0'; -- assign default values to logic
	loadpc <= '0';
	step <= '0';
	deposit <= '0';
	disp_d <= '0';
	next_state_deb <= cur_state_deb;
	case cur_state_deb is
		when b0 =>  if btnl = '1' or btnr = '1' or btnu = '1' or btnd = '1' or btnc = '1' then
							next_state_deb <= b1;
						end if;
		when b1 =>  if count0 = '1' then
							next_state_deb <= b2;
						end if;
		when b2 =>  loadpc <= btnl;
						loadac <= btnr;
						step <= btnu;
						deposit <= btnd;
						disp_d <= btnc;
						next_state_deb <= b3;
		when b3 =>  if btnl = '0' and btnr = '0' and btnu = '0' and btnd = '0' and btnc = '0' then
							next_state_deb <= b0;
						end if;
		when others => next_state_deb <= b0; --just to make vhdl happy
	end case;
end process;

----Power switch and light state machine
process (cur_state_pow, count0, sw, halt)
begin
	running <= '1';
	next_state_pow <= cur_state_pow;
	case cur_state_pow is
		when p0 =>          running <= '0';
						if sw (12) = '1' then
							next_state_pow <= p1;
						end if;
                              
		when p1 =>          if count0 = '1' then
							next_state_pow <= p2;
						end if;	
                              
		when p2 =>          if sw (12) = '0' then
                                   next_state_pow <= p3;
						elsif halt = '1' then
							running <= '0';
                                   next_state_pow <= p4;
						end if;
                              
		when p3 =>          if count0 = '1' then
							next_state_pow <= p0;
						end if;
                              
		when p4 =>          running <= '0';    
                              if sw (12) = '0' then
                                   next_state_pow <= p0;
						end if;                           
		when others => next_state_pow <= p0; --just to make vhdl happy	
	end case;
end process;

end Behavioral;