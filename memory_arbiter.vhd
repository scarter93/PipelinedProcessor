library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.memory_arbiter_lib.all;

-- Do not modify the port map of this structure
entity memory_arbiter is
port (clk 	: in STD_LOGIC;
      reset : in STD_LOGIC;
      
			--Memory port #1
			addr1	: in NATURAL;
			data1	:	inout STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
			re1		: in STD_LOGIC;
			we1		: in STD_LOGIC;
			busy1 : out STD_LOGIC;
			
			--Memory port #2
			addr2	: in NATURAL;
			data2	:	inout STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0);
			re2		: in STD_LOGIC;
			we2		: in STD_LOGIC;
			busy2 : out STD_LOGIC
  );
end memory_arbiter;

architecture behavioral of memory_arbiter is

	--Main memory signals
  --Use these internal signals to interact with the main memory
  SIGNAL mm_address       : NATURAL                                       := 0;
  SIGNAL mm_we            : STD_LOGIC                                     := '0';
  SIGNAL mm_wr_done       : STD_LOGIC                                     := '0';
  SIGNAL mm_re            : STD_LOGIC                                     := '0';
  SIGNAL mm_rd_ready      : STD_LOGIC                                     := '0';
  SIGNAL mm_data          : STD_LOGIC_VECTOR(MEM_DATA_WIDTH-1 downto 0)   := (others => 'Z');
  SIGNAL mm_initialize    : STD_LOGIC                                     := '0';

  type ports is (NONE, PORT_1, PORT_2);
  SIGNAL who : ports := NONE;
  SIGNAL busy : STD_LOGIC := '0';
  SIGNAL port2_busy : ports := NONE;
begin

	--Instantiation of the main memory component (DO NOT MODIFY)
      main_memory : ENTITY work.Main_Memory
      GENERIC MAP (
	Num_Bytes_in_Word	=> NUM_BYTES_IN_WORD,
	Num_Bits_in_Byte 	=> NUM_BITS_IN_BYTE,
        Read_Delay        => 3, 
        Write_Delay       => 3
      )
      PORT MAP (
        clk	    => clk,
        address     => mm_address,
        Word_Byte   => '1',
        we          => mm_we,
        wr_done     => mm_wr_done,
        re          => mm_re,
        rd_ready    => mm_rd_ready,
        data        => mm_data,
        initialize  => mm_initialize,
        dump        => '0'
      );

-- determine priority between ports 1 and 2
process (clk, reset)
begin
	if (reset = '1') then
		-- default values
		who <= NONE;
	elsif (rising_edge(clk)) then
		-- give port 1 priority over port 2, but make sure we don't
		-- interrupt an operation on port 2
		if (port2_busy = NONE and (re1 = '1' or we1 = '1')) then
			-- Port 1 Operation
			mm_address	<= addr1;
			mm_we		<= we1;
			mm_re		<= re1;
			mm_data		<= data1;
			who		<= PORT_1;
		elsif (re2 = '1' or we2 = '1') then
			-- Port 2 Operation
			mm_address	<= addr2;
			mm_we		<= we2;
			mm_re		<= re2;
			mm_data		<= data2;
			who		<= PORT_2;
		end if;
	end if;
end process;

-- determine whether PORT 1 or PORT_2 is busy 
process (clk, re1, re2, mm_wr_done, mm_rd_ready)
begin
	if ((re1 = '1' or we1 = '1') and (mm_wr_done = '0' and mm_rd_ready ='0')) then
		-- set port 1 as busy until mm_wr_done or mm_rd_ready goes off
		busy1 <= '1';
	elsif (who = PORT_1) then
		-- signal port 1 off when write or read has finished
		busy1 <= '0';
	end if;

	if ((re2 = '1' or we2 = '1') and (mm_wr_done = '0' and mm_rd_ready ='0')) then
		-- set port 1 as busy until mm_wr_done or mm_rd_ready goes off
		busy2 <= '1';
	elsif (who = PORT_2) then
		-- signal port 2 off when write or read has finished
		busy2 <= '0';
	end if;

	if (reset = '1') then
		busy1 <= '0';
		busy1 <= '0';
	end if;
end process;

-- makes sure port 1 doesn't write when port 2 is up to something
process (clk, re1, re2, mm_wr_done, mm_rd_ready)
begin
	if (reset = '1') then
		port2_busy <= NONE;
	-- case in which port 2 is busy
	elsif ((re2 = '1' or we2 = '1') and who = PORT_2) then
		port2_busy <= PORT_2;
	else
		port2_busy <= NONE;
	end if;
end process;

end behavioral;