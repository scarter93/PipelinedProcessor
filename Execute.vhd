-- Entity: EXECUTE
-- Author: Stephen Carter, Jit Kanetkar, Auguste Lalande
-- Date: 03/30/2016
-- Description: Execute stage of the basic 5 stage RISC pipeline. ALU_result is used to hold the result of the operation,
-- if the operation is invalid, then the result is all 'Z'. There is also a branch_taken is always zero (EARLY BRANCH RESOLUTION).
-- The op2_out port forwards operand2 (RS). Forw_reg is used for port forwarding. The inputs come from the decode stage and are used
-- in the calculation.

library ieee;
library lpm;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use lpm.lpm_components.all;

entity EXECUTE is

generic ( DATA_WIDTH : integer := 32
	);
port(	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);	-- input IR
	PC_in	: in unsigned(DATA_WIDTH-1 downto 0);	-- input PC
	IMM_in	: in unsigned(DATA_WIDTH-1 downto 0);	-- Immediate (sign or zero extended)
	op1	: in unsigned(DATA_WIDTH-1 downto 0);	-- rt
	op2	: in unsigned(DATA_WIDTH-1 downto 0);	-- rs
	clk	: in std_logic;				-- clk
	branch_taken	: out std_logic;		-- no longer used
	alu_result	: out unsigned(DATA_WIDTH-1 downto 0);	-- rd
	forw_reg	: out unsigned(4 downto 0);	-- used for port forwarding
	op2_out	: out unsigned(DATA_WIDTH-1 downto 0);	-- forward the op2 (rs) to mem
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0)	-- forward IR to mem
	);

end entity;

architecture disc of EXECUTE is

-- UNUSED SIGNALS
signal status_check : unsigned(3 downto 0) := (others => '0');
signal op0	: unsigned(3 downto 0);
-- opcode
signal operation : unsigned(5 downto 0);
--constants used for extending by ones, zeros or adding four
constant zeros		: unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
constant ones		: unsigned(DATA_WIDTH-1 downto 0) := (others => '1');
constant four		: unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(integer(4), DATA_WIDTH);

--signal data_rslt 	: signed(DATA_WIDTH-1 downto 0) := (others => '0');
-- operation codes
signal mult	: std_logic := '0';
signal div	: std_logic := '0';
signal alu_op	: std_logic := '0';
-- HI, LO registers
signal HI	: signed(DATA_WIDTH-1 downto 0) := (others => '0');
signal LO	: signed(DATA_WIDTH-1 downto 0) := (others => '0');
--signal HILO	: signed((2*DATA_WIDTH)-1 downto 0) := (others => '0');

-- curretn registers
signal rs,rt,rd : unsigned(4 downto 0) := (others => '0');
-- UNUSED
signal multdivalu : std_logic_vector(2 downto 0) := "000";
-- signals for data from IR_in
signal shamt 	: unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
signal imm	: unsigned(15 downto 0);
signal jaddr	: unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
signal PC_temp 	: unsigned(DATA_WIDTH-1 downto 0) := PC_in;
begin
-- get shift amount
shamt(4 downto 0) <=  IR_in(10 downto 6);
-- get opcode
operation <= IR_in(DATA_WIDTH-1 downto DATA_WIDTH-6);
-- UNUSED
multdivalu <= mult & div & alu_op;
-- get unextended immediate
imm <= IR_in(15 downto 0);
-- temp PC updated by 4
PC_temp <= PC_in + four;
-- address for jumps
--jaddr <= PC_temp(DATA_WIDTH-1 downto 28) & IR_in(25 downto 0) & "00";
jaddr <= "000000" & IR_in(25 downto 0);
-- get registers from IR
rs <= IR_in(25 downto 21);
rt <= IR_in(20 downto 16);
rd <= IR_in(15 downto 11);
--process(clk)
--begin
--if rising_edge(clk) then
--	case mult is
--		when '1' =>
--			HI <= HILO(2*DATA_WIDTH-1 downto DATA_WIDTH);
--			LO <= HILO(DATA_WIDTH-1 downto 0);
--		when others =>
--			HI <= HI;
--			LO <= LO;
--	end case;
--end if;
--end process;

