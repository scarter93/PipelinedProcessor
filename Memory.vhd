library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEMORY is

generic ( DATA_WIDTH : integer := 32
	);
port(	clk	: in std_logic;
	branch_taken	: in std_logic;
	alu_result_in	: in unsigned(DATA_WIDTH-1 downto 0);
	op2_in	: in unsigned(DATA_WIDTH-1 downto 0);
	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
	memory	: out unsigned(DATA_WIDTH-1 downto 0);
	branch_taken_out : out std_logic := '0';
	alu_result_out	: out unsigned(DATA_WIDTH-1 downto 0);
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
	-- memory access
	ID_addr	: out NATURAL := 0;
	ID_data	: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	ID_re	: out STD_LOGIC;
	ID_we	: out STD_LOGIC;
	ID_busy	: in STD_LOGIC
	);

end entity;

architecture disc of MEMORY is
begin

update_values : process(clk)
begin
	if (rising_edge(clk)) then
		if (ID_busy = '0') then
			ID_re <= '0';
		else
			ID_re <= '1' after 10 ns;
			ID_addr <= 0;
		end if;
	end if;
end process;

end disc;