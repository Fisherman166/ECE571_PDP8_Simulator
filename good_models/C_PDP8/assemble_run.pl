#!/usr/bin/perl

# This script assembles the inputted assembly file by using the pal assembler.
# It then runs the generated object file through our PDP8 simulator
#
# Written by Sean Koppenhafer Feb 5th, 2015
# ECE486 PDP8 simulator - Luis Santiago, Sean Koppenhafer, Steve Pierce, Ken Benderly

use warnings;
use strict;
use Getopt::Long;

my $filename = undef;
my $tracename = "memory_trace.txt";
my $PDP_name = "PDP8_sim";

GetOptions(
				"f=s" => \$filename,
			);

die("Enter the filename of the assembly file you would like to assemble and run with -f \"filename\"\n") unless defined ($filename);

#Check to see if the entered file is of type .as
my @split_filename = split(/\./, $filename);
die "Filename entered is not an assembly file\n" unless($split_filename[-1] eq "as");

#Assemble the input file
my $assemble_return = system("./pal -o $filename");
die "Assembler failed. Exiting script.\n" unless $assemble_return == 0;

#Generate the object filename
pop @split_filename;	#Remove the .as at the end
my $object_name = join('.', @split_filename);
$object_name = $object_name . '.obj';

#Run the object file through our simulator
system("./$PDP_name $object_name $tracename");

exit(0);
