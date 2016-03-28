library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity INSTRUCTION_DECODE is

generic ( DATA_WIDTH : integer := 32
	);
port( 	clk	: in std_logic;
	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
	PC_in	: in unsigned(DATA_WIDTH-1 downto 0);
	MEM	: in unsigned(DATA_WIDTH-1 downto 0);	-- data to write back
	WB_IR	: in unsigned(DATA_WIDTH-1 downto 0);	-- location to write back
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
	PC_out	: out unsigned(DATA_WIDTH-1 downto 0);
	IMM	: out unsigned(DATA_WIDTH-1 downto 0);	-- immiediate operand
	op1	: out unsigned(DATA_WIDTH-1 downto 0);
	op2	: out unsigned(DATA_WIDTH-1 downto 0);
	branch_taken	: out std_logic;
	branch_to	: out unsigned(DATA_WIDTH-1 downto 0)
	);

end entity;

architecture disc of INSTRUCTION_DECODE is

constant ADD	: unsigned(5 downto 0) := "000000";
constant SUB	: unsigned(5 downto 0) := "000001";
constant ADDI	: unsigned(5 downto 0) := "000010";
constant MULT	: unsigned(5 downto 0) := "000011";
constant DIV	: unsigned(5 downto 0) := "000100";
constant SLT	: unsigned(5 downto 0) := "000101";
constant SLTI	: unsigned(5 downto 0) := "000110";
constant ANDD	: unsigned(5 downto 0) := "000111";
constant ORR	: unsigned(5 downto 0) := "001000";
constant NORR	: unsigned(5 downto 0) := "001001";
constant XORR	: unsigned(5 downto 0) := "001010";
constant ANDI	: unsigned(5 downto 0) := "001011";
constant ORI	: unsigned(5 downto 0) := "001100";
constant XORI	: unsigned(5 downto 0) := "001101";
constant MFHI	: unsigned(5 downto 0) := "001110";
constant MFLO	: unsigned(5 downto 0) := "001111";
constant LUI	: unsigned(5 downto 0) := "010000";
constant SLLL	: unsigned(5 downto 0) := "010001";
constant SRLL	: unsigned(5 downto 0) := "010010";
constant SRAA	: unsigned(5 downto 0) := "010011";
constant LW		: unsigned(5 downto 0) := "010100";
constant LB		: unsigned(5 downto 0) := "010101";
constant SW		: unsigned(5 downto 0) := "010110";
constant SB		: unsigned(5 downto 0) := "010111";
constant BEQ	: unsigned(5 downto 0) := "011000";
constant BNE	: unsigned(5 downto 0) := "011001";
constant J		: unsigned(5 downto 0) := "011010";
constant JR		: unsigned(5 downto 0) := "011011";
constant JAL	: unsigned(5 downto 0) := "011100";

-- used in branch resolution
constant zeros		: unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
constant ones		: unsigned(DATA_WIDTH-1 downto 0) := (others => '1');
constant four		: unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(integer(4), DATA_WIDTH);

type REGISTERS is array (0 to 31) of unsigned(DATA_WIDTH-1 downto 0);
signal reg :  REGISTERS;
signal op1_addr, op2_addr, wb_addr : unsigned(4 downto 0);
signal op1_tmp, op2_tmp : unsigned(DATA_WIDTH-1 downto 0);

signal wb_opcode : unsigned(5 downto 0);
signal current_opcode : unsigned(5 downto 0);

begin

wb_opcode <= WB_IR(31 downto 26);
current_opcode <= IR_in(31 downto 26);

op1_addr <= IR_in(25 downto 21);
op2_addr <= IR_in(20 downto 16);

op1_tmp <= reg(to_integer(op1_addr));
op2_tmp <= reg(to_integer(op2_addr));

operands : process (clk)
begin
	if rising_edge(clk) then
        op1 <= op1_tmp;
		op2 <= op2_tmp;
	end if;
end process;


sign_extend : process(clk)
begin
	-- don't do anything for these immediate opperations
	-- LUI or BEQ or BNE
	if rising_edge(clk) then
		if 	current_opcode = ADDI or --sign extend
			current_opcode = SLTI or
			current_opcode = LW or
			current_opcode = LB or
			current_opcode = SW or
			current_opcode = SB
		then
			if IR_in(15) = '1' then
				IMM <= "1111111111111111" & IR_in(15 downto 0);
			else
				IMM <= "0000000000000000" & IR_in(15 downto 0);
			end if;
		elsif current_opcode = ANDI or --zero extend
			current_opcode = ORI or
			current_opcode = XORI
		then
			IMM <= "0000000000000000" & IR_in(15 downto 0);
		end if;
	end if;
end process;


-- get_wb_addr
wb_addr <= WB_IR(15 downto 11) when --store to rd
		wb_opcode = ADD or
		wb_opcode = SUB or
		wb_opcode = SLT or
		wb_opcode = ANDD or
		wb_opcode = ORR or
		wb_opcode = NORR or
		wb_opcode = XORR or
		wb_opcode = MFHI or
		wb_opcode = MFLO or
		wb_opcode = SLLL or
		wb_opcode = SRLL or
		wb_opcode = SRAA
	else WB_IR(20 downto 16) when --store to rt
		wb_opcode = ADDI or
		wb_opcode = SLTI or
		wb_opcode = ANDI or
		wb_opcode = ORI or
		wb_opcode = XORI or
		wb_opcode = LUI or
		wb_opcode = LW or
		wb_opcode = LB
		-- don't store anything for
		-- MULT or DIV or SW or SB or BEQ or BNE or J or JR or JAL
	else (others => '0');

write_to_regs : process(clk)
begin
	if falling_edge(clk) then
		--write data
		reg(to_integer(wb_addr)) <= MEM;

		--ensure $R0 is always 0
		reg(0) <= (others => '0');

		--handle JAL
		if current_opcode = JAL then
			reg(integer(31)) <= PC_in + 8;
		end if;
	end if;
end process;

push_through : process(clk)
begin
	if rising_edge(clk) then
		case current_opcode is
		when "011000" => --beq
			if(op1_tmp = op2_tmp) then
				branch_taken <= '1';
				if(IR_in(15) = '1') then
					branch_to <=  PC_in + four + (ones(13 downto 0) & IR_in(15 downto 0) & "00");
				else
					branch_to <=  PC_in + four + (zeros(13 downto 0) & IR_in(15 downto 0) & "00");
				end if;
				--IR_out <= to_unsigned(0, DATA_WIDTH);
				--PC_out <= to_unsigned(0, DATA_WIDTH);
			IR_out <= IR_in;
			PC_out <= PC_in;
			end if;
		when "011001" => --bne
			if(op1_tmp /= op2_tmp) then
				branch_taken <= '1';
				if(IR_in(15) = '1') then
					branch_to <=  PC_in + four + (ones(13 downto 0) & IR_in(15 downto 0) & "00");
				else
					branch_to <=  PC_in + four + (zeros(13 downto 0) & IR_in(15 downto 0) & "00");
				end if;
				--IR_out <= to_unsigned(0, DATA_WIDTH);
				--PC_out <= to_unsigned(0, DATA_WIDTH);
			IR_out <= IR_in;
			PC_out <= PC_in;
			end if;
		when others =>
			branch_taken <= '0';
			IR_out <= IR_in;
			PC_out <= PC_in;
		end case;
	end if;
end process;

end disc;