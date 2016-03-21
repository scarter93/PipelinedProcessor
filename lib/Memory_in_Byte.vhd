LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use STD.textio.all; --Don't forget to include this library for file operations.

ENTITY Memory_in_Byte IS
	generic (
			File_Address_Read : string :="Init.dat";
			File_Address_Write : string :="MemCon.dat";
			Mem_Size : integer:=256;
			Num_Bits_in_Byte: integer:=8;
			Read_Delay: integer:=0; 
			Write_Delay:integer:=0
			
		 );
	port (
			clk : in std_logic;
			address : in integer;
			we : in std_logic;
			wr_done:out std_logic; --indicates that the write operation has been done.
			re :in std_logic;
			rd_ready: out std_logic; --indicates that the read data is ready at the output.
			data : inout std_logic_vector(Num_Bits_in_Byte-1 downto 0);  
			initialize: in std_logic;
			dump: in std_logic
			
		 );			
END Memory_in_Byte;

ARCHITECTURE Behavioural OF Memory_in_Byte IS 
	 
	 type MEM_Type is array (0 to Mem_Size-1) of std_logic_vector(Num_Bits_in_Byte-1 downto 0);
	 signal Memory: Mem_Type;     
BEGIN

   

    process (initialize, dump, clk) 
		file file_pointer : text;
        variable line_content : string(1 to Num_Bits_in_Byte);
		variable line_num : line;
        variable i,j : integer := 0;
        variable char : character:='0'; 
		variable Mem_Address : integer:=0;
		variable  bin_value : std_logic_vector(Num_Bits_in_Byte-1 downto 0);
		variable delay_cnt : integer :=0;
	begin
	
		--	Initializing the memory from a file
		if (initialize'event and initialize='1') then
			  --Open the file read.txt from the specified location for reading(READ_MODE).
			file_open(file_pointer,File_Address_Read,READ_MODE);    
			while not endfile(file_pointer) loop --till the end of file is reached continue.
				readline (file_pointer,line_num);  --Read the whole line from the file
			  --Read the contents of the line from  the file into a variable.
				READ (line_num,line_content); 
			  --For each character in the line convert it to binary value.
			  --And then store it in a signal named 'bin_value'.
				for j in 1 to Num_Bits_in_Byte loop        
					char := line_content(j);
					if(char = '0') then
						 bin_value(Num_Bits_in_Byte-j) := '0';
					else
						 bin_value(Num_Bits_in_Byte-j) := '1';
					end if; 
				end loop;   
				Memory(Mem_Address) <= bin_value;
				Mem_Address := Mem_Address +1;
			end loop;
			
			file_close(file_pointer);  --after reading all the lines close the file.  
		------------------------------------------
		------------------------------------------
		
     
		--Write to file
		
		elsif(dump'event and dump='1') then
			 --Open the file write.txt from the specified location for writing(WRITE_MODE).
			file_open(file_pointer,File_Address_Write,WRITE_MODE);      
			  --We want to store binary values from 0000 to 1111 in the file.
			for i in 0 to Mem_Size-1 loop 
			  bin_value := memory(i);
			  --convert each bit value to character for writing to file.
			  for j in 0 to Num_Bits_in_Byte-1 loop
					if(bin_value(j) = '0') then
						 line_content(Num_Bits_in_Byte-j) := '0';
					elsif(bin_value(j) = '1') then
						 line_content(Num_Bits_in_Byte-j) := '1';
					elsif(bin_value(j) = 'U') then
						 line_content(Num_Bits_in_Byte-j) := 'U';
					elsif(bin_value(j) = 'X') then
						 line_content(Num_Bits_in_Byte-j) := 'X';
					elsif(bin_value(j) = 'Z') then
						line_content(Num_Bits_in_Byte-j) := 'Z';
					end if; 
			  end loop;
			  write(line_num,line_content); --write the line.
			  writeline (file_pointer,line_num); --write the contents into the file.
			  
			end loop;
			file_close(file_pointer); --Close the file after writing.
			 
		
		-- if not initializing nor dumping
		elsif(clk'event and clk='1') then
			data <= (others=>'Z'); --Since the data port is an INOUT 
			if (re='1' and we='0') then
				if(delay_cnt >= Read_Delay) then -- wait enough till Read_Dalys pass
					data <= Memory(address);
					delay_cnt := 0;
					wr_done <= '0';
					rd_ready <='1';
				else
					--data <= (others=>'U');
					delay_cnt := delay_cnt +1;
					wr_done <= '0';
					rd_ready <='0';
				end if;
			elsif (re='0' and we='1') then 
				if(delay_cnt >= Write_Delay) then -- wait enough till Write_Dalys pass
					Memory(address)<=data;
					delay_cnt := 0;
					wr_done <= '1';
					rd_ready <='0';
				else
					--Memory(address)<= (others=>'U');
					delay_cnt := delay_cnt +1;
					wr_done <= '0';
					rd_ready <='0';
				end if;
			else
				data <= (others =>'Z'); --if write and read enables get activated simultaneously!
				wr_done <= '0';
				rd_ready <='0';
			end if;
			
		end if;
    end process;


end Behavioural;