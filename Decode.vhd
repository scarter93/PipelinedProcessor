library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity INSTRUCTION_DECODE is

generic ( DATA_WIDTH : integer := 32
	);
port( 	clk	: in std_logic;
	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
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

type REGISTERS is array (0 to 31) of unsigned(DATA_WIDTH-1 downto 0);
signal reg :  REGISTERS;
signal addr1, addr2, addr3 : unsigned(4 downto 0);

begin

process (clk)
begin
	if rising_edge(clk) then
        addr1 <= IR_in(25 downto 21);
		addr2 <= IR_in(20 downto 16);
        addr3 <= WB_IR(15 downto 11);
        op1 <= reg(to_integer(addr1));
		op2 <= reg(to_integer(addr2));
		IMM <= "1111111111111111" & IR_in(15 downto 0);
		reg(to_integer(addr3)) <= MEM;
		reg(0) <= (others => '0'); --ensure $R0 is always 0
	end if;
end process;

process (clk)
begin
	if rising_edge(clk) then
		IR_out <= IR_in;
		PC_out <= PC_in;
	end if;
end process;

end disc;