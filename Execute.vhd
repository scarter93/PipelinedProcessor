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
	op1	: in unsigned(DATA_WIDTH-1 downto 0);
	op2	: in unsigned(DATA_WIDTH-1 downto 0);
	clk	: in std_logic;
	branch_taken	: out std_logic;
	alu_result	: out unsigned(DATA_WIDTH-1 downto 0);
	op2_out	: out unsigned(DATA_WIDTH-1 downto 0);
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0)
	);

end entity;

architecture disc of EXECUTE is

signal status_check : unsigned(3 downto 0) := (others => '0');
signal op0	: unsigned(3 downto 0);
signal operation : unsigned(5 downto 0);

signal data1 		: signed(DATA_WIDTH-1 downto 0) := (others => '0');
signal data2 		: signed(DATA_WIDTH-1 downto 0) := (others => '0');

signal data_rslt 	: signed(DATA_WIDTH-1 downto 0) := (others => '0');
signal data_rslt_mult 	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal data_rslt_div 	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal data_rslt_other 	: unsigned(DATA_WIDTH-1 downto 0) := (others => '0');

signal mult	: std_logic := '0';
signal div	: std_logic := '0';
signal alu_op	: std_logic := '0';

signal HI	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal LO	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal HILO	: std_logic_vector((2*DATA_WIDTH)-1 downto 0) := (others => '0');

signal multdivalu 	: std_logic_vector(2 downto 0) := "000";
signal shamt 	: unsigned(DATA_WIDTH-1 downto 0) := (others => '0');

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
generic(LPM_WIDTHA : natural := DATA_WIDTH; 
        LPM_WIDTHB : natural := DATA_WIDTH;
        LPM_WIDTHS : natural := 1;
        LPM_WIDTHP : natural := 2*DATA_WIDTH;
	LPM_REPRESENTATION : string := "SIGNED";
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
generic(LPM_WIDTHN : natural := DATA_WIDTH;
        LPM_WIDTHD : natural := DATA_WIDTH;
	LPM_NREPRESENTATION : string := "SIGNED";
	LPM_DREPRESENTATION : string := "SIGNED";
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

shamt(4 downto 0) <=  IR_in(10 downto 6);
operation <= IR_in(DATA_WIDTH-1 downto DATA_WIDTH-6);
multdivalu <= mult & div & alu_op;



ALU_inst :  alu port map(OPCODE => op0, DATA0 => data1, DATA1 => data2, CLOCK => clk, RESET => '0', DATA_OUT => data_rslt, STATUS => status_check);
multiplier : LPM_MULT  port map( DATAA => std_logic_vector(data1),DATAB => std_logic_vector(data2), ACLR => '0', CLOCK => clk, CLKEN => mult, RESULT => HILO);
divider : LPM_DIVIDE  port map( NUMER => std_logic_vector(data1),DENOM => std_logic_vector(data2), ACLR => '0', CLOCK => clk, CLKEN => div, QUOTIENT => LO, REMAIN => LO );

with multdivalu select HI <=
	HILO(2*DATA_WIDTH-1 downto DATA_WIDTH) when "100",
	HI when others;

with multdivalu select LO <=
	HILO(DATA_WIDTH-1 downto 0) when "100",
	LO when others;	

with multdivalu select alu_result <=
	unsigned(data_rslt) when "001",
	(others => '0') when "100",
	(others => '0') when "010",
	data_rslt_other when others;

alu_result <= unsigned(data_rslt);
process(IR_in)
begin

	case operation is
		when "000000" => --add
			op0 <= "0000";
			data1 <= signed(op1);
			data2 <= signed(op2);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "000001" => --sub
			op0 <= "0001";
			data1 <= signed(op1);
			data2 <= signed(op2);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "000010" => --addi
			op0 <= "0000";
			data1 <= signed(op1);
			data2 <= signed(IMM_in);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "000011" => --mult
			data1 <= signed(op1);
			data2 <= signed(op2);
			mult <= '1';
			div <= '0';			
			alu_op <= '0';
		when "000100" => --div
			data1 <= signed(op1);
			data2 <= signed(op2);
			mult <= '0';
			div <= '1';
			alu_op <= '0';
		when "000101" => --slt
			if op1 < op2 then
				data_rslt_other <= (others => '1');
			else
				data_rslt_other <= (others => '0');
			end if;
		when "000110" => --slti
			if op1 < IMM_in then
				data_rslt_other <= (others => '1');
			else
				data_rslt_other <= (others => '0');
			end if;
		when "000111" => --and
			op0 <= "0011";
			data1 <= signed(op1);
			data2 <= signed(op2);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "001000" => --or
			op0 <= "0101";
			data1 <= signed(op1);
			data2 <= signed(op2);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "001001" => --nor
			op0 <= "0110";
			data1 <= signed(op1);
			data2 <= signed(op2);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "001010" => --xor
			op0 <= "0111";
			data1 <= signed(op1);
			data2 <= signed(op2);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "001011" => --andi
			op0 <= "0011";
			data1 <= signed(op1);
			data2 <= signed(IMM_in);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "001100" => --ori
			op0 <= "0101";
			data1 <= signed(op1);
			data2 <= signed(IMM_in);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "001101" => --xori
			op0 <= "0111";
			data1 <= signed(op1);
			data2 <= signed(IMM_in);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "001110" => --mfhi
			data_rslt_other <= unsigned(HI);
			mult <= '0';
			div <= '0';
			alu_op <= '0';
		when "001111" => --mflo
			data_rslt_other <= unsigned(LO);
			mult <= '0';
			div <= '0';
			alu_op <= '0';
		when "010000" => --lui
		when "010001" => --sll
			op0 <= "1011";
			data1 <= signed(op1);
			data2 <= signed(shamt);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "010010" => --srl
			op0 <= "1100";
			data1 <= signed(op1);
			data2 <= signed(shamt);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "010011" => --sra
			op0 <= "1010";
			data1 <= signed(op1);
			data2 <= signed(shamt);
			mult <= '0';
			div <= '0';
			alu_op <= '1';
		when "010100" => --lw
		when "010101" => --lb
		when "010110" => --sw
		when "010111" => --sb
		when "011000" => --beq
		when "011001" => --bne
		when "011010" => --j
		when "011011" => --jr
		when "011100" => --jal
		when others =>
			data1 <= (others => '0');
			data2 <= (others => '0');
			mult <= '0';
			div <= '0';
			alu_op <= '0';
	end case;

end process;

end disc;
