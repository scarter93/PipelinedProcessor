LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

ENTITY test_ex IS
END test_ex;

ARCHITECTURE behaviour OF test_ex IS

component EXECUTE is
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

end component;


constant DATA_WIDTH : integer := 32;



signal clk, reset: std_logic := '0';
constant clk_period : time := 1 ns;

signal op1_test : unsigned(DATA_WIDTH-1 downto 0);
signal op2_test : unsigned(DATA_WIDTH-1 downto 0);
signal IR : unsigned(DATA_WIDTH-1 downto 0);
signal result, result_correct : unsigned(DATA_WIDTH-1 downto 0);
signal correct_HI, correct_LO, LO, HI : unsigned(DATA_WIDTH-1 downto 0);
signal PC : unsigned(DATA_WIDTH-1 downto 0) := (others =>  '0');
signal zeros : unsigned(DATA_WIDTH-1 downto 0) := (others =>  '0');
signal imm : unsigned(DATA_WIDTH-1 downto 0) := (others =>  '0');
signal op2_res : unsigned(DATA_WIDTH-1 downto 0) := (others =>  '0');
signal branch : std_logic;
signal IR_o : unsigned(DATA_WIDTH-1 downto 0) := (others =>  '0');

BEGIN
	dut: EXECUTE	PORT MAP(IR, PC, imm, op1_test, op2_test, clk, branch, result, op2_res, IR_o);

	 --clock process
	clk_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR clk_period/2;
		clk <= '1';
		WAIT FOR clk_period/2;
	END PROCESS;
	

	--TODO: Thoroughly test the crap
	stim_process: PROCESS
	BEGIN
		reset <= '1';
		WAIT FOR 1 * clk_period;
		reset	<= '0';

		REPORT "Add test: 30 + 21";
		IR <= "000000" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(20, DATA_WIDTH);
		op2_test <= to_unsigned(31, DATA_WIDTH);
		result_correct <= to_unsigned(51, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN ADD: positive" SEVERITY ERROR;

		REPORT "Add test: -3 - 20";
		IR <= "000000" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= unsigned(to_signed(-3, DATA_WIDTH));
		op2_test <= unsigned(to_signed(-1, DATA_WIDTH));
		result_correct <= unsigned(to_signed(-4, DATA_WIDTH));
		WAIT FOR 1* clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN ADD: negative" SEVERITY ERROR;

		REPORT "Sub test: 17, 5";
		IR <= "000001" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(17, DATA_WIDTH);
		op2_test <= to_unsigned(5, DATA_WIDTH);
		result_correct <= to_unsigned(12, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SUB" SEVERITY ERROR;

--		REPORT "Mult test: 5, 6";
--		IR <= "000001" & (others => '0');
--		op1_test <= to_signed(5, 32);
--		op2_test <= to_signed(6, 32);
--		correct_HI <= to_signed(0, 32);
--		correct_LO <= to_signed(30, 32);
--		WAIT FOR 3 * clk_period;
--		ASSERT (LO = correct_LO) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN MUL HI" SEVERITY ERROR;
--		ASSERT (HI = correct_HI) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN MUL LO" SEVERITY ERROR;
--
--		--REPORT "Mult test: 2147483647, 2";
--		--IR <= "011000";
--		--op1_test <= to_signed(2147483647, 32);
--		--op2_test <= to_signed(2, 32);
--		--correct_HI <= to_signed(0, 32);
--		--correct_LO <= to_signed(0, 32);
--		--WAIT FOR 3 * clk_period;
--		--ASSERT (LO = correct_LO) REPORT "ERROR IN MUL HI" SEVERITY ERROR;
--		--ASSERT (HI = correct_HI) REPORT "ERROR IN MUL LO" SEVERITY ERROR;
--
--		REPORT "Div test: 300, 50";
--		IR <= "011010";
--		op1_test <= to_signed(300, 32);
--		op2_test <= to_signed(50, 32);
--		correct_HI <= to_signed(0, 32);
--		correct_LO <= to_signed(6, 32);
--		WAIT FOR 3 * clk_period;
--		ASSERT (LO = correct_LO) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN DIV HI" SEVERITY ERROR;
--		ASSERT (HI = correct_HI) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN DIV LO" SEVERITY ERROR;
--
--		REPORT "Div test: 34, 5";
--		IR <= "011010";
--		op1_test <= to_signed(34, 32);
--		op2_test <= to_signed(5, 32);
--		correct_HI <= to_signed(4, 32);
--		correct_LO <= to_signed(6, 32);
--		WAIT FOR 3 * clk_period;
--		ASSERT (LO = correct_LO) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN DIV HI" SEVERITY ERROR;
--		ASSERT (HI = correct_HI) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN DIV LO" SEVERITY ERROR;
--
--		REPORT "XOR test";
--		IR <= "100110";
--		op1_test <= to_signed(364836, 32);
--		op2_test <= to_signed(947376, 32);
--		result_correct <= to_signed(779668, 32);
--		WAIT FOR 1 * clk_period;
--		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN XOR" SEVERITY ERROR;
--
--		REPORT "SHIFT LEFT test";
--		IR <= "000000";
--		op1_test <= to_signed(40, 32);
--		op2_test <= to_signed(1, 32);
--		result_correct <= to_signed(80, 32);
--		WAIT FOR 1 * clk_period;
--		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SHIFT LEFT" SEVERITY ERROR;
--
--		REPORT "SHIFT RIGHT LOGICAL test";
--		IR <= "000010";
--		op1_test <= to_signed(40, 32);
--		op2_test <= to_signed(1, 32);
--		result_correct <= to_signed(20, 32);
--		WAIT FOR 1 * clk_period;
--		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SHIFT RIGHT LOGICAL" SEVERITY ERROR;
--
--		REPORT "SHIFT RIGHT ARITHMETIC test";
--		IR <= "000011";
--		op1_test <= to_signed(40, 32);
--		op2_test <= to_signed(1, 32);
--		result_correct <= to_signed(20, 32);
--		WAIT FOR 1 * clk_period;
--		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SHIFT RIGHT ARITHMETIC" SEVERITY ERROR;
--
--		REPORT "SHIFT RIGHT ARITHMETIC test: Negative";
--		IR <= "000011";
--		op1_test <= to_signed(-40, 32);
--		op2_test <= to_signed(1, 32);
--		result_correct <= to_signed(-20, 32);
--		WAIT FOR 1 * clk_period;
--		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SHIFT RIGHT ARITHMETIC" SEVERITY ERROR;
	wait;

	END PROCESS;
END architecture;