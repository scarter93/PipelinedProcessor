library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_arbiter_lib.all;

entity PipelinedProcessor is

	port(clk 	: in std_logic
	);

end entity;

architecture disc of PipelinedProcessor is

-------------------------
-- constant definition --
-------------------------

-----------------------
-- signal definition --
-----------------------

-- Universal
signal reset	: std_logic;

-- STAGE 1 IN
-- inputs from stage 4
-- branch_taken
signal branch_pc	: unsigned(DATA_WIDTH-1 downto 0);
signal branch_taken	: std_logic;
-- STAGE 2 IN
-- inputs from stage 1
-- IR, PC
-- inputs from stage 5
signal MEM	: unsigned(DATA_WIDTH-1 downto 0);	-- location to write back
signal WB	: unsigned(DATA_WIDTH-1 downto 0);	-- data to write back
signal branch_to_early	: unsigned(DATA_WIDTH-1 downto 0);
signal branch_taken_early	: std_logic;

-- STAGE 3 IN
-- inputs from stage 2
-- IR, PC
signal IMM	: unsigned(DATA_WIDTH-1 downto 0);	-- immiediate operand
-- op1_2, op2_2

-- STAGE 4 IN
-- IR, PC
-- alu_result_3
-- branch_taken_3
-- op2

-- STAGE 5 IN
signal data_memory	: unsigned(DATA_WIDTH-1 downto 0);
signal mem_data	: std_logic_vector(DATA_WIDTH-1 downto 0);
-- MULTISTAGE IO
signal IR_1, IR_2, IR_3, IR_4, IR_5 : unsigned(DATA_WIDTH-1 downto 0) := (OTHERS => '0');
signal PC_1, PC_2, PC_3 : unsigned(DATA_WIDTH-1 downto 0) := (OTHERS => '0');

signal op1_2	: unsigned(DATA_WIDTH-1 downto 0);
signal op2_2, op2_3	: unsigned(DATA_WIDTH-1 downto 0);

signal alu_result_3, alu_result_4, alu_result_5 : unsigned(DATA_WIDTH-1 downto 0);
signal branch_taken_3, branch_taken_4	: std_logic := '0';


--FORWARDING
signal forward : unsigned(4 downto 0) := (OTHERS => 'Z');

-- MEMORY ARBITER
signal rw_word	: std_logic;
-- conversions
signal IR_addr_nat, ID_addr_nat : natural;
-- Memory Port #1
signal IR_addr	: unsigned(DATA_WIDTH-1 downto 0);
signal IR_data	: std_logic_vector(DATA_WIDTH-1 downto 0);
signal IR_re	: std_logic := '0';
signal IR_we	: std_logic := '0';
signal IR_busy	: std_logic;

-- Memory Port #2
signal ID_addr	: natural;
signal ID_data	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => 'Z');
signal ID_re	: std_logic;
signal ID_we	: std_logic;
signal ID_busy	: std_logic;

--------------------------
-- component definition --
--------------------------

-- PIPELINE --
-- Stage 1 --
component INSTRUCTION_FETCH is

	generic ( DATA_WIDTH : integer := 32
		);
	port(	clk	: in std_logic;
		reset	: in std_logic;
		branch_taken	: in std_logic;
		branch_pc	: in unsigned(DATA_WIDTH-1 downto 0);
		IR	: out unsigned(DATA_WIDTH-1 downto 0);
		PC_out	: out unsigned(DATA_WIDTH-1 downto 0);
		-- memory access
		IR_pc	: out unsigned(DATA_WIDTH-1 downto 0);
		IR_re	: out std_logic;
		IR_data	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		IR_busy : in std_logic;
		ID_busy : in std_logic
		);

end component;

-- Stage 2 --
component INSTRUCTION_DECODE is

	generic ( DATA_WIDTH : integer := 32
		);
	port( 	clk	: in std_logic;
		IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
		PC_in	: in unsigned(DATA_WIDTH-1 downto 0);
		MEM	: in unsigned(DATA_WIDTH-1 downto 0);	-- location to write back
		WB_IR	: in unsigned(DATA_WIDTH-1 downto 0);	-- data to write back
		forw_reg: in unsigned(4 downto 0);
		alu_res	: in unsigned(DATA_WIDTH-1 downto 0);
		IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
		PC_out	: out unsigned(DATA_WIDTH-1 downto 0);
		IMM	: out unsigned(DATA_WIDTH-1 downto 0);	-- immiediate operand
		op1	: out unsigned(DATA_WIDTH-1 downto 0);
		op2	: out unsigned(DATA_WIDTH-1 downto 0);
		branch_taken	: out std_logic;
		branch_to	: out unsigned(DATA_WIDTH-1 downto 0)
		);

end component;

-- Stage 3 --
component EXECUTE is

	generic ( DATA_WIDTH : integer := 32
		);
	port(	clk	: in std_logic;
		IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
		PC_in	: in unsigned(DATA_WIDTH-1 downto 0);
		IMM_in	: in unsigned(DATA_WIDTH-1 downto 0);
		op1	: in unsigned(DATA_WIDTH-1 downto 0);
		op2	: in unsigned(DATA_WIDTH-1 downto 0);
		branch_taken	: out std_logic;
		forw_reg	: out unsigned(4 downto 0);
		alu_result	: out unsigned(DATA_WIDTH-1 downto 0);
		op2_out	: out unsigned(DATA_WIDTH-1 downto 0);
		IR_out	: out unsigned(DATA_WIDTH-1 downto 0)
		);

