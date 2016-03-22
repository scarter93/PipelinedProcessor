library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WRITE_BACK is

generic ( DATA_WIDTH : integer := 32
	);
port(   clk     : in std_logic;
	memory	: in unsigned(DATA_WIDTH-1 downto 0);
	alu_result	: in unsigned(DATA_WIDTH-1 downto 0);
	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
	WB	: out unsigned(DATA_WIDTH-1 downto 0)
	);

end entity;

architecture disc of WRITE_BACK is

constant LW     : unsigned(5 downto 0) := "010100";
constant LB     : unsigned(5 downto 0) := "010101";

signal current_opcode : unsigned(5 downto 0);

begin

current_opcode <= IR_in(31 downto 26);

process(clk)
begin
    if rising_edge(clk) then
        IR_out <= IR_in;
        if current_opcode = LW or current_opcode = LB then
            WB <= memory;
        else
            WB <= alu_result;
        end if;
    end if;
end process;

end disc;
