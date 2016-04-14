-- Direct mapped cache testbench
-- Author: Stephen Carter

library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_tb is
end cache_tb;

architecture testbench of cache_tb is

component cache is
generic ( DATA_WIDTH : integer := 32
	);
	
port (	clk 	: in STD_LOGIC;
      	reset 	: in STD_LOGIC;
	PC	: in unsigned(DATA_WIDTH-1 downto 0);
	PC_up	: in unsigned(DATA_WIDTH-1 downto 0);
	data_up	: in unsigned(DATA_WIDTH-1 downto 0);
	data	: out unsigned(DATA_WIDTH-1 downto 0);
	mem 	: out STD_LOGIC;
	mem_addr: out unsigned(DATA_WIDTH-1 downto 0)
  );

end component;
constant DATA_WIDTH : integer := 32;
constant blk_sz : integer := 32;
constant offset_sz : integer := 0;
constant tag_sz : integer := 22;
constant index_sz : integer := 10;
constant num_blks : integer := 1024;

constant cache_blk_sz : integer := tag_sz+blk_sz+offset_sz;

constant zero : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');

constant clk_period : time := 1 ns;

signal clk_t : std_logic;
signal reset_t : std_logic;

signal	PC_t		: unsigned(DATA_WIDTH-1 downto 0);
signal	PC_up_t		: unsigned(DATA_WIDTH-1 downto 0);
signal	data_up_t	: unsigned(DATA_WIDTH-1 downto 0);
signal	data_t		: unsigned(DATA_WIDTH-1 downto 0);
signal	mem_t	 	: STD_LOGIC;
signal	mem_addr_t	: unsigned(DATA_WIDTH-1 downto 0);

begin

dut : cache port map(	clk 	=> clk_t,
      			reset	=> reset_t,
			PC	=> PC_t,
			PC_up	=> PC_up_t,
			data_up	=> data_up_t,
			data	=> data_t,
			mem 	=> mem_t,
			mem_addr=> mem_addr_t
			);

clk_process : process
begin
	clk_t <= '1';
	wait for clk_period/2;
	clk_t <= '0';
	wait for clk_period/2;
end process;

test : process
begin

reset_t <= '0';

REPORT "trying to read empty cache (location 0) and update other location (6) in cache";
PC_t <= "00000000000000000000000000000000";
PC_up_t <= "00000000000000000000000000000110";
data_up_t <= "11111111111111111111111111111111";
wait for 1.1*clk_period;
--ASSERT(data_t = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ")report "Data_t should be all 'Z'";
ASSERT(mem_t = '1') report "Failed to detect invalid cache block";
ASSERT(mem_addr_t = PC_t) report "Failed to update memory address";

REPORT "trying to read instr cache (location 6) updating previous bad data from last location (1)";
PC_t <= "00000000000000000000000000000110";
PC_up_t <= mem_addr_t;
data_up_t <= "00011111111111111111111111111111"; --"11111111111111111111111111111111";
wait for 1.1*clk_period;
ASSERT(data_t = "11111111111111111111111111111111")report "Data_t should be all '1'";
ASSERT(mem_t = '0') report "cache block should be valid";
--ASSERT(mem_addr_t = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ") report "Failed to update memory address";

REPORT "trying to read and update same block";
PC_t <= "00000000000000000000000000000110";
PC_up_t <= "00000000000000000000000000000110";
data_up_t <= "11111111111111111111111111110000";
wait for 1.1*clk_period;
ASSERT(data_t = "11111111111111111111111111110000")report "Data_t should be all 'Z'";
ASSERT(mem_t = '0') report "Failed to detect invalid cache block";
--ASSERT(mem_addr_t = PC_t) report "Failed to update memory address";

wait;

end process;



end architecture;