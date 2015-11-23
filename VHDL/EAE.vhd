-- EAE for PDP8 Project
-- Jonathan Waldrip

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EAE is 
     Port(clk       : in  STD_LOGIC                     ;
          eae_start : in  STD_LOGIC                     ;
          ac_reg    : in  STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
          mq_reg    : in  STD_LOGIC_VECTOR (11 downto 0) := (others => '0');          
          temp_reg  : in  STD_LOGIC_VECTOR (11 downto 0) := (others => '0'); 
          mq_mul    : out STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
          ac_mul    : out STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
          mq_dvi    : out STD_LOGIC_VECTOR (11 downto 0) := (others => '0');          
          ac_dvi    : out STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
          link_dvi  : out STD_LOGIC;
          eae_fin   : out STD_LOGIC
         );      
end EAE;

architecture Behavioral of EAE is

component multiply is
     Generic (N : integer := 12);  
     Port    (clk          : in  STD_LOGIC                        ;
              multiplier   : in  STD_LOGIC_VECTOR (  N-1 downto 0);
              multiplicand : in  STD_LOGIC_VECTOR (  N-1 downto 0);          
              start        : in  STD_LOGIC                        ;          
              product      : out STD_LOGIC_VECTOR (2*N-1 downto 0); 
              finished     : out STD_LOGIC                        
             );     
end component;

component divide is
     Generic (N : integer := 12);  
     Port    (clk          : in  STD_LOGIC;
              dividend     : in  STD_LOGIC_VECTOR (2*N-1 downto 0);
              divisor      : in  STD_LOGIC_VECTOR (  N-1 downto 0);          
              start        : in  STD_LOGIC                      ;          
              quotient     : out STD_LOGIC_VECTOR (  N-1 downto 0); 
              remainder    : out STD_LOGIC_VECTOR (  N-1 downto 0);
              link_out     : out STD_LOGIC;
              finished     : out STD_LOGIC                        
             ); 
end component;

signal start    : STD_LOGIC;
signal finished : STD_LOGIC;
signal fin_div  : STD_LOGIC;
signal product  : STD_LOGIC_VECTOR (23 downto 0);
signal dividend : STD_LOGIC_VECTOR (23 downto 0);
signal quotient : STD_LOGIC_VECTOR (11 downto 0);
signal remainder: STD_LOGIC_VECTOR (11 downto 0);                       

begin


eae_fin <= finished;
start <= eae_start;
dividend <= ac_reg & mq_reg;

MUL0: multiply
	generic map (
		N      => 12
		)	
	port map(
		clk          => clk          ,             
		multiplier   => mq_reg       ,
		multiplicand => temp_reg     ,             
		start        => start        ,
          product      => product      ,
          finished     => finished
	);
     
DVI0: divide
     generic map (
          N      => 12
          ) 
     port map(
          clk          => clk          ,
          dividend     => dividend     ,
          divisor      => temp_reg     ,
          start        => start        ,
          quotient     => quotient     ,
          remainder    => remainder    ,
          link_out     => link_dvi     ,
          finished     => fin_div
             );      
    
process (clk) begin
     if rising_edge(clk) then
          if (finished = '1') then
               ac_mul <= product (23 downto 12);
               mq_mul <= product (11 downto 0 );
          end if;
          if (fin_div = '1') then
               ac_dvi <= remainder;
               mq_dvi <= quotient ;
          end if;
     end if;
end process;    
    
end Behavioral;

