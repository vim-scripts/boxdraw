# Convert +-| style drawings into utf characters
# 2003-11-24 10:12:22 created by nsg
use strict;
use utf8;
#binmode (STDOUT, ":utf8");
my $BOX=" \x{2502}\x{2500}\x{2514}\x{2502}\x{2502}\x{250c}\x{251c}\x{2500}\x{2518}\x{2500}\x{2534}\x{2510}\x{2524}\x{252c}\x{253c}\n";

my $prev='';
my $pprev='';
while(<STDIN>) {
  process_line();
}
process_line();

sub process_line
{
 my $out='';
 for(my $i=0; $i<length($prev); ++$i) {
   my $code=0;
   my $c=substr($prev,$i,1);
   if( $c=~/[-+\|]/ ) {
     $code |= 1 if substr($pprev,$i  ,1)=~/[\|+]/ ;
     $code |= 2 if substr($prev ,$i+1,1)=~/[-+]/ ;
     $code |= 4 if substr($_    ,$i  ,1)=~/[\|+]/ ;
     $code |= 8 if substr($prev ,$i-1,1)=~/[-+]/ ;

     $code |= 10 if $code && '-' eq $c;
     $code |= 5 if $code && '|' eq $c;
   }
   $out.=$code?substr($BOX,$code,1):$c;
 }
 print $out;
 $pprev=$prev;
 $prev=$_;
}

#
#  
#  0001 02
#  0010 00
#  0011 14
#  0100 02
#  0101 02
#  0110 0c
#  0111 1c
#  1000 00
#  1001 18
#  1010 00
#  1011 34
#  1100 10
#  1101 24
#  1110 2c
#  1111 3c
