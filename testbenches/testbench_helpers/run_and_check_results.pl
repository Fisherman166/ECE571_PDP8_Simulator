#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

my $input_filename = undef;
my $print_help = undef;

GetOptions(
    "input=s", \$input_filename,
    "h", \$print_help,
);

if($print_help) {
    print "-input   Path to .as or .txt file to use a memory image\n";
    print "-h       Print help information\n";
    exit(0);
}

die "No input filename was given. Exiting\n" unless defined $input_filename;
print "$input_filename\n";

my @split_filename = split(/\./, $input_filename);
print "split filename = @split_filename\n";
if($split_filename[-1] eq 'txt') {
    print "This is Jon's file\n";
}
elsif($split_filename[-1] eq 'as') {
    print "This is Sean's file\n";
}
else {
    die "Input file is neither of filetype .as or .txt. Exiting.\n";
}

#Compile verilog and run it

#Compile vhdl and run it

#Diff the text files

