#!/usr/bin/perl -w
use strict;
#use warnings;

# ROOT file of simulation runs
my $Root = $ARGV[0];
# Runs = Runs file for each of the time series simulation
my $runs = $ARGV[1];

# Check file completion i.e. if time series runs completely finished simulation
# Get number of fenders and mooring lines from *.dat file
# Check solution completion from *.lis file
# Get statistics and write to stats file
my $num_mooring_lines;
my $num_Fenders;

open FHIN_RUNS, "$runs";
while (<FHIN_RUNS>){
    my $line = $_;
    my @tmp = split /\t/,$line;
    if ($line =~ m/\d\d\d/){
        my $file = $Root."_"."DRFT"."_".$tmp[0];
        my $check = &Check_Runs($file);
        my @tmp = &Get_Model_Data($file);
        $num_mooring_lines = $tmp[0];
        $num_Fenders = $tmp[1];
        if ($check == 1){
            &Get_Stats($file,$num_mooring_lines,$num_Fenders);
        }
        elsif ($check == 0){
            open FHOUT_STATS, "> $file"."_STAT.csv";
            print FHOUT_STATS "NO SOLUTION";
            close FHOUT_STATS;
        };
    }
}
close FHIN_RUNS;


sub Check_Runs(){
    # Open all drift files and look for non-convergance
    my $inputFile = $_[0];
    my $flag = 1;
    open TMPFHIN, "< $inputFile.LIS";
    while(<TMPFHIN>){
        my $line = $_;
        if ($line =~ m/TERMINATED WITH ERRORS/){
            $flag = 0;
        }
    }
    return $flag;
}

sub Get_Model_Data(){
    # Open *.dat file and find number of mooring lines and fenders
    my $fileName = $_[0];
    my $num_lines = 0;
    my $num_fends = 0;
    open FHIN_DAT, "< $fileName.dat";
    while (<FHIN_DAT>){
        my $line = $_;
        if ($line =~ m/NLIN/){
            $num_lines = $num_lines + 1;
        }
        elsif ($line =~ m/FEND/){
            $num_fends = $num_fends +1;
        }
    }
    close FHIN_DAT;
    my @return = ($num_lines,$num_fends);
    return @return;
}

sub Get_Stats(){
    # If file not failed, extract statistics into *.csv file
    # See extractTimeSeries.pl
    my $inputFile = $_[0];
    my $num_mooring_lines = $_[1];
    my $num_fenders = $_[2];
    
    # Define all variables
    my @POSITION;
    my @SLOW_POSITION;
    my @WAVE_POSITION;
    my @LINE_TENSION;
    my @tmpLineTension;
    my @FENDER_COMPRESSION;
    my @tmpFenderCompression;
    my @FENDER_DEFLECTION;
    my @tmpFenderDeflection;
    my @statsStart;
    my @probsStart;
    my @tmpProbs;
    my @tmpRange;
    my @tmpAll;
    
    # Open *.lis file for processing
    open FHIN_STATS, "< $inputFile".".lis";
    # Open stats file for printing
    open FHOUT_STATS, "> $inputFile"."_STAT.csv";
    
    my $ii = 0;
    # Loop through input file and read lines for indexes of required arrays
    while (<FHIN_STATS>){
	my $line = $_;
        if ($line =~ m/^\s+(?:\*.){4}S\sT\sA\sT\sI\sS\sT\sI\sC\sS\s+R\sE\sS\sU\sL\sT\sS\s(?:\*.){4}\n/){
            push @statsStart,$ii;
        }
        elsif ($line =~ m/^\s+PROBABILITY\s+RANGE/){
            push @probsStart,$ii;
        }
	$ii = $ii + 1;
    };
    close FHIN_STATS;
    open FHIN_STATS, "< $inputFile".".lis";
    $ii = 0;
    my $jj = 0;
    while (<FHIN_STATS>){
	my $line = $_;
	if (($ii > $statsStart[$jj]) and ($ii < ($probsStart[$jj] - 2))){
	    if ($line !~ m/(?:(?:^$)|(?:^\s+(?:-){2})|(?:^\s+-\s))/mx){
	        if ($line =~ m/^\s+STRUCTURE\s+\d\s+(\s+.+)/mx){
	            print FHOUT_STATS &rtrim(&ltrim($1));
	            print FHOUT_STATS "\n";
	        }
	        else {
	            my @tmp = unpack("a19 a18 a18 a18 a18 a18 a18",$line);
	            foreach (@tmp) {
	                $_ = &rtrim(&ltrim($_));
	            }
	            local $, = ",";
	            print FHOUT_STATS @tmp;
	            print FHOUT_STATS "\n";
	        }
	    }
	}
        $ii = $ii + 1;
        if ($ii == $probsStart[$jj]){
            $jj = $jj + 1;
        }
    }
    close FHIN_STATS;
    close FHOUT_STATS;
}
sub ltrim($){
	my $string = shift;
	$string =~ s/^\s+//;
	return $string;
}
sub rtrim($){
	my $string = shift;
	$string =~ s/\s+$//;
	return $string;
}
