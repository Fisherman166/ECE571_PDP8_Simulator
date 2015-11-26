# Generated by vmake version 10.4c

# Define path to each library
LIB_SV_STD = /pkgs/mentor/questa/10.4c/modelsim/modeltech/linux_x86_64/../sv_std
LIB_WORK = work

# Define path to each design unit
SV_STD__std = $(LIB_SV_STD)/_lib.qdb
WORK__Top = $(LIB_WORK)/_lib.qdb
WORK__simulation_tb = $(LIB_WORK)/_lib.qdb
WORK__Multiply = $(LIB_WORK)/_lib.qdb
WORK__micro_instruction_decoder = $(LIB_WORK)/_lib.qdb
WORK__memory_utils = $(LIB_WORK)/_lib.qdb
WORK__memory_controller = $(LIB_WORK)/_lib.qdb
WORK__main_bus = $(LIB_WORK)/_lib.qdb
WORK__Front_Panel = $(LIB_WORK)/_lib.qdb
WORK__EAE = $(LIB_WORK)/_lib.qdb
WORK__Divide = $(LIB_WORK)/_lib.qdb
WORK__CPU_Definitions = $(LIB_WORK)/_lib.qdb
WORK__CPU = $(LIB_WORK)/_lib.qdb
WORK__Controller_sv_unit = $(LIB_WORK)/_lib.qdb
WORK__Controller = $(LIB_WORK)/_lib.qdb
VCOM = vcom
VLOG = vlog
VOPT = vopt
SCCOM = sccom

current_dir = $(shell pwd)

whole_library : $(LIB_WORK)/_lib.qdb

$(LIB_WORK)/_lib.qdb : src/Top.sv testbenches/simulation_tb.sv src/Multiply.sv \
		 src/micro_instruction_decoder.sv /u/koppen2/ECE571/Project/src//memory_utils.pkg \
		 src/memory_controller.sv /u/koppen2/ECE571/Project/src//CPU_Definitions.pkg \
		 src/Front_Panel.sv src/EAE.sv src/Divide.sv \
		 src/CPU.sv src/Controller.sv src/CPU_Definitions.pkg \
		 src/memory_utils.pkg \
		$(SV_STD__std)
	$(VLOG) -sv -source -mfcu src/Controller.sv \
		 src/CPU.sv src/Divide.sv src/EAE.sv src/Front_Panel.sv \
		 src/memory_controller.sv src/micro_instruction_decoder.sv \
		 src/Multiply.sv src/Top.sv src/CPU_Definitions.pkg \
		 src/memory_utils.pkg testbenches/simulation_tb.sv \
		 +incdir+$(current_dir)/src/ \

clean:
	rm -rf $(LIB_WORK) transcript

