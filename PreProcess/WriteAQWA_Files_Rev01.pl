#!/usr/bin/perl -w
use strict;
use Fortran::Format;
use Term::Prompt;
use Math::Trig;
use Data::Dumper;

# Define hash of header
our %deckHeaders = (
    0 =>  "*[ \#Deck_00: Overall administration parameters                       \#\n",
    1 =>  "*[ \#Deck_01: Coordinate positions                                    \#\n",
    2 =>  "*[ \#Deck_02: Element topology                                        \#\n",
    3 =>  "*[ \#Deck_03: Material parameters                                     \#\n",
    4 =>  "*[ \#Deck_04: Geometrical properties                                  \#\n",
    5 =>  "*[ \#Deck_05: Global paramters                                        \#\n",
    6 =>  "*[ \#Deck_06: Frequency and directions for model analysis             \#\n",
    7 =>  "*[ \#Deck_07: Wave frequency dependent parameters and stiffness matrix\#\n",
    8 =>  "*[ \#Deck_08: Drfit force coefficients                                \#\n",
    9 =>  "*[ \#Deck_09: Drift motion parameters                                 \#\n",
    10 => "*[ \#Deck_10: Hull drag coefficients and thrusters                    \#\n",
    11 => "*[ \#Deck_11: Environmental parameters                                \#\n",
    12 => "*[ \#Deck_12: Constraints                                             \#\n",
    13 => "*[ \#Deck_13: Regular wave parameters                                 \#\n",
    14 => "*[ \#Deck_14: Mooring lines description                               \#\n",
    15 => "*[ \#Deck_15: Starting conditions                                     \#\n",
    16 => "*[ \#Deck_16: Time integration parameters                             \#\n",
    17 => "*[ \#Deck_17: Hydrodynamic parameters for none diffracting elements   \#\n",
    18 => "*[ \#Deck_18: Printing options                                        \#\n",
    99 => "*]\n"
);

# Define hash of actions for decks
#my @inputs;
our %actions = (
    0 =>  {
           func => \&Deck00,
           param => []},
    1 =>  {
           func => \&Deck01,
           param => []},
    2 =>  {
           func => \&Deck02,
           param => []},
    3 =>  {
           func => \&Deck03,
           param => []},
    4 =>  {
           func => \&Deck04,
           param => []},
    5 =>  {
           func => \&Deck05,
           param => []},
    6 =>  {
           func => \&Deck06,
           param => []},
    7 =>  {
           func => \&Deck07,
           param => []},
    8 =>  {
           func => \&Deck08,
           param => []},
    9 =>  {
            func => \&Deck09,
            param => []},
    10 =>  {
           func => \&Deck10,
           param => []},
    11 =>  {
           func => \&Deck11,
           param => []},
    12 =>  {
           func => \&Deck12,
           param => []},
    13 =>  {
           func => \&Deck13,
           param => []},
    14 =>  {
           func => \&Deck14,
           param => []},
    15 =>  {
           func => \&Deck15,
           param => []},
    16 =>  {
           func => \&Deck16,
           param => []},
    17 =>  {
            func => \&Deck17,
            param => []},
    18 =>  {
             func => \&Deck18,
             param => []}
    );



# Define basic model parameters
my @inputs = @ARGV;
for (my $ii = 0; $ii < @inputs; $ii++){
    $inputs[$ii] = &ltrim(&rtrim($inputs[$ii]));
    if ($inputs[$ii] =~ m/NONE/){
        $inputs[$ii] = "";
    }
}

# Open output file and check it the file has been written. If the file exists the append, if not then write to the file
my $outputDatFile = shift(@inputs);
if (-e $outputDatFile){
    open FHOUT, ">> $outputDatFile";
}
else {
    open FHOUT, "> $outputDatFile";
}

# Parse all inputs into GenericInputs to determine what to do
my $tmp = &GenericInputs(@inputs);
print FHOUT $tmp;
#print "WTF";
#&testDeck06();

#&testGetLineLengths();
close FHOUT;

sub GenericInputs()
{
    # Gets a number of control options passed and passes these options onto the individual deck sub functions
    my $tmp;
    my $text = "";
    my $deck = $_[0];
    my $code = $_[1];
    my $templateFile = $_[2];
    my $numInputs = @_;
    my @inputs = @_[3...$numInputs];
    my $deckHeader = $deckHeaders{$deck};
    $tmp = $deckHeader;
    $text = join('',$text,$tmp);
    if ($code == 0){
        # Write none
        $tmp = &None;        
    }
    elsif ($code == 1){
        # Copy file data from template file
        $tmp = &Read_WB_Data($templateFile,$deck);
    }
    elsif ($code == 2){
        # Run specific functions related
        $actions{$deck}{param} = \@inputs;
        $tmp = &{$actions{$deck}{func}}(@{$actions{$deck}{param}});
    };
    $text = join('',$text,$tmp);
    $tmp = $deckHeaders{99};
    $text = join('',$text,$tmp);
    return $text;
}


sub Deck00()
{
    my $tmp;
    my $text = "";
    my @inputs = @_;
    my $SimType = $inputs[0];
    
    #Preliminary Deck - Fortran format strings
    my $job = Fortran::Format->new("A3,A1,A4,A2,A4,A2,A4");
    my $title = Fortran::Format->new("A5,A15,A");
    my $options = Fortran::Format->new("A7,A1,A4,A1,A4,A1,A4,A1,A4,A1,A3");
    my $restart = Fortran::Format->new("A7,A1,I1,A2,I1,A2,A6,A");
        
    if ($SimType =~ m/LINE/){
        $tmp = sprintf($job->write("JOB","","","",$SimType,"",$inputs[1]));
        $text = join('',$text,$tmp);
        $tmp = sprintf($title->write("TITLE","",$inputs[2]));
        $text = join('',$text,$tmp);
        $tmp = sprintf($options->write("OPTIONS","",$inputs[4],"",$inputs[5],"",$inputs[6],"","NQTF"));
        $text = join('',$text,$tmp);
        $tmp = sprintf($options->write("OPTIONS","","PRSS","","PRPT"));
        $text = join('',$text,$tmp);
        $tmp = sprintf($options->write("OPTIONS","",$inputs[3],"","END"));
        $text = join('',$text,$tmp);
        $tmp = sprintf($restart->write("RESTART","",$inputs[7],"",$inputs[8]));
        $text = join('',$text,$tmp);
    }
    elsif ($SimType =~ m/LIBR/){
        $tmp = sprintf($job->write("JOB","","","",$SimType,"",$inputs[1]));
        $text = join('',$text,$tmp);
        $tmp = sprintf($title->write("TITLE","",$inputs[2]));
        $text = join('',$text,$tmp);
        $tmp = sprintf($options->write("OPTIONS","",$inputs[3],"",$inputs[4],"",$inputs[5],"",$inputs[6],"","END"));
        $text = join('',$text,$tmp);
        $tmp = sprintf($restart->write("RESTART","",$inputs[7],"",$inputs[8],"","",$inputs[9]));
        $text = join('',$text,$tmp);
    }
    elsif ($SimType =~ m/DRFT/){
        $tmp = sprintf($job->write("JOB","","","",$SimType,"",$inputs[1]));
        $text = join('',$text,$tmp);
        $tmp = sprintf($title->write("TITLE","",$inputs[2]));
        $text = join('',$text,$tmp);
        $tmp = sprintf($options->write("OPTIONS","",$inputs[3],"",$inputs[4],"",$inputs[5],"",$inputs[6],"",""));
        $text = join('',$text,$tmp);
        $tmp = sprintf($options->write("OPTIONS","","SQTF","","CONV","","","","","","END"));
        $text = join('',$text,$tmp);
        $tmp = sprintf($restart->write("RESTART","",$inputs[7],"",$inputs[8],"","",$inputs[9]));
        $text = join('',$text,$tmp);        
    }
    elsif ($SimType =~ m/FER/){
        $tmp = sprintf($job->write("JOB","","","",$SimType,"",$inputs[1]));
        $text = join('',$text,$tmp);
        $tmp = sprintf($title->write("TITLE","",$inputs[2]));
        $text = join('',$text,$tmp);
        $tmp = sprintf($options->write("OPTIONS","",$inputs[3],"",$inputs[4],"",$inputs[5],"",$inputs[6],"",""));
        $text = join('',$text,$tmp);
        $tmp = sprintf($options->write("OPTIONS","","NOBL","","RDEP","","","","","","END"));
        $text = join('',$text,$tmp);
        $tmp = sprintf($restart->write("RESTART","",$inputs[7],"",$inputs[8],"","",$inputs[9]));
        $text = join('',$text,$tmp);   
    };
    
    return $text; 
}

