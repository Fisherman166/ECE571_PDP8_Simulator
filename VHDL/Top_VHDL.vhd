-- Top Level for PDP8 Project
-- Jonathan Waldrip

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_VHDL is 
     Port(
      clk      : in  STD_LOGIC                     ;  -- On Board 10 MHz Clock 
      led      : out STD_LOGIC_VECTOR (15 downto 0);  -- LED's
      an       : out STD_LOGIC_VECTOR ( 7 downto 0);  -- 7 Segment anodes
      seg      : out STD_LOGIC_VECTOR ( 6 downto 0);  -- 7 Segment cathodes
      dp       : out STD_LOGIC                     ;  -- decimal point cathode
      sw       : in  STD_LOGIC_VECTOR (12 downto 0);  -- 13 switches
      btnc     : in  STD_LOGIC                     ;  -- Center button
      btnu     : in  STD_LOGIC                     ;  -- Up button
      btnd     : in  STD_LOGIC                     ;  -- Down button
      btnl     : in  STD_LOGIC                     ;  -- Left button
      btnr     : in  STD_LOGIC                        -- Right button
         );      
end Top_VHDL;
 
architecture Behavioral of Top_VHDL is

---------------------------
----- Declare Modules -----
---------------------------

component front_panel is
    port( 
     clk      : in   STD_LOGIC;
     -- Connection to pins on Nexsys Board
	led      : out  STD_LOGIC_VECTOR (15 downto 0) := (others=>'0');
     an       : out  STD_LOGIC_VECTOR ( 7 downto 0);
     seg      : out  STD_LOGIC_VECTOR ( 6 downto 0);
     dp       : out  STD_LOGIC;
     sw       : in   STD_LOGIC_VECTOR (12 downto 0);
     btnc     : in   STD_LOGIC;
     btnu     : in   STD_LOGIC;
     btnd     : in   STD_LOGIC;
     btnl     : in   STD_LOGIC;
     btnr     : in   STD_LOGIC;
     
     -- Front Panel to CPU
     swreg    : out  STD_LOGIC_VECTOR (11 downto 0);
     dispsel  : out  STD_LOGIC_VECTOR ( 1 downto 0);
     run      : out  STD_LOGIC;
     loadpc   : out  STD_LOGIC;
     loadac   : out  STD_LOGIC;
     step     : out  STD_LOGIC;
     deposit  : out  STD_LOGIC;
     dispout  : in   STD_LOGIC_VECTOR (11 downto 0);
     
     -- CPU to Front Panel 
     linkout  : in   STD_LOGIC;
     halt     : in   STD_LOGIC;
     CPU_idle : in   STD_LOGIC
     );
end component;

