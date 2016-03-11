library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch_pc_tb is
end fetch_pc_tb;

architecture test of fetch_pc_tb is

-- constants
constant clk_period : time := 1 ns;
constant DATA_WIDTH : integer := 32;
-- signal declaration
signal clk		: std_logic := '0';
signal branch_taken	: std_logic := '0';
signal branch_pc	: unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, 32);
signal IR		: unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, 32);
signal PC_out		: unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, 32);

component INSTRUCTION_FETCH is
	generic ( DATA_WIDTH : integer := 32
		);
	port(	clk	: in std_logic;
		branch_taken	: in std_logic;
		branch_pc	: in unsigned(DATA_WIDTH-1 downto 0);
		IR	: out unsigned(DATA_WIDTH-1 downto 0);
		PC_out	: out unsigned(DATA_WIDTH-1 downto 0)
		);
end component;

begin 
-- entity declaration
dut: INSTRUCTION_FETCH
port map(clk, branch_taken, branch_pc, IR, PC_out);

-- clock process
clk_process : process
begin
	clk <= '0';
	wait for clk_period/2;
	clk <= '1';
	wait for clk_period/2;
end process;

-- test process
tb_process : process
begin
	REPORT "let the program counter increment 10 times (to 40)";
	for i in 0 to 9 loop
		wait for 1 * clk_period;
	end loop;
	ASSERT (PC_out = 40) REPORT "program counter not incrementing";
end process;

end;