sub Deck01()
{
    #Coordinate positions deck - read from dat file generated by *.lin
    my $tmp;
    my $text = "";
    my $writeFile = $_[0];
    my $ID = $_[1];
    my $input_file = [2];
    
    if ($writeFile == 0)
    {
        return $text;
    }
    else
    {
    }
    #Coordinate posittions deck - read from dat file generated by *.lin
    $tmp = "*[ \#Deck_01: Coordinate positions\#\n";
    $text = join('',$text,$tmp);
    my $header = Fortran::Format->new("A4,A2,A4,A4");
    $tmp = sprintf($header->write("",$ID,"","COOR"));
    $text = join('',$text,$tmp);
    
    if ($writeFile == 0)
    {
        return
    }
    elsif ($writeFile == 1)
    {
        
    }
    elsif ($writeFile == 2)
    {
        # Read in data from either aqwa or Workbench file
        $tmp = &Read_WB_Data("TimeResponse_EQ.dat",1);
        $text = join('',$text,$tmp);
    }
    
    $tmp = "*]\n";
    $text = join('',$text,$tmp);
    return $text;
}
sub Deck02()
{
    #Coordinate posittions deck - read from dat file generated by *.lin
    my $tmp;
    my $text = "";
    my $ID = $_[0];
    my $template = $_[1];
    my $deckID = 2;
    
    #Coordinate posittions deck - read from dat file generated by *.lin
    $tmp = "*[ \#Deck_02: Element topology\#\n";
    $text = join('',$text,$tmp);

    # Read in data from either aqwa or Workbench file
    # TODO
    if ($ID == 0){
        &None;
    }
    else {
        &Read_WB_Data($template,$deckID);
    }
    
    $tmp = "*]\n";
    $text = join('',$text,$tmp);
    return $text;
}

