library ieee;
library lpm;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use lpm.lpm_components.all;

entity EXECUTE is

generic ( DATA_WIDTH : integer := 32
	);
port(	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
	PC_in	: in unsigned(DATA_WIDTH-1 downto 0);
	IMM_in	: in unsigned(DATA_WIDTH-1 downto 0);
	op0	: in unsigned(4 downto 0);
	op1	: in unsigned(DATA_WIDTH-1 downto 0);
	op2	: in unsigned(DATA_WIDTH-1 downto 0);
	branch_taken	: out std_logic;
	alu_result	: out unsigned(DATA_WIDTH-1 downto 0);
	op2_out	: out unsigned(DATA_WIDTH-1 downto 0);
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0)
	);

end entity;

architecture disc of EXECUTE is

component alu
generic(DATA_WIDTH : integer := 32
	);
port(	OPCODE	:	in unsigned(3 downto 0);
	DATA0	:	in signed(DATA_WIDTH-1 downto 0);
	DATA1	:	in signed(DATA_WIDTH-1 downto 0);
		
	CLOCK	:	in std_logic;
	RESET	:	in std_logic;

	DATA_OUT :	out signed(DATA_WIDTH-1 downto 0);
	STATUS	:	out unsigned(3 downto 0)
	);
end component;

component LPM_MULT
generic(LPM_WIDTHA : natural; 
        LPM_WIDTHB : natural;
        LPM_WIDTHS : natural := 1;
        LPM_WIDTHP : natural;
	LPM_REPRESENTATION : string := "UNSIGNED";
	LPM_PIPELINE : natural := 0;
	LPM_TYPE: string := L_MULT;
	LPM_HINT : string := "UNUSED"
	);
port( 	DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
	DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
	ACLR : in std_logic := '0';
	CLOCK : in std_logic := '0';
	CLKEN : in std_logic := '1';
	SUM : in std_logic_vector(LPM_WIDTHS-1 downto 0) := (OTHERS => '0');
	RESULT : out std_logic_vector(LPM_WIDTHP-1 downto 0)
	);
end component;


component LPM_DIVIDE
generic(LPM_WIDTHN : natural;
        LPM_WIDTHD : natural;
	LPM_NREPRESENTATION : string := "UNSIGNED";
	LPM_DREPRESENTATION : string := "UNSIGNED";
	LPM_PIPELINE : natural := 0;
	LPM_TYPE : string := L_DIVIDE;
	LPM_HINT : string := "UNUSED"
	);
port (	NUMER : in std_logic_vector(LPM_WIDTHN-1 downto 0);
	DENOM : in std_logic_vector(LPM_WIDTHD-1 downto 0);
	ACLR : in std_logic := '0';
	CLOCK : in std_logic := '0';
	CLKEN : in std_logic := '1';
	QUOTIENT : out std_logic_vector(LPM_WIDTHN-1 downto 0);
	REMAIN : out std_logic_vector(LPM_WIDTHD-1 downto 0)
	);
end component;
begin

process(IR_in)
begin

	case op0 is
		when "00000" => --add
		when "00001" => --sub
		when "00010" => --addi
		when "00011" => --mult
		when "00100" => --div
		when "00101" => --slt
		when "00110" => --slti
		when "00111" => --and
		when "01000" => --or
		when "01001" => --nor
		when "01010" => --xor
		when "01011" => --andi
		when "01100" => --ori
		when "01101" => --xori
		when "01110" => --mfhi
		when "01111" => --mflo
		when "10000" => --lui
		when "10001" => --sll
		when "10010" => --slr
		when "10011" => --sra
		when "10100" => --lw
		when "10101" => --lb
		when "10110" => --sw
		when "10111" => --sb
		when "11000" => --beq
		when "11001" => --bne
		when "11010" => --j
		when "11011" => --jr
		when "11100" => --jal
		when others =>
	end case;

end process;

end disc;
