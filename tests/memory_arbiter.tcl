
;# This function is responsible for adding to the Waves window 
;# the signals that are relevant to the memory arbiter. This
;# allows the developers to inspect the behavior of the memory  
;# arbiter component as it is being simulated.
proc AddWaves {} {

	;#Add the following signals to the Waves window
	add wave -position end  -radix binary sim:/memory_arbiter/clk
	add wave -position end  -radix binary sim:/memory_arbiter/reset
  
  ;#These signals will be contained in a group named "Port 1"
	add wave -group "Port 1"  -radix hex sim:/memory_arbiter/addr1\
                            -radix hex sim:/memory_arbiter/data1\
                            -radix binary sim:/memory_arbiter/re1\
                            -radix binary sim:/memory_arbiter/we1\
                            -radix binary sim:/memory_arbiter/busy1
                            
  ;#These signals will be contained in a group named "Port 2"
  add wave -group "Port 2"  -radix hex sim:/memory_arbiter/addr2\
                            -radix hex sim:/memory_arbiter/data2\
                            -radix binary sim:/memory_arbiter/re2\
                            -radix binary sim:/memory_arbiter/we2\
                            -radix binary sim:/memory_arbiter/busy2
  
  ;#These signals will be contained in a group named "Main Memory"
  add wave -group "Main Memory" -radix binary sim:/memory_arbiter/mm_we\
                                -radix binary sim:/memory_arbiter/mm_wr_done\
                                -radix binary sim:/memory_arbiter/mm_re\
                                -radix binary sim:/memory_arbiter/mm_rd_ready\
                                -radix hex sim:/memory_arbiter/mm_address\
                                -radix hex sim:/memory_arbiter/mm_data

  ;#Set some formating options to make the Waves window more legible
	configure wave -namecolwidth 250
	WaveRestoreZoom {0 ns} {8 ns}
}

;#Generates a clock of period 1 ns on the clk input pin of the memory arbiter.
proc GenerateCPUClock {} { 
	force -deposit /memory_arbiter/clk 0 0 ns, 1 0.5 ns -repeat 1 ns
}

;#The following functions "place" a read or write on the inputs of the
;#selected port. However, they do not start the operations right away. This is 
;#because the user might want to place another read or write operation on the
;#other port at the same time. Once all operations have been set, use the
;#WaitForAnyPort or WaitForAllPorts functions to move time forward until any or
;#all the operations complete.
proc PlaceRead {port addr} {
  force -deposit /memory_arbiter/addr$port 16#$addr 0 0
  force -deposit /memory_arbiter/data$port "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" 0
  force -deposit /memory_arbiter/we$port 0 0
  force -deposit /memory_arbiter/re$port 1 0
  run 0 ;#Force signals to update right away
}

proc PlaceWrite {port addr data} {
  force -deposit /memory_arbiter/addr$port 16#$addr 0 0
  force -deposit /memory_arbiter/data$port 16#$data 0 0
  force -deposit /memory_arbiter/we$port 1 0
  force -deposit /memory_arbiter/re$port 0 0
  run 0 ;#Force signals to update right away
}

;#Moves time forward until either the operation on Port 1 or Port 2 is complete.
;#An operation is considered complete on a port when the port's busy signal goes low.
proc WaitForAnyPort {} {
  ;# Only wait if there is a transaction pending
  if {[exa /memory_arbiter/re1] == 1 || [exa /memory_arbiter/re2] ||
      [exa /memory_arbiter/we1] == 1 || [exa /memory_arbiter/we2]} {
    
    run 1 ns
    
    ;# Wait for at least one port to be free 
    while {[exa /memory_arbiter/busy1] == 1 && [exa /memory_arbiter/busy2] == 1} {
      run 1 ns
    }
    
    ResetEnableSignalsIfReady
    run 0
  }
}

;#Moves time forward until the operations on both Port 1 and Port 2 are complete.
;#An operation is considered complete on a port when the port's busy signal goes low.
proc WaitForAllPorts {} {
  ;# Only wait if there is a transaction pending
  if {[exa /memory_arbiter/re1] == 1 || [exa /memory_arbiter/re2] ||
      [exa /memory_arbiter/we1] == 1 || [exa /memory_arbiter/we2]} {
      
    run 1 ns
    
    ;# Wait for all ports to be free 
    while {[exa /memory_arbiter/busy1] == 1 || [exa /memory_arbiter/busy2] == 1} {
      ResetEnableSignalsIfReady
      run 1 ns
    }
    
    ResetEnableSignalsIfReady
    run 0
  }
}

;#Function used to reset the read enable and write enable signals to low
;#once a read or write operation is complete.
proc ResetEnableSignalsIfReady {} {
  ;# Reset the re and we signals for the ports that just finished their transaction
  if {[exa /memory_arbiter/busy1] == 0} {
    force -deposit /memory_arbiter/re1 0 0
    force -deposit /memory_arbiter/we1 0 0
  }
  if {[exa /memory_arbiter/busy2] == 0} {
    force -deposit /memory_arbiter/re2 0 0
    force -deposit /memory_arbiter/we2 0 0
  }
}

