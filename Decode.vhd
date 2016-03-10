library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity INSTRUCTION_DECODE is

generic ( DATA_WIDTH : integer := 32
	);
port( 	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
	PC_in	: in unsigned(DATA_WIDTH-1 downto 0);
	MEM	: in unsigned(DATA_WIDTH-1 downto 0);	-- location to write back
	WB_IR	: in unsigned(DATA_WIDTH-1 downto 0);	-- data to write back
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
	PC_out	: out unsigned(DATA_WIDTH-1 downto 0);
	IMM	: out unsigned(DATA_WIDTH-1 downto 0);	-- immiediate operand
	op1	: out unsigned(DATA_WIDTH-1 downto 0);
	op2	: out unsigned(DATA_WIDTH-1 downto 0)
	);

end entity;

architecture disc of INSTRUCTION_DECODE is
begin
end disc;