sub Deck03()
{
    #Material properties
    my $tmp;
    my $text = "";
    my $ID = $_[0];
    
    #Physical properties of materials associated with the elements in Deck 2.
    $tmp = "*[ \#Deck_03: Material parameters\#\n";
    $text = join('',$text,$tmp);
    my $header = Fortran::Format->new("A4,A2,A4,A4");
    $tmp = sprintf($header->write("",$ID,"","MATE"));
    $text = join('',$text,$tmp);

    #Read from topology file
    #TODO
    
    $tmp = "*]\n";
    $text = join('',$text,$tmp);
    return $text;
}
sub Deck04()
{
    #GEOM Geometric properties
    my $tmp;
    my $text = "";
    my $ID = $_[0];
    
    #Geometrical properties of physical geometry associated with the elements in Deck 2.
    $tmp = "*[ \#Deck_04: Geometrical properties\#\n";
    $text = join('',$text,$tmp);
    
    #Format strings
    my $header = Fortran::Format->new("A4,A2,A4,A4");
    
    #Print to text
    $tmp = sprintf($header->write("",$ID,"","GEOM"));
    $text = join('',$text,$tmp);
    
    #Read from topology file
    #TODO
    
    $tmp = "*]\n";
    $text = join('',$text,$tmp);
    return $text;
}
sub Deck05()
{
    #GLOB Global parameters
    my $tmp;
    my $text = "";
    my $ID = $_[0];
    my $DEPTH = $_[1];
    if ($DEPTH = []){
        $DEPTH = 1000.00
    }
    my $DENS = $_[2];
    if ($DENS = []){
        $DENS = 1025.00
    }
    my $ACCG = $_[3];
    if ($ACCG = []){
        $ACCG = 9.81
    }
   
    #Global parameters of model runs
    $tmp = "*[ \#Deck_05: Global paramters\#\n";
    $text = join('',$text,$tmp);
    
    #Format strings
    my $header = Fortran::Format->new("A4,A2,A4,A4");
    my $depth = Fortran::Format->new("A1,A3,A2,A4,F10.0");
    my $density = Fortran::Format->new("A1,A3,A2,A4,F10.0");
    my $acceleration = Fortran::Format->new("A1,A3,A2,A4,F10.2");
    
    #Print to text
    $tmp = sprintf($header->write("",$ID,"","GLOB"));
    $text = join('',$text,$tmp);
    $tmp = sprintf($depth->write("","",$ID,"DPTH",$DEPTH));
    $text = join('',$text,$tmp);
    $tmp = sprintf($density->write("","",$ID,"DENS",$DENS));
    $text = join('',$text,$tmp);
    $tmp = sprintf($acceleration->write("","END",$ID,"ACCG",$ACCG));
    $text = join('',$text,$tmp);


    #End string
    $tmp = "*]\n";
    $text = join('',$text,$tmp);
    return $text;
}
sub Deck06()
{
    #Frequency and directions table - each structure can have a different table up to 50 structures
    #Frequency and directions can be obtained from previous solutions
    #DECK FDR
    my $tmp;
    my $text = "";
    my $ID = $_[0];
    my $DB = $_[1];
    my $PERD = $_[2];
    my $DIRN = $_[3];
    #Structure number for each frequency and directions table
    my $STRUCT = $_[4];
    my $FWRDS = $_[5];
    my $FLAG = $_[6];
    
    my $structIn = 1;
    
    my @files;
    if ($DB = []){
        @files = [];
    }
    else {
        @files = @$DB;
    }
    
    #Generate list of periods if the array is not passed
    my @PERDS;
    if ($PERD = []){
        #@PERDS = (125,90,80,70,60,50,40,35,30,25,23,21,19,17,15,14,13,12,11,10,9,8,7,6);
        @PERDS = (150, 125.66, 61.73, 55.0, 50.0, 45.0, 40.91, 35.0, 30.60, 24.44, 22.0, 20.34, 17.42, 15.23, 13.53, 12.18,
                  11.07, 10.14, 9.36, 8.69, 8.11, 7.60, 7.15, 6.75, 6.40,5)
        #@PERDS = (100,30,13,11,10,9,8,7.5,7,6.75,6.5,6.25,6,5.75);
        #@PERDS = (125,50,20,18,16,14,12,10,8,6)
        #@PERDS = (110,105,100,95,90,80,70,60,55,52.5,50,47.5,45,40,35,30,25,23,21,19,18,17,16,15,14,13,12,11,10.5,10,9.5,9,8.5,8,7.5,7,6.5,6,5.5,5)
        #@PERDS = (110.000,99.099,89.767,81.697,74.657,68.467,62.989,58.112,53.746,49.820,
        #            46.274,43.059,40.135,37.465,35.021,32.779,30.715,28.813,27.055,25.427,
        #            23.918,22.516,21.212,19.997,18.863,17.805,16.815,15.888,15.020,14.205,
        #            13.441,12.723,12.047,11.412,10.814,10.250,9.718,9.217,8.744,8.297,
        #            7.875,7.476,7.099,6.742,6.404,6.084,5.782,5.495,5.223,4.965)
        #@PERDS = (100.000,95.000,90.000,85.000,80.000,76.000,72.000,68.000,64.000,60.000,
        #            58.000,56.000,54.000,52.000,50.000,48.000,46.000,44.000,42.000,40.000,
        #            38.000,36.000,34.000,32.000,30.000,29.000,28.000,27.000,26.000,25.000,
        #            24.000,23.000,22.000,21.000,20.000,19.000,18.000,17.000,16.000,15.000,
        #            14.000,13.000,12.000,11.000,10.000,9.000,8.000,7.000,6.000,5.000)
    }
    else {
        @PERDS = @$PERD;
    }
    
    #Generate list of directions if the array is not passed
    my @DIRNS;
    if ($DIRN = []){
        @DIRNS = (-180,-170,-160,-150,-140,-130,-120,-110,-100,-90,
                  -80,-70,-60,-50,-40,-30,-20,-10,0,
                  10,20,30,40,50,60,70,80,90,
                  100,110,120,130,140,150,160,170,180);
        #@DIRNS = (-180,)
    }
    else {
        @DIRNS = @$DIRN;
    }
       
    #Frequency and directions tables for model runs
    #$tmp = "*[ \#Deck_06: Frequency and directions for model analysis\#\n";
    #$text = join('',$text,$tmp);
    
    # Outside loop for each structure - TODO HERE
    my $struct;
    #Format strings
    my $header = Fortran::Format->new("A4,A2,A4,A4");
    my $periods = Fortran::Format->new("A1,A3,A2,A4,I5,I5,F10.5");
    my $directions = Fortran::Format->new("A1,A3,A2,A4,I5,I5,F10.3");
    my $forwardSpeed = Fortran::Format->new("A1,A3,A4,A10,F10.0");
    my $file = Fortran::Format->new("A1,A3,A2,A4,A10,A");
    my $ends = Fortran::Format->new("A1,A3");
    my $cstr = Fortran::Format->new("A1,A3,A2,A4,I5");
    my $cpdb = Fortran::Format->new("A1,A3,A2,A4");
    my $fini = Fortran::Format->new("A1,A3,A2,A4");
    
    STRUCTS: {            
        for ($struct = 0,$struct < $STRUCT,$struct++)
        {
            if(@files = [])
            {
                #Print to text
                $tmp = sprintf($header->write("",$ID,"","FDR".$struct));
                $text = join('',$text,$tmp);
                
                #Loop through list of periods to test
                my $ii = 1;
                foreach my $period (@PERDS){
                    $tmp = sprintf($periods->write("","",$ID,"HRTZ",$ii,$ii,1/$period));
                    $text = join('',$text,$tmp);
                    $ii++;
                }
                #Loop through list of directions to test
                $ii = 1;
                foreach my $dir (@DIRNS){
                    $tmp = sprintf($directions->write("","",$ID,"DIRN",$ii,$ii,$dir));
                    $text = join('',$text,$tmp);
                    $ii++;
                }
                $tmp = sprintf($ends->write("","END"));
                $text = join('',$text,$tmp);
            }
            else
            {
                #Print hyd files
                FILES: foreach my $files (@files)
                {
                    $tmp = sprintf($header->write("",$ID,"","FDR".$struct));
                    $text = join('',$text,$tmp);
                    $tmp = sprintf($file->write("","","","FILE","",$files));
                    $text = join('',$text,$tmp);
                    $tmp = sprintf($cstr->write("","","","CSTR",$structIn));
                    $text = join('',$text,$tmp);
                    $tmp = sprintf($cpdb->write("","","","CPDB"));
                    $text = join('',$text,$tmp);
                    $tmp = sprintf($ends->write("","END"));
                    $text = join('',$text,$tmp);
                    if ($FLAG == 0){
                        last FILES;
                    }
                }
                $tmp = sprintf($ends->write("","","","FINI"));
                $text = join('',$text,$tmp);
            }
            if ($FLAG == 0){
                last STRUCTS;
            }
        }
    }
    #my $fini = Fortran::Format->new("A1,A3,A2,A4");
    #End outside loop for each structure - TODO HERE
    
    #Forward speed
    #$tmp = sprintf($forwardSpeed->write("","",$ID,"FWDS",$FWRDS));
    
    #End string
    return $text;
    
}
sub Deck07()
{
    
}
sub Deck08()
{
    
}
sub Deck09()
# Drift motion parameters
{
    my $tmp;
    my $currentDeck = 9;
    my $text = "";
    my @deck_inputs = @_;
    # Restart file from QTF for slow drift parameters
    my $restartFile = shift @deck_inputs;
    my $structure = $deck_inputs[0];
    # Fortran::Format for writing deck information
    my $header = Fortran::Format->new("A4,A2,A4,A4");
    my $file = Fortran::Format->new("A1,A3,A2,A4,A5,A5,A");
    my $cstr = Fortran::Format->new("A1,A3,A2,A4,A5");
    
    # Write format for header
    $tmp = sprintf($header->write("","","","DRM".$structure));
    $text = join('',$text,$tmp);
    $tmp = sprintf($file->write("","","","FILE","","",$restartFile));
    $text = join('',$text,$tmp);
    $tmp = sprintf($file->write("","","","CSTR",$structure));
    $text = join('',$text,$tmp);
    $tmp = &End;
    $text = join('',$text,$tmp); 
    return $text;  
}
sub Deck10()
{
    
}
sub Deck11()
{
    # Environmental parameters
    my $tmp;
    my $currentDeck = 11;
    my $text = "";
    my @deck_inputs = @_;
    
    # Specify fortran formats
    my $header = Fortran::Format->new("A4,A2,A4,A4");
    my $curr = Fortran::Format->new("A1,A3,A2,A4,F10.5,F10.5");
    my $wind = Fortran::Format->new("A1,A3,A2,A4,F10.5,F10.5");
    
    # Get flag info
    my $flagSPEC = $deck_inputs[0];
    my $flagType = $deck_inputs[1];
        
    # Get environmental parameters
    my $currentSpeed = $deck_inputs[2];
    my $currentDirection = $deck_inputs[3];
    my $windSpeed = $deck_inputs[4];
    my $windDirection = $deck_inputs[5];
    my $referenceHeight = $deck_inputs[6];
    
    # Write Header
    $tmp = sprintf($header->write("","","","ENVR"));
    $text = join('',$text,$tmp);
    
    if ($flagType =~ m/NONE/){
        $tmp = &None;
        $text = join('',$text,$tmp); 
    }
    else {
        # Write environmental parameters
        $tmp = sprintf($curr->write("","","","CURR",$currentSpeed,$currentDirection));
        $text = join('',$text,$tmp);
        $tmp = sprintf($wind->write("","","","WIND",$windSpeed,$windDirection));
        $text = join('',$text,$tmp);
    }
    $tmp = &End;
    $text = join('',$text,$tmp); 
    return $text;  
}
sub Deck12()
{
    # Constraints -> import from 
    
}
sub Deck13()
{
    my $tmp;
    my $currentDeck = 13;
    my $text = "";
    my @deck_inputs = @_;
    # Read tag for wave of spectral parameters
    my $flagSPEC = $deck_inputs[0];
    my $flagType = $deck_inputs[1];
    # Read parameters only for jonh at present
    my $SPDN = $deck_inputs[2];
    my $currentSpeed = $deck_inputs[3];
    my $currentDirection = $deck_inputs[4];
    my $windSpeed = $deck_inputs[5];
    my $windDirection = $deck_inputs[6];
    my $windSpectrum = $deck_inputs[7];
    my $referenceHeight = $deck_inputs[8];
    # Wave spreading
    my $SPREAD_N = $deck_inputs[13];
    my $SPREAD_THETA = $deck_inputs[14];
        
    # Wave parameters -> Either Spectral or regular waves
    if ($flagSPEC =~ m/SPEC/){
        my $header = Fortran::Format->new("A4,A2,A4,A4");
        # Specify all frequencies in hertz
        my $hrtz = Fortran::Format->new("A1,A3,A2,A4");
        my $spdn = Fortran::Format->new("A1,A3,A2,A4,I5,A5,F10.0");
        my $seed = Fortran::Format->new("A1,A3,A2,A4,I10");
        my $psmz = Fortran::Format->new("A1,A3,A2,A4,A10,F10.3,F10.3,F10.3,F10.3");
        my $jonh = Fortran::Format->new("A1,A3,A2,A4,A10,A10,A10,F10.3,F10.3,F10.3");
        my $udef = Fortran::Format->new("A1,A3,A2,A4,A10,F10.5,F10.5");
        my $iwht = Fortran::Format->new("A1,A3,A2,A4,A5,A5,A");
        # Currently only available 
        my $windSpec = Fortran::Format->new("A1,A3,A2,A4,A10,A10,A10,A10");
        my $curr = Fortran::Format->new("A1,A3,A2,A4,A10,F10.5,F10.5,F10.5");
        my $wind = Fortran::Format->new("A1,A3,A2,A4,A10,F10.5,F10.5,F10.5");
        
        # Write header
        if ($flagType !~ m/NONE/){
            $tmp = sprintf($header->write("","","","SPEC"));
            $text = join('',$text,$tmp);
            # Write wind specrta defintion
            $tmp = sprintf($windSpec->write("","","",$windSpectrum,"","","",""));
            $text = join('',$text,$tmp);
            # Write speed direction
            $tmp = sprintf($wind->write("","","","WIND","",$windSpeed,$windDirection,$referenceHeight));
            $text = join('',$text,$tmp);
            # Write current direction
            $tmp = sprintf($curr->write("","","","CURR","",$currentSpeed,$currentDirection,0));
            $text = join('',$text,$tmp);
            # Write hertz
            $tmp = sprintf($hrtz->write("","","","HRTZ"));
            $text = join('',$text,$tmp);
            # Write spdn
            $tmp = sprintf($spdn->write("","","","SPDN",$SPREAD_N,"",$SPDN));
            $text = join('',$text,$tmp);
        }
        
        if ($flagType =~ m/JONH/){
            my $GAMMA = $deck_inputs[9];
            my $HS = $deck_inputs[10];
            my $TP = $deck_inputs[11];
            $tmp = sprintf($jonh->write("","","","JONH","","","",$GAMMA,$HS,$TP));
            $text = join('',$text,$tmp);
        };
        if ($flagType =~ m/UDEF/){
            my $specFile = $deck_inputs[12];
            my @freq;
            my @ordinate;
            open FHIN, "< $specFile";
            while(<FHIN>){
                my $line = $_;
                my @tmp = split /\t/,$line;
                push @freq, $tmp[1];
                push @ordinate, $tmp[2];
                #print $tmp[0],$tmp[1]
            }
            close FHIN;
            my $loop = @freq;
            for(my $ii = 0; $ii < $loop; $ii++ ){
                $tmp = sprintf($udef->write("","","","UDEF","",$freq[$ii],$ordinate[$ii]));
                $text = join('',$text,$tmp);
            }
        }
        if ($flagType =~ m/IWHT/){
            my $iwhtFile = $deck_inputs[12];
            my $tmp = sprintf($iwht->write("","","","IWHT","","",$iwhtFile));
            $text = join('',$text,$tmp);
        }
        if ($flagType =~ m/NONE/){
            $tmp = &None;
            $text = join('',$text,$tmp); 
        }
        $tmp = &Fini;
        $text = join('',$text,$tmp); 
      
    }
    $tmp = &End;
    $text = join('',$text,$tmp); 
    return $text;

}
sub Deck14()
{
    my $tmp;
    my $currentDeck = 14;
    my $text = "";
    my @deck_inputs = @_;
    my $templateFile = shift @deck_inputs;
    my $calcLineLengths = shift @deck_inputs;
    my $lineBreakFlag = shift @deck_inputs;
    #my $ISFIXED = shift @deck_inputs;
    my $breakingStrength;
    #my $linesToBreak = shift @deck_inputs;
    $breakingStrength = shift @deck_inputs;
    $breakingStrength = $breakingStrength*1000;
    my @linePoly = @deck_inputs[0...4];
    my @fendPoly = @deck_inputs[5...9];
    
    # My flag to write to moor file 
    
    # If moor file exists -> then write format to moor file
    
    # If moor file does not exist -> write moor file and check if moor file exists.
    
    # Description of mooring lines
    # Defaults to mooring lines and fenders only - Can upgrade to pulleys at a later stage
    # Read results from WB run in order to get preliminary mooring line data and nodes of connections
    my $wb_deck = &Read_WB_Data($templateFile,14);
    my @mooringData = &GetAttachmentPoints($wb_deck);
    # Read template file and extract nodes. 
    my $header = Fortran::Format->new("A4,A2,A4,A4");
    my $polyLine = Fortran::Format->new("A1,A3,A2,A4,A20,2(E10.3)");
    my $polyFend = Fortran::Format->new("A1,A3,A2,A4,A20,5(E10.3)");   
    my $wnch = Fortran::Format->new("A1,A3,A2,A4,I5,I5,I5,I5,F10.3,F10.3,F10.3,F10.3");
    my $nlin = Fortran::Format->new("A1,A3,A2,A4,I5,I5,I5,I5,F10.3,F10.3,F10.3,F10.3");
    my $fend = Fortran::Format->new("A1,A3,A2,A4,A20,F10.3,A10,E10.3,A10,E10.3");
    my $flin = Fortran::Format->new("A1,A3,A2,A4,I5,A5,I5,I5,I5,A5,I5,I5,I5");
    my $dynm = Fortran::Format->new("A1,A3,A2,A4");
    my $lbrk = Fortran::Format->new("A1,A5,A4,A4,I5,A10,A10,A10,A10");
    
    $tmp = sprintf($header->write("","","","MOOR"));
    $text = join('',$text,$tmp);
    # Dereference passed variables
    my $nlinData = $mooringData[0];
    my @nlinData = @$nlinData;
    my $fendData = $mooringData[1];
    my @fendData = @$fendData;
    my $flinData = $mooringData[2];
    my @flinData = @$flinData;

    
    my $numMooringLines = scalar @{$nlinData[0]};
    my $numFenders = scalar @{$flinData[0]};
    
    # Loop through lines and write correct format
    for (my $ii = 0; $ii < $numMooringLines; $ii++){
        my $lineLength = $nlinData[4][$ii];
        # Calculate all line lengths
        if ($calcLineLengths == 1){
            my $wb_deck01 = &Read_WB_Data($templateFile,1);
            $lineLength = &getLineLengths($wb_deck01,$nlinData[0][$ii],$nlinData[1][$ii],$nlinData[2][$ii],$nlinData[3][$ii]);            
        }
        my @writeLinePoly = &getLineCoefficients($linePoly[0],$linePoly[1],$linePoly[2],$lineLength,$linePoly[3],$linePoly[4]);
        $tmp = sprintf($polyLine->write("","","","POLY","",$writeLinePoly[2],$writeLinePoly[1]));
        $text = join('',$text,$tmp);
        # Get new line lengths shortened to account for pretension
        $lineLength = $lineLength - $writeLinePoly[0];
        #$tmp = sprintf($wnch->write("","","","WNCH",$nlinData[0][$ii],$nlinData[1][$ii],$nlinData[2][$ii],$nlinData[3][$ii],0,$lineLength,0,0));
        #$text = join('',$text,$tmp);
        $tmp = sprintf($nlin->write("","","","NLIN",$nlinData[0][$ii],$nlinData[1][$ii],$nlinData[2][$ii],$nlinData[3][$ii],0,$lineLength,0,0));
        $text = join('',$text,$tmp);
    }
    
    if ($lineBreakFlag =~ m/TRUE/){
        for (my $ii = 0; $ii < $numMooringLines; $ii++){
            $tmp = sprintf($lbrk->write("","","LBRK","",$ii+1,"","0.",$breakingStrength,"0."));
            $text = join('',$text,$tmp);
        }
    }
    
    $tmp = sprintf($dynm->write("","","","DOFF"));
    $text = join('',$text,$tmp);
    
    # Loop through fenders and write correct format
    for (my $jj = 0; $jj < $numFenders; $jj++){
        $tmp = sprintf($fend->write("","","","FEND","",$fendData[0][$jj],"",$fendData[1][$jj],"",$fendData[2][$jj]));
        $text = join('',$text,$tmp);
        $tmp = sprintf($polyFend->write("","","","POLY","",@fendPoly));
        $text = join('',$text,$tmp);
        $tmp = sprintf($flin->write("","","","FLIN",$flinData[0][$jj],"",$flinData[1][$jj],$flinData[2][$jj],$flinData[3][$jj],
                                    "",$flinData[4][$jj],$flinData[5][$jj],$flinData[6][$jj]));
        $text = join('',$text,$tmp);
    }
    $tmp = &End;
    $text = join('',$text,$tmp); 
    return $text;
}
sub Deck15()
{
    
}
sub Deck16()
{
    my @deck_inputs = @_;
    my $type = $deck_inputs[0];
    my $text = "";
    my $tmp;
    
    # Set fortran format writes
    my $header = Fortran::Format->new("A4,A2,A4,A4");
    # Time integration parameters for AQWA-DRIFT
    my $time = Fortran::Format->new("A1,A3,A2,A4,A5,I5,F10.3,F10.3");
    # Iteration limits for AQWA-LIBRIUM
    my $mxni = Fortran::Format->new("A1,A3,A2,A4,A5,I5");
    my $mmve = Fortran::Format->new("A1,A3,A2,A4,I5,A5,6(F10.3)");
    my $merr = Fortran::Format->new("A1,A3,A2,A4,I5,A5,6(F10.3)");
   
    if ($type =~ m/TINT/){
        # Time integration parameters
        # Write header
        $tmp = sprintf($header->write("","","",$type));
        $text = join('',$text,$tmp);
        
        # Get time integration parameters
        my $numTimeSteps = $deck_inputs[1];
        my $delTimeStep = $deck_inputs[2];
        my $startTime = $deck_inputs[3];
        
        $tmp = sprintf($time->write("","","","TIME","",$numTimeSteps,$delTimeStep,$startTime));
        $text = join('',$text,$tmp);
    }
    elsif ($type =~ m/GMCH/){
        # Geometrical changes for AQWA-LINE
        
    }
    elsif ($type =~ m/LMTS/){
        # Write header
        $tmp = sprintf($header->write("","","",$type));
        $text = join('',$text,$tmp);
        my $StructNum = 1;
        
        # Iteration limits for AQWA-LIRBRIUM
        my @defaultMultipliers =($deck_inputs[1],$deck_inputs[2],$deck_inputs[3]);
        my @mxniDefaults = (100);
        my @mmveDefaults = (2.00,2.00,0.50,0.573,0.573,1.432); #(G=9.81)
        my @merrDefaults = (0.02,0.02,0.02,0.057,0.057,0.143);
        my @mxniWrite = @mxniDefaults;
        foreach my $x (@mxniWrite) {$x = scalar($defaultMultipliers[0])*$x;}
        my @mmveWrite = @mmveDefaults;
        foreach my $x (@mmveWrite) {$x = scalar($defaultMultipliers[1])*$x;}
        my @merrWrite = @merrDefaults;
        foreach my $x (@merrWrite) {$x = scalar($defaultMultipliers[2])*$x;}
        
        # Write values
        $tmp = sprintf($mxni->write("","","","MXNI","",@mxniWrite));
        $text = join('',$text,$tmp);
        $tmp = sprintf($mmve->write("","","","MMVE",$StructNum,"",@mmveWrite));
        $text = join('',$text,$tmp);
        $tmp = sprintf($merr->write("","","","MERR",$StructNum,"",@merrWrite));
        $text = join('',$text,$tmp);
    }
    $tmp = &End;
    $text = join('',$text,$tmp); 
    return $text;    
}
sub Deck17()
{
    
}
sub Deck18()
{
    # Specification of printing options
    my @deck_inputs = @_;
    my $text = "";
    my $tmp;
    
    # Defaulta print info for only structure 1
    # Ignore articulations
     
    # Initiate print parameters
    my @no_print_drift;
    my @print_drift;
    
    if ($deck_inputs[0] =~ m/DRIFT_MIN/){
        @no_print_drift = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,19,21,22,24,25,27,28,30,31,33,50);
        @print_drift = (1,4,7,10,14,19,25);
    }

    
    # Set fortran format writes
    my $header = Fortran::Format->new("A4,A2,A4,A4");
        
    # Input fortran format for read and write
    # The NODE card - Nodal position for listing file output
    my $node = Fortran::Format->new("A1,A2,A4,I5,I5,I5");
    # Limit the information output associated with the positions on the NODE card.
    # Default information is disp. in the x,y and z translational freedoms.
    my $allm = Fortran::Format->new("A1,A2,A2,A4");
    my $pggp = Fortran::Format->new("A1,A3,A2,A4,I5,12(I5)"); # Not yet implimented
    
    # PREV Time Step Increment determines how often the full printout of positions and forces is printed to the output listing file.
    my $prev = Fortran::Format->new("A1,A3,A2,A4,I5");

    # PRINT/NOPR Care - used to change the list of variables to be output on the listing file - See POD below for parameters list
    my $prnt = Fortran::Format->new("A1,A3,A2,A4,I5,I5,I5");
    my $nopr = Fortran::Format->new("A1,A3,A2,A4,I5,I5,I5");
    
    # PTEN - Print cable tensions
    my $pten = Fortran::Format->new("A1,A3,A2,A4,I5"); # I5 is the structure number, this indicates for which structure cable tensions are extracted and printed
    
    # PPRV - Print POS every nth timestep
    my $pprv = Fortran::Format->new("A1,A3,A2,A4,I5"); # I5 is the timestep increment, how often the progrm will print positions and velocities etc to the output *.pos file
    
    # GREV - Graphics output every nth timestep
    my $grev = Fortran::Format->new("A1,A3,A2,A4,I5"); # Determines how often the full graphics and plotting results are output. Used to limit the size of the files.
    
    $tmp = sprintf($header->write("","","","PROP"));
    $text = join('',$text,$tmp);
    $tmp = sprintf($prev->write("","","","PREV",5));
    $text = join('',$text,$tmp);
    while(<@no_print_drift>){
        $tmp = sprintf($nopr->write("","","","NOPR",1,$_,0));
        $text = join('',$text,$tmp);
        $tmp = sprintf($nopr->write("","","","NOPR",2,$_,0));
        $text = join('',$text,$tmp);
    }
    while(<@print_drift>){
        $tmp = sprintf($prnt->write("","","","PRNT",1,$_,0));
        $text = join('',$text,$tmp);
    }
    
    # Print cable tensions for structure 1
    $tmp = sprintf($prev->write("","","","PTEN",1));
    $text = join('',$text,$tmp);
    
    # Print data for graphics output
    # Assume total timestep 14400 @0.5 seconds
    $tmp = sprintf($prev->write("","","","GREV",5));
    $text = join('',$text,$tmp);
    
    
    $tmp = &End;
    $text = join('',$text,$tmp); 
    return $text;    
