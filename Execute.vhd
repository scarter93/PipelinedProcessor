library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EXECUTE is

generic ( DATA_WIDTH : integer := 32
	);
port(	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
	PC_in	: in unsigned(DATA_WIDTH-1 downto 0);
	IMM_in	: in unsigned(DATA_WIDTH-1 downto 0);
	op1	: in unsigned(DATA_WIDTH-1 downto 0);
	op2	: in unsigned(DATA_WIDTH-1 downto 0);
	branch_taken	: out std_logic;
	alu_result	: out unsigned(DATA_WIDTH-1 downto 0);
	op2_out	: out unsigned(DATA_WIDTH-1 downto 0);
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0)
	);

end entity;

architecture disc of EXECUTE is
begin
end disc;
