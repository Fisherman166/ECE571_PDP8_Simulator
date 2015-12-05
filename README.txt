/******************************************************************************
** INTRODUCTION
******************************************************************************/

This project has a few different build flows. There is a build flow for
simulation and emulation. There is also a build flow that is required to make
the golden models. We have made most of this fairly simple and streamlined,
but there is still a few steps you have to walk through.

**NOTE: For some reason the simulation version of the SystemVerilog and the C
version golden model don't work very well on the veloce workstation. Running
these builds on eve.ece.pdx.edu works much better.

/******************************************************************************
** SIMULATION BUILD AND RUN FLOW
******************************************************************************/
First, I'll walk through all of the steps to manually build and run both the
SystemVerilog project and the golden model C project. After that, I will
explain how to use the script I have written to accomplish this task faster.

-------------------------------------------------------------------------------

In the root folder of our project there is a makefile that builds the
simulation version of the SystemVerilog project. To build, simply type:

make

To build the C golden model, cd to good_models/C_PDP8/ and run make again:

make

Now both the SystemVerilog project and the C project have been compiled. Time
to move onto running a test. cd back to the root folder of our project.

-------------------------------------------------------------------------------

Our test cases are in the test_cases folder within the root of our project.
Inside of the test_cases folder you will find some .as files and more folders.
All .as files are a test case that can be assembled and ran on our Project.

Before we can run a test, we need to assemble the .as file. In
PROJECT_ROOT/testbenches/ there is an assembler named pal. This is the
assembler we used to assemble our test cases. For an example, this is how I
would assemble the add01.as test from the root of our project directory.

./testbenches/pal -o test_cases/add01.as

The assembler generators a .obj file. In test_cases/ there should now be a 
add01.obj file. This is the file that will be passed into both the
SystemVerilog and the C project ot run the test.

-------------------------------------------------------------------------------

Now we are ready to run the two models. First, the SystemVerilog model. Make
sure you are in the root of our project. We have a paramaterized string called
INIT_MEM_FILENAME that you can use to point to the .obj file you want to run.
The top level module in our project is called simulation_tb. To run the
add01.obj we assembled above, run this command:

vsim -c -do "run -all" simulation_tb -g INIT_MEM_FILENAME=test_cases/add01.obj

If you do a ls, you should see these four files: branch_trace_sv.txt,
opcodes_sv.txt, memory_trace_sv.txt and valid_memory_sv.txt.

The C model is similar. The syntax for running it is:

PDP8_sim <path to obj file> <memory_trace_filename>

To run the add01.obj test we assembled above, run this from the root of the
project (I always choose memory_trace_golden.txt for the memory_trace
filename):

./good_models/C_PDP8/PDP8_sim test_cases/add01.obj memory_trace_golden.txt

If you do a ls, you should see these four files: branch_trace_golden.txt,
opcodes_golden.txt, memory_trace_golden.txt and valid_memory_golden.txt.

-------------------------------------------------------------------------------

At this point you are all done. You can use your favorite method of doing a
diff between the *_sv.txt files and the *_golden.txt files. I would go with
either vimdiff or diff -q.

-------------------------------------------------------------------------------

To make all of this simpiler, you can just use a perl script that I wrote to
automate all of this. It can build both the SV and C projects, assemble the
test files, run the test case on both projects, and diff the results.
The script is called run_and_check_results.pl and it's in the root of the 
project. The options for the script are as follows (vhdl functionality
was never fully added):

Options:
-f       Path to .as file to use as a memory image
-c       Compile C simulator
-runc    Run C simulator
-sv      Compile SystemVerilog simulator
-vhdl    Compile vhdl simulator
-runvhdl Run vhdl simulator
-all     Run all tests
-h       Print help information

For example, if you want to compile both the sv and the C model AND run all of
our test cases, it would look something like this (from the root of our
project):

./run_and_check_results.pl -c -sv -runc -all

/******************************************************************************
** EMULATION BUILD AND RUN FLOW
******************************************************************************/