component CPU is 
    port(
     clk         : in    STD_LOGIC ; 
     -- Front Panel to CPU
     swreg       : in    STD_LOGIC_VECTOR(11 downto 0); -- Switch register
     dispsel     : in    STD_LOGIC_VECTOR( 1 downto 0); -- Select data to be supplied on dispo 0-PC, 1-MQ, 2-Memory, 3-AC   
     run         : in    STD_LOGIC;                     -- 0 - stop execution 1 - run program 
     loadpc      : in    STD_LOGIC;                     -- Load PC from switch register if CPU stopped
     loadac      : in    STD_LOGIC;                     -- Load AC from switch register if CPU stopped
     step        : in    STD_LOGIC;                     -- Execute an instruction if CPU stopped
     deposit     : in    STD_LOGIC;                     -- Store switch register into memory specified by PC,increment the PC
                                                          
     -- CPU to Front Panel                              
     dispout     : inout STD_LOGIC_VECTOR(11 downto 0); -- data to 7-segment display      
     linkout     : out   STD_LOGIC;                     -- link to 7-segment display
     halt        : out   STD_LOGIC;                     -- halt instruction
     CPU_idle    : out   STD_LOGIC;      
                 
     -- IOT_Distributor to CPU
     skip_flag   : in    STD_LOGIC;                     -- skip next instruction
     clearacc    : in    STD_LOGIC;                     -- clear AC in clock period 2 if bit 1 of IR set.   
     datain      : in    STD_LOGIC_VECTOR(7 downto 0);  -- data to OR into AC in clock period 3
                 
     -- CPU to IOT_Distributor
     bit1_cp2    : out   STD_LOGIC;                     -- bit 1 of IR set and clock period 2
     bit2_cp3    : out   STD_LOGIC;                     -- bit 2 of IR set and clock period 3
     io_address  : out   STD_LOGIC_VECTOR(2 downto 0);  -- IO address (bits 5 to 3 of instruction
     dataout_IOT : inout STD_LOGIC_VECTOR(7 downto 0);  -- lower 8 bits of AC

     -- RAM to CPU:
     read_data   : in    STD_LOGIC_VECTOR(11 downto 0); -- data read from RAM
     mem_finished: in    STD_LOGIC;                     -- High for 1 clock cycle when memory cycle is finished.                    

     -- CPU to RAM:
     address     : inout STD_LOGIC_VECTOR(11 downto 0); -- memory address
     write_data  : inout STD_LOGIC_VECTOR(11 downto 0); -- data to write
     write_enable: out   STD_LOGIC;                     -- 1 - write write_data to address on next active clock edge.
     read_enable : out   STD_LOGIC                      -- 1 - start read of RAM at address on next active clock edge 
     );      
end component;

component Memory is
    port( 
     clk          : in  STD_LOGIC;
     address      : in  STD_LOGIC_VECTOR(11 downto 0);
     write_data   : in  STD_LOGIC_VECTOR(11 downto 0);
     write_enable : in  STD_LOGIC;
     read_enable  : in  STD_LOGIC;
     read_data    : out STD_LOGIC_VECTOR(11 downto 0);
     mem_finished : out STD_LOGIC
     );
end component;




---------------------------
----- Declare Signals -----
---------------------------

-- Signals to Connect CPU
 -- Front Panel to CPU
 signal swreg       : STD_LOGIC_VECTOR(11 downto 0);
 signal dispsel     : STD_LOGIC_VECTOR( 1 downto 0);
 signal run         : STD_LOGIC;                    
 signal loadpc      : STD_LOGIC;                    
 signal loadac      : STD_LOGIC;                    
 signal step        : STD_LOGIC;                    
 signal deposit     : STD_LOGIC;                    
                                                    
 -- CPU to Front Panel                             
 signal dispout     : STD_LOGIC_VECTOR(11 downto 0); 
 signal linkout     : STD_LOGIC; 
 signal halt        : STD_LOGIC;  
 signal CPU_idle    : STD_LOGIC;  
            
 -- IOT_Distributor to CPU
 signal skip_flag   : STD_LOGIC;                    
 signal clearacc    : STD_LOGIC;                    
 signal datain      : STD_LOGIC_VECTOR(7 downto 0); 
           
 -- CPU to IOT_Distributor
 signal bit1_cp2    : STD_LOGIC;                    
 signal bit2_cp3    : STD_LOGIC;                    
 signal io_address  : STD_LOGIC_VECTOR(2 downto 0); 
 signal dataout_IOT : STD_LOGIC_VECTOR(7 downto 0); 

 -- RAM to CPU:
 signal read_data   : STD_LOGIC_VECTOR(11 downto 0);
 signal mem_finished: STD_LOGIC;                    

 -- CPU to RAM:
 signal address     : STD_LOGIC_VECTOR(11 downto 0);
 signal write_data  : STD_LOGIC_VECTOR(11 downto 0);
 signal write_enable: STD_LOGIC;                    
 signal read_enable : STD_LOGIC;                     

-- Signals to connect UART to IOT
signal clear_3      : STD_LOGIC;      
signal load_3       : STD_LOGIC;      
--signal dataout_3  : STD_LOGIC_VECTOR (7 downto 0);
signal ready_3      : STD_LOGIC;   
signal clearacc_3   : STD_LOGIC;
signal datain_3     : STD_LOGIC_VECTOR (7 downto 0); 
signal clear_4      : STD_LOGIC;         
signal load_4       : STD_LOGIC;      
signal dataout_4    : STD_LOGIC_VECTOR (7 downto 0);
signal ready_4      : STD_LOGIC;   
signal clearacc_4   : STD_LOGIC;
signal datain_4     : STD_LOGIC_VECTOR (7 downto 0); 

begin

-------------------------------
----- Instantiate Modules -----
-------------------------------
    
FP: front_panel
     port map(
      clk       =>  clk             ,
      -- Connection to pins on Nexsys Board
	 led       =>  led             ,
      an        =>  an              ,
      seg       =>  seg             ,
      dp        =>  dp              ,
      sw        =>  sw              ,
      btnc      =>  btnc            ,
      btnu      =>  btnu            ,
      btnd      =>  btnd            ,
      btnl      =>  btnl            ,
      btnr      =>  btnr            ,
           
      -- Front Panel to CPU
      swreg     =>  swreg           ,  
      dispsel   =>  dispsel         ,
      run       =>  run             ,
      loadpc    =>  loadpc          ,
      loadac    =>  loadac          ,
      step      =>  step            ,
      deposit   =>  deposit         ,
      dispout   =>  dispout         ,
      
      -- CPU to Front Panel 
      linkout   =>  linkout         ,
      halt      =>  halt            ,
      CPU_idle  =>  CPU_idle    
      );
  
CPU0: CPU
     port map(
      clk          =>  clk          ,  
      
      -- Front Panel to CPU
      swreg        =>  swreg        ,   
      dispsel      =>  dispsel      ,
      run          =>  run          ,
      loadpc       =>  loadpc       ,
      loadac       =>  loadac       ,
      step         =>  step         ,
      deposit      =>  deposit      ,
                                   
      -- CPU to Front Panel        
      dispout      =>  dispout      ,    
      linkout      =>  linkout      ,
      halt         =>  halt         ,
      CPU_idle     =>  CPU_idle     ,
                  
      -- IOT_Distributor to CPU
      skip_flag    =>  skip_flag    ,  
      clearacc     =>  clearacc     ,
      datain       =>  datain       ,
                  
      -- CPU to IOT_Distributor
      bit1_cp2     =>  bit1_cp2     ,  
      bit2_cp3     =>  bit2_cp3     ,
      io_address   =>  io_address   ,
      dataout_IOT  =>  dataout_IOT  ,
      
      -- RAM to CPU:
      read_data    =>  read_data    ,  
      mem_finished =>  mem_finished ,
      
      -- CPU to RAM:
      address      =>  address      ,     
      write_data   =>  write_data   , 
      write_enable =>  write_enable , 
      read_enable  =>  read_enable 
     );     

MEM: Memory
     port map(
      clk          =>  clk          ,         
      address      =>  address      ,
      write_data   =>  write_data   ,
      write_enable =>  write_enable ,
      read_enable  =>  read_enable  ,
      read_data    =>  read_data    ,
      mem_finished =>  mem_finished
     );
 
  

end Behavioral;
