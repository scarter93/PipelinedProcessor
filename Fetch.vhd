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
	IR_busy : in STD_LOGIC := '0'
	);

end entity;

architecture disc of INSTRUCTION_FETCH is

type instruction_log is array (1 to 4) of unsigned(DATA_WIDTH-1 downto 0);
signal IR_log :  instruction_log;

-- signals
signal PC : unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);
signal IR_check : unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, DATA_WIDTH);

begin

IR_update : process(clk)
begin
	if falling_edge(clk) then --check for hazards

	elsif rising_edge(clk) then --pass new instruction
		IR <= unsigned(IR_data);
		PC_out <= PC - 8;
	end if;
end process;

IR_track : process(clk)
begin
	if rising_edge(clk)
		IR_log(4) <= IR_log(3);
		IR_log(3) <= IR_log(2);
		IR_log(2) <= IR_log(1);
		IR_log(1) <= IR_check;
	end if;
end process;

PC_update : process(IR_busy, clk)
begin
	-- read next instruction unless reset
	IR_re <= '1';
	if (reset = '1') then
		PC <= to_unsigned(0, DATA_WIDTH);
		IR_re <= '0';
	elsif falling_edge(IR_busy) then
		IR_pc <= PC + 4;
		case branch_taken is
			when '0' => PC <= PC + 4;
			when '1' => PC <= branch_pc;
			when others => report "unreachable" severity failure;
		end case;
	end if;
end process;

end disc;