--with mult select LO <=
--	HILO(DATA_WIDTH-1 downto 0) when '1',
--	LO when others;
-- process for ALU
process(clk)
variable HILO	: signed((2*DATA_WIDTH)-1 downto 0) := (others => '0');
begin

	if rising_edge(clk) then
		-- updated IR
		IR_out <= IR_in;
		--update branch taken
		branch_taken <= '0';
		case operation is
			when "000000" => --add
				alu_result <= unsigned(signed(op1) + signed(op2));
				-- update other signals
				branch_taken <= '0';
				op2_out <= op2;
				forw_reg <= rd;
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "000001" => --sub
				alu_result <= unsigned(signed(op1) - signed(op2));
				-- update other signals
				branch_taken <= '0';
				op2_out <= op2;
				forw_reg <= rd;
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "000010" => --addi
				alu_result <= unsigned(signed(op1) + signed(IMM_in));
				branch_taken <= '0';
				-- update other signals
				op2_out <= op2;
				forw_reg <= rt;
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "000011" => --mult
				HILO := signed(op1) * signed(op2);
				-- update other signals
				branch_taken <= '0';
				forw_reg <= (others => 'Z');
				op2_out <= op2;
				mult <= '1';
				div <= '0';
				alu_op <= '0';
				HI <= HILO(2*DATA_WIDTH-1 downto DATA_WIDTH);
				LO <= HILO(DATA_WIDTH-1 downto 0);
			when "000100" => --div
				LO <= signed(op1) / signed(op2);
				HI <= signed(op1) MOD signed(op2);
				-- update other signals
				branch_taken <= '0';
				forw_reg <= (others => 'Z');
				op2_out <= op2;
				mult <= '0';
				div <= '1';
				alu_op <= '0';
			when "000101" => --slt
				if op1 < op2 then
					alu_result <= (others => '1');
				else
					alu_result <= (others => '0');
				end if;
				-- update other signals
				branch_taken <= '0';
				forw_reg <= rd;
				op2_out <= op2;
				mult <= '0';
				div <= '0';
				alu_op <= '0';
			when "000110" => --slti
				if op1 < IMM_in then
					alu_result <= (others => '1');
				else
					alu_result <= (others => '0');
				end if;
				-- update other signals
				branch_taken <= '0';
				forw_reg <= rt;
				op2_out <= op2;
				mult <= '0';
				div <= '0';
				alu_op <= '0';
			when "000111" => --and
				alu_result <= op1 AND op2;
				op2_out <= op2;
				forw_reg <= rd;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "001000" => --or
				alu_result <= op1 OR op2;
				op2_out <= op2;
				forw_reg <= rd;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "001001" => --nor
				alu_result <= op1 NOR op2;
				op2_out <= op2;
				forw_reg <= rd;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "001010" => --xor
				alu_result <= op1 XOR op2;
				-- update other signals
				op2_out <= op2;
				forw_reg <= rd;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "001011" => --andi
				alu_result <= op1 AND IMM_in;
				-- update other signals
				op2_out <= op2;
				forw_reg <= rt;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "001100" => --ori
				alu_result <= op1 OR IMM_in;
				-- update other signals
				op2_out <= op2;
				forw_reg <= rt;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "001101" => --xori
				alu_result <= op1 XOR IMM_in;
				-- update other signals
				op2_out <= op2;
				forw_reg <= rt;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "001110" => --mfhi
				alu_result <= unsigned(HI);
				-- update other signals
				op2_out <= op2;
				forw_reg <= rd;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '0';
			when "001111" => --mflo
				alu_result <= unsigned(LO);
				-- update other signals
				op2_out <= op2;
				forw_reg <= rd;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '0';
			when "010000" => --lui
				alu_result <= IMM_in(DATA_WIDTH-1 downto DATA_WIDTH/2) & zeros((DATA_WIDTH/2)-1 downto 0);
				-- update other signals
				op2_out <= op2;
				forw_reg <= rt;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '0';
			when "010001" => --sll
				alu_result <= unsigned(shift_left(op2, to_integer(shamt)));
				-- update other signals
				op2_out <= op2;
				forw_reg <= rd;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "010010" => --srl
				alu_result <= unsigned(shift_right(op2, to_integer(shamt)));
				-- update other signals
				op2_out <= op2;
				forw_reg <= rd;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "010011" => --sra
				alu_result <= unsigned(shift_right(signed(op2), to_integer(shamt)));
				-- update other signals
				op2_out <= op2;
				forw_reg <= rd;
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "010100" => --lw
				alu_result <= op1 + IMM_in;
				-- update other signals
				op2_out <= op2;
				forw_reg <= (others => 'Z');
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "010101" => --lb
				alu_result <= op1 + IMM_in;
				-- update other signals
				op2_out <= op2;
				forw_reg <= (others => 'Z');
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "010110" => --sw
				alu_result <= op1 + IMM_in;
				-- update other signals
				op2_out <= op2;
				forw_reg <= (others => 'Z');
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "010111" => --sb
				alu_result <= op1 + IMM_in;
				-- update other signals
				op2_out <= op2;
				forw_reg <= (others => 'Z');
				branch_taken <= '0';
				mult <= '0';
				div <= '0';
				alu_op <= '1';
			when "011000" => --beq
