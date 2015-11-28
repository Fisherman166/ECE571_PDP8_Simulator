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
my $compile_vhdl = undef;
my $run_vhdl = undef;
my $run_all = undef;
my $print_help = undef;

my $pwd = getcwd;
my $C_PDP_path = 'good_models/C_PDP8/';
my $VHDL_path = 'VHDL/';

GetOptions(
    "f=s",      \$input_filename,
    "c",        \$compile_c,
    "runc",     \$run_c,
    "sv",       \$compile_sv,
    "vhdl",     \$compile_vhdl,
    "runvhdl",  \$run_vhdl,
    "all",      \$run_all,
    "h",        \$print_help,
);

if(defined $print_help) {
    print"Options:\n";
    print "-f       Path to .as file to use a memory image\n";
    print "-c       Compile C simulator\n";
    print "-runc    Run C simulator\n";
    print "-sv      Compile SystemVerilog simulator\n";
    print "-vhdl    Compile vhdl simulator\n";
    print "-runvhdl Run vhdl simulator\n";
    print "-all     Run all tests\n";
    print "-h       Print help information\n";
    exit(0);
}

die "No golden model chosen to run. Exiting.\n" unless (defined $run_c or defined $run_vhdl);

if(defined $compile_c) {
    chdir "$pwd/$C_PDP_path";
    my $return = system('make');
    die "Failed to compile C simulator\n" unless (!$return);
    chdir $pwd;
}

if(defined $compile_vhdl) {
    chdir "$pwd/$VHDL_path";
    my $return = system('make');
    die "Failed to compile VHDL simulator\n" unless (!$return);
    chdir $pwd;
}

if(defined $compile_sv) {
    my $return = system('make');
    die "Failed to compile SystemVerilog simulator\n" unless (!$return);
}

if(defined $run_all) {
    my @simple_tests = glob "$pwd/test_cases/*.as";
    my @nonmicro_tests = glob("$pwd/test_cases/non_micro_tests/*.as");
    my @micro_tests = glob("$pwd/test_cases/micro_tests/*.as");

    #print "Simple: @simple_tests\n\n";
    #print "Nonmicro: @nonmicro_tests\n\n";
    #print "Micro: @micro_tests\n\n";
    #exit(0);

    my $simple_return = &iterate_over_tests(@simple_tests);
    my $nonmicro_return = &iterate_over_tests(@nonmicro_tests);
    my $micro_return = &iterate_over_tests(@micro_tests);
    my $combined_return = $simple_return + $nonmicro_return + $micro_return;
    if($combined_return) {
        print "FAIL: At least one test failed.\n";
        print "Simple test failed\n" if $simple_return;
        print "Nonmicro test failed\n" if $nonmicro_return;
        print "Micro test failed\n" if $micro_return;
        exit($combined_return);
    }
    else {
        print "PASS: All tests passed.\n";
        exit(0);
    }
}

## With no options run this
##
my $normal_return = &compile_and_run($input_filename);
exit($normal_return);

## Functions start here
##
sub iterate_over_tests() {
    my @tests = @_;
    my $return_code = 0;

    foreach my $test (@tests) {
        $return_code += &compile_and_run($test);
        print "Test $test failed.\n" unless $return_code == 0;
    }

    return $return_code;
}

sub compile_and_run() {
    my $obj_filename = shift;
    my $obj_file = &run_assembler($obj_filename);
    my $sv_return = system("vsim -c -do \"run -all\" simulation_tb -g INIT_MEM_FILENAME=$obj_file");
    die "Sv run failed.\n" unless $sv_return == 0;

    my $c_diff = 0;
    my $vhdl_diff = 0;
    if(defined $run_c) {
        my $tracename = "memory_trace_golden.txt";
        my $PDP_name = "PDP8_sim";
        my $C_return = system("./$C_PDP_path/$PDP_name $obj_file $tracename");
        die "C PDP failed to run. Exiting.\n" unless $C_return == 0;
        $c_diff = &diff_results();
    }

    if(defined $run_vhdl) {
        chdir "$pwd/$VHDL_path";
        my $VHDL_return = system("vsim -c -g data_file=$obj_file");
        die "VHDL failed to run. Exiting.\n" unless $VHDL_return == 0;
        $vhdl_diff = &diff_results();
    }

    return ($c_diff + $vhdl_diff);
}

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

