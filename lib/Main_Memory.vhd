LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use STD.textio.all; --Don't forget to include this library for file operations.

ENTITY Main_Memory IS
	generic (
			File_Address_Read : string :="Init.dat";
			File_Address_Write : string :="MemCon.dat";
			Mem_Size_in_Word : integer:=256;	
			Num_Bytes_in_Word: integer:=4;
			Num_Bits_in_Byte: integer := 8; 
			Read_Delay: integer:=0; 
			Write_Delay:integer:=0
		 );
	port (
			clk : in std_logic;
			address : in integer;
			Word_Byte: in std_logic; -- when '1' you are interacting with the memory in word otherwise in byte
			we : in std_logic;
			wr_done:out std_logic; --indicates that the write operation has been done.
			re :in std_logic;
			rd_ready: out std_logic; --indicates that the read data is ready at the output.
			data : inout std_logic_vector((Num_Bytes_in_Word*Num_Bits_in_Byte)-1 downto 0);        
			initialize: in std_logic;
			dump: in std_logic
		 );			
END Main_Memory;

ARCHITECTURE Behavioural OF Main_Memory IS 


	signal data0,data1,data2,data3 : std_logic_vector (Num_Bits_in_Byte-1 downto 0);
	signal wr_done0,wr_done1,wr_done2,wr_done3:std_logic; 
	signal rd_ready0,rd_ready1,rd_ready2,rd_ready3:std_logic; 
	signal re0,re1,re2,re3:std_logic; 
	signal we0,we1,we2,we3:std_logic; 
	
	signal Byte_Offset : integer:=0;
	signal Word_Pointer : integer:=0;
	signal Block_Mem_Init :std_logic:='0';
	
	
	component Memory_in_Byte
	 generic (
				File_Address_Read : string :="Init.dat";
				File_Address_Write : string :="MemCon.dat";
				Mem_Size : integer:=256;
				Num_Bits_in_Byte: integer:=8;
				Read_Delay: integer:=0;
				Write_Delay:integer:=0
				);
    PORT(
         clk : IN  std_logic;
         address : IN  integer;
         we : IN  std_logic;
         wr_done : OUT  std_logic;
         re : IN  std_logic;
         rd_ready : OUT  std_logic;
         data : INOUT  std_logic_vector(Num_Bits_in_Byte-1 downto 0);
         initialize : IN  std_logic;
         dump : IN  std_logic
		
        );
    END component;
BEGIN
	  Block0: Memory_in_Byte 
		generic map (
			 File_Address_Read => "Init0.dat",
			 File_Address_Write => "MemCon0.dat",
			 Mem_Size => Mem_Size_in_Word,
			 Num_Bits_in_Byte => Num_Bits_in_Byte,
			 Read_Delay => Read_Delay,
			 Write_Delay => Write_Delay			 
		)
		PORT MAP (
          clk => clk,
          address => (Word_Pointer),
          we => we0,
          wr_done => wr_done0,
          re => re0,
          rd_ready => rd_ready0,
          data => data0,  
          initialize => Block_Mem_Init,
          dump => dump
        );

	 
    Block1: Memory_in_Byte 
		generic map (
			 File_Address_Read => "Init1.dat",
			 File_Address_Write => "MemCon1.dat",
			 Mem_Size => Mem_Size_in_Word,
			 Num_Bits_in_Byte => Num_Bits_in_Byte,
			 Read_Delay => Read_Delay,
			 Write_Delay => Write_Delay			 
		)
		PORT MAP (
          clk => clk,
          address => (Word_Pointer),
          we => we1,
          wr_done => wr_done1,
          re => re1,
          rd_ready => rd_ready1,
          data => data1,   
          initialize => Block_Mem_Init,
          dump => dump
        );
		
	 Block2: Memory_in_Byte 
		generic map (
			 File_Address_Read => "Init2.dat",
			 File_Address_Write => "MemCon2.dat",
			 Mem_Size => Mem_Size_in_Word,
			 Num_Bits_in_Byte => Num_Bits_in_Byte,
			 Read_Delay => Read_Delay,
			 Write_Delay => Write_Delay			 
		)
		PORT MAP (
          clk => clk,
          address => (Word_Pointer),
          we => we2,
          wr_done => wr_done2,
          re => re2,
          rd_ready => rd_ready2,
          data => data2,
          initialize => Block_Mem_Init,
          dump => dump
        );
		
	 Block3: Memory_in_Byte 
		generic map (
			 File_Address_Read => "Init3.dat",
			 File_Address_Write => "MemCon3.dat",
			 Mem_Size => Mem_Size_in_Word,
			 Num_Bits_in_Byte => Num_Bits_in_Byte,
			 Read_Delay => Read_Delay,
			 Write_Delay => Write_Delay			 
		)
		PORT MAP (
          clk => clk,
          address => (Word_Pointer),
          we => we3,
          wr_done => wr_done3,
          re => re3,
          rd_ready => rd_ready3,
          data => data3,
          initialize => Block_Mem_Init,
          dump => dump
        );		
		  
		  
