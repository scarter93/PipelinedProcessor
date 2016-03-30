-- Entity: MEMORY
-- Author: Stephen Carter, Jit Kanetkar, Auguste Lalande
-- Date: 03/30/2016
-- Description: Controls access to port 1 of the Memory Arbiter

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
	rw_word	: out std_logic;
	branch_taken_out : out std_logic := '0';
	alu_result_out	: out unsigned(DATA_WIDTH-1 downto 0);
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
	-- memory access
	ID_addr	: out NATURAL := 0;
	ID_data	: inout STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	ID_re	: out STD_LOGIC;
	ID_we	: out STD_LOGIC;
	ID_busy	: in STD_LOGIC
	);

end entity;

architecture disc of MEMORY is

-- opcodes of LOAD and STORE instructions
constant LOAD_WORD : unsigned(5 downto 0) := "010100";
constant LOAD_BYTE : unsigned(5 downto 0) := "010101";

constant STORE_WORD : unsigned(5 downto 0) := "010110";
constant STORE_BYTE : unsigned(5 downto 0) := "010111";

-- input operation
-- hardwired to top 6 bits or IR
signal operation : unsigned(5 downto 0);

-- stages for memory arbiter
-- hardwired to ID_re and IR_we
signal reading, writing : std_logic := '0';


begin

-- hardwire operation, reading, and writing
operation <= IR_in(DATA_WIDTH-1 downto DATA_WIDTH-6);
ID_re <= reading;
ID_we <= writing;

-- determine if reading a word or byte
with operation select rw_word <=
	'1' when LOAD_WORD,
	'1' when STORE_WORD,
	'0' when LOAD_BYTE,
	'0' when STORE_BYTE,
	'1' when others;

-- set outputs on rising clock edge
clocked : process(clk)
begin
	if (rising_edge(clk)) then
		IR_out <= IR_in;
		alu_result_out <= alu_result_in;
		branch_taken_out <= branch_taken;
	end if;
end process;

-- setup data to memory arbiter according to documentation
-- Write Word:	Word to Write
-- Write Byte;	24 `Z` and Byte to Write
-- Read Any:	All `Z`
process(writing, reading)
begin
	if (writing = '1' and operation = STORE_WORD) then
		ID_data <= std_logic_vector(op2_in);
	elsif (writing = '1' and operation = STORE_BYTE) then
		ID_data <= "ZZZZZZZZZZZZZZZZZZZZZZZZ" & std_logic_vector(op2_in(7 downto 0));
	else
               ID_data <= (others=>'Z');
       end if;
end process;

-- set reading and writing signals as ID busy changed
-- unclocked inorder to ensure that Memory Access overrides Fetch
update_values : process(clk, ID_busy, writing, reading, operation)
begin
	if ((ID_busy = '0' and reading = '1')) then
		reading <= '0';
	elsif ((ID_busy = '0' and writing = '1')) then
		writing <= '0';
	elsif (operation = LOAD_WORD or operation = LOAD_BYTE) then
		reading <= '1';
		writing <= '0';
		ID_addr <= to_integer(alu_result_in);
	elsif (operation = STORE_WORD or operation = STORE_BYTE) then
		reading <= '0';
		writing <= '1';
		ID_addr <= to_integer(alu_result_in);
	end if;

	if (falling_edge(ID_busy)) then
		reading <= '0';
		writing <= '0';
	end if;
end process;

-- setup update output once done reading
update_tmp_data : process(ID_busy)
begin
	if (falling_edge(ID_busy)) then
		memory <= unsigned(ID_data);
	end if;
end process;


end disc;