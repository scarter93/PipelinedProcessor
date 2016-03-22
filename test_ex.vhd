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
signal ones : unsigned(DATA_WIDTH-1 downto 0) := (others =>  '1');
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

		REPORT "Mult and mfhi/mflo test: 5, 6";
		IR <= "000011" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(5, DATA_WIDTH);
		op2_test <= to_unsigned(6, DATA_WIDTH);
		result_correct <= to_unsigned(30, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (op2_res = op2_test) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN op2_out" SEVERITY ERROR;
		ASSERT (IR = IR_o) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN IR_out" SEVERITY ERROR;
		ASSERT (branch = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN branch" SEVERITY ERROR;
		IR <= "001111" & zeros(DATA_WIDTH-7 downto 0);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN LO result" SEVERITY ERROR;
		IR <= "001110" & zeros(DATA_WIDTH-7 downto 0);
		WAIT FOR 1 * clk_period;
		ASSERT (result = zeros) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN HI result" SEVERITY ERROR;


		REPORT "Div test: 300, 34 and mfhi,mflo";
		IR <= "000100" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(300, DATA_WIDTH);
		op2_test <= to_unsigned(34, DATA_WIDTH);
		correct_HI <= to_unsigned(28, DATA_WIDTH);
		correct_LO <= to_unsigned(8, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (op2_res = op2_test) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN op2_out" SEVERITY ERROR;
		ASSERT (IR = IR_o) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN IR_out" SEVERITY ERROR;
		ASSERT (branch = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN branch" SEVERITY ERROR;
		IR <= "001111" & zeros(DATA_WIDTH-7 downto 0);
		WAIT FOR 1 * clk_period;
		ASSERT (result = correct_LO) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN result" SEVERITY ERROR;
		IR <= "001110" & zeros(DATA_WIDTH-7 downto 0);
		WAIT FOR 1 * clk_period;
		ASSERT (result = correct_HI) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN result" SEVERITY ERROR;
		
		REPORT "slt test: 0 5";
		IR <= "000101" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(0, DATA_WIDTH);
		op2_test <= to_unsigned(5, DATA_WIDTH);
		result_correct <= (others => '1');
		WAIT FOR 1* clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN slt" SEVERITY ERROR;

		REPORT "slti test: 5 0";
		IR <= "000110" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(5, DATA_WIDTH);
		imm <= to_unsigned(0, DATA_WIDTH);
		result_correct <= (others => '0');
		WAIT FOR 1* clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN slt" SEVERITY ERROR;

		REPORT "and test: 3 5";
		IR <= "000111" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(3, DATA_WIDTH);
		op2_test <= to_unsigned(5, DATA_WIDTH);
		result_correct <= to_unsigned(1, DATA_WIDTH);
		WAIT FOR 1* clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN and" SEVERITY ERROR;

		REPORT "or test: 5 0";
		IR <= "001000" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(5, DATA_WIDTH);
		op2_test <= to_unsigned(0, DATA_WIDTH);
		result_correct <= to_unsigned(5, DATA_WIDTH);
		WAIT FOR 1* clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN or" SEVERITY ERROR;

		REPORT "nor test: 3 7";
		IR <= "001000" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(3, DATA_WIDTH);
		op2_test <= to_unsigned(6, DATA_WIDTH);
		result_correct <= to_unsigned(7, DATA_WIDTH);
		WAIT FOR 1* clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN nor" SEVERITY ERROR;
		
		REPORT "XOR test";
		IR <= "001010" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(364836, DATA_WIDTH);
		op2_test <= to_unsigned(129090, DATA_WIDTH);
		result_correct <= to_unsigned(289126, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN xor" SEVERITY ERROR;

		REPORT "andi test: 3 5";
		IR <= "001011" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(3, DATA_WIDTH);
		imm <= to_unsigned(5, DATA_WIDTH);
		result_correct <= to_unsigned(1, DATA_WIDTH);
		WAIT FOR 1* clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN andi" SEVERITY ERROR;

		REPORT "ori test: 5 0";
		IR <= "001100" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(5, DATA_WIDTH);
		imm <= to_unsigned(0, DATA_WIDTH);
		result_correct <= to_unsigned(5, DATA_WIDTH);
		WAIT FOR 1* clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN ori" SEVERITY ERROR;

		REPORT "xori test";
		IR <= "001101" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(364836, DATA_WIDTH);
		imm <= to_unsigned(129090, DATA_WIDTH);
		result_correct <= to_unsigned(289126, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN xori" SEVERITY ERROR;
		
		REPORT "lui test";
		IR <= "010000" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(364836, DATA_WIDTH);
		imm <= (others => '1');
		result_correct <= ones(DATA_WIDTH-1 downto 16) & zeros(15 downto 0);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN lui" SEVERITY ERROR;

		REPORT "SHIFT LEFT LOGICAL test";
		IR <= "010001" & zeros(DATA_WIDTH-7 downto 11) & "00001000000";
		op2_test <= to_unsigned(40, DATA_WIDTH);
		--op2_test <= to_unsigned(1, DATA_WIDTH);
		result_correct <= to_unsigned(80, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SHIFT LEFT" SEVERITY ERROR;

		REPORT "SHIFT RIGHT LOGICAL test";
		IR <= "010010" & zeros(DATA_WIDTH-7 downto 11) & "00001000000";
		op2_test <= to_unsigned(40, DATA_WIDTH);
		--op2_test <= to_unsigned(1, DATA_WIDTH);
		result_correct <= to_unsigned(20, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SHIFT RIGHT LOGICAL" SEVERITY ERROR;

		REPORT "SHIFT RIGHT ARITHMETIC test";
		IR <= "010011" & zeros(DATA_WIDTH-7 downto 11) & "00001000000";
		op2_test <= to_unsigned(40, DATA_WIDTH);
		--op2_test <= to_unsigned(1, DATA_WIDTH);
		result_correct <= to_unsigned(20, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SHIFT RIGHT ARITHMETIC" SEVERITY ERROR;

		REPORT "SHIFT RIGHT ARITHMETIC test: Negative";
		IR <= "010011" & zeros(DATA_WIDTH-7 downto 11) & "00001000000";
		op2_test <= unsigned(to_signed(-40, DATA_WIDTH));
		--op2_test <= to_unsigned(1, DATA_WIDTH);
		result_correct <= unsigned(to_signed(-20, DATA_WIDTH));
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN SHIFT RIGHT ARITHMETIC" SEVERITY ERROR;
		
		REPORT "lw test";
		IR <= "010100" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(32, DATA_WIDTH);
		imm <= to_unsigned(4, DATA_WIDTH);
		result_correct <= to_unsigned(36, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN lw" SEVERITY ERROR;	
	
		REPORT "lb test";
		IR <= "010101" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(28, DATA_WIDTH);
		imm <= to_unsigned(4, DATA_WIDTH);
		result_correct <= to_unsigned(32, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN lb" SEVERITY ERROR;	

		REPORT "sw test";
		IR <= "010110" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(32, DATA_WIDTH);
		imm <= to_unsigned(4, DATA_WIDTH);
		result_correct <= to_unsigned(36, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN sw" SEVERITY ERROR;	

		REPORT "sb test";
		IR <= "010111" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(28, DATA_WIDTH);
		imm <= to_unsigned(4, DATA_WIDTH);
		result_correct <= to_unsigned(32, DATA_WIDTH);
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN sb" SEVERITY ERROR;		
		
		REPORT "beq test";
		IR <= "011000" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(32, DATA_WIDTH);
		op2_test <= to_unsigned(32, DATA_WIDTH);
		result_correct <= PC + to_unsigned(integer(4), DATA_WIDTH) + zeros;
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN beq" SEVERITY ERROR;	
		ASSERT (branch = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN branch" SEVERITY ERROR;

		REPORT "bne test";
		IR <= "011001" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(28, DATA_WIDTH);
		op2_test <= to_unsigned(28, DATA_WIDTH);
		--result_correct <= PC + to_unsigned(integer(4), DATA_WIDTH) + zeros;;
		WAIT FOR 1 * clk_period;
		--ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN bne" SEVERITY ERROR;	
		ASSERT (branch = '0') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN branch" SEVERITY ERROR;

		REPORT "j test";
		IR <= "011010" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(20, DATA_WIDTH);
		--imm <= to_unsigned(4, DATA_WIDTH);
		result_correct <= (others => '0');
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN j" SEVERITY ERROR;	
		ASSERT (branch = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN branch" SEVERITY ERROR;

		REPORT "jr test";
		IR <= "011010" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(20, DATA_WIDTH);
		--imm <= to_unsigned(4, DATA_WIDTH);
		result_correct <= (others => '0');
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN jr" SEVERITY ERROR;	
		ASSERT (branch = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN branch" SEVERITY ERROR;

		REPORT "jal test";
		IR <= "011010" & zeros(DATA_WIDTH-7 downto 0);
		op1_test <= to_unsigned(20, DATA_WIDTH);
		--imm <= to_unsigned(4, DATA_WIDTH);
		result_correct <= (others => '0');
		WAIT FOR 1 * clk_period;
		ASSERT (result = result_correct) REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN sw" SEVERITY ERROR;	
		ASSERT (branch = '1') REPORT ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR IN branch" SEVERITY ERROR;


		wait;

	END PROCESS;
END architecture;