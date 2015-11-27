configure -emul velocesolo1
reg setvalue synth_tb.btnCpuReset 1
run 10
reg setvalue synth_tb.btnCpuReset 0
run 400
memory upload -file init.mem -instance synth_TB.mem_image
upload -tracedir ./veloce.wave/wave1
memory upload -file Memout.txt -instance synth_TB.mem_image
exit
