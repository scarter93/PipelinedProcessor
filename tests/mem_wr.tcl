proc AddWaves {} {
    ;#Add waves we're interested in to the Wave window
    add wave -position end sim:/mem_wr_tb/clk
    add wave -group "Main Memory" -radix hex sim:/mem_wr_tb/memory_arbiter_t/main_memory/Block0/Memory\
                                  -radix hex sim:/mem_wr_tb/memory_arbiter_t/main_memory/Block1/Memory\
                                  -radix hex sim:/mem_wr_tb/memory_arbiter_t/main_memory/Block2/Memory\
                                  -radix hex sim:/mem_wr_tb/memory_arbiter_t/main_memory/Block3/Memory

    add wave -group "Memory Arbiter" -position end -radix hex sim:/mem_wr_tb/memory_arbiter_t/*

    add wave -group "Memory" -radix hex sim:/mem_wr_tb/dut/*

    add wave -position end -radix hex sim:/mem_wr_tb/ID_data

    add wave -position end -radix hex sim:/mem_wr_tb/mem_data
}
  ;#Create the work library, which is the default library used by ModelSim
  vlib work

  ;#Compile the memory arbiter and its subcomponents
  vcom lib/Memory_in_Byte.vhd
  vcom lib/Main_Memory.vhd
  vcom lib/memory_arbiter_lib.vhd
  vcom memory_arbiter.vhd
  vcom Memory.vhd
  vcom -check_synthesis tests/mem_wr_tb.vhd
  ;#Start a simulation session with the memory_arbiter component
  vsim mem_wr_tb
  AddWaves
  force -deposit {/mem_wr_tb/clk} 0 0 ns, 1 0.5 ns -repeat 1 ns
  ;#Add the memory_arbiter's input and ouput signals to the waves window
  ;#to allow inspecting the module's behavior
  force -deposit /mem_wr_tb/memory_arbiter_t/mm_initialize 1 0ns, 0 1ns
  force -deposit /mem_wr_tb/memory_arbiter_t/busy1 0 0

  run 31ns
