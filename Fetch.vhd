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
	IR	: out unsigned(DATA_WIDTH-1 downto 0);
	PC_out	: out unsigned(DATA_WIDTH-1 downto 0);
	-- memory access
	IR_pc	: out unsigned(DATA_WIDTH-1 downto 0);
	IR_re	: out std_logic := '1';
	IR_data	: in std_logic_vector(DATA_WIDTH-1 downto 0);
	IR_busy : in STD_LOGIC := '0'
	);

end entity;

architecture disc of INSTRUCTION_FETCH is

-- signals
signal PC : unsigned(DATA_WIDTH-1 downto 0);

begin

IR <= unsigned(IR_data);

PC_update : process(IR_busy, clk)
begin
	-- read next instruction unless reset
	IR_re <= '1';
	if (reset = '1') then
		PC <= to_unsigned(0, DATA_WIDTH);
		IR_re <= '0';
	elsif rising_edge(IR_busy) then
		case branch_taken is
			when '0' => PC <= PC + 4;
			when '1' => PC <= branch_pc;
			when others => report "unreachable" severity failure;
		end case;
		IR_pc <= PC;
		PC_out <= PC;
	end if;
end process;

end disc;
