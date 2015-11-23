-------------------------------------------------------------------------------
-- Module Name: Adder12
-- Original Code by Allan Douglas
-- Edited by Jonathan Waldrip
-------------------------------------------------------------------------------
library ieee;
library work;
library modelsim_lib;


use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.math_real.all;  
use ieee.numeric_std.all;

entity Adder12 is
   port(
     In_1            : in  std_logic_vector(11 downto 0) := (others => '0');       -- 12-bit value #1
     In_2            : in  std_logic_vector(11 downto 0) := (others => '0');       -- 12-Bit value #2 to be added or subtracted from Input #1
     Carry_In        : in  std_logic := '0';                           -- Carry in to link this module to others
     Sum             : out std_logic_vector(11 downto 0) := (others => '0');       -- 8-Bit output result of addition or subtraction
     Carry_Out       : out std_logic := '0'                            -- Carry out
   );
end Adder12;

-------------------------------------------------------------------------------
architecture behavioral of Adder12 is
-------------------------------------------------------------------------------

-- Component declaration
component Adder                                   -- Single bit full adder module
   port(
     X          : in  std_logic;
     Y          : in  std_logic;
     Cin        : in  std_logic;
     S          : out std_logic;
     Cout       : out std_logic
   );
end component;


-- declare signals
signal C         : std_logic_vector(11 downto 1) := (others => '0');  -- bit carry between modules
signal TempSum   : std_logic_vector(11 downto 0) := (others => '0'); 
signal TempCarry : std_logic := '0';


begin

Sum <= TempSum;
Carry_Out <= TempCarry;

-- Instantiate full adders to perform bitwise addition for 12 bits

FA0 : Adder port map(
    X    =>         In_1(0),
    Y    =>         In_2(0),
    Cin  =>        Carry_In,
    S    =>      TempSum(0),
    Cout =>            C(1)
    );

FA1 : Adder port map(
    X    =>         In_1(1),
    Y    =>         In_2(1),
    Cin  =>            C(1),
    S    =>      TempSum(1),
    Cout =>            C(2)
    );

FA2 : Adder port map(
    X    =>         In_1(2),
    Y    =>         In_2(2),
    Cin  =>            C(2),
    S    =>      TempSum(2),
    Cout =>            C(3)
    );

FA3 : Adder port map(
    X    =>         In_1(3),
    Y    =>         In_2(3),
    Cin  =>            C(3),
    S    =>      TempSum(3),
    Cout =>            C(4)
    );

FA4 : Adder port map(
    X    =>         In_1(4),
    Y    =>         In_2(4),
    Cin  =>            C(4),
    S    =>      TempSum(4),
    Cout =>            C(5)
    );

FA5 : Adder port map(
    X    =>         In_1(5),
    Y    =>         In_2(5),
    Cin  =>            C(5),
    S    =>      TempSum(5),
    Cout =>            C(6)
    );

FA6 : Adder port map(
    X    =>         In_1(6),
    Y    =>         In_2(6),
    Cin  =>            C(6),
    S    =>      TempSum(6),
    Cout =>            C(7)
    );

FA7 : Adder port map(
    X    =>         In_1(7),
    Y    =>         In_2(7),
    Cin  =>            C(7),
    S    =>      TempSum(7),
    Cout =>            C(8)
    );
    
FA8 : Adder port map(
    X    =>         In_1(8),
    Y    =>         In_2(8),
    Cin  =>            C(8),
    S    =>      TempSum(8),
    Cout =>            C(9)
    );

FA9 : Adder port map(
    X    =>         In_1(9),
    Y    =>         In_2(9),
    Cin  =>            C(9),
    S    =>      TempSum(9),
    Cout =>           C(10)
    );        
    
FA10 : Adder port map(
    X    =>         In_1(10),
    Y    =>         In_2(10),
    Cin  =>            C(10),
    S    =>      TempSum(10),
    Cout =>            C(11)
    );   

FA11 : Adder port map(
    X    =>         In_1(11),
    Y    =>         In_2(11),
    Cin  =>            C(11),
    S    =>      TempSum(11),
    Cout =>       TempCarry
    );       
        
end behavioral;