
vlib work

################################################################################
## Source Files
################################################################################

.main clear


vlog Controller.sv
vlog CPU.sv
vlog +define+CPU_DEF_PKG Multiply.sv
vlog +define+CPU_DEF_PKG Divide.sv
vlog +define+CPU_DEF_PKG EAE.sv
vlog +define+CPU_DEF_PKG Front_Panel.sv
vlog +define+CPU_DEF_PKG memory_controller.sv
vlog +define+CPU_DEF_PKG micro_instruction_decoder.sv
vlog +define+CPU_DEF_PKG TestBench001.sv
vlog +define+CPU_DEF_PKG Top.sv



vsim TestBench001

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label Clock /TestBench001/clk
add wave -noupdate -label Reset /TestBench001/btnCpuReset
add wave -noupdate -label {Board LED's} -radix binary -radixshowbase 0 /TestBench001/led
add wave -noupdate -label {Boeard Switches} -radix octal -radixshowbase 0 /TestBench001/sw
add wave -noupdate -label {Display Select Button} -radix binary -radixshowbase 0 /TestBench001/Display_Select
add wave -noupdate -label {Step Button} -radix binary -radixshowbase 0 /TestBench001/Step
add wave -noupdate -label {Deposit Button} -radix binary -radixshowbase 0 /TestBench001/Deposit
add wave -noupdate -label {Load PC Button} -radix binary -radixshowbase 0 /TestBench001/Load_PC
add wave -noupdate -label {Load AC Button} -radix binary -radixshowbase 0 /TestBench001/Load_AC
add wave -noupdate -label Registers -radix octal -childformat {{/TestBench001/TOP0/CPU0/curr_reg.ac -radix octal} {/TestBench001/TOP0/CPU0/curr_reg.lk -radix octal} {/TestBench001/TOP0/CPU0/curr_reg.ir -radix octal -childformat {{{[11]} -radix octal} {{[10]} -radix octal} {{[9]} -radix octal} {{[8]} -radix octal} {{[7]} -radix octal} {{[6]} -radix octal} {{[5]} -radix octal} {{[4]} -radix octal} {{[3]} -radix octal} {{[2]} -radix octal} {{[1]} -radix octal} {{[0]} -radix octal}}} {/TestBench001/TOP0/CPU0/curr_reg.mq -radix octal} {/TestBench001/TOP0/CPU0/curr_reg.pc -radix octal} {/TestBench001/TOP0/CPU0/curr_reg.mb -radix octal} {/TestBench001/TOP0/CPU0/curr_reg.ea -radix octal}} -radixshowbase 0 -expand -subitemconfig {/TestBench001/TOP0/CPU0/curr_reg.ac {-color White -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/CPU0/curr_reg.lk {-color Gray60 -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/CPU0/curr_reg.ir {-color {Cornflower Blue} -height 15 -radix octal -childformat {{{[11]} -radix octal} {{[10]} -radix octal} {{[9]} -radix octal} {{[8]} -radix octal} {{[7]} -radix octal} {{[6]} -radix octal} {{[5]} -radix octal} {{[4]} -radix octal} {{[3]} -radix octal} {{[2]} -radix octal} {{[1]} -radix octal} {{[0]} -radix octal}} -radixshowbase 0} {/TestBench001/TOP0/CPU0/curr_reg.ir[11]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/TestBench001/TOP0/CPU0/curr_reg.ir[10]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/TestBench001/TOP0/CPU0/curr_reg.ir[9]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/TestBench001/TOP0/CPU0/curr_reg.ir[8]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/TestBench001/TOP0/CPU0/curr_reg.ir[7]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/TestBench001/TOP0/CPU0/curr_reg.ir[6]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/TestBench001/TOP0/CPU0/curr_reg.ir[5]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/TestBench001/TOP0/CPU0/curr_reg.ir[4]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/TestBench001/TOP0/CPU0/curr_reg.ir[3]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/TestBench001/TOP0/CPU0/curr_reg.ir[2]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/TestBench001/TOP0/CPU0/curr_reg.ir[1]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} {/TestBench001/TOP0/CPU0/curr_reg.ir[0]} {-color {Cornflower Blue} -radix octal -radixshowbase 0} /TestBench001/TOP0/CPU0/curr_reg.mq {-color Gold -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/CPU0/curr_reg.pc {-color {Spring Green} -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/CPU0/curr_reg.mb {-color Magenta -height 15 -radix octal -radixshowbase 0} /TestBench001/TOP0/CPU0/curr_reg.ea {-color Cyan -height 15 -radix octal -radixshowbase 0}} /TestBench001/TOP0/CPU0/curr_reg
add wave -noupdate /TestBench001/TOP0/CPU0/SM0/cpu/ea_reg_8_to_15
add wave -noupdate -color White /TestBench001/TOP0/CPU0/SM0/Curr_State
add wave -noupdate -color Gray50 /TestBench001/TOP0/CPU0/fsm/AC_ctrl
add wave -noupdate -color Gray50 /TestBench001/TOP0/CPU0/fsm/LK_ctrl
add wave -noupdate -color Gray50 /TestBench001/TOP0/CPU0/fsm/MQ_ctrl
add wave -noupdate -color Gray50 /TestBench001/TOP0/CPU0/fsm/PC_ctrl
add wave -noupdate -color Gray50 /TestBench001/TOP0/CPU0/fsm/IR_ctrl
add wave -noupdate -color Gray50 /TestBench001/TOP0/CPU0/fsm/EA_ctrl
add wave -noupdate -color Gray50 /TestBench001/TOP0/CPU0/fsm/MB_ctrl
add wave -noupdate -color Gray50 /TestBench001/TOP0/CPU0/fsm/WD_ctrl
add wave -noupdate -color Gray50 /TestBench001/TOP0/CPU0/fsm/AD_ctrl
add wave -noupdate -color Gray50 /TestBench001/TOP0/CPU0/fsm/DO_ctrl
add wave -noupdate -color Gray50 /TestBench001/TOP0/CPU0/fsm/DT_ctrl
add wave -noupdate -divider -height 20 MEMORY
add wave -noupdate -color Gold -radix octal -radixshowbase 0 /TestBench001/TOP0/CPU0/mem/address
add wave -noupdate -color {Cornflower Blue} -radix octal -radixshowbase 0 /TestBench001/TOP0/CPU0/mem/read_data
add wave -noupdate -color {Cornflower Blue} -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/mem/read_enable
add wave -noupdate -color White -radix octal -radixshowbase 0 /TestBench001/TOP0/CPU0/mem/write_data
add wave -noupdate -color White -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/mem/write_enable
add wave -noupdate -color Magenta -radix binary -radixshowbase 0 /TestBench001/TOP0/CPU0/mem/mem_finished
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2564079 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 369
configure wave -valuecolwidth 194
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {2563865 ns} {2564193 ns}

run 10 ms
