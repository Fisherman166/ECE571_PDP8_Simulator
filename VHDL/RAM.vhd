
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY RAM IS
  PORT (
    clk : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0) := (others =>'0');
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0) := (others =>'0');
    dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0) := (others =>'0');
    douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0) := (others =>'0')
  );
END RAM;

ARCHITECTURE RAM_a OF RAM IS

type mem_array2_t is array (0 to 4095) of std_logic_vector(11 DOWNTO 0);
signal RAM_IMAGE : mem_array2_t := (others => o"0000");
signal add_int: INTEGER range 0 to 4095 := 0;


BEGIN

add_int <= to_integer(unsigned(addra));

process (clk) begin
     if (rising_edge(clk)) then
          douta <= RAM_IMAGE(add_int);
          if (wea = "1") then
               RAM_IMAGE(add_int) <= dina;     
          end if;

     end if;
     
     
end process;




END RAM_a;