--				if(op1 = op2) then
--					branch_taken <= '1';
--					if(imm(15) = '1') then
--						alu_result <=  PC_in + four + (ones(13 downto 0) & imm & "00");
--					else
--						alu_result <=  PC_in + four + (zeros(13 downto 0) & imm & "00");
--					end if;
--				end if;
				-- branches have been moved to decode
				alu_result <= to_unsigned(0, DATA_WIDTH);
				forw_reg <= (others => 'Z');
				op2_out <= op2;
				mult <= '0';
				div <= '0';
				alu_op <= '0';
			when "011001" => --bne
--				if(op1 /= op2) then
--					branch_taken <= '1';
--					if(imm(15) = '1') then
--						alu_result <=  PC_in + four + (ones(13 downto 0) & imm & "00");
--					else
--						alu_result <=  PC_in + four + (zeros(13 downto 0) & imm & "00");
--					end if;
--				end if;
				-- branches moved to decode
				alu_result <= to_unsigned(0, DATA_WIDTH);
				forw_reg <= (others => 'Z');
				op2_out <= op2;
				mult <= '0';
				div <= '0';
				alu_op <= '0';
			when "011010" => --j
				branch_taken <= '1';
				alu_result <= jaddr;
				-- update other signals
				forw_reg <= (others => 'Z');
				op2_out <= op2;
				mult <= '0';
				div <= '0';
				alu_op <= '0';
			when "011011" => --jr
				branch_taken <= '1';
				forw_reg <= (others => 'Z');
				-- update other signals
				alu_result <=  op1;
				op2_out <= op2;
				mult <= '0';
				div <= '0';
				alu_op <= '0';
			when "011100" => --jal
				branch_taken <= '1';
				forw_reg <= (others => 'Z');
				-- update other signals
				alu_result <= jaddr;
				op2_out <= op2;
				mult <= '0';
				div <= '0';
				alu_op <= '0';
			when others =>
				-- update other signals on bad opcode
				branch_taken <= '0';
				alu_result <= (others => 'Z');
				forw_reg <= (others => 'Z');
				op2_out <= op2;
				mult <= '0';
				div <= '0';
				alu_op <= '0';
		end case;
	end if;

end process;

end disc;
