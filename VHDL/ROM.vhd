
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ROM IS
  PORT (
    clk : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
END ROM;

ARCHITECTURE ROM_a OF ROM IS

type mem_array_t is array (0 to 4095) of std_logic_vector(11 DOWNTO 0);
signal ROM_IMAGE : mem_array_t := (others => o"0000");
signal add_int: INTEGER range 0 to 4095 := 0;

BEGIN

add_int <= to_integer(unsigned(addra));

process (clk) begin
     if (rising_edge(clk)) then
          douta <= ROM_IMAGE(add_int);
     end if;
     
end process;

END ROM_a;
