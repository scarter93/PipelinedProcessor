library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity INSTRUCTION_FETCH is

generic ( DATA_WIDTH : integer := 32
	);
port(	branch_taken	: in std_logic;
	branch_pc	: in unsigned(DATA_WIDTH-1 downto 0);
	IR	: out unsigned(DATA_WIDTH-1 downto 0);
	PC	: out unsigned(DATA_WIDTH-1 downto 0)
	);

end entity;

architecture disc of INSTRUCTION_FETCH is
begin
end disc;
