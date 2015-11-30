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
	vlog -sv -mfcu ../src/memory_utils.pkg ../src/CPU_Definitions.pkg ../src/Controller.sv ../src/Divide.sv ../src/CPU.sv ../src/EAE.sv ../src/Front_Panel.sv ../src/memory_controller.sv ../src/micro_instruction_decoder.sv ../src/Multiply.sv hdl/veloce_top.sv -dpiheader tbxbindings.h +incdir+../src/
	vlog hvl/PDP8_hvl.cxx
else
	velanalyze -sv -mfcu ../src/memory_utils.pkg ../src/CPU_Definitions.pkg ../src/Controller.sv ../src/Divide.sv ../src/CPU.sv ../src/EAE.sv ../src/Front_Panel.sv ../src/memory_controller.sv ../src/micro_instruction_decoder.sv ../src/Multiply.sv hdl/veloce_top.sv +incdir+../src/
	#Note that the ImageProcessorTestBench.cxx file is passed to velcomp in veloce.config file. That way it knows this is the CoModel and compiles, then later runs on workstation
	velcomp
endif
                                                           
run:
ifeq ($(MODE),puresim)
	vsim -c veloce_top -do "run -all" | tee transcript.puresim
else
	velrun $(RUNTIME_OPTS) | tee transcript.veloce
endif
                                                                                
clean:
	rm -rf edsenv transcript modelsim.ini transcript.veloce veloce.puresim transcript.puresim veloce.map veloce.wave velrunopts.ini work work.veloce veloce.out veloce.med veloce.log work.puresim tbxbindings.h