=pod

=head1 NODE 
N.B. Maximum of the total number of NODE cards that may be input is 35. 

      2   5  7   11    16    21    26
    - --- -- ---- ----- ----- ----- -----
   |X|   |  |NODE|     |     |     |     |
    - --- -- ---- ----- ----- ----- -----
       |  |   |     |     |     |     |
       |  |   |     |     |     |     |_(4) Node Number (I5)
       |  |   |     |     |     |
       |  |   |     |     |     |_(3) Structure Number (I5)
       |  |   |     |     |
       |  |   |     |     |_(2) Node Number (I5)
       |  |   |     |
       |  |   |     |_(1) Structure Number (I5)
       |  |   |
       |  |   |_Compulsory Card Header (A4)
       |  |
       |  |_Optional User Identifier (A2)
       |
       |_Compulsory END on last card in Deck (A3)
(1) The structure number must correspond to one of the structures defined in Deck 2.
If '1' is input then this will correspond to the structure defined in Deck ELM1.
If '2' is input then this will correspond to the structure defined in Deck ELM2, etc.
As the NODE card is a request for output of the position/motion of the node number specified (2), structure number '0'
(i.e. a fixed node) is illegal in this field and will produce an error, since zero structure indicates a fixed node.
(2) This is the node number whose position/motions are requested during the analysis. The position of this node on the structure (1) must be defined in Deck 1.
Note that these motions are with respect to the position defined by (3) and (4).
(3)-(4) This structure number and its corresponding node number (4) define the reference point for the positions/motions defined by parameters (1) and (2).
Both these fields may be left blank, in which case the program will assume that the output at the position defined by (1) and (2) is with respect to the origin of the
Fixed Reference Axes, i.e. the ABSOLUTE values.
If '0' is input as the structure number (3), together with a node number (4),
the program will recognise that this node number (4) references the fixed position as defined in Deck 1 in the Fixed Reference Axis System (FRA).
Note that a non-zero structure number (3) must be followed by a valid node number (4) on that structure.
1. Information Output at NODAL POSITIONS

