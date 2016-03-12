library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PIPELINED_PROCESSOR is

end entity;

architecture disc of PIPELINED_PROCESSOR is

-------------------------
-- constant definition --
-------------------------
constant DATA_WIDTH : integer := 32;

-------------------------
-- constant definition --
-------------------------
-- STAGE 1 IN
-- inputs from stage 4
-- branch_taken
signal branch_pc	: unsigned(DATA_WIDTH-1 downto 0);

-- STAGE 2 IN
-- inputs from stage 1
-- IR, PC
-- inputs from stage 5
signal MEM	: unsigned(DATA_WIDTH-1 downto 0);	-- location to write back
signal WB_IR	: unsigned(DATA_WIDTH-1 downto 0);	-- data to write back

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

-- MULTISTAGE IO
signal IR_1, IR_2, IR_3, IR_4, IR_5 : unsigned(DATA_WIDTH-1 downto 0);
signal PC_1, PC_2, PC_3 : unsigned(DATA_WIDTH-1 downto 0);

signal op1_2	: unsigned(DATA_WIDTH-1 downto 0);
signal op2_2, op2_3	: unsigned(DATA_WIDTH-1 downto 0);

signal alu_result_3, alu_result_4, alu_result_5 : unsigned(DATA_WIDTH-1 downto 0);
signal branch_taken_3, branch_taken_4	: std_logic;
--------------------------
-- component definition --
--------------------------

-- PIPELINE --
-- Stage 1 --
component INSTRUCTION_FETCH is

	generic ( DATA_WIDTH : integer := 32
		);
	port(	branch_taken	: in std_logic;
		branch_pc	: in unsigned(DATA_WIDTH-1 downto 0);
		IR	: out unsigned(DATA_WIDTH-1 downto 0);
		PC	: out unsigned(DATA_WIDTH-1 downto 0)
		);

end component;

-- Stage 2 --
component INSTRUCTION_DECODE is

	generic ( DATA_WIDTH : integer := 32
		);
	port( 	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
		PC_in	: in unsigned(DATA_WIDTH-1 downto 0);
		MEM	: in unsigned(DATA_WIDTH-1 downto 0);	-- location to write back
		WB_IR	: in unsigned(DATA_WIDTH-1 downto 0);	-- data to write back
		IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
		PC_out	: out unsigned(DATA_WIDTH-1 downto 0);
		IMM	: out unsigned(DATA_WIDTH-1 downto 0);	-- immiediate operand
		op1	: out unsigned(DATA_WIDTH-1 downto 0);
		op2	: out unsigned(DATA_WIDTH-1 downto 0)
		);

end component;

-- Stage 3 --
component EXECUTE is

	generic ( DATA_WIDTH : integer := 32
		);
	port(	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
		PC_in	: in unsigned(DATA_WIDTH-1 downto 0);
		IMM_in	: in unsigned(DATA_WIDTH-1 downto 0);
		op1	: in unsigned(DATA_WIDTH-1 downto 0);
		op2	: in unsigned(DATA_WIDTH-1 downto 0);
		branch_taken	: out std_logic;
		alu_result	: out unsigned(DATA_WIDTH-1 downto 0);
		op2_out	: out unsigned(DATA_WIDTH-1 downto 0);
		IR_out	: out unsigned(DATA_WIDTH-1 downto 0)
		);

end component;

-- Stage 4 --
component MEMORY is

	generic ( DATA_WIDTH : integer := 32
		);
	port(	branch_taken	: in std_logic;
		alu_result_in	: in unsigned(DATA_WIDTH-1 downto 0);
		op2_in	: in unsigned(DATA_WIDTH-1 downto 0);
		IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
		memory	: out unsigned(DATA_WIDTH-1 downto 0);
		alu_result_out	: out unsigned(DATA_WIDTH-1 downto 0);
		IR_out	: out unsigned(DATA_WIDTH-1 downto 0)
		);

end component;

-- Stage 5 --
component WRITE_BACK is

	generic ( DATA_WIDTH : integer := 32
		);
	port(	memory	: in unsigned(DATA_WIDTH-1 downto 0);
		alu_result	: in unsigned(DATA_WIDTH-1 downto 0);
		IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
		IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
		WB	: out unsigned(DATA_WIDTH-1 downto 0)
		);

end component;


-- MISC --
-- Memory Arbiter --
-- TODO


begin

------------------------------
-- component initialization --
------------------------------
fetch : INSTRUCTION_FETCH 
	port map (
		branch_taken => branch_taken_4,
		-- TODO: setup branch_taken_4
		branch_pc => branch_pc,
		IR => IR_1,
		PC => PC_1
	);

decode : INSTRUCTION_DECODE
	port map (
		IR_in => IR_1,
		PC_in => PC_1,
		MEM => MEM,
		WB_IR => WB_IR,
		IR_out => IR_2,
		PC_out => PC_2,
		IMM => IMM,
		op1 => op1_2,
		op2 => op2_2
	);

execute_t : EXECUTE 
	port map (
		IR_in => IR_2,
		PC_in => PC_2,
		IMM_in => IMM,
		op1 => op1_2,
		op2 => op2_2,
		branch_taken => branch_taken_3,
		alu_result => alu_result_3,
		op2_out => op2_3,
		IR_out => IR_3
	);

memory_t : MEMORY
	port map (
		branch_taken => branch_taken_3,
		alu_result_in => alu_result_3,
		op2_in => op2_3,
		IR_in => IR_3,
		memory => data_memory,
		-- TODO branch_taken_out => branch_taken_4
		alu_result_out => alu_result_4,
		IR_out => IR_4
	);

write_back_t : WRITE_BACK
	port map (
		memory => data_memory,
		alu_result => alu_result_4,
		IR_in => IR_4,
		IR_out => IR_5,
		WB => WB_IR
	);

end disc;