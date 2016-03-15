-- entity: alu_16
-- author: Stephen Carter
-- stephen.carter@mail.mcgill.ca
-- Date: 2/5/2016
-- 
-- This module perfoms severl ALU operations as seen below.
-- The STATUS Register has a 2 clock cycle delay opposed to the DATA_OUT Register that has 1
-- All testing waits two clock cycles to verify that the correct STATUS Register is displayed
-- This ALU only preforms signed operations (+,-) therefore there is no carry out, only overflow
--
-- OPCODE TABLE
--
-- ADD | "0000"
-- SUB | "0001"
-- NOT | "0010"
-- AND | "0011"
-- NAND| "0100"
-- OR  | "0101"
-- NOR | "0110"
-- XOR | "0111"
-- XNOR| "1000"
-- ASL | "1001"
-- ASR | "1010"
-- LSL | "1011"
-- LSR | "1100"

-- STATUS REGISTER 4 bits
-- 
-- "Zero | Negative | Overflow | Parity"
--
-- TODO: Improve STATUS register operation to single clock cycle.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- import package for STATUS Register
--use work.status_type.all;

entity alu_16 is
	Generic(
		DATA_WIDTH : integer := 32
	);
	Port(
		OPCODE	:	in unsigned(3 downto 0);
		DATA0	:	in signed(DATA_WIDTH-1 downto 0);
		DATA1	:	in signed(DATA_WIDTH-1 downto 0);
		
		CLOCK	:	in std_logic;
		RESET	:	in std_logic;

		DATA_OUT :	out signed(DATA_WIDTH-1 downto 0);
		STATUS	:	out unsigned(3 downto 0)
	);
end entity;

architecture implementation of alu_16 is
-- Constants for OPCODE, increase ease of readability
CONSTANT ADD : unsigned(3 downto 0) := "0000";
CONSTANT SUB : unsigned(3 downto 0) := "0001";
CONSTANT NOT_IN : unsigned(3 downto 0) := "0010";
CONSTANT AND_IN : unsigned(3 downto 0) := "0011";
CONSTANT NAND_IN : unsigned(3 downto 0) := "0100";
CONSTANT OR_IN : unsigned(3 downto 0) := "0101";
CONSTANT NOR_IN : unsigned(3 downto 0) := "0110";
CONSTANT XOR_IN : unsigned(3 downto 0) := "0111";
CONSTANT XNOR_IN : unsigned(3 downto 0) := "1000";
CONSTANT ASL : unsigned(3 downto 0) := "1001";
CONSTANT ASR : unsigned(3 downto 0) := "1010";
CONSTANT LSL : unsigned(3 downto 0) := "1011";
CONSTANT LSR : unsigned(3 downto 0) := "1100";
-- Signals used to hold temporary values
Signal input1, input2, output : signed(DATA_WIDTH-1 downto 0);
Signal in_code : unsigned(3 downto 0);
Signal Z,N,O,P : std_logic;

begin
-- assign temporary values  and outputs
input1 <= DATA0;
input2 <= DATA1;
in_code <= OPCODE;
DATA_OUT <= output;
STATUS <= Z & N & O & P;

Process(CLOCK, RESET) -- process to perform ALU operations
	Begin
		-- check reset condition
		if RESET = '1' then
			output <= to_signed(0,DATA_WIDTH);
		elsif rising_edge(CLOCK) then
			-- depending on OPCODE perform Operation
			case OPCODE is
				when ADD =>
					output <= input1 + input2;
				when SUB =>
					output <= input1 - input2;
				when NOT_IN =>
					output <= NOT input1;
				when AND_IN =>
					output <= input1 AND input2;
				when NAND_IN =>
					output <= input1 NAND input2;
				when OR_IN =>
					output <= input1 OR input2;
				when NOR_IN =>
					output <= input1 NOR input2;
				when XOR_IN =>
					output <= input1 XOR input2;
				when XNOR_IN =>
					output <= input1 XNOR input2;
				when ASL =>
					output <= shift_left(input1, to_integer(unsigned(input2)));
				when ASR =>
					output <= shift_right(input1, to_integer(unsigned(input2)));
				when LSL =>
					output <= signed(shift_left(unsigned(input1), to_integer(unsigned(input2))));
				when LSR =>
					output <= signed(shift_right(unsigned(input1), to_integer(unsigned(input2))));
				-- when others, simply assign 0 output
				when others =>
					output <= to_signed(0,DATA_WIDTH);
			end case;
		end if;
	end process;

Process(CLOCK, RESET) -- process for updating OPCODE
	Begin
		-- check reset signal
		if RESET = '1' then
			Z <= '0';
			N <= '0';
			O <= '0';
			P <= '0';
		else
			-- no rising edge needed, we want to get get result up as fast as possible
			case OPCODE is
				-- check overflow conditions, zero conditions, negative conditions, and parity for addition
				when ADD =>
					O <= ((input1(DATA_WIDTH-1) AND input2(DATA_WIDTH-1) AND NOT output(DATA_WIDTH-1)) OR (NOT input1(DATA_WIDTH-1) AND NOT input2(DATA_WIDTH-1) AND output(DATA_WIDTH-1)));
					if to_integer(output) = 0 then
						Z <= '1';
					else
						Z <= '0';
					end if;
					N <= output(DATA_WIDTH-1);
					P <=  NOT (xor output);
				-- check overflow conditions, zero conditions, negative conditions, and parity for SUB
				when SUB =>
					O <= ((NOT input1(DATA_WIDTH-1) AND input2(DATA_WIDTH-1) AND output(DATA_WIDTH-1)) OR (input1(DATA_WIDTH-1) AND NOT input2(DATA_WIDTH-1) AND NOT output(DATA_WIDTH-1)));
					if to_integer(output) = 0 then
						Z <= '1';
					else
						Z <= '0';
					end if;
					N <= output(DATA_WIDTH-1);
					P <= NOT (xor output);
				-- check overflow conditions, zero conditions, negative conditions, and parity for everything else
				when OTHERS =>
					O <= '0';
					if to_integer(output) = 0 then
						Z <= '1';
					else
						Z <= '0';
					end if;
					N <= output(DATA_WIDTH-1);
					P <=  NOT (xor output);
			end case;
		end if;
	end process;

end implementation;