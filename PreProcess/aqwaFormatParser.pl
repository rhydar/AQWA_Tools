#!/usr/bin/perl -w
#use strict;
use Fortran::Format;
use Exporter;

=open
    Write correct format for catenary lines
=cut

@ISA=qw(Exporter);
@EXPORT=qw(COMP(@ARGV) ECAT(@ARGV) NLIN(@ARGV) BUOY(@ARGV) 
           CLMP(@ARGV) POLY(@ARGV) REST(@ARGV) FLIN(@ARGV)
           FDRX(@ARGV) FILE(@ARGV) CSTR(@ARGV) CPDB(@ARGV)
           FINI(@ARGV) FILM(@ARGV) STRT(@ARGV) POSX(@ARGV)
           ENDX(@ARGV) ZCGE(@ARGV));

sub COMP{
    my $COMP = Fortran::Format->new("A1,A3,A2,A4,I5,I5,A5,I5,3E10.3");
    my $tmp  = sprintf($COMP->write(@_));
    print STDOUT $tmp;
}

sub ECAT{
    my $ECAT = Fortran::Format->new("A1,A3,A2,A4,A20,E10.3,F10.3,2E10.3,F10.3");
    my $tmp  = sprintf($ECAT->write(@_));
    print STDOUT $tmp;
}

sub NLIN{
    my $NLIN = Fortran::Format->new("A1,A3,A2,A4,I5,I5,I5,I5,F10.3,F10.3,F10.3,F10.3");
    my $tmp  = sprintf($NLIN->write(@_));
    print STDOUT $tmp;
}

sub BUOY{
    my $BUOY = Fortran::Format->new("A1,A3,A2,A4,A10,A10,F10.3,F10.3,F10.3,F10.3");
    my $tmp  = sprintf($BUOY->write(@_));
    print STDOUT $tmp;
}

sub CLMP{
    my $CLMP = Fortran::Format->new("A1,A3,A2,A4,A10,A10,F10.3,F10.3,F10.3,F10.3");
    my $tmp  = sprintf($CLMP->write(@_));
    print STDOUT $tmp;
}

sub POLY{
    my $POLY = Fortran::Format->new("A1,A3,A2,A4,A20,5E10.3");
    my $tmp  = sprintf($POLY->write(@_));
    print STDOUT $tmp;
}

sub REST{
    my $REST = Fortran::Format->new("A7,A1,I3,I3,A6,A");
    my $tmp  = sprintf($REST->write(@_));
    print STDOUT $tmp;
}

sub FLIN{
    my $FLIN = Fortran::Format->new("A1,A3,A2,A4,A5,A5,3I5,A5,3I5");
    my $tmp  = sprintf($FLIN->write(@_));
    print STDOUT $tmp;
}

sub FDRX{
    my $FDRX = Fortran::Format->new("A4,A2,A4,A3,A1");
    my $tmp  = sprintf($FDRX->write(@_));
    print STDOUT $tmp;
}

sub FILE{
    my $FILE = Fortran::Format->new("A1,A3,A2,A4,A5,A5,A");
    my $tmp  = sprintf($FILE->write(@_));
    print STDOUT $tmp;
}

sub CSTR{
    my $CSTR = Fortran::Format->new("A1,A3,A2,A4,I5");
    my $tmp  = sprintf($CSTR->write(@_));
    print STDOUT $tmp;
}

sub CPDB{
    my $CPDB = Fortran::Format->new("A1,A3,A2,A4");
    my $tmp  = sprintf($CPDB->write(@_));
    print STDOUT $tmp;
}

sub FINI{
    my $FINI = Fortran::Format->new("A1,A3,A2,A4");
    my $tmp  = sprintf($FINI->write(@_));
    print STDOUT $tmp;
}

sub FILM{
    my $FILM = Fortran::Format->new("A1,A3,A2,A4,A10,A");
    my $tmp  = sprintf($FILM->write(@_));
    print STDOUT $tmp;
}

sub STRT{
    my $STRT = Fortran::Format->new("A4,A2,A4,A4");
    my $tmp  = sprintf($STRT->write(@_));
    print STDOUT $tmp;
}

sub POSX{
    my $POSX = Fortran::Format->new("A1,A3,A2,A4,A5,A5,6F10.3");
    my $tmp  = sprintf($POSX->write(@_));
    print STDOUT $tmp;
}

sub ENDX{
    my  $ENDX = Fortran::Format->new("A1,A3");
    my $tmp  = sprintf($ENDX->write(@_));
    print STDOUT $tmp;
}

sub POLY{
    my $POLY = Fortran::Format->new("A1,A3,A2,A4,A20,5E10.3");
    my $tmp  = sprintf($POLY->write(@_));
    print STDOUT $tmp;
}

sub ZCGE{
    my $ZCGE = Fortran::Format->new("A1,A3,A2,A4,A10,F10.3");
    my $tmp  = sprintf($ZCGE->write(@_));
    print STDOUT $tmp;
}
=open
Calling perl subroutine from shell script and pass @ARGV's

Perl script : a.pl

#!/usr/bin/perl -w

use Exporter;
@ISA = qw(Exporter);
@EXPORT=qw(a(@ARGV));
sub a{
my($a,$b)=@_;

print $a."\n";
print $b."\n";
}
1;

Shell script : b.sh
#/bin/bash -e
arg1=1;
arg2=2;
perl -e "require qw(a.pl) ; a($arg1, $arg2);"

run ./b.sh

output :
1
2
=cut