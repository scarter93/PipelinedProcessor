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
	IR_data	: in std_logic_vector(DATA_WIDTH-1 downto 0);
	IR_busy : in std_logic := '0';
	ID_busy : in std_logic
	);

end entity;

architecture disc of INSTRUCTION_FETCH is

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

-- signals
signal PC : unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);
signal IR_check : unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);

--hazards
signal hazard : std_logic;
signal cycles_to_wait : unsigned(2 downto 0);

begin

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

IR_update : process(clk)
begin
	if falling_edge(clk) then --check for hazards
		if hazard = '1' then
			IR_check <= to_unsigned(0, DATA_WIDTH);
		elsif ID_busy = '1' then
			IR_check <= to_unsigned(0, DATA_WIDTH);
		else
			IR_check <= unsigned(IR_data);
		end if;
	elsif rising_edge(clk) then --pass new instruction
		IR <= IR_check;
		PC_out <= PC - 4;
	end if;
end process;

IR_track : process(clk)
begin
	if rising_edge(clk) then
		IR_log(4) <= IR_log(3);
		IR_log(3) <= IR_log(2);
		IR_log(2) <= IR_log(1);
		IR_log(1) <= IR_check;
	end if;
end process;

PC_update : process(reset, IR_busy, clk, hazard, branch_taken)
begin
	if reset = '1' then
		PC <= to_unsigned(0, DATA_WIDTH);
	elsif (branch_taken = '1') then
		PC <= branch_pc;
		IR_pc <= branch_pc;
	elsif falling_edge(IR_busy) then
		IR_pc <= PC + 4;
		PC <= PC + 4;
	end if;

	if rising_edge(hazard) then
		IR_pc <= PC - 4;
		PC <= PC - 4;
	elsif falling_edge(hazard) then
		IR_pc <= PC + 4;
		PC <= PC + 4;
	end if;
end process;

memory_read_update : process(reset, clk, hazard)
begin
	if reset = '1' then
		IR_re <= '0';
	elsif hazard = '1' then
		IR_re <= '0';
	elsif falling_edge(clk) then
		IR_re <= '1';
	end if ;
end process;

end disc;
