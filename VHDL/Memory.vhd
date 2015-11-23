
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Memory is
    Port (clk                 : in STD_LOGIC := '0';
          address             : in  STD_LOGIC_VECTOR (11 downto 0) := (others =>'0');
          write_data          : in  STD_LOGIC_VECTOR (11 downto 0) := (others =>'0');
          write_enable        : in  STD_LOGIC := '0';
          read_enable         : in  STD_LOGIC := '0';
          read_data           : out STD_LOGIC_VECTOR (11 downto 0) := (others =>'0');
          mem_finished        : out STD_LOGIC := '0' 
          );          
		end Memory; 

architecture Behavioral of Memory is

signal count_enable           : STD_LOGIC := '0';
signal counter                : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others =>'0');
signal ROM_address            : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others =>'0');

signal ROM_Dout               : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others =>'0');
signal end_of_memory          : STD_LOGIC := '0';
signal address_internal       : STD_LOGIC_VECTOR(11 downto 0) := (others =>'0');
signal write_data_internal    : STD_LOGIC_VECTOR(11 downto 0) := (others =>'0');

type STATE_TYPE is (S_Init_Start, S_Init_Write, S_Init_Stop, S_Init_Inc, S_Init_End,
                    S_Idle, 
                    S_Wr_Start, S_Write,
                    S_Read_Reg, S_Read);

signal current_state    : STATE_TYPE;
signal next_state       : STATE_TYPE := S_Init_Start;
signal RAM_Write_Data   : STD_LOGIC_VECTOR (11 downto 0);
signal RAM_Write_Enable : STD_LOGIC_VECTOR( 0 downto 0);
signal wait_count       : INTEGER range 0 to 20 := 0; 
signal wait_enable      : STD_LOGIC := '0';
signal wait_done        : STD_LOGIC := '0';
signal register_read    : STD_LOGIC := '0'; 
signal register_write   : STD_LOGIC := '0';
signal en_write_bus     : STD_LOGIC := '0';
signal RAM_Address      : STD_LOGIC_VECTOR (11 downto 0) := (others =>'0');

COMPONENT ROM
  PORT (
    clk   : IN  STD_LOGIC;
    addra : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
END COMPONENT;

COMPONENT RAM
  PORT (
    clk   : IN  STD_LOGIC;
    wea   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
    dina  : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
END COMPONENT;

BEGIN

-- Register In Data and Address from CPU if read or write requested
process (clk) begin
	if rising_edge(clk) then
		if register_write = '1' then
			address_internal <= address;
			write_data_internal <= write_data;
		elsif register_read = '1' then
			address_internal <= address;
		end if;
	end if;
end process;

		
ROM0 : ROM
  PORT MAP (																												
    clk => clk,
    addra => ROM_address,
    douta => ROM_Dout
  );
  
RAM0 : RAM
  PORT MAP (																												
    clk   => clk,
    wea   => RAM_Write_Enable,
    addra => RAM_Address,
    dina  => RAM_Write_Data,
    douta => read_data 
    );
    
  
process (clk) begin -- counter to cycle through addresses in memory
		if rising_edge (clk) then
			if count_enable = '1' then
				counter <= counter + 1;
		end if;
			end if;
end process;


process (clk) begin --state register
		if rising_edge (clk) then
			current_state <= next_state;
		end if;
end process;

-- end of mem test used to know when Initialization is done
end_of_memory <= '1' when counter = o"7777" else '0';

-- control timing
process (clk) begin
     if rising_edge (clk) then
          if   ( wait_enable = '1' and wait_count /= 2) then
                 wait_count <= wait_count + 1;
                 wait_done  <= '0';
                 
          elsif( wait_enable = '1' and wait_count >= 2) then
                 wait_count <=  0;
                 wait_done  <= '1';
                 
          else   wait_count <=  0;
                 wait_done  <= '0';
          end if;
     end if;
end process;

ROM_address <= counter;

process (address_internal, current_state, end_of_memory, counter, read_enable, write_enable, wait_done)
begin -- defaults if not assigned in state
		count_enable        <= '0';
		next_state          <= current_state;
		RAM_Address         <= address_internal;
          RAM_Write_Data      <= write_data_internal;
          RAM_Write_Enable    <= "0";
		mem_finished        <= '0'; 
          wait_enable         <= '0';
          register_read       <= '0';          
          register_write      <= '0';          
          en_write_bus        <= '0';
          
	case current_state is 
          
          ---------------Init RAM with ROM Data----------------------
     
		when S_Init_Start =>     
					RAM_Address <= counter;   
                         RAM_Write_Data <= ROM_Dout;
                         next_state <= S_Init_Write;
                         
		when S_Init_Write =>
					RAM_Address <= counter;   
                         RAM_Write_Data <= ROM_Dout;
                         RAM_Write_Enable <= "1";   
                         wait_enable <= '1';
                         if (wait_done = '1') then
                              next_state <= S_Init_Stop;
                         end if;
									
		when S_Init_Stop =>
					RAM_Address <= counter;   
                         RAM_Write_Data <= ROM_Dout;
                         next_state <= S_Init_Inc;

		when S_Init_Inc =>
					RAM_Address <= counter;   
                         RAM_Write_Data <= ROM_Dout;
					count_enable <= '1';
					next_state <= S_Init_End;
					
		when S_Init_End =>
					RAM_Address <= counter;   
                         RAM_Write_Data <= ROM_Dout;
					if end_of_memory = '0' then 
						next_state <= S_Init_Start;
					else next_state <= S_Idle;
					end if;

		--------------IDLE STATE-----------------------
          
		when S_Idle => if write_enable = '1' then
						next_state <= S_Wr_Start;
					elsif read_enable = '1' then
						next_state <= S_Read_Reg;
					end if;
					
		--------------WRITE CYCLE-----------------------
          
		when S_Wr_Start =>
                         register_write <= '1';
                         next_state <= S_Write;
          
		when S_Write => 
					RAM_Write_Enable <= "1"; 
                         wait_enable <= '1';
                         if (wait_done = '1') then
                              mem_finished <= '1';
                              next_state <= S_Idle;
                         end if;
                        
		--------------READ CYCLE-----------------------
                    
		when S_Read_Reg =>    
                         register_read <= '1';
					next_state <= S_Read;
					     
		when S_Read => wait_enable <= '1';
					if (wait_done = '1') then
                              mem_finished <= '1';
                              next_state <= S_Idle;
                         end if;  
                         
          when others => next_state <= S_Idle;
                         
		end case;
end process;
										
end Behavioral;

