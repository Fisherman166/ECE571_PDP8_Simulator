-- CPU for PDP8 Project
-- Jonathan Waldrip

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL; -- for + operator

entity CPU is 
     Port(clk       : in  STD_LOGIC ; 
          -- Front Panel to CPU
          swreg     : in  STD_LOGIC_VECTOR(11 downto 0) := (others => '0');     -- Switch register
          dispsel   : in  STD_LOGIC_VECTOR( 1 downto 0) := (others => '0');     -- Select data to be supplied on dispo 0-PC, 1-MQ, 2-Memory, 3-AC   
          run       : in  STD_LOGIC := '0';                         -- 0 - stop execution 1 - run program 
          loadpc    : in  STD_LOGIC := '0';                         -- Load PC from switch register if CPU stopped
          loadac    : in  STD_LOGIC := '0';                         -- Load AC from switch register if CPU stopped
          step      : in  STD_LOGIC := '0';                         -- Execute an instruction if CPU stopped
          deposit   : in  STD_LOGIC := '0';                         -- Store switch register into memory specified by PC,increment the PC
                                                             
          -- CPU to Front Panel                              
          dispout   : inout STD_LOGIC_VECTOR(11 downto 0) := (others => '0');   -- data to 7-segment display      
          linkout   : out   STD_LOGIC := '0';                       -- link to 7-segment display
          halt      : out   STD_LOGIC := '0';                       -- halt instruction
          CPU_idle  : out   STD_LOGIC := '0';          
                    
          -- IOT_Distributor to CPU
          skip_flag : in  STD_LOGIC := '0';                         -- skip next instruction
          clearacc  : in  STD_LOGIC := '0';                         -- clear AC in clock period 2 if bit 1 of IR set.   
          datain    : in  STD_LOGIC_VECTOR(7 downto 0) := (others => '0');      -- data to OR into AC in clock period 3
          
          -- CPU to IOT_Distributor
          bit1_cp2    : out   STD_LOGIC := '0';                     -- bit 1 of IR set and clock period 2
          bit2_cp3    : out   STD_LOGIC := '0';                     -- bit 2 of IR set and clock period 3
          io_address  : out   STD_LOGIC_VECTOR(2 downto 0) := (others => '0');  -- IO address (bits 5 to 3 of instruction
          dataout_IOT : inout STD_LOGIC_VECTOR(7 downto 0) := (others => '0');  -- lower 8 bits of AC

          -- RAM to CPU:
          read_data   : in  STD_LOGIC_VECTOR(11 downto 0) := (others => '0');   -- data read from RAM
          mem_finished: in  STD_LOGIC := '0';                       -- High for 1 clock cycle when memory cycle is finished.                    

          -- CPU to RAM:
          address     : inout STD_LOGIC_VECTOR(11 downto 0) := (others => '0'); -- memory address
          write_data  : inout STD_LOGIC_VECTOR(11 downto 0) := (others => '0'); -- data to write
          write_enable: out   STD_LOGIC := '0';                     -- 1 - write write_data to address on next active clock edge.
          read_enable : out   STD_LOGIC := '0'                      -- 1 - start read of RAM at address on next active clock edge 
         );      
end CPU;
 
architecture Behavioral of CPU is

---------------------------
----- Declare Modules -----
---------------------------

component State_Machine is
    Port (run                 : in  STD_LOGIC;
          dispsel             : in  STD_LOGIC_VECTOR;
          loadpc              : in  STD_LOGIC;
          loadac              : in  STD_LOGIC;
          step                : in  STD_LOGIC;
          deposit             : in  STD_LOGIC;
          skip_flag           : in  STD_LOGIC;
          clearacc            : in  STD_LOGIC;
          mem_finished        : in  STD_LOGIC;
          clk                 : in  STD_LOGIC;
          i_reg               : in  STD_LOGIC_VECTOR (11 downto 0);
          temp_reg            : in  STD_LOGIC_VECTOR (11 downto 0);	
          ea_reg_8_to_15      : in  STD_LOGIC;
          srchange            : in  STD_LOGIC;
          micro_g1            : in  STD_LOGIC;
          micro_g2            : in  STD_LOGIC;
          micro_g3            : in  STD_LOGIC;
          skip                : in  STD_LOGIC;
          eae_fin             : in  STD_LOGIC;
          halt                : out STD_LOGIC;
          bit1_cp2            : out STD_LOGIC;
          bit2_cp3            : out STD_LOGIC;
          io_address          : out STD_LOGIC_VECTOR (2 downto 0);
          write_enable        : out STD_LOGIC;
          read_enable         : out STD_LOGIC;
          en_ac_sr            : out STD_LOGIC;
          en_ac_and           : out STD_LOGIC;
          en_ac_tad           : out STD_LOGIC;
          en_read_isz         : out STD_LOGIC;
          en_write_pcp1       : out STD_LOGIC;
          en_write_temp       : out STD_LOGIC;
          en_pc_p1            : out STD_LOGIC;
          en_pc_p2            : out STD_LOGIC;
          en_pc_sr            : out STD_LOGIC;
          en_write_ac         : out STD_LOGIC;
          en_ac_clear         : out STD_LOGIC;
          en_add_pcp1         : out STD_LOGIC;
          en_add_pc           : out STD_LOGIC;
          en_add_ea           : out STD_LOGIC;
          en_write_ea         : out STD_LOGIC;
          en_write_dep        : out STD_LOGIC;    
          en_pc_jmp           : out STD_LOGIC;
          en_ac_micro         : out STD_LOGIC;
          en_load_ea_zero     : out STD_LOGIC;
          en_load_ea_current  : out STD_LOGIC;
          en_load_ea_mem      : out STD_LOGIC;
          en_load_ea_memp1    : out STD_LOGIC;
          en_mem_memp1        : out STD_LOGIC;
          en_ir_load          : out STD_LOGIC;
          en_disp_pc          : out STD_LOGIC;
          en_disp_ac          : out STD_LOGIC;
          en_disp_mq          : out STD_LOGIC;
          en_disp_mem         : out STD_LOGIC;
          en_ac_ord_datain    : out STD_LOGIC;
          en_dataout_ac       : out STD_LOGIC;
          en_add_sr           : out STD_LOGIC;
          en_ac_ord_sr        : out STD_LOGIC;
          en_ac_mul           : out STD_LOGIC;
          en_mq_mul           : out STD_LOGIC;
		en_ac_dvi           : out STD_LOGIC;
		en_mq_dvi           : out STD_LOGIC;
		en_ac_mq            : out STD_LOGIC;
		en_mq_ac            : out STD_LOGIC;
		en_ac_ord_mq        : out STD_LOGIC;
		eae_start           : out STD_LOGIC;
          CPU_idle            : out STD_LOGIC
          );
end component;

component EAE is
     Port(clk       : in  STD_LOGIC;
          eae_start : in  STD_LOGIC;                        -- Start Multiply and Divide
          ac_reg    : in  STD_LOGIC_VECTOR (11 downto 0);   -- accumulator register in
          mq_reg    : in  STD_LOGIC_VECTOR (11 downto 0);   -- mq register in          
          temp_reg  : in  STD_LOGIC_VECTOR (11 downto 0);   -- Value from memory in
          mq_mul    : out STD_LOGIC_VECTOR (11 downto 0);   -- Value for MQ after multiply
          ac_mul    : out STD_LOGIC_VECTOR (11 downto 0);   -- Value for AC after multiply
          mq_dvi    : out STD_LOGIC_VECTOR (11 downto 0);   -- Value for MQ after divide       
          ac_dvi    : out STD_LOGIC_VECTOR (11 downto 0);   -- Value for AC after divide 
          link_dvi  : out STD_LOGIC;                        -- Value for link after divide
          eae_fin   : out STD_LOGIC                         -- multiply and divide are finished 
         );     
end component;

component Micro is
     Port(i_reg     : in  STD_LOGIC_VECTOR ( 8 downto 0);  -- instruction register in
          ac_reg    : in  STD_LOGIC_VECTOR (11 downto 0);  -- accumulator register in
          l_reg     : in  STD_LOGIC                     ;  -- link register in
          ac_micro  : out STD_LOGIC_VECTOR (11 downto 0);  -- instruction register out
          l_micro   : out STD_LOGIC                     ;  -- accumulator register out
          skip      : out STD_LOGIC                     ;  -- skip flag to SM for Group 2         
          micro_g1  : out STD_LOGIC                     ;  -- flag to SM, indicates group 1
          micro_g2  : out STD_LOGIC                     ;  -- flag to SM, indicates group 2
          micro_g3  : out STD_LOGIC                        -- flag to SM, indicates group 3                   
         );     
end component;

component Adder12 is
   port(
     In_1            : in  std_logic_vector(11 downto 0);       -- 12-bit value #1
     In_2            : in  std_logic_vector(11 downto 0);       -- 12-Bit value #2 to be added
     Carry_In        : in  std_logic;                           -- Carry in
     Sum             : out std_logic_vector(11 downto 0);       -- 12-Bit output result of addition or subtraction
     Carry_Out       : out std_logic                            -- Carry out
     );
end component;

---------------------------
----- Declare Signals -----
---------------------------

---- Main Registers -----
signal ac_reg              : STD_LOGIC_VECTOR (11 downto 0) := (others => '0'); -- accumulator
signal l_reg               : STD_LOGIC := '0';                                  -- link bit                   
signal i_reg               : STD_LOGIC_VECTOR (11 downto 0) := (others => '0'); -- instruction register
signal mq_reg              : STD_LOGIC_VECTOR (11 downto 0) := (others => '0'); -- mq register 
signal pc_reg              : STD_LOGIC_VECTOR (11 downto 0) := (others => '0'); -- program counter
signal temp_reg            : STD_LOGIC_VECTOR (11 downto 0) := (others => '0'); -- register to store values from memory 
signal ea_reg              : STD_LOGIC_VECTOR (11 downto 0) := (others => '0'); -- effective address register

---- Temp Registers -----
signal ac_reg_new_val      : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
signal l_reg_new_val       : STD_LOGIC := '0';                                 
signal i_reg_new_val       : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
signal mq_reg_new_val      : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
signal pc_reg_new_val      : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
signal temp_reg_new_val    : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
signal ea_reg_new_val      : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
signal write_data_new_val  : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
signal address_new_val     : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
signal dispout_new_val     : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
signal dataout_new_val     : STD_LOGIC_VECTOR ( 7 downto 0) := (others => '0');


----- Signals from CPU to State Machine -----
signal skip                : STD_LOGIC := '0';	
signal ea_reg_8_to_15      : STD_LOGIC := '0';
signal micro_g1            : STD_LOGIC := '0';
signal micro_g2            : STD_LOGIC := '0';
signal micro_g3            : STD_LOGIC := '0';
signal srchange            : STD_LOGIC := '0';
signal eae_fin             : STD_LOGIC := '0';

----- Signals from state machine to CPU ------
-- Control EAE module
signal eae_start           : STD_LOGIC := '0';

-- Control accumulator
signal en_ac_sr            : STD_LOGIC := '0';
signal en_ac_and           : STD_LOGIC := '0';
signal en_ac_tad           : STD_LOGIC := '0';
signal en_ac_clear         : STD_LOGIC := '0';
signal en_ac_micro         : STD_LOGIC := '0';
signal en_ac_ord_sr        : STD_LOGIC := '0';
signal en_ac_ord_mq        : STD_LOGIC := '0';
signal en_ac_mq            : STD_LOGIC := '0';
signal en_ac_mul           : STD_LOGIC := '0';
signal en_ac_dvi           : STD_LOGIC := '0';
signal en_ac_ord_datain    : STD_LOGIC := '0';

-- Control MQ
signal en_mq_mul           : STD_LOGIC := '0';
signal en_mq_dvi           : STD_LOGIC := '0';
signal en_mq_ac            : STD_LOGIC := '0';

-- Control Program Counter
signal en_pc_p1            : STD_LOGIC := '0';
signal en_pc_p2            : STD_LOGIC := '0';
signal en_pc_sr            : STD_LOGIC := '0';
signal en_pc_jmp           : STD_LOGIC := '0';

-- Control instruction register
signal en_ir_load          : STD_LOGIC := '0';
signal en_mem_memp1        : STD_LOGIC := '0';  -- used to increment temp_reg and load to IR 

-- Control temp register
signal en_read_isz         : STD_LOGIC := '0';
signal en_read_isz_temp    : STD_LOGIC := '0';
signal temp_regp1          : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');

-- Control write data to memory
signal en_write_temp       : STD_LOGIC := '0';
signal en_write_ac         : STD_LOGIC := '0';
signal en_write_ea         : STD_LOGIC := '0';
signal en_write_dep        : STD_LOGIC := '0'; 
signal en_write_pcp1       : STD_LOGIC := '0';

-- Control address to memory
signal en_add_pc           : STD_LOGIC := '0';
signal en_add_ea           : STD_LOGIC := '0';
signal en_add_pcp1         : STD_LOGIC := '0';
signal en_add_sr           : STD_LOGIC := '0';

-- Control effective address
signal en_load_ea_current  : STD_LOGIC := '0';
signal en_load_ea_zero     : STD_LOGIC := '0';
signal en_load_ea_mem      : STD_LOGIC := '0';
signal en_load_ea_memp1    : STD_LOGIC := '0';

-- Control display out to front panel
signal en_disp_pc          : STD_LOGIC := '0';
signal en_disp_mq          : STD_LOGIC := '0';
signal en_disp_mem         : STD_LOGIC := '0';
signal en_disp_ac          : STD_LOGIC := '0';


-- Control data out to IOT
signal en_dataout_ac       : STD_LOGIC := '0';


----- Signals for output of EAE Module  ----------
signal mq_mul     : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal ac_mul     : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal mq_dvi     : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal ac_dvi     : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal link_dvi   : STD_LOGIC := '0';

----- Signals for Output of Microcoded Module ----
signal ac_micro   : STD_LOGIC_VECTOR(11 downto 0) := (others => '0'); 
signal l_micro    : STD_LOGIC := '0'                    ;                    

----- Signals for Adder/Carry Out for TAD --------
signal tad_sum    : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal cout       : STD_LOGIC := '0'; 

---Signal for switch register change detection---- 
signal swreg_temp   : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal swreg_change : STD_LOGIC := '0';

begin

-------------------------------
----- Instantiate Modules -----
-------------------------------

SM0: State_Machine
	port map(
          run                 =>  run                ,          
          dispsel             =>  dispsel            ,
          loadpc              =>  loadpc             ,
          loadac              =>  loadac             ,
          step                =>  step               ,
          deposit             =>  deposit            ,
          skip_flag           =>  skip_flag          ,
          clearacc            =>  clearacc           ,
          mem_finished        =>  mem_finished       ,
          clk                 =>  clk                ,
          i_reg               =>  i_reg              ,
          temp_reg            =>  temp_reg           ,
          ea_reg_8_to_15      =>  ea_reg_8_to_15     ,
          srchange            =>  srchange           ,
          micro_g1            =>  micro_g1           ,
          micro_g2            =>  micro_g2           ,
          micro_g3            =>  micro_g3           ,
          skip                =>  skip               ,
          eae_fin             =>  eae_fin            ,
          halt                =>  halt               ,
          bit1_cp2            =>  bit1_cp2           ,
          bit2_cp3            =>  bit2_cp3           ,
          io_address          =>  io_address         ,
          write_enable        =>  write_enable       ,
          read_enable         =>  read_enable        ,
          en_ac_sr            =>  en_ac_sr           ,
          en_ac_and           =>  en_ac_and          ,
          en_ac_tad           =>  en_ac_tad          ,
          en_read_isz         =>  en_read_isz        ,
          en_write_pcp1       =>  en_write_pcp1      ,
          en_write_temp       =>  en_write_temp      ,
          en_pc_p1            =>  en_pc_p1           ,
          en_pc_p2            =>  en_pc_p2           ,
          en_pc_sr            =>  en_pc_sr           ,
          en_write_ac         =>  en_write_ac        ,
          en_ac_clear         =>  en_ac_clear        ,
          en_add_pcp1         =>  en_add_pcp1        ,
          en_add_pc           =>  en_add_pc          ,
          en_add_ea           =>  en_add_ea          ,
          en_write_ea         =>  en_write_ea        ,
          en_write_dep        =>  en_write_dep       ,
          en_pc_jmp           =>  en_pc_jmp          ,
          en_ac_micro         =>  en_ac_micro        ,
          en_load_ea_zero     =>  en_load_ea_zero    ,
          en_load_ea_current  =>  en_load_ea_current ,
          en_load_ea_mem      =>  en_load_ea_mem     ,
          en_load_ea_memp1    =>  en_load_ea_memp1   ,
          en_mem_memp1        =>  en_mem_memp1       ,
          en_ir_load          =>  en_ir_load         ,
          en_disp_pc          =>  en_disp_pc         ,
          en_disp_ac          =>  en_disp_ac         ,
          en_disp_mq          =>  en_disp_mq         ,
          en_disp_mem         =>  en_disp_mem        ,
          en_ac_ord_datain    =>  en_ac_ord_datain   ,
          en_dataout_ac       =>  en_dataout_ac      ,
          en_add_sr           =>  en_add_sr          ,
          en_ac_ord_sr        =>  en_ac_ord_sr       ,
          en_ac_mul           =>  en_ac_mul          ,
          en_mq_mul           =>  en_mq_mul          ,
          en_ac_dvi           =>  en_ac_dvi          ,
          en_mq_dvi           =>  en_mq_dvi          ,
          en_ac_mq            =>  en_ac_mq           ,
          en_mq_ac            =>  en_mq_ac           ,
          en_ac_ord_mq        =>  en_ac_ord_mq       ,
          eae_start           =>  eae_start          ,
          CPU_idle            =>  CPU_idle
          );

EAE0: EAE
	port map(
          clk          =>    clk           ,  
          eae_start    =>    eae_start     ,
          ac_reg       =>    ac_reg        ,
          mq_reg       =>    mq_reg        ,
          temp_reg     =>    temp_reg      ,
          mq_mul       =>    mq_mul        ,
          ac_mul       =>    ac_mul        ,
          mq_dvi       =>    mq_dvi        ,
          ac_dvi       =>    ac_dvi        ,
          link_dvi     =>    link_dvi      ,
          eae_fin      =>    eae_fin        
         );      
    
MIC0: Micro
     port map(
          i_reg     =>   i_reg (8 downto 0)  ,
          ac_reg    =>   ac_reg              ,
          l_reg     =>   l_reg               ,
          ac_micro  =>   ac_micro            ,
          l_micro   =>   l_micro             ,
          skip      =>   skip                ,
          micro_g1  =>   micro_g1            ,
          micro_g2  =>   micro_g2            ,
          micro_g3  =>   micro_g3
     );
    
ADD0: Adder12
     port map(
          In_1        =>  ac_reg    ,       
          In_2        =>  temp_reg  ,
          Carry_In    =>  '0'       ,
          Sum         =>  tad_sum   ,
          Carry_Out   =>  cout 
     );

--------------------------------------------------------------------     
--Signal for SM to know when in auto-incrementing memory locations--
--------------------------------------------------------------------
ea_reg_8_to_15 <= '1' when ea_reg(11 downto 3) = "000000001" else '0';

-------------------------------------------------------
----- Process to detect change in switch register -----
-------------------------------------------------------

process (clk) begin
     if rising_edge(clk) then
          swreg_temp <= swreg;
          if (swreg_change = '1') then
               srchange <= '0';
          else srchange <= '0';     
          end if;
     end if;
end process;

process (swreg, swreg_temp) begin
     if (swreg /= swreg_temp) then
          swreg_change <= '1';
     else swreg_change <= '0';
     end if;
end process;

-------------------------------    
----- MUX's for Registers -----
-------------------------------
    
-- ac_reg (Accumulator)
ac_reg_new_val <= (swreg)            when (en_ac_sr         = '1') -- load switch register
     else (ac_reg and temp_reg     ) when (en_ac_and        = '1') -- AND instruction
     else (tad_sum                 ) when (en_ac_tad        = '1') -- TAD instruction
     else (o"0000"                 ) when (en_ac_clear      = '1') -- Clear
     else (ac_micro                ) when (en_ac_micro      = '1') -- Group 1 Microcoded Instruction
     else (ac_reg or swreg         ) when (en_ac_ord_sr     = '1') -- OR switch register into AC
     else (ac_reg or mq_reg        ) when (en_ac_ord_mq     = '1') -- OR MQ into AC
     else (mq_reg                  ) when (en_ac_mq         = '1') -- Load MQ register (for swap)
     else (ac_mul                  ) when (en_ac_mul        = '1') -- Result from EAE for multiply    
     else (ac_dvi                  ) when (en_ac_dvi        = '1') -- Result from EAE for divide     
     else (ac_reg or x"0" & datain ) when (en_ac_ord_datain = '1') -- OR Data from IOT into AC     
     else (ac_reg                  );                              -- Default, no change

-- Link bit
l_reg_new_val <= (l_reg xor cout) when (en_ac_tad      = '1') -- for TAD, complement L with cout from adder
     else (l_micro              ) when (en_ac_micro    = '1') -- Group 1 Microcoded Instruction
     else ('0'                  ) when (en_ac_mul      = '1') -- Clear for multiply   
     else (link_dvi             ) when (en_ac_dvi      = '1') -- Bit shifted out of divided process inside EAE    
     else (l_reg                );                              -- Default, no change

-- mq_reg (register for multiply and divide operations)
mq_reg_new_val <= (ac_reg     ) when (en_mq_ac         = '1') -- for MQ/AC swap operation
     else (mq_mul             ) when (en_mq_mul        = '1') -- for multiplies
     else (mq_dvi             ) when (en_mq_dvi        = '1') -- for divided     
     else (mq_reg             );                              -- Default, no change     

-- pc_reg (Program Counter)
pc_reg_new_val <= (pc_reg + '1') when (en_pc_p1        = '1') -- Increment by 1
     else (pc_reg + "10"       ) when (en_pc_p2        = '1') -- Increment by 2 (skip)
     else (swreg               ) when (en_pc_sr        = '1') -- Load PC from switch register  
     else (ea_reg              ) when (en_pc_jmp       = '1') -- Load PC with effective address  
     else (pc_reg              );                              -- Default, no change     

-- i_reg (Instruction Register)
i_reg_new_val  <= (read_data  ) when (en_ir_load       = '1') -- Load instruction from memory  
     else (temp_reg + '1'     ) when (en_mem_memp1     = '1') -- used for auto increment
     else (i_reg              );                              -- Default, no change       

-- temp_reg ("hidden" register to store values from memory temporarily)
temp_reg_new_val <= (temp_regp1    ) when (en_read_isz      = '1') -- For ISZ and auto increment EA
     else           (read_data     );                              -- Default to read store from memory      

-- Write data to memory module
write_data_new_val <= (temp_reg) when (en_write_temp   = '1') -- store temp_reg to memory
     else (ac_reg              ) when (en_write_ac     = '1') -- store ac_reg to memory
     else (ea_reg              ) when (en_write_ea     = '1') -- store ea_reg to memory   
     else (pc_reg + '1'        ) when (en_write_pcp1   = '1') -- store program counter + 1 to memory 
     else (swreg               ) when (en_write_dep    = '1') -- for deposit function     
     else (write_data          );                              -- Default, no change     

-- Address to memory module
address_new_val <= (pc_reg    ) when (en_add_pc        = '1') -- use program counter
     else (ea_reg             ) when (en_add_ea        = '1') -- use effective address
     else (pc_reg + '1'       ) when (en_add_pcp1      = '1') -- use program counter plus 1   
     else (swreg              ) when (en_add_sr        = '1') -- use switch register    
     else (address            );                              -- Default, no change       
     
-- ea_reg (Effective Address register)
ea_reg_new_val <= (pc_reg(11 downto 7) & i_reg (6 downto 0)) 
                                         when (en_load_ea_current = '1') -- change page with upper 5 of PC
     else ("00000" & i_reg (6 downto 0)) when (en_load_ea_zero    = '1') -- use simple address
     else (temp_reg                    ) when (en_load_ea_mem     = '1') -- for indirection   
     else (temp_reg + '1'              ) when (en_load_ea_memp1   = '1') -- for auto increment indirection
     else (ea_reg                      );                                -- Default, no change        

-- display out to front panel
dispout_new_val <= (pc_reg    ) when (en_disp_pc      = '1') -- display program counter
     else (mq_reg             ) when (en_disp_mq      = '1') -- dispay mq
     else (temp_reg           ) when (en_disp_mem     = '1') -- display memory   
     else (ac_reg             ) when (en_disp_ac      = '1') -- display accumulator    
     else (dispout            );                             -- default, no change
     
-- data out to IOT
dataout_new_val <= (ac_reg(7 downto 0)) when (en_dataout_ac   = '1') -- send accumultor out to IOT 
     else  (dataout_IOT       );                                     -- default, no change                         

-- synchronize registers     
process (clk) begin
     if rising_edge(clk) then
          ac_reg      <= ac_reg_new_val      ;
          l_reg       <= l_reg_new_val       ;
          i_reg       <= i_reg_new_val       ;
          mq_reg      <= mq_reg_new_val      ;
          pc_reg      <= pc_reg_new_val      ;
          temp_reg    <= temp_reg_new_val    ;
          ea_reg      <= ea_reg_new_val      ;
          write_data  <= write_data_new_val  ;
          address     <= address_new_val     ;
          dispout     <= dispout_new_val     ;
          dataout_IOT <= dataout_new_val     ;
          linkout     <= l_Reg               ;
     end if;
end process;     

-------------------------------------------------------
----- Process to increment for ISZ and Auto Inc EA ----
-------------------------------------------------------

process (clk) begin
     if rising_edge(clk) then
          en_read_isz_temp <= en_read_isz;
          if (en_read_isz_temp /= en_read_isz) and
             (en_read_isz = '1'              ) then
               temp_regp1 <= temp_reg + '1';                    
          else
               temp_regp1 <= temp_reg_new_val;
          end if;               
     end if;
end process;
     
end Behavioral;
