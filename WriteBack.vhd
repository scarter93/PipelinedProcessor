library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WRITE_BACK is

generic ( DATA_WIDTH : integer := 32
	);
port(	memory	: in unsigned(DATA_WIDTH-1 downto 0);
	alu_result	: in unsigned(DATA_WIDTH-1 downto 0);
	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
	WB	: out unsigned(DATA_WIDTH-1 downto 0);
	);

end entity;

architecture disc of WRITE_BACK is
begin
end disc;
