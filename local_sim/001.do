
vlib work

.main clear

vlog -mfcu -sv ../src/Controller.sv ../src/CPU.sv ../src/Multiply.sv ../src/Divide.sv \
 ../src/EAE.sv ../src/Front_Panel.sv ../src/memory_controller.sv \
 ../src/micro_instruction_decoder.sv ../testbenches/simulation_tb.sv ../src/Top.sv +incdir+../src/

vsim simulation_tb

add wave /simulation_tb/*

run 10 ms