Byte_Offset <= address mod 4;	
Word_Pointer <=  address / 4;

we0 <= '1' when (we='1' and Word_Byte='1') or (we='1' and Word_Byte='0' and Byte_Offset=0) else
		 '0';
we1 <= '1' when (we='1' and Word_Byte='1') or (we='1' and Word_Byte='0' and Byte_Offset=1) else
		 '0';
we2 <= '1' when (we='1' and Word_Byte='1') or (we='1' and Word_Byte='0' and Byte_Offset=2) else
		 '0';
we3 <= '1' when (we='1' and Word_Byte='1') or (we='1' and Word_Byte='0' and Byte_Offset=3) else
		 '0';
		 

data0 <= data(Num_Bits_in_Byte*1-1 downto 0) when (we='1' and Word_Byte='1') else
		   data(Num_Bits_in_Byte*1-1 downto 0) when (we='1' and Word_Byte='0' and Byte_Offset=0) else
			"ZZZZZZZZ";
data1 <= data(Num_Bits_in_Byte*2-1 downto Num_Bits_in_Byte*1) when (we='1' and Word_Byte='1') else
		   data(Num_Bits_in_Byte*1-1 downto 0) when (we='1' and Word_Byte='0' and Byte_Offset=1) else
			"ZZZZZZZZ";
data2 <= data(Num_Bits_in_Byte*3-1 downto Num_Bits_in_Byte*2) when (we='1' and Word_Byte='1') else
		   data(Num_Bits_in_Byte*1-1 downto 0) when (we='1' and Word_Byte='0' and Byte_Offset=2) else
			"ZZZZZZZZ";
data3 <= data(Num_Bits_in_Byte*4-1 downto Num_Bits_in_Byte*3) when (we='1' and Word_Byte='1') else
		   data(Num_Bits_in_Byte*1-1 downto 0) when (we='1' and Word_Byte='0' and Byte_Offset=3) else
			"ZZZZZZZZ";

data(Num_Bits_in_Byte*1-1 downto 0) <= data0 when (re='1' and Word_Byte='1') else
		   data0 when (re='1' and Word_Byte='0' and Byte_Offset=0) else
			data1 when (re='1' and Word_Byte='0' and Byte_Offset=1) else
			data2 when (re='1' and Word_Byte='0' and Byte_Offset=2) else
			data3 when (re='1' and Word_Byte='0' and Byte_Offset=3) else
			"ZZZZZZZZ";			
data(Num_Bits_in_Byte*2-1 downto Num_Bits_in_Byte*1) <= data1 when (re='1' and Word_Byte='1') else
		   "ZZZZZZZZ";
data(Num_Bits_in_Byte*3-1 downto Num_Bits_in_Byte*2) <= data2 when (re='1' and Word_Byte='1') else
		   "ZZZZZZZZ";
data(Num_Bits_in_Byte*4-1 downto Num_Bits_in_Byte*3) <= data3 when (re='1' and Word_Byte='1') else
		   "ZZZZZZZZ";


re0 <= '1' when (re='1' and Word_Byte='1') or (re='1' and Word_Byte='0' and Byte_Offset=0) else
		 '0';
re1 <= '1' when (re='1' and Word_Byte='1') or (re='1' and Word_Byte='0' and Byte_Offset=1) else
		 '0';
re2 <= '1' when (re='1' and Word_Byte='1') or (re='1' and Word_Byte='0' and Byte_Offset=2) else
		 '0';
re3 <= '1' when (re='1' and Word_Byte='1') or (re='1' and Word_Byte='0' and Byte_Offset=3) else
		 '0';

rd_ready <= '1' when rd_ready0='1' or rd_ready1='1' or rd_ready2='1' or rd_ready3='1' else
			'0';