The input of the NODE card is designed to enable the user to request the positions/motions of any point on a structure with respect to any other point, whether on a structure or fixed in space (i.e. the difference between the positions/motions of two points). For each NODE card, the program will output the following

           |---------------------------------------------------------|
           |            |The difference between -                    |
           |------------+--------------------------------------------|
           |            |                                            |
           | AQWA-LINE  |The RAOs of the NODAL POSITIONS specified.  |
           |            |Note that AQWA-LINE must be run for stages  |
           |            |1 to 5                                      |
           |            |                                            |
           |------------+--------------------------------------------|
           |            |                                            |
           | AQWA-DRIFT |The positions/velocities/accelerations of   |
           |            |the NODES at each step in the time-history  |
           |            |                                            |
           |------------+--------------------------------------------|
           |            |                                            |
           |  AQWA-FER  |The RAOs and significant motion of the      |
           |            |NODAL POSITIONS specified.                  |
           |            |                                            |
           |------------+--------------------------------------------|
           |            |                                            |
           |AQWA-LIBRIUM|The positions of the specified NODES at     |
           |            |each static equilibrium position found.     |
           |            |                                            |
           |------------+--------------------------------------------|
           |            |                                            |
           | AQWA-NAUT  |The positions/velocities/accelerations of   |
           |            |the NODES at each step in the time-history  |
           |            |                                            |
           |---------------------------------------------------------|
