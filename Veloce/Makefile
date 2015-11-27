#This makefile is for the PDP8

#Specify the mode- could be either puresim or veloce
#Always make sure that everything works fine in puresim before changing to veloce

MODE ?= veloce
#MODE ?= puresim

#make all does everything

all: 
ifeq ($(MODE),puresim)
	clean lib compile run
else	
	lib vmwclk compile run view  
endif


lib:
ifeq ($(MODE),puresim)
	vlib work.$(MODE)
	vmap work work.$(MODE) 
else	
	vellib work.$(MODE)
	velmap work work.$(MODE)
endif

#analyze:
#	-velcomp
#	@echo -e "\nMakeInfo: You may get an error informing vmw.clk.generated file is missing if you are running this the first time. \n\tThis is normal, do not panic! You will generate this file using GUI in the next step\n"

     
vmwclk: 
	@echo -e "\nMakeInfo: Now Use velview to create vmw.clk clock/IO specification file. Follow steps from Standalone Flow guide. \n\t\tPress enter to continue....."
	@read
	velview 	
     
     
compile:
ifeq ($(MODE),puresim)
	vlog -sv -mfcu ../src/Controller.sv ../src/CPU.sv ../src/Multiply.sv ../src/Divide.sv ../src/EAE.sv ../src/Front_Panel.sv ../src/memory_controller.sv ../src/micro_instruction_decoder.sv ../src/Top.sv synth_tb.sv +incdir+../src/
else
	velanalyze  -sv -mfcu ../src/Controller.sv ../src/CPU.sv ../src/Multiply.sv ../src/Divide.sv ../src/EAE.sv ../src/Front_Panel.sv ../src/memory_controller.sv ../src/micro_instruction_decoder.sv ../src/Top.sv synth_tb.sv +incdir+../src/velcomp
	velcomp
endif

run:
ifeq ($(MODE),puresim)
	vsim synth_tb -do "run -all" | tee transcript.puresim
else
	#velrun $(RUNTIME_OPTS) | tee transcript.veloce
	velrun -nac -c -do run.do
	@echo -e "\nMakeInfo: Emulation run successful!"
endif


clean:
	rm -rf edsenv transcript modelsim.ini transcript.veloce veloce.puresim transcript.puresim veloce.map veloce.wave velrunopts.ini work work.veloce veloce.out veloce.med veloce.log work.puresim