;#This function compiles the memory arbiter and its submodules.
;#It initializes a memory arbiter simulation session, and
;#sets up the Waves window to contain useful input/output signals
;#for debugging.
proc InitMemoryArbiter {} {
  ;#Create the work library, which is the default library used by ModelSim
  vlib work
  
  ;#Compile the memory arbiter and its subcomponents
  vcom lib/Memory_in_Byte.vhd
  vcom lib/Main_Memory.vhd
  vcom lib/memory_arbiter_lib.vhd
  vcom memory_arbiter.vhd
  
  ;#Start a simulation session with the memory_arbiter component
  vsim memory_arbiter
	
  ;#Add the memory_arbiter's input and ouput signals to the waves window
  ;#to allow inspecting the module's behavior
	AddWaves
  
  force -deposit /memory_arbiter/reset 1 0 ns, 0 1 ns
  force -deposit /memory_arbiter/addr1 0 0
  force -deposit /memory_arbiter/data1 "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" 0
  force -deposit /memory_arbiter/re1 0 0
  force -deposit /memory_arbiter/we1 0 0
  force -deposit /memory_arbiter/addr2 0 0
  force -deposit /memory_arbiter/data2 "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" 0
  force -deposit /memory_arbiter/re2 0 0
  force -deposit /memory_arbiter/we2 0 0
  
  ;#Generate a CPU clock
	GenerateCPUClock
  
  run 1 ns
}

;# This testbench verifies that the memory arbiter
;# prioritizes Port1 over Port2 when two requests
;# are made at the same time.
proc TestPort1Priority {} {
  ;# Initiate a write to the same address on both ports
  PlaceWrite 1 0 12345678
  PlaceWrite 2 0 FFFFFFFF
  
  ;# Wait for the first operation to complete
  WaitForAnyPort
  
  ;# The memory arbiter should have done the write on Port 1 first,
  ;# so verify that memory address 0 contains 12345678
  set memoryContent [ReadMemoryWord 0]
  set testResult [expr $memoryContent == 0x12345678]
  
  WaitForAllPorts
  
  ;# Verify that Port 2's write finally took place
  set memoryContent [ReadMemoryWord 0]
  set testResult [expr $testResult && $memoryContent == 0xFFFFFFFF]
  
  ;# Wait for all operations to complete before returning
  run 1 ns
  
  return $testResult
}

;# This testbench verifies that the memory arbiter
;# prioritizes Port1 over Port2 when two requests
;# are made at the same time, and as long as requests
;# on Port 1 keep coming.
proc TestPort1StreamPriority {} {
  
  ;# Initiate a write to the same address on both ports
  PlaceWrite 2 0 FFFFFFFF
  
  ;# Keep writing on Port 1, and verify that Port 2's
  ;# write never completes.
  for {set i 0} {$i < 9} {incr i} {
		PlaceWrite 1 0 12345678
    WaitForAnyPort
    
    if { [expr [ReadMemoryWord 0] != 0x12345678]} {
      WaitForAllPorts
      run 1 ns
      return 0
    }
	}
  
  WaitForAllPorts
  
  ;# Verify that Port 2's write finally took place
  set memoryContent [ReadMemoryWord 0]
  set testResult [expr $memoryContent == 0xFFFFFFFF]
  
  ;# Wait for all operations to complete before returning
  run 1 ns
  
  return $testResult
}

;# This testbench verifies that Port 1 waits for a previously
;# started Port 2 request to finish before taking control of
;# the main memory.
proc TestPort1WaitForPort2 {} {
  ;# Start a write on Port 2
  PlaceWrite 2 0 AAAAAAAA
  run 1 ns
  
  ;# Start a read on Port 1 while Port 2's write is in progress
  PlaceRead 1 0
  WaitForAnyPort
  
  ;# Port 2 should have finished its read. Make sure that Port 1 hasn't started it read yet.
  set testResult [expr [exa /memory_arbiter/busy1] == 1 && [exa /memory_arbiter/busy2] == 0]
  
  ;# Finish up all operations
  WaitForAllPorts
  run 1 ns
  
  set testResult [expr $testResult && [ReadMemoryWord 0] == 0xAAAAAAAA]
  
  return $testResult
}

;# Utility function used to examine a word at a given address in main memory.
proc ReadMemoryWord {addr} {
  set wordIndex [expr $addr / 4]
  set byte0 [exa -radix unsigned /memory_arbiter/main_memory/Block0/Memory($wordIndex)]
  set byte1 [exa -radix unsigned /memory_arbiter/main_memory/Block1/Memory($wordIndex)]
  set byte2 [exa -radix unsigned /memory_arbiter/main_memory/Block2/Memory($wordIndex)]
  set byte3 [exa -radix unsigned /memory_arbiter/main_memory/Block3/Memory($wordIndex)]
  
  set word [format %u [expr ($byte3 << 24) | ($byte2 << 16) | ($byte1 << 8) | $byte0]]
  
  return $word
}

InitMemoryArbiter
;#TestPort1Priority
TestPort1StreamPriority
;#TestPort1WaitForPort2