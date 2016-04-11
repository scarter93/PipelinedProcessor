-- Direct mapped cache
-- Author: Stephen Carter

library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic ( DATA_WIDTH : integer := 32
	);
	
port (	clk 	: in STD_LOGIC;
      	reset 	: in STD_LOGIC;
	PC	: in unsigned(DATA_WIDTH-1 downto 0);
--	tag	: in unsigned(20 downto 0);
--	index	: in unsigned(9 downto 0);
--	offset	: in STD_LOGIC;
	data	: out unsigned(DATA_WIDTH-1 downto 0);
	mem 	: out STD_LOGIC;
	mem_addr: out unsigned(DATA_WIDTH-1 downto 0)
  );

end cache;

architecture controller of cache is

constant zero : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
constant num_blks : integer := 1024;
-- 1 valid bit, 21 bit tag, 32 bit data
type blocks is array (num_blks-1 downto 0) of unsigned(53 downto 0);

signal cache_blks : blocks  := (others => (others => '0'));

begin




end architecture;