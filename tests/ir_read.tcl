proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/PipelinedProcessor/clk
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
  run 5ns