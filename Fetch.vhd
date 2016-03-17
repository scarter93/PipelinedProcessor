library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity INSTRUCTION_FETCH is

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

end entity;

architecture disc of INSTRUCTION_FETCH is

-- signals
signal PC : unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(0, 32);

begin

PC_out <= PC;
IR_pc <= PC;

-- determine next value of PC
update_pc : process (clk)
begin
	if (rising_edge(clk)) then
		case branch_taken is
			when '0' => PC <= PC + 4;
			when '1' => PC <= branch_pc;
			when others => report "unreachable" severity failure;
		end case;
	end if;
end process;

-- get instruction
--update_pc : process (clk)
--begin
--	if (falling_edge(IR_re)) then
--		case branch_taken is
--			when '0' => PC <= PC + 4;
--			when '1' => PC <= branch_pc;
--			when others => report "unreachable" severity failure;
--		end case;
--	end if;
--end process;

end disc;
