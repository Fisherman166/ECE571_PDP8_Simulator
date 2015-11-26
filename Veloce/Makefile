#This makefile is for the PDP8

#Specify the mode- could be either puresim or veloce
#Always make sure that everything works fine in puresim before changing to veloce

#MODE ?= veloce
MODE ?= puresim

#make all does everything
all: clean lib compile run

lib:
ifeq ($(MODE),puresim)
	vlib work.$(MODE)
	vmap work work.$(MODE) 
else	
	vellib work.$(MODE)
	velmap work work.$(MODE)
endif


compile:
ifeq ($(MODE),puresim)
	vlog ../src/Controller.sv ../src/CPU.sv ../src/Multiply.sv ../src/Divide.sv ../src/EAE.sv ../src/Front_Panel.sv ../src/memory_controller.sv ../src/micro_instruction_decoder.sv ../src/Top.sv
	vlog synth_tb.sv 
else
	#velanalyze ../Packages.sv ../CellProcessor_int.sv ../CellProcessor.sv hdl/veloce_top.sv
	#Note that the ImageProcessorTestBench.cxx file is passed to velcomp in veloce.config file. That way it knows this is the CoModel and compiles, then later runs on workstation
	#velcomp
endif
                                                           
run:
ifeq ($(MODE),puresim)
	vsim -c synth_tb -do "run -all" | tee transcript.puresim
else
	#velrun $(RUNTIME_OPTS) | tee transcript.veloce
endif
                                                                                
clean:
	rm -rf edsenv transcript modelsim.ini transcript.veloce veloce.puresim transcript.puresim veloce.map veloce.wave velrunopts.ini work work.veloce veloce.out veloce.med veloce.log work.puresim