wr_done <= '1' when wr_done0='1' or wr_done1='1' or wr_done2='1' or wr_done3='1' else
			'0';
		 
	process (initialize, dump, clk) 
 
			file file_pointer : text;
			file file_write_pointer0,file_write_pointer1,file_write_pointer2,file_write_pointer3 : text;
			file file_read_pointer0,file_read_pointer1,file_read_pointer2,file_read_pointer3 : text;
			variable line_content : string(1 to Num_Bytes_in_Word*Num_Bits_in_Byte);
			variable line_content_read, line_content_read0,line_content_read1, line_content_read2, line_content_read3 : string(1 to Num_Bits_in_Byte);
			variable line_num_read,line_num_write : line;
			variable i,j : integer := 0;
			variable char : character:='0'; 
			variable Mem_Address : integer:=0;
			variable  word_value : std_logic_vector(Num_Bytes_in_Word*Num_Bits_in_Byte-1 downto 0);
			variable  byte_value : std_logic_vector(Num_Bits_in_Byte-1 downto 0);
			variable delay_cnt : integer :=0;
	begin
	
		Block_Mem_Init <='0';
	
		--	Initializing the memory from a file
		if (initialize'event and initialize='1') then
			  --Open the file read.txt from the specified location for reading(READ_MODE).
			file_open(file_pointer,File_Address_Read,READ_MODE);
			file_open (file_write_pointer0, "Init0.dat", WRITE_MODE);
			file_open (file_write_pointer1, "Init1.dat", WRITE_MODE);
			file_open (file_write_pointer2, "Init2.dat", WRITE_MODE);
			file_open (file_write_pointer3, "Init3.dat", WRITE_MODE);
			
			while not endfile(file_pointer) loop --till the end of file is reached continue.
				readline (file_pointer,line_num_read);  --Read the whole line from the file
			  --Read the contents of the line from  the file into a variable.
				READ (line_num_read,line_content); 
			  --For each character in the line convert it to binary value.
			  --And then store it in a signal named 'word_value'.
			  
--				for j in 1 to Num_Bytes_in_Word*Num_Bits_in_Byte loop        
--					char := line_content(j);
--					if(char = '0') then
--						 word_value(Num_Bytes_in_Word*Num_Bits_in_Byte-j) := '0';
--					else
--						 word_value(Num_Bytes_in_Word*Num_Bits_in_Byte-j) := '1';
--					end if; 
--				end loop;   
				
				--write(line_num_write, "1111000"); --write the line.
			   write(line_num_write, line_content(1 to Num_Bits_in_Byte*1)); --write the line.
			   writeline (file_write_pointer3,line_num_write); --write the contents into the file.
				write(line_num_write,line_content(Num_Bits_in_Byte*1+1 to Num_Bits_in_Byte*2 )); --write the line.
			   writeline (file_write_pointer2,line_num_write); --write the contents into the file.
				write(line_num_write,line_content(Num_Bits_in_Byte*2+1 to Num_Bits_in_Byte*3 )); --write the line.
			   writeline (file_write_pointer1,line_num_write); --write the contents into the file.
				write(line_num_write,line_content( Num_Bits_in_Byte*3+1 to Num_Bits_in_Byte*4 )); --write the line.
			   writeline (file_write_pointer0,line_num_write); --write the contents into the file.
				
				--Memory(Mem_Address) <= word_value;
				--Mem_Address := Mem_Address +1;
			end loop;
			
			file_close(file_pointer);  --after reading all the lines close the file.  
			
			file_close(file_write_pointer0);
			file_close(file_write_pointer1);
			file_close(file_write_pointer2);
			file_close(file_write_pointer3);
			Block_Mem_Init <='1';
		------------------------------------------
		------------------------------------------
		
     
		--Write to file
		
		elsif(dump'event and dump='1' ) then
			 --Open the file write.txt from the specified location for writing(WRITE_MODE).
			file_open(file_pointer,File_Address_Write,WRITE_MODE);      
			file_open(file_read_pointer0,"MemCon0.dat",READ_MODE);
			file_open(file_read_pointer1,"MemCon1.dat",READ_MODE);
			file_open(file_read_pointer2,"MemCon2.dat",READ_MODE);
			file_open(file_read_pointer3,"MemCon3.dat",READ_MODE);
			  --We want to store binary values from 0000 to 1111 in the file.
			for i in 0 to Mem_Size_in_Word-1 loop 
			
				readline (file_read_pointer0,line_num_read);  --Read the whole line from the file
			  --Read the contents of the line from  the file into a variable.
				READ (line_num_read,line_content_read0); 
			  
				
				readline (file_read_pointer1,line_num_read);  --Read the whole line from the file
			  --Read the contents of the line from  the file into a variable.
				READ (line_num_read,line_content_read1); 
			  				
				readline (file_read_pointer2,line_num_read);  --Read the whole line from the file
			  --Read the contents of the line from  the file into a variable.
				READ (line_num_read,line_content_read2); 
			  
				readline (file_read_pointer3,line_num_read);  --Read the whole line from the file
			  --Read the contents of the line from  the file into a variable.
				READ (line_num_read,line_content_read3); 
				
			  line_content(1 to Num_Bits_in_Byte) :=  line_content_read3; 
			  line_content(1*Num_Bits_in_Byte+1 to 2*Num_Bits_in_Byte) :=  line_content_read2; 
  			  line_content(2*Num_Bits_in_Byte+1 to 3*Num_Bits_in_Byte) :=  line_content_read1;
  			  line_content(3*Num_Bits_in_Byte+1 to 4*Num_Bits_in_Byte) :=  line_content_read0;
  			  
			  write(line_num_write,line_content); --write the line.
			  writeline (file_pointer,line_num_write); --write the contents into the file.
			  
			end loop;
			file_close(file_pointer); --Close the file after writing.
			file_close(file_read_pointer0);
			file_close(file_read_pointer1);
			file_close(file_read_pointer2);
			file_close(file_read_pointer3);
		end if;
	end process;


end Behavioural;