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
		PC_out	: out unsigned(DATA_WIDTH-1 downto 0);
		-- memory access
		IR_pc	: out unsigned(DATA_WIDTH-1 downto 0);
		IR_re	: out std_logic;
		IR_data	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		IR_busy : in STD_LOGIC
		);
end component;

signal IR_pc	: unsigned(DATA_WIDTH-1 downto 0);
signal IR_re	: std_logic;
signal IR_data	: std_logic_vector(DATA_WIDTH-1 downto 0);
signal IR_busy	: std_logic; 

begin 
-- entity declaration
dut: INSTRUCTION_FETCH
port map(clk, branch_taken, branch_pc, IR, PC_out, IR_pc, IR_re, IR_data, IR_busy);

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
--------------------------------------------------------------------------------
-----------------------Increment Program Counter--------------------------------
--------------------------------------------------------------------------------
	REPORT "Incrementing PC";
	wait for 10 * clk_period;		-- run 10 cycles
	ASSERT (PC_out = 40) REPORT "program counter incrementing improperly (1)";
	wait for 1 * clk_period;
	ASSERT (PC_out = 44) REPORT "program counter incrementing improperly (2)";
--------------------------------------------------------------------------------
-----------------------------Taking Branch--------------------------------------
--------------------------------------------------------------------------------
	REPORT "Taking Branch";
	branch_taken <= '1';
	branch_pc <= to_unsigned(8880, 32);	-- branch to 8880
	wait for 1 * clk_period;
	ASSERT (PC_out = 8880) REPORT "branch not taken (1)";
	branch_taken <= '0';
--------------------------------------------------------------------------------
-------------------------Increment After Branch---------------------------------
--------------------------------------------------------------------------------
	REPORT "Continuing After Branch";
	wait for 10 * clk_period;		-- run 10 cycles
	ASSERT (PC_out = 8920) REPORT "program counter incrementing improperly (3)";
--------------------------------------------------------------------------------
-----------------------------Taking Branch--------------------------------------
--------------------------------------------------------------------------------
	REPORT "Taking Another Branch";
	branch_taken <= '1';
	branch_pc <= to_unsigned(192, 32);	-- branch to 8880
	wait for 1 * clk_period;
	ASSERT (PC_out = 192) REPORT "branch not taken (1)";
	branch_taken <= '0';
--------------------------------------------------------------------------------
-------------------------Increment After Branch---------------------------------
--------------------------------------------------------------------------------
	REPORT "Continuing After Another Branch";
	wait for 10 * clk_period;		-- run 10 cycles
	ASSERT (PC_out = 232) REPORT "program counter incrementing improperly (3)";
--------------------------------------------------------------------------------
----------------------------------END-------------------------------------------
--------------------------------------------------------------------------------
	wait;
end process;

end;