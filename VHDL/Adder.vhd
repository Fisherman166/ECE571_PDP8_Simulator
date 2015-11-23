-------------------------------------------------------------------------------
-- Module Name: Adder
-- by Jonathan Waldrip
-- This a 1-bit adder with carry in and carry out bits
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Adder is
   port(
     X          : in  std_logic;            -- 1st Input to add
     Y          : in  std_logic;            -- 2nd Input to add
     Cin        : in  std_logic := '0';     -- Carry In
     S          : out std_logic;            -- Sum output
     Cout       : out std_logic             -- Carrry Out
   );
end Adder;

-------------------------------------------------------------------------------
architecture behavioral of Adder is
-------------------------------------------------------------------------------

begin

    S   <= X xor Y xor Cin;     -- 0+0+0=0, 0+0+1=1, 1+1+0=0+Carry, 1+1+1=1+Carry
    
    Cout <= (X and Y) or ((X xor Y)and Cin);

end behavioral;