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
	PC_up	: in unsigned(DATA_WIDTH-1 downto 0);
	data_up	: in unsigned(DATA_WIDTH-1 downto 0);
	data	: out unsigned(DATA_WIDTH-1 downto 0);
	mem 	: out STD_LOGIC;
	mem_addr: out unsigned(DATA_WIDTH-1 downto 0)
  );

end cache;

architecture controller of cache is

constant blk_sz : integer := 32;
constant offset_sz : integer := 0;
constant tag_sz : integer := 22;
constant index_sz : integer := 10;
constant num_blks : integer := 1024;

constant cache_blk_sz : integer := tag_sz+blk_sz+offset_sz;

constant zero : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');

-- 1 valid bit, 21 bit tag, 32 bit data
type blocks is array (num_blks-1 downto 0) of unsigned(cache_blk_sz-1 downto 0);

signal cache_blks : blocks  := (others => (others => '0'));

signal cur_blk : unsigned(cache_blk_sz-1 downto 0);
--signal update_blk : unsigned(53 downto 0);

signal tag	: unsigned(tag_sz-1 downto 0);
signal index	: unsigned(index_sz-1 downto 0);
--signal offset	: STD_LOGIC;

signal tag_update	: unsigned(tag_sz-1 downto 0);
signal index_update	: unsigned(index_sz-1 downto 0);
--signal offset_update	: STD_LOGIC;

begin

tag <= PC(DATA_WIDTH-1 downto DATA_WIDTH-tag_sz);
index <= PC(DATA_WIDTH-tag_sz-1 downto DATA_WIDTH-tag_sz-blk_sz);
--add logic for offset, i.e. 64 bit cache_block
--offset <= PC(0);

tag_update <= PC_up(DATA_WIDTH-1 downto DATA_WIDTH-tag_sz);
index_update <= PC_up(DATA_WIDTH-tag_sz-1 downto DATA_WIDTH-tag_sz-blk_sz);
--offset_update <= PC(0);


get_data : process(clk,reset)
begin

cur_blk <= cache_blks(to_integer(index));

if reset = '1' then
	tag <= (others => '0');
	index <= (others => '0');
	--offset <= 'Z';
	cur_blk <= (others => '0');
	cache_blks <= (others => (others => '0'));
	data <= (others => 'Z');
	mem <= 'Z';
	mem_addr <= (others => 'Z');
elsif reset = '0' and rising_edge(clk) then
	if(tag = cur_blk(cache_blk_sz-2 downto cache_blk_sz-2-tag_sz) and cur_blk(cache_blk_sz-1) = '1' and index /= index_update) then
		data <= cur_blk(DATA_WIDTH downto 0);
		mem <= '0';
		mem_addr <= (others => '0');
	else
		mem <= '1';
		mem_addr <= cur_blk(DATA_WIDTH downto 0);
		cur_blk(cache_blk_sz-1) <= '0';
		
	end if;
end if;

end process;

update_data : process(clk,reset)
begin

--update_blk <= cache_blks(to_integer(index));

if reset = '1' then
	tag_update <= (others => '0');
	index_update <= (others => '0');
	--offset_update <= 'Z';
	--update_blk <= (others => '0');
elsif reset = '0' and rising_edge(clk) then
	cache_blks(to_integer(index_update))(cache_blk_sz-2 downto cache_blk_sz-2-tag_sz) <= tag_update;
	cache_blks(to_integer(index_update))(DATA_WIDTH downto 0) <= data_up;
	cache_blks(to_integer(index_update))(cache_blk_sz-1) <= '1';	
end if;

end process;

end architecture;