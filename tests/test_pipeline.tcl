proc AddWaves {} {
  ;#Add waves we're interested in to the Wave window
  add wave -group "Registers" -radix dec sim:/pipelinedprocessor/decode/reg
  add wave -position end sim:/PipelinedProcessor/clk
  add wave -group "Main Memory" -radix hex /pipelinedprocessor/memory_arbiter_t/main_memory/Block0/Memory\
                                -radix hex /pipelinedprocessor/memory_arbiter_t/main_memory/Block1/Memory\
                                -radix hex /pipelinedprocessor/memory_arbiter_t/main_memory/Block2/Memory\
                                -radix hex /pipelinedprocessor/memory_arbiter_t/main_memory/Block3/Memory\
                                -radix dec /pipelinedprocessor/memory_arbiter_t/main_memory/*

  add wave -group "Cache" -radix hex sim:/pipelinedprocessor/cache/*
                       
  add wave -group "Fetch" -radix dec sim:/pipelinedprocessor/fetch/PC_out\
                          -radix dec sim:/pipelinedprocessor/fetch/PC\
                          -radix dec sim:/pipelinedprocessor/fetch/IR_pc\
                          -radix dec sim:/pipelinedprocessor/fetch/PC_old\
                          -radix hex sim:/pipelinedprocessor/fetch/reset\
                          -radix hex sim:/pipelinedprocessor/fetch/IR\
                          -radix hex sim:/pipelinedprocessor/fetch/IR_data\
                          -radix hex sim:/pipelinedprocessor/fetch/IR_checked\
                          -radix bin sim:/pipelinedprocessor/fetch/IR_busy\
                          -radix dec sim:/pipelinedprocessor/fetch/IR_re\
                          -radix dec sim:/pipelinedprocessor/fetch/branch_taken\
                          -radix dec sim:/pipelinedprocessor/fetch/branch_pc\
                          -radix dec sim:/pipelinedprocessor/fetch/hazard\
                          -radix hex sim:/pipelinedprocessor/fetch/IR_log\
                          -radix unsigned sim:/pipelinedprocessor/fetch/cycles_to_wait\
                          -radix unsigned sim:/pipelinedprocessor/fetch/hazard_resume_delay

  add wave -group "Fetch" -group "Hazard Detection" -radix dec sim:/pipelinedprocessor/fetch/hazard_detect/*

  add wave -group "Decode" -radix dec sim:/pipelinedprocessor/decode/*

  add wave -group "Execute" -radix dec sim:/pipelinedprocessor/execute_t/*

  add wave -group "Memory" -radix dec sim:/pipelinedprocessor/memory_t/*

  add wave -group "Write Back" -radix dec sim:/pipelinedprocessor/write_back_t/*

  add wave -group "Memory Arbiter" -radix bin sim:/pipelinedprocessor/memory_arbiter_t/*

  add wave -group "Main Memory" sim:/pipelinedprocessor/memory_arbiter_t/main_memory/*
}

;#Create the work library, which is the default library used by ModelSim
vlib work

;#Compile the memory arbiter and its subcomponents
vcom lib/Memory_in_Byte.vhd
vcom lib/Main_Memory.vhd
vcom lib/memory_arbiter_lib.vhd
vcom memory_arbiter.vhd
vcom HazardDetection.vhd
vcom cache.vhd
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
force -deposit /pipelinedprocessor/memory_arbiter_t/mm_initialize 1 0ns, 0 1ns
# force -deposit /pipelinedprocessor/memory_arbiter_t/busy1 0 0

force -deposit /pipelinedprocessor/reset 1 0ns, 0 2.25ns

set NumericStdNoWarnings 1

run 500 ns

wave zoom full