end component;

-- Stage 4 --
component MEMORY is

	generic ( DATA_WIDTH : integer := 32
		);
	port(	clk	: in std_logic;
		branch_taken	: in std_logic;
		alu_result_in	: in unsigned(DATA_WIDTH-1 downto 0);
		op2_in	: in unsigned(DATA_WIDTH-1 downto 0);
		IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
		memory	: out unsigned(DATA_WIDTH-1 downto 0);
		rw_word	: out std_logic;
		branch_taken_out : out std_logic;
		alu_result_out	: out unsigned(DATA_WIDTH-1 downto 0);
		IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
		ID_addr	: out NATURAL;
		ID_data	: inout STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
		ID_re	: out STD_LOGIC;
		ID_we	: out STD_LOGIC;
		ID_busy	: in STD_LOGIC
		);

end component;

-- Stage 5 --
component WRITE_BACK is

	port(   clk     : in std_logic;
		memory	: in unsigned(DATA_WIDTH-1 downto 0);
		alu_result	: in unsigned(DATA_WIDTH-1 downto 0);
		IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
		IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
		WB	: out unsigned(DATA_WIDTH-1 downto 0)
		);

end component;


-- MISC --
-- Memory Arbiter --
component memory_arbiter is
	generic ( File_Address_Read : string := "test_branch.dat"
		);
	port(
		clk	: in std_logic;
		reset	: in std_logic;
		rw_word : in std_logic;
		--Memory port #1
		addr1	: in natural;
		data1	: inout std_logic_vector(DATA_WIDTH-1 downto 0);
		re1	: in std_logic;
		we1	: in std_logic;
		busy1 : out std_logic;

		--Memory port #2
		addr2	: in natural;
		data2	: inout std_logic_vector(DATA_WIDTH-1 downto 0);
		re2	: in std_logic;
		we2	: in std_logic;
		busy2	: out std_logic

	  );

end component;


begin
-----------------------
-- hardwired signals --
-----------------------
IR_addr_nat <= to_integer(IR_addr);

--with ID_we select ID_data  <=
--	mem_data when '1',
--	(others => 'Z') when others;

branch_pc <= alu_result_4 when (branch_taken_4 = '1') else
	branch_to_early when (branch_taken_early = '1') else
	(others => 'Z');

branch_taken <= (branch_taken_4 or branch_taken_early);

--ID_addr_nat <= to_integer(ID_addr);
------------------------------
-- component initialization --
------------------------------
fetch : INSTRUCTION_FETCH
	port map (
		clk => clk,
		reset => reset,
		branch_taken => branch_taken,
		branch_pc => branch_pc,
		IR => IR_1,
		PC_out => PC_1,
		IR_pc => IR_addr,
		IR_re => IR_re,
		IR_data => IR_data,
		IR_busy => IR_busy,
		ID_busy => ID_busy
	);

decode : INSTRUCTION_DECODE
	port map (
		clk => clk,
		IR_in => IR_1,
		PC_in => PC_1,
		MEM => WB,
		WB_IR => IR_5,
		forw_reg => forward,
		alu_res => alu_result_3,
		IR_out => IR_2,
		PC_out => PC_2,
		IMM => IMM,
		op1 => op1_2,
		op2 => op2_2,
		branch_taken => branch_taken_early,
		branch_to => branch_to_early
	);

execute_t : EXECUTE
	port map (
		clk => clk,
		IR_in => IR_2,
		PC_in => PC_2,
		IMM_in => IMM,
		op1 => op1_2,
		op2 => op2_2,
		branch_taken => branch_taken_3,
		alu_result => alu_result_3,
		forw_reg => forward,
		op2_out => op2_3,
		IR_out => IR_3
	);

memory_t : MEMORY
		port map (
			clk => clk,
			branch_taken => branch_taken_3,
			alu_result_in => alu_result_3,
			op2_in => op2_3,
			IR_in => IR_3,
			memory => data_memory,
			rw_word => rw_word,
			branch_taken_out => branch_taken_4,
			alu_result_out => alu_result_4,
			IR_out => IR_4,
			ID_addr => ID_addr,
			ID_data => ID_data,
			ID_re => ID_re,
			ID_we => ID_we,
			ID_busy => ID_busy
		);

write_back_t : WRITE_BACK
	port map (
		clk => clk,
		memory => data_memory,
		alu_result => alu_result_4,
		IR_in => IR_4,
		IR_out => IR_5,
		WB => WB
	);

memory_arbiter_t : memory_arbiter
	port map (
		clk => clk,
		reset => reset,
		rw_word => rw_word,
		--Memory port #1
		addr1 => ID_addr,
		data1 => ID_data,
		re1 => ID_re,
		we1 => ID_we,
		busy1 => ID_busy,
		--Memory port #2
		addr2 => IR_addr_nat,
		data2 => IR_data,
		re2 => IR_re,
		we2 => IR_we,
		busy2 => IR_busy
	);
end disc;