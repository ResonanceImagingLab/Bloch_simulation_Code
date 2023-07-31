#!/usr/bin/perl -w

# Written by Christopher Rowley
# Goal is to normalize the B1 image so the middle value is around 1 

# requires dual MT, pos MT, neg MT, and a noMT image obtained with a higher flip angle. 
####################################################
# location
# /data_/tardiflab/chris/development/2019-03-20-ihmt/ihMT_calc.pl
#
###############################
require 5.001;
use Getopt::Tabular;
use MNI::Startup qw(nocputimes);
use MNI::Spawn;
use MNI::FileUtilities qw(check_output_dirs);
use File::Basename;
use List::MoreUtils qw(zip);
use Cwd;
if($0 =~ /[\/A-Za-z_0-9-]+\/([A-Za-z0-9_-]+\.pl)/) {$program = $1;}	#program name without path
$Usage = <<USAGE;

Compute B1 maps

Usage: $program <B1_fieldmap> <B0_field> <ref_img> <output_base>


USAGE
#-help for options

#@args_table = (
#);

Getopt::Tabular::SetHelp ($Usage, '');

#GetOptions(\@args_table, \@ARGV, \@args) || exit 1;
die $Usage unless $#ARGV >=0;

if($ARGV[0]=~/help/i){print $Usage; exit(1);}

################ MY CODE ##############
# specify inputs
$output_base=pop(@ARGV);
$no_MT=pop(@ARGV);
$B0_field=pop(@ARGV);
$B1=pop(@ARGV);

## normalize the b1map 
$a_b1=80; #`mincinfo -attvalue acquisition:flip_angle $B1`;chomp($a_b1); # usually is 80 in case it gets removed from header
$normb1=$B1."_normalized.mnc";

print "\n--FA in degrees for B1map: $a_b1\n\n";

`minccalc -float -nocheck_dimensions -expr "clamp(A[0] / ($a_b1 * 10),0,3)" $B1 $normb1 `;


## resample the b1map to the same dimensions at the mt image
$b1field_rs=$output_base."_b1field.mnc";
`mincresample -clobber -float -like $no_MT -fill $normb1 $b1field_rs`; 

$b0field_rs=$output_base."_b0field.mnc";
`mincresample -clobber -float -like $no_MT -fill $B0_field $b0field_rs`; 
#
#
#
#
#
#
#
#
##




