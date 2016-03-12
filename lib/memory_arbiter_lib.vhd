library ieee;

use ieee.std_logic_1164.all; -- allows use of the std_logic_vector type
use ieee.numeric_std.all; -- allows use of the unsigned type

PACKAGE memory_arbiter_lib IS 

  --Memory configuration constants (do not modify)
	CONSTANT NUM_BYTES_IN_WORD 	: INTEGER := 4;
	CONSTANT NUM_BITS_IN_BYTE 	: INTEGER := 8;
	CONSTANT MEM_DATA_WIDTH 		: INTEGER := NUM_BYTES_IN_WORD * NUM_BITS_IN_BYTE;

END memory_arbiter_lib;