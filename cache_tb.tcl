proc AddWaves {} {
    ;#Add waves we're interested in to the Wave window
    add wave -position end sim:/cache_tb/*
    add wave -group "cache" -radix hex sim:/cache_tb/dut/*
    add wave -group "cache" -radix hex sim:/cache_tb/dut/cache_blks
}

;#Create the work library, which is the default library used by ModelSim
  vlib work
;#compile
vcom cache.vhd
vcom cache_tb.vhd

vsim cache_tb

AddWaves

force -deposit {/cache_tb/clk_t} 0 0 ns, 1 0.5 ns -repeat 1 ns


run 50ns