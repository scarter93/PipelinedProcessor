library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEMORY is

generic ( DATA_WIDTH : integer := 32
	);
port(	branch_taken	: in std_logic;
	alu_result_in	: in unsigned(DATA_WIDTH-1 downto 0);
	op2_in	: in unsigned(DATA_WIDTH-1 downto 0);
	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
	memory	: out unsigned(DATA_WIDTH-1 downto 0);
	alu_result_out	: out unsigned(DATA_WIDTH-1 downto 0);
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0)
	);

end entity;

architecture disc of MEMORY is
begin
end disc;