=back
= head1 PRNT/NOPR
 The default selection of parameters to be printed for all possible types of AQWA-DRIFT/LIBRIUM/NAUT analysis is shown in the table below.

     2   5  7    11
    - --- -- ---- ----- ----- -----
   |X|   |  |PRNT|     |     |     |
    - --- -- ---- ----- ----- -----
   |X|   |  |NOPR|     |     |     |
    - --- -- ---- ----- ----- -----
       |  |   |     |     |     |
       |  |   |     |     |     |_(4) Articulation Number (I5)
       |  |   |     |     |
       |  |   |     |     |_(3) Parameter Number (I5)
       |  |   |     |
       |  |   |     |_(2) Structure Number (I5)
       |  |   |
       |  |   |_(1)Compulsory Card Header (A4)
       |  |
       |  |_Optional User Identifier (A2)
       |
       |_Compulsory END on last card in Deck (A3)

(1) PRNT causes the specified parameter to be added to the list of output. NOPR causes it to be removed from the list.

(2) The structure number must correspond to one of the structures defined in Deck 2. If '1' is input, this will correspond to the structure defined in Deck ELM1. If '2' is input, this will correspond to the structure defined in Deck ELM2, etc.

(3) The parameter number refers to a type of output as shown in the list below. If the parameter number is omitted all the parameters for the specified structure will be output (PRNT) or omitted (NOPR).

(4) For articulation reactions, the 3rd number on the card is the number of the articulation (1-50) for which reactions are required.



NOTE.
The FROUDE-KRYLOV and DIFFRACTION forces are sub-divided differently for AQWA-DRIFT and NAUT, as shown in the table below.

 ----------------------------------------------------------------------------------
