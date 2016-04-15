-- Entity: FETCH
-- Author: Stephen Carter, Jit Kanetkar, Auguste Lalande
-- Date: 03/30/2016
-- Description: Access Instructions to Run based off PC

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity INSTRUCTION_FETCH is

generic ( DATA_WIDTH : integer := 32
	);
port(	clk	: in std_logic;
	reset	: in std_logic;
	branch_taken	: in std_logic;
	branch_pc	: in unsigned(DATA_WIDTH-1 downto 0);
	IR	: out unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);
	PC_out	: out unsigned(DATA_WIDTH-1 downto 0);
	-- memory access
	IR_pc	: out unsigned(DATA_WIDTH-1 downto 0);
	IR_re	: out std_logic := '1';
	reset_memory_controller : out std_logic;
	IR_data	: in std_logic_vector(DATA_WIDTH-1 downto 0);
	IR_busy : in std_logic := '0';
	ID_busy : in std_logic
	);

end entity;

architecture disc of INSTRUCTION_FETCH is

component INSTRUCTION_CACHE is
generic ( DATA_WIDTH : integer := 32
	);
	
port (	clk 	: in STD_LOGIC;
      	reset 	: in STD_LOGIC;
	PC	: in unsigned(DATA_WIDTH-1 downto 0);
	PC_up	: in unsigned(DATA_WIDTH-1 downto 0);
	data_up	: in unsigned(DATA_WIDTH-1 downto 0);
	update  : in std_logic;
	data	: out unsigned(DATA_WIDTH-1 downto 0);
	mem 	: out STD_LOGIC;
	mem_addr: out unsigned(DATA_WIDTH-1 downto 0);
	data_ready : out std_logic
  );

end component;

component HAZARD_DETECTION is

	generic ( DATA_WIDTH : integer := 32
		);
	port(
		IR_check	: in unsigned(DATA_WIDTH-1 downto 0);
		IR1	: in unsigned(DATA_WIDTH-1 downto 0);
		IR2	: in unsigned(DATA_WIDTH-1 downto 0);
		IR3	: in unsigned(DATA_WIDTH-1 downto 0);
		IR4	: in unsigned(DATA_WIDTH-1 downto 0);
		HAZARD	: out std_logic;
		cycles_to_wait	: out unsigned(2 downto 0)
		);

end component;

type instruction_log is array (integer range <>) of unsigned(DATA_WIDTH-1 downto 0);
signal IR_log :  instruction_log(1 to 4);

signal PC_update : unsigned(DATA_WIDTH-1 downto 0);
signal mem_addr_tmp : unsigned(DATA_WIDTH-1 downto 0);
signal data_tmp : unsigned(DATA_WIDTH-1 downto 0);
signal mem_chk : std_logic;

-- signals
signal PC, PC_old : unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);
signal IR_checked : unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);
signal IR_next : unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);

--hazards
signal hazard : std_logic;
signal cycles_to_wait : unsigned(2 downto 0);
signal hazard_resume_delay : std_logic := '0';

signal cache_data_ready : std_logic;
signal cache_update : std_logic;

begin

cache : INSTRUCTION_CACHE	
port map(clk 	=> clk,
      	reset 	=> reset,
	PC	=> PC,
	PC_up	=> PC_update,
	data_up	=> unsigned(IR_data),
	update  => cache_update,
	data	=> data_tmp,
	mem 	=> mem_chk,
	mem_addr => mem_addr_tmp,
	data_ready => cache_data_ready
 );

PC_update <= PC - 4;

-- Detect Hazards
hazard_detect : HAZARD_DETECTION
	port map (
		IR_check => unsigned(IR_data),
		IR1 => IR_log(1),
		IR2 => IR_log(2),
		IR3 => IR_log(3),
		IR4 => IR_log(4),
		HAZARD => hazard,
		cycles_to_wait => cycles_to_wait
	);

-- Update IR Based off hazards
IR_update : process(clk)
begin
	if falling_edge(clk) then --check for hazards
		cache_update <= '0';
		reset_memory_controller <= '0';

		-- stall if a hazard is present
		if hazard = '1' then
			IR_checked <= to_unsigned(0, DATA_WIDTH);
		---- stall if Memory Stage is accessing Memory
		--elsif ID_busy = '1' then
		--	IR_checked <= to_unsigned(0, DATA_WIDTH);
		-- delay hazards to avoid issuing same instruction twice
		elsif hazard_resume_delay = '1' then
			IR_checked <= to_unsigned(0, DATA_WIDTH);
		-- stall if no new instruction has been fetched
		elsif cache_data_ready = '1' then
			IR <= data_tmp;
			IR_checked <= data_tmp;
			PC_old <= PC;
			reset_memory_controller <= '1';
		elsif PC_old = PC then
			IR_checked <= to_unsigned(0, DATA_WIDTH);
		-- otherwise, forward the IR
--		elsif mem_chk = '0' then
--			IR_checked <= data_tmp;
--			PC_old <= PC;
		else
			cache_update <= '1';
			IR_checked <= unsigned(IR_data);
			PC_old <= PC;
		end if;
	elsif rising_edge(clk) then --pass new instruction
		IR <= IR_checked;
		PC_out <= PC - 4;
	end if;
end process;

-- Update Hazard Counters
IR_track : process(clk)
begin
	-- Update IR_log as follows
	-- IR_log(1)` = IR_checked
	-- IR_log(i+1)` = IR_log(i)
	if rising_edge(clk) then
		IR_log(4) <= IR_log(3);
		IR_log(3) <= IR_log(2);
		IR_log(2) <= IR_log(1);
		IR_log(1) <= IR_checked;
	end if;
end process;

-- update the program counter when a new instruction is issued
PC_update_process : process(reset, IR_busy, clk, hazard, branch_taken)
begin
	-- reset to instruction 1
	if reset = '1' then
		PC <= to_unsigned(0, DATA_WIDTH);
	-- don't update if branching
	elsif (branch_taken = '1') then
		PC <= branch_pc - 4;
		IR_pc <= branch_pc - 4;
	-- run next instruction
--	elsif data_tmp /= to_unsigned(integer(3), DATA_WIDTH) then
--		IR_pc <= PC + 4;
--		PC <= PC + 4;
--	elsif falling_edge(mem_chk) then
--		IR_pc <= PC + 4;
--		PC <= PC + 4;
	elsif falling_edge(clk) then
		if cache_data_ready = '1' and hazard = '0' then
			IR_pc <= PC + 4;
			PC <= PC + 4;
		end if;
	elsif falling_edge(IR_busy) then
		IR_pc <= PC + 4;
		PC <= PC + 4;
	end if;

	-- unincrement on hazard
	if rising_edge(hazard) then
		IR_pc <= PC - 4;
		PC <= PC - 4;
	-- reincrement on end of hazard
	elsif falling_edge(hazard) then
		IR_pc <= PC + 4;
		PC <= PC + 4;
		hazard_resume_delay <= '1';
	end if;

	-- end hazard delay
	if rising_edge(clk) then
		hazard_resume_delay <= '0';
	end if;
end process;

-- determine whether to read memory
memory_read_update : process(reset, clk, hazard)
begin
	-- disable on reset
	if reset = '1' then
		IR_re <= '0';
	-- disable on hazard
	elsif hazard = '1' then
		IR_re <= '0';
	-- else read on a falling edge
	elsif falling_edge(clk) then
		IR_re <= '1';
	end if ;
end process;

end disc;
