proc AddWaves {} {
    ;#Add waves we're interested in to the Wave window
    add wave -position end sim:/PipelinedProcessor/clk
    add wave -position end -radix hex /pipelinedprocessor/memory_arbiter_t/main_memory/Block0/Memory
    add wave -position end -radix hex  /pipelinedprocessor/memory_arbiter_t/main_memory/Block1/Memory
    add wave -position end -radix hex  /pipelinedprocessor/memory_arbiter_t/main_memory/Block2/Memory
    add wave -position end -radix hex  /pipelinedprocessor/memory_arbiter_t/main_memory/Block3/Memory
}
  ;#Create the work library, which is the default library used by ModelSim
  vlib work
  
#  ;#Compile the memory arbiter and its subcomponents
  vcom lib/Memory_in_Byte.vhd
  vcom lib/Main_Memory.vhd
  vcom lib/memory_arbiter_lib.vhd
  vcom memory_arbiter.vhd
  vcom Fetch.vhd
  vcom Decode.vhd
  vcom Execute.vhd
  vcom Memory.vhd
  vcom WriteBack.vhd
  vcom -check_synthesis PipelinedProcessor.vhd
  ;#Start a simulation session with the memory_arbiter component
  vsim PipelinedProcessor
  AddWaves
  force -deposit {/PipelinedProcessor/clk} 0 0 ns, 1 0.5 ns -repeat 1 ns
  ;#Add the memory_arbiter's input and ouput signals to the waves window
  ;#to allow inspecting the module's behavior
  force -deposit /pipelinedprocessor/memory_arbiter_t/mm_initialize 1 0
  run 5ns
  force -deposit /pipelinedprocessor/memory_arbiter_t/mm_initialize 0 0
  run 5ns