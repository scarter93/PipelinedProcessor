proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/test_ex/clk
    add wave -position end sim:/test_ex/IR
    add wave -position end sim:/test_ex/op1_test
    add wave -position end sim:/test_ex/op2_test
    add wave -position end sim:/test_ex/result
    add wave -position end sim:/test_ex/PC
    add wave -position end sim:/test_ex/imm
    add wave -position end sim:/test_ex/op2_res
    add wave -position end sim:/test_ex/branch
    add wave -position end sim:/test_ex/IR_o
}


;#Create the work library, which is the default library used by ModelSim
vlib work

;#Compile everything
vcom Execute.vhd
vcom test_ex.vhd

;#Start a simulation session with the test_ex component
vsim -t ps test_ex

force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

AddWaves

run 50ns