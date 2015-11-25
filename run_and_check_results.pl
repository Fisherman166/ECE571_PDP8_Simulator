#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use Cwd;

## Commandline options
##
my $input_filename = undef;
my $compile_sv = undef;
my $compile_c = undef;
my $run_c = undef;
my $compile_vdhl = undef;
my $run_vdhl = undef;
my $print_help = undef;

my $pwd = getcwd;
my $C_PDP_path = 'good_models/C_PDP8/';


GetOptions(
    "f=s",      \$input_filename,
    "c",        \$compile_c,
    "runc",     \$run_c,
    "sv",       \$compile_sv,
    "vhdl",     \$compile_vdhl,
    "runvhdl",  \$run_vdhl,
    "h",        \$print_help,
);

if(defined $print_help) {
    print "-input   Path to .as or .txt file to use a memory image\n";
    print "-c       Compile C simulator\n";
    print "-sv      Compile SystemVerilog simulator\n";
    print "-vhdl    Compile vhdl simulator\n";
    print "-h       Print help information\n";
    exit(0);
}

die "No golden model chosen to run. Exiting.\n" unless (defined $run_c or defined $run_vdhl);

if(defined $compile_c) {
    chdir "$pwd/$C_PDP_path";
    my $return = system('make');
    die "Failed to make C simulator\n" unless (!$return);
    chdir $pwd;
}

if(defined $compile_sv) {
    my $return = system('make');
    die "Failed to make C simulator\n" unless (!$return);
}

if(defined $compile_vdhl) {
    print "Compiling vhdl\n";
}

## The real script starts here
##
my $obj_file = &run_assembler($input_filename);
my $sv_return = system("vsim -c simulation_tb -g INIT_MEM_FILENAME=$obj_file");
die "Sv run failed.\n" unless $sv_return == 0;

my $c_diff = 0;
if(defined $run_c) {
    my $tracename = "memory_trace_golden.txt";
    my $PDP_name = "PDP8_sim";
    my $C_return = system("./$C_PDP_path/$PDP_name $obj_file $tracename");
    die "C PDP failed to run run.\n" unless $C_return == 0;
    $c_diff = &diff_results($C_PDP_path);
}

exit($c_diff);

## Functions start here
##
sub run_assembler() {
    my $filename = shift;

    ##Run the file through the pal assembler
    die "No input filename was given. Exiting\n" unless defined $filename;
    print "$filename\n";
    my @split_filename = split(/\./, $filename);
    die "Filename entered is not an assembly file\n" unless( ($split_filename[-1] eq "as") or ($split_filename[-1] eq "pal") );
    my $assembler_return = system("./testbenches/pal -o $filename");
    die "Assembler failed. Exiting script.\n" unless $assembler_return == 0;

    #Generate the object filename
    pop @split_filename;	#Remove the .as at the end
    my $object_name = join('.', @split_filename);
    $object_name = $object_name . '.obj';

    return $object_name;
}

sub diff_results() {
    my $mem_trace_sv = "memory_trace_sv.txt";
    my $branch_trace_sv = "branch_trace_sv.txt";
    my $valid_memory_sv = "valid_memory_sv.txt";
    my $opcodes_sv = "opcodes_sv.txt";

    my $mem_trace_golden = "memory_trace_golden.txt";
    my $branch_trace_golden = "branch_trace_golden.txt";
    my $valid_memory_golden = "valid_memory_golden.txt";
    my $opcodes_golden = "opcodes_golden.txt";

    my $mem_trace_diff = system("diff -q $mem_trace_sv $mem_trace_golden");
    my $branch_trace_diff = system("diff -q $branch_trace_sv $branch_trace_golden");
    my $valid_memory_diff = system("diff -q $valid_memory_sv $valid_memory_golden");
    my $opcodes_diff = system("diff -q $opcodes_sv $opcodes_golden");

    print "ERROR: Memory trace files do not match. Exiting\n" unless $mem_trace_diff == 0;
    print "ERROR: Branch trace files do not match. Exiting\n" unless $branch_trace_diff == 0;
    print "ERROR: Valid memory files do not match. Exiting\n" unless $valid_memory_diff == 0;
    print "ERROR: Opcode trace files do not match. Exiting\n" unless $opcodes_diff == 0;

    my $retval = $mem_trace_diff + $branch_trace_diff + $valid_memory_diff + $opcodes_diff;
    return $retval;
}

