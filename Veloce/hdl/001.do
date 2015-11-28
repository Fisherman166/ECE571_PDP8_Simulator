
vlib work

.main clear

#vlog -mfcu -dpiheader tbxbindings.h veloce_top.sv +incdir+../../src/ 




vlog -mfcu -sv -dpiheader tbxbindings.h veloce_top.sv  ../../src/Controller.sv ../../src/CPU.sv ../../src/Multiply.sv ../../src/Divide.sv \
                             ../../src/EAE.sv ../../src/Front_Panel.sv ../../src/memory_controller.sv \
                             ../../src/micro_instruction_decoder.sv +incdir+../../src/


vsim veloce_top

#add wave /veloce_top/*

#run
