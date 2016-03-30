-- Entity: Write Back
-- Author: Stephen Carter, Jit Kanetkar, Auguste Lalande
-- Date: 03/22/2016
-- Description: Takes the result from memory or EXECUTE and passes this data back to decode to update the registers.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WRITE_BACK is

generic ( DATA_WIDTH : integer := 32
	);
port(   clk     : in std_logic;					-- clk
	memory	: in unsigned(DATA_WIDTH-1 downto 0);		-- result from mem stage
	alu_result	: in unsigned(DATA_WIDTH-1 downto 0);	-- result from execute stage
	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);		-- incoming IR
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0);		-- outgoing IR
	WB	: out unsigned(DATA_WIDTH-1 downto 0)		-- data to writeback
	);

end entity;

architecture disc of WRITE_BACK is
-- constants to check for load 
constant LW     : unsigned(5 downto 0) := "010100";
constant LB     : unsigned(5 downto 0) := "010101";

signal current_opcode : unsigned(5 downto 0);

begin
-- get current opcode
current_opcode <= IR_in(31 downto 26);

process(clk)
begin

	if current_opcode = LW or current_opcode = LB then
		-- if operation was memory access use result from memory
        	WB <= memory;
        else
		-- else use result from execute stage
        	WB <= alu_result;

        end if;
	if rising_edge(clk) then
		-- update IR
		IR_out <= IR_in;
	end if;
end process;

end disc;
