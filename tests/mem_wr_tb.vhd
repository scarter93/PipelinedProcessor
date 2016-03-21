library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_arbiter_lib.all;

entity mem_wr_tb is
end mem_wr_tb;

architecture test of mem_wr_tb is
-- CONSTANTS
constant clk_period : time := 1 ns;

-- MEMORY
signal clk : std_logic;
signal reset : std_logic;
signal branch_taken : std_logic;
signal alu_result	: unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);
signal op2	: unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);
signal IR	: unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);
signal data_memory	: unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);
signal branch_taken_out : std_logic;
signal alu_result_out	: unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);
signal IR_out	: unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);

-- MEMORY ARBITER
-- conversions
signal IR_addr_nat, ID_addr_nat : natural; 
-- Memory Port #1
signal IR_addr	: unsigned(DATA_WIDTH-1 downto 0);
signal IR_data	: std_logic_vector(DATA_WIDTH-1 downto 0);
signal IR_re	: std_logic := '0';
signal IR_we	: std_logic := '0';
signal IR_busy	: std_logic;

-- Memory Port #2
signal ID_addr	: natural;
signal mem_data	: std_logic_vector(DATA_WIDTH-1 downto 0);
signal ID_re	: std_logic;
signal ID_we	: std_logic;
signal ID_busy	: std_logic;

signal ID_data	: std_logic_vector(DATA_WIDTH-1 downto 0);

component MEMORY is

	generic ( DATA_WIDTH : integer := 32
		);
	port(	clk	: in std_logic;
		branch_taken	: in std_logic;
		alu_result_in	: in unsigned(DATA_WIDTH-1 downto 0);
		op2_in	: in unsigned(DATA_WIDTH-1 downto 0);
		IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
		memory	: out unsigned(DATA_WIDTH-1 downto 0);
		branch_taken_out : out std_logic;
		alu_result_out	: out unsigned(DATA_WIDTH-1 downto 0);
		IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
		ID_addr	: out NATURAL;
		ID_data	: out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
		ID_re	: out STD_LOGIC;
		ID_we	: out STD_LOGIC;
		ID_busy	: in STD_LOGIC
		);

end component;

component memory_arbiter is

	port(
		clk	: in std_logic;
		reset	: in std_logic;
	      
		--Memory port #1
		addr1	: in natural;
		data1	: inout std_logic_vector(DATA_WIDTH-1 downto 0);
		re1	: in std_logic;
		we1	: in std_logic;
		busy1 : out std_logic;
	
		--Memory port #2
		addr2	: in natural;
		data2	: inout std_logic_vector(DATA_WIDTH-1 downto 0);
		re2	: in std_logic;
		we2	: in std_logic;
		busy2	: out std_logic

	  );

end component;

begin 
	dut : MEMORY
		port map (
			clk => clk,
			branch_taken => branch_taken,
			alu_result_in => alu_result,
			op2_in => op2,
			IR_in => IR,
			memory => data_memory,
			branch_taken_out => branch_taken_out,
			alu_result_out => alu_result_out,
			IR_out => IR_out,
			ID_addr => ID_addr,
			ID_data => mem_data,
			ID_re => ID_re,
			ID_we => ID_we,
			ID_busy => ID_busy
		);

	memory_arbiter_t : memory_arbiter
		port map (
			clk => clk,
			reset => reset,
			--Memory port #1
			addr1 => ID_addr,
			data1 => ID_data,
			re1 => ID_re,
			we1 => ID_we,
			busy1 => ID_busy,
			--Memory port #2
			addr2 => IR_addr_nat,
			data2 => IR_data,
			re2 => IR_re,
			we2 => IR_we,
			busy2 => IR_busy
		);

with ID_we select ID_data  <= 
	mem_data when '1',
	(others => 'Z') when others;

-- clock process
clk_process : process
begin
	clk <= '1';
	wait for clk_period/2;
	clk <= '0';
	wait for clk_period/2;
end process;

tb_process : process
begin
------------------------------------------------------------------------
-----------------------Read from Memory---------------------------------
------------------------------------------------------------------------
	REPORT "READING FROM 0x00000000";
	alu_result <= x"00000000";
	IR <= "01010000000000000000000000000000";
	
	while (ID_busy = '0') loop
		wait for 1 * clk_period;
	end loop;
	while (ID_busy = '1') loop
		wait for 1 * clk_period;
	end loop;

	ASSERT (ID_data = x"DEADBEEF") REPORT "Read Improperly: ";
------------------------------------------------------------------------
--------------------------Read More-------------------------------------
------------------------------------------------------------------------
	REPORT "READING FROM 0x00000010";
	alu_result <= x"00000010";
	IR <= "01010000000000000000000000000000";
		
	while (ID_busy = '0') loop
		wait for 1 * clk_period;
	end loop;
	while (ID_busy = '1') loop
		wait for 1 * clk_period;
	end loop;

	ASSERT (ID_data = x"00000010") REPORT "Read 0x00000010 Improperly";
	REPORT "READING FROM 0x000000FF";
	alu_result <= x"00000100";
	IR <= "01010000000000000000000000000000";
		
	while (ID_busy = '0') loop
		wait for 1 * clk_period;
	end loop;
	while (ID_busy = '1') loop
		wait for 1 * clk_period;
	end loop;

	ASSERT (ID_data = x"00000100") REPORT "Read 0x00000100 Improperly: ";
	REPORT "READING FROM 0x000000F4";
	alu_result <= x"000000F4";
	IR <= "01010000000000000000000000000000";
		
	while (ID_busy = '0') loop
		wait for 1 * clk_period;
	end loop;
	while (ID_busy = '1') loop
		wait for 1 * clk_period;
	end loop;

	ASSERT (ID_data = x"000000F4") REPORT "Read Improperly: ";

------------------------------------------------------------------------
------------------------Write to Memory---------------------------------
------------------------------------------------------------------------
	REPORT "WRITING TO 0x00000000";
	alu_result <= x"00000000";
	op2 <= x"8BADF00D";
	--op2 <= x"00000000";
	IR <= "01011000000000000000000000000000";
	
	while (ID_busy = '0') loop
		wait for 1 * clk_period;
	end loop;
	while (ID_busy = '1') loop
		wait for 1 * clk_period;
	end loop;
------------------------------------------------------------------------
---------------------------Read Back------------------------------------
------------------------------------------------------------------------
	REPORT "Reading back 0x00000000";
	alu_result <= x"00000000";
	IR <= "01010000000000000000000000000000";
	while (ID_busy = '0') loop
		wait for 1 * clk_period;
	end loop;
	while (ID_busy = '1') loop
		wait for 1 * clk_period;
	end loop;
------------------------------------------------------------------------
-----------------------------Done---------------------------------------
------------------------------------------------------------------------
	wait;

end process;

end;