| PARAMETER (#)     |       AQWA-DRIFT                    |      AQWA-NAUT         |
|---------------------------------------------------------|------------------------|
| DIFFRACTION (16)  | Diffraction AND Froude-Krylov force | Diffraction force on   |
|                   | on diffracting panels               | diffracting panels     |
|                   |                                     |                        |
| FROUDE-KRYLOV (20)| Froude-Krylov force on Morison      | Froude-Krylov force on |
|                   | elements only                       | all elements           |
|                   |                                     |                        |
| WAVE INERTIA (23) | Diffraction force on                | Diffraction force on   |
|                   | Morison elements                    | Morison elements       |
 ----------------------------------------------------------------------------------



This is the full list of output parameters for AQWA-LIBRIUM, DRIFT and NAUT. Further output can be requested using additional cards in Deck 18. 

  ------------------------------------------------------------------------------
 | FULL LIST OF AVAILABLE   | AQWA-DRIFT DEFAULT FOR  | AQWA-DRIFT DEFAULT FOR  |
 |    PARAMETERS            |  DRIFT MOTION ONLY      | PLUS W/FREQUENCY MOTION |
 |--------------------------|-------------------------|-------------------------|
 | 1. POSITION              | 1. POSITION             | 1. POSITION             |
 | 2. VELOCITY              | 2. VELOCITY             | 2. VELOCITY             |
 | 3. ACCELERATION          | 3. ACCELERATION         | 3. ACCELERATION         |
 | 4. RAO BASED POSITION    |                         | 4. RAO BASED POSITION   |
 | 5. RAO BASED VELOCITY    |                         | 5. RAO BASED VELOCITY   |
 | 6. RAO BASED ACCEL       |                         |                         |
 | 7. WAVE FREQ POSITION    |                         | 7. WAVE FREQ POSITION   |
 | 8. WAVE FREQ VELOCITY    |                         | 8. WAVE FREQ VELOCITY   |
 | 9. WAVE FREQ ACCEL       |                         | 9. WAVE FREQ ACCEL      |
 |10. SLOW POSITION         |                         |1O. SLOW POSITION        |
 |11. SLOW VELOCITY         |                         |11. SLOW VELOCITY        |
 |12. SLOW ACCEL            |                         |12. SLOW ACCEL           |
 |13. SLOW YAW              |                         |                         |
 |14. MOORING               |14. MOORING              |14. MOORING              |
 |15. GYROSCOPIC            |                         |                         |
 |16. DIFFRACTION           |                         |16. DIFFRACTION          |
 |17. LINEAR DAMPING        |17. LINEAR DAMPING       |17. LINEAR DAMPING       |
 |18. MORISON DRAG          |                         |                         |
 |19. DRIFT                 |19. DRIFT                |19. DRIFT                |
 |2O. FROUDE KRYLOV         |                         |      SEE NOTE ABOVE     |
 |21. GRAVITY               |21. GRAVITY              |21. GRAVITY              |
 |22. CURRENT DRAG          |22. CURRENT DRAG         |22. CURRENT DRAG         |
 |23. WAVE INERTIA          |                         |                         |
 |24. HYDROSTATIC           |24. HYDROSTATIC          |24. HYDROSTATIC          |
 |25. WIND                  |25. WIND                 |25. WIND                 |
 |26. SLAM                  |                         |                         |
 |27. THRUSTER              |27. THRUSTER             |27. THRUSTER             |
 |28. YAW DRAG              |28. YAW DRAG             |28. YAW DRAG             |
 |29. SLENDER BODY FORCES   |                         |                         |
 |3O. ERROR PER TIMESTEP    |3O. ERROR PER TIMESTEP   |3O. ERROR PER TIMESTEP   |
 |31. TOTAL REACTION FORCE  |31. TOTAL REACTION FORCE |31. TOTAL REACTION FORCE |
 |33. L/WAVE DRIFT DAMPING  |33. L/WAVE DRIFT DAMPING |33. L/WAVE DRIFT DAMPING |
 |34. EXTERNAL FORCE        |                         |                         |
 |35. RADIATION FORCE       |       DEFAULT WITH CONV OPTION, ZERO WITHOUT      |
 |36. FLUID MOMENTUM        |                         |                         |
 |38. FLUID GYROSCOPIC FORCE|                         |                         |
 |39. ADD STRUCT STIFF FORCE|                         |                         |
 |47. ARTICULATION REACTION |                    SEE (3) ABOVE                  |
 |5O. TOTAL FORCE           |5O. TOTAL FORCE          |5O. TOTAL FORCE          |
  ------------------------------------------------------------------------------


  ------------------------------------------------------------------------------
 | FULL LIST OF AVAILABLE   |  AQWA-LIBRIUM DEFAULTS  | AQWA-NAUT DEFAULTS      |
 |    PARAMETERS            |                         |                         |
 |--------------------------|-------------------------|-------------------------|
 | 1. POSITION              | 1. POSITION             | 1. POSITION             |
 | 2. VELOCITY              |                         | 2. VELOCITY             |
 | 3. ACCELERATION          |                         | 3. ACCELERATION         |
 | 4. RAO BASED POSITION    |                         | 4. RAO BASED POSITION   |
 | 5. RAO BASED VELOCITY    |                         | 5. RAO BASED VELOCITY   |
 | 6. RAO BASED ACCEL       |                         |                         |
 | 7. WAVE FREQ POSITION    |                         |                         |
 | 8. WAVE FREQ VELOCITY    |                         |                         |
 | 9. WAVE FREQ ACCEL       |                         |                         |
 |1O. SLOW POSITION         |                         |                         |
 |11. SLOW VELOCITY         |                         |                         |
 |12. SLOW ACCEL            |                         |                         |
 |13. SLOW YAW              |                         |                         |
 |14. MOORING               |14. MOORING              |14. MOORING              |
 |15. GYROSCOPIC            |                         |                         |
 |16. DIFFRACTION           |                         |16. DIFFRACTION          |
 |17. LINEAR DAMPING        |                         |17. LINEAR DAMPING       |
 |18. MORISON DRAG          |                         |18. MORISON DRAG         |
 |19. DRIFT                 |19. DRIFT                |                         |
 |2O. FROUDE KRYLOV         |                         |20. FROUDE-KRYLOV        |
 |21. GRAVITY               |21. GRAVITY              |21. GRAVITY              |
 |22. CURRENT DRAG          |22. CURRENT DRAG         |22. CURRENT DRAG         |
 |23. WAVE INERTIA          |                         |                         |
 |24. HYDROSTATIC           |24. HYDROSTATIC          |24. HYDROSTATIC          |
 |25. WIND                  |25. WIND                 |25. WIND                 |
 |26. SLAM                  |                         |                         |
 |27. THRUSTER              |27. THRUSTER             |                         |
 |28. YAW DRAG              |                         |                         |
 |29. SLENDER BODY FORCES   |                         |                         |
 |3O. ERROR PER TIMESTEP    |                         |3O. ERROR PER TIMESTEP   |
 |31. TOTAL REACTION FORCE  |                         |31. TOTAL REACTION FORCE |
 |34. EXTERNAL FORCE        |                         |                         |
 |35. RADIATION FORCE       |                         |                         |
 |36. FLUID MOMENTUM        |                         |                         |
 |38. FLUID GYROSCOPIC FORCE|                         |                         |
 |39. ADD STRUCT STIFF FORCE|                         |                         |
 |47. ARTICULATION REACTION |                    SEE (3) ABOVE                  |
 |5O. TOTAL FORCE           |5O. TOTAL FORCE          |5O. TOTAL FORCE          |
  ------------------------------------------------------------------------------
=back
=cut

# Set-up standard printing templates with user defined options based on input array



}
sub Deck19()
{
    
}
sub Deck20()
{
    
}
sub Read_WB_Data()
{
    # Input file name 
    my $file = $_[0];
    my $required = $_[1];
    my $string = "";
    my %deck_hash;
    my @deck_indices;
    my @decks;
    my @start;
    my @end;
    my @file;
    # Read only Deck01 to Deck04 and return to upper deck sub as tmp string
    # Insert header and footer fo fomratting
    open FHIN, "< $file";
    while (<FHIN>)
    {
        my $line = $_;
        if ($line !~ m/\*{80}\n/)
        {
            push @file,$line;
        }
    }
    close FHIN;
    my $ii = 0;
    # Get indices of start and end lines for DECKS
    foreach my $line (@file)
    {
        if ($line =~ m/DECK\s+(\d+)/)
        {
            push @decks,$1;
            push @deck_indices,$ii;
            push @start,$ii+1;
            push @end,$ii-1;
        }
        $ii = $ii+1;
    };
    shift @end;
    my $lastline = @file;
    push @end,$lastline-2;
    
    $ii = 0;
    foreach my $tmpDecks (@decks)
    {
        my $tmpString = join('',@file[$start[$ii]...$end[$ii]]);
        $deck_hash{$decks[$ii]} = $tmpString;
        $ii = $ii + 1;
    }
    return $deck_hash{$required};
}
sub Read_Custom_Data()
{
    # Reads cutomised data file for updates of decks
    # May be easier to rewrite files based on typical usage
}
sub None()
{
    # Sub function to insert none into deck
    # Need to check that "NONE" works for REST files
    my $header = Fortran::Format->new("A4,A2,A4,A4");
    my $tmp = sprintf($header->write("","","","NONE"));
    return $tmp;
}
sub End()
{
    # Sub function to insert none into deck
    # Need to check that "NONE" works for REST files
    my $header = Fortran::Format->new("A1,A3");
    my $tmp = sprintf($header->write("","END"));
    return $tmp;
}
sub Fini()
{
    # Sub function to insert FINI into deck
    my $header = Fortran::Format->new("A1,A3,A2,A4");
    my $tmp = sprintf($header->write("","","","FINI"));
    return $tmp;
}
sub WindCurrentCoefficients()
{
    # Insert wind and current coefficients into *.dat file   
}
sub Mooring()
{
    # Generates mooring configuration file and inserts into
    
}
sub GetAttachmentPoints()
{
    # Gets all node values for attachment points from Deck 14 read from WB file
    my $wb_text = $_[0];
    my @wb_text = $wb_text =~ /^(\s+.*)\n/mg;
    
    # Declare all arrays
    my @lineNodeStart;
    my @lineNodeEnd;
    my @lineStructStart;
    my @lineStructEnd;
    my @lineLength;
    my @fendNodeStart;
    my @fendNormStart;
    my @fendNodeEnd;
    my @fendNormEnd;
    my @fendStructStart;
    my @fendStructEnd;
    my @fendSize;
    my @fendFriction;
    my @fendDamping;
    my @fendType;
# Additional variables added to account for a fixed structure i.e. nodes associated with a single structure
    my $structStart;
    my $structEnd;
    my $fendStructStart;
    my $fendStructEnd;
    
    # Read apply fortran formats for reading 
    my $nlin = Fortran::Format->new("A1,A3,A2,A4,I5,I5,I5,I5,F10.0,F10.0,F10.0,F10.0");
    my $fend = Fortran::Format->new("A1,A3,A2,A4,A20,F10.0,A10,F10.0,A10,F10.0");
    my $flin = Fortran::Format->new("A1,A3,A2,A4,I5,A5,I5,I5,I5,A5,I5,I5,I5");
    
    # Loop through the array of text and extract relevant data
    foreach (@wb_text){
        if ($_ =~ m/NLIN/){
            my @tmpfields = $nlin->read($_,12);
            my $fields = $tmpfields[0];
            my @fields = @$fields;
            if ($fields[4] == 0){
                $structStart = 1;
            }
            else {$structStart = $fields[4]};
            push @lineStructStart, $structStart;
            push @lineNodeStart, $fields[5];
            if ($fields[6] == 0){
                $structEnd = 1;
            }
            else {$structEnd = $fields[6]};
            push @lineStructEnd, $structEnd; 
            push @lineNodeEnd, $fields[7];
            push @lineLength, $fields[9];
        }
        if ($_ =~ m/FLIN/){
            my @tmpfields = $flin->read($_,13);
            my $fields = $tmpfields[0];
            my @fields = @$fields;
            push @fendType, $fields[4];
            if ($fields[6] == 0){
                $fendStructStart = 1;
            }
            else {$fendStructStart = $fields[6]};            
            push @fendStructStart, $fendStructStart;
            push @fendNodeStart, $fields[7];
            push @fendNormStart, $fields[8];
            if ($fields[10] == 0){
                $fendStructEnd = 1;
            }
            else {$fendStructEnd = $fields[10]};
            push @fendStructEnd, $fields[10];
            push @fendNodeEnd, $fields[11];
            push @fendNormEnd, $fields[12];
        }
        if ($_ =~ m/FEND/){
            my @tmpfields = $fend->read($_,10);
            my $fields = $tmpfields[0];
            my @fields = @$fields;
            push @fendSize, $fields[5];
            push @fendFriction, $fields[7];
            push @fendDamping, $fields[9];
        }
    }
    
    # Package all arrays into a usable array format
    my @nlinData = (\@lineStructStart,\@lineNodeStart,\@lineStructEnd,\@lineNodeEnd,\@lineLength);
    my @flinData = (\@fendType,\@fendStructStart,\@fendNodeStart,\@fendNormStart,\@fendStructEnd,\@fendNodeEnd,\@fendNormEnd);
    my @fendData = (\@fendSize,\@fendFriction,\@fendDamping);
    my @return = (\@nlinData,\@fendData,\@flinData);
    # Pass data to Deck_14
    return @return;
}
sub getLineLengths(){
    # Given a start and end node on a specific structure - the intitial line length is calculated
    my $startStruct = $_[1];
    my $startNode = $_[2];
    my $endStruct = $_[3];
    my $endNode = $_[4];
    my %structureNodes;
    my $structure = 999;
    # Specify Fortran::Format for data read
    my $coordinate = Fortran::Format->new("A1,A3,A2,I5,I4,I5,3(A10)");
    # Gets all node details from Deck 01
    my $wb_text = $_[0];
    my @wb_text = $wb_text =~ /^(\s+.*)\n/mg;
    # Loop through array and assign to a structure hash
    foreach(@wb_text){
        my $line = $_;
        if ($line =~ m/^\s+STRC\s+\d+/){
            $structure = ($line =~ /^\s+STRC\s+(\d+)/g)[0];
            $structure = &ltrim(&rtrim($structure));
        }
        if($line =~ m/^\s+$structure/){
            my @tmp01 = $coordinate->read($line,9);
            my $coords= $tmp01[0];
            my @coords = @$coords;
            my $structRead = &ltrim(&rtrim($coords[2]));
            my $nodeNumber = $coords[3];
            my $x = $coords[6];
            my $y = $coords[7];
            my $z = $coords[8];
            my @tmpPositions = [$x,$y,$z];
            $structureNodes{$structRead}{$nodeNumber} = \@tmpPositions;
        }
    };
    my $point01 = $structureNodes{$startStruct}{$startNode};
    my @point01 = @$point01;
    my $tmpRef = $point01[0];
    @point01 = @$tmpRef;
    my $point02 = $structureNodes{$endStruct}{$endNode};
    my @point02 = @$point02;
    $tmpRef = $point02[0];
    @point02 = @$tmpRef;
    my $distance = sqrt(($point02[0]-$point01[0])**2 + ($point02[1]-$point01[1])**2 + ($point02[2]-$point01[2])**2);
    return $distance;
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
sub getLineCoefficients(){
    my @getLineInputs = @_;
    my $pythonScriptFolder = 'C:\Users\rlh.PRDW\Documents\Projects\Mozambique" (1118) Northern Port BFS"\Programs\\';
    my $pythonScript = 'calculatePolyCoefficients.py';
    my $pythonPath = 'C:\Python27\Python.exe';
    my $runString = $pythonPath." ".$pythonScriptFolder.$pythonScript;
    my @results = `$runString @getLineInputs`;
    foreach (@results){
        $_ = &ltrim(&rtrim($_));
    }
return @results;
}
sub getWindCoefficients(){
    my $direction = $_[0];
    my $vesselCode = "GC";
    my $loadingCode = "B";
    my @Directions = (0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,
                      100,105,110,115,120,125,130,135,140,145,150,155,160,165,170,175,180);
    # WIND DRAG FORCE COEFFICIENTS
    # BALLAST CONDITIONS
    my @BCTWAFTGC = (0.00,0.10,0.20,0.30,0.41,0.56,0.70,0.86,1.02,1.15,1.28,1.39,1.50,1.58,1.67,1.74,1.80,
                 1.85,1.90,1.94,1.97,1.99,2.00,2.00,1.99,1.94,1.89,1.79,1.68,1.54,1.40,1.21,1.02,0.70,0.37,0.19,0.00);
    my @BCTWFWDGC = (0.00,0.23,0.46,0.66,0.86,1.06,1.25,1.42,1.59,1.67,1.75,1.80,1.84,1.85,1.86,1.85,1.83,
                 1.79,1.75,1.68,1.60,1.51,1.42,1.33,1.24,1.14,1.04,0.93,0.82,0.71,0.59,0.46,0.33,0.22,0.11,0.06,0.00);
    my @BCLWLATGC = (0.81,0.76,0.76,0.77,0.76,0.75,0.69,0.64,0.56,0.49,0.43,0.36,0.31,0.26,0.23,0.21,0.20,
                 0.19,0.00,-0.19,-0.26,-0.33,-0.39,-0.44,-0.49,-0.53,-0.57,-0.60,-0.62,-0.63,-0.63,-0.63,-0.62,-0.61,-0.59,-0.58);
    my @BCTWAFTCT = (-0.06,0.09,0.24,0.43,0.62,0.85,1.07,1.32,1.56,1.75,1.95,2.10,2.24,2.37,2.50,2.60,2.70,
                 2.78,2.85,2.91,2.97,3.01,3.05,3.07,3.09,3.03,2.96,2.77,2.57,2.31,2.04,1.72,1.41,1.07,0.74,0.43,0.13);
    my @BCTWFWDCT = (0.00,0.29,0.58,0.88,1.18,1.49,1.80,2.07,2.34,2.52,2.70,2.82,2.94,2.99,3.04,3.02,3.01,
                 2.95,2.90,2.81,2.73,2.61,2.48,2.34,2.19,2.01,1.83,1.64,1.45,1.23,1.01,0.78,0.56,0.37,0.19,0.07,-0.06);
    my @BCLWLATCT = (0.64,0.64,0.63,0.63,0.64,0.63,0.62,0.59,0.55,0.46,0.38,0.34,0.31,0.32,0.34,0.35,0.37,
                 0.35,0.34,0.31,0.28,0.23,0.19,0.13,0.07,-0.01,-0.09,-0.19,-0.28,-0.38,-0.47,-0.53,-0.59,-0.61,-0.64,-0.60,-0.57);
    my @BCTWAFTOC = (0.00,0.11,0.22,0.38,0.54,0.72,0.90,1.08,1.26,1.43,1.60,1.75,1.90,2.06,2.21,2.33,2.45,
                 2.53,2.62,2.67,2.72,2.73,2.74,2.73,2.71,2.65,2.58,2.41,2.25,2.02,1.80,1.54,1.29,0.99,0.69,0.35,0.00);
    my @BCTWFWDOC = (0.00,0.22,0.45,0.69,0.93,1.17,1.40,1.63,1.87,2.06,2.26,2.35,2.44,2.44,2.45,2.40,2.35,
                 2.26,2.17,2.04,1.91,1.77,1.62,1.46,1.29,1.12,0.96,0.82,0.67,0.53,0.40,0.30,0.20,0.14,0.07,0.04,0.00);
    my @BCLWLATOC = (1.20,1.11,1.03,0.94,0.85,0.75,0.65,0.55,0.45,0.37,0.29,-0.05,-0.38,-0.51,-0.64,-0.64,
                 -0.64,-0.51,-0.38,-0.26,-0.14,-0.18,-0.22,-0.30,-0.37,-0.43,-0.50,-0.56,-0.63,-0.68,-0.73,-0.77,-0.81,-0.82,-0.84,-0.82,-0.80);
    # LOADED CONDITIONS
    my @LCTWAFTGC = (0.00,0.13,0.26,0.39,0.52,0.66,0.79,0.93,1.06,1.19,1.32,1.40,1.49,1.55,1.61,1.66,1.71,1.74,
                 1.78,1.82,1.86,1.89,1.92,1.93,1.94,1.90,1.86,1.75,1.64,1.52,1.39,1.20,1.01,0.69,0.37,0.18,0.00);
    my @LCTWFWDGC = (0.00,0.18,0.35,0.52,0.68,0.85,1.02,1.17,1.33,1.43,1.52,1.57,1.62,1.64,1.65,1.65,1.64,1.61,
                 1.58,1.53,1.48,1.42,1.36,1.27,1.19,1.09,0.99,0.89,0.79,0.67,0.55,0.42,0.29,0.19,0.09,0.05,0.00);
    my @LCLWLATGC = (1.18,1.12,1.05,1.05,1.04,1.06,1.07,1.06,1.06,1.02,0.98,0.89,0.80,0.69,0.58,0.46,0.34,0.20,
                 0.07,-0.12,-0.31,-0.39,-0.47,-0.52,-0.57,-0.60,-0.64,-0.69,-0.73,-0.77,-0.81,-0.83,-0.85,-0.83,-0.81,-0.76,-0.71);
    my @LCTWAFTCT = (0.06,0.15,0.25,0.38,0.52,0.71,0.90,1.14,1.38,1.58,1.79,1.95,2.10,2.23,2.35,2.44,2.54,2.60,
                 2.67,2.72,2.76,2.79,2.81,2.82,2.83,2.77,2.71,2.51,2.31,2.02,1.72,1.40,1.08,0.78,0.49,0.28,0.08);
    my @LCTWFWDCT = (0.00,0.23,0.45,0.68,0.91,1.24,1.56,1.84,2.13,2.35,2.58,2.71,2.84,2.84,2.85,2.80,2.76,2.66,
                 2.57,2.46,2.36,2.25,2.14,2.02,1.89,1.74,1.58,1.42,1.26,1.05,0.84,0.62,0.40,0.25,0.09,0.01,-0.07);
    my @LCLWLATCT = (0.54,0.56,0.59,0.60,0.61,0.62,0.62,0.59,0.55,0.48,0.42,0.39,0.36,0.37,0.38,0.39,0.40,0.40,
                 0.40,0.36,0.33,0.25,0.16,0.04,-0.09,-0.24,-0.38,-0.50,-0.62,-0.69,-0.77,-0.69,-0.61,-0.56,-0.50,-0.51,-0.51);
    my @LCTWAFTOC = (0.00,0.11,0.21,0.37,0.54,0.71,0.89,1.07,1.25,1.39,1.53,1.63,1.74,1.82,1.91,1.97,2.04,2.09,
                 2.14,2.17,2.21,2.23,2.25,2.25,2.25,2.22,2.19,2.11,2.03,1.85,1.66,1.44,1.21,0.94,0.67,0.34,0.00);
    my @LCTWFWDOC = (0.00,0.07,0.13,0.23,0.32,0.44,0.56,0.68,0.80,0.89,0.97,1.04,1.10,1.14,1.18,1.19,1.20,1.18,
                 1.15,1.09,1.04,0.98,0.92,0.86,0.80,0.73,0.66,0.59,0.52,0.45,0.39,0.32,0.26,0.20,0.14,0.07,0.00);
    my @LCLWLATOC = (1.82,1.77,1.72,1.65,1.58,1.48,1.39,1.28,1.18,1.05,0.92,0.79,0.65,0.52,0.38,0.26,0.14,0.04,
                 -0.06,-0.15,-0.24,-0.31,-0.39,-0.47,-0.54,-0.63,-0.72,-0.83,-0.93,-1.06,-1.19,-1.29,-1.39,-1.42,-1.45,-1.42,-1.39);
    
}
sub getCurrentCoefficients(){
    
}