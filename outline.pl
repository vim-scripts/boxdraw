# outlines groups of similar characters
# 2003-11-24 15:07:28 Created by nsg
#
use strict;
use utf8;
use Getopt::Std;

our (
  $opt_s, # boxset
  $opt_d, # double each input character
  $opt_e, # output encoding
);
getopts("s:de:");
$opt_s='s' if '' eq $opt_s;
$opt_e='utf8' if '' eq $opt_e;

#binmode (STDIN, ":encoding($opt_e)");
#binmode (STDOUT, ":encoding($opt_e)");
#binmode (STDOUT, ":encoding(utf8)");
my $p='';

my $BOX=" \x{2502}\x{2500}\x{2514}\x{2502}\x{2502}\x{250c}\x{251c}\x{2500}\x{2518}\x{2500}\x{2534}\x{2510}\x{2524}\x{252c}\x{253c}";

while(<STDIN>){
  chomp;
  s/./$&$&/g if $opt_d;
  process_line();
  $p=$_;
}
$_='';
process_line();

sub process_line
{
  my $out;
  my $l=length;
  $l=length($p) if length($p)>$l;
  for my$i(0..$l) {
    my $c=0;
    $c|=1 if sc($p,$i-1) ne sc($p,$i);
    $c|=2 if sc($p,$i) ne sc($_,$i);
    $c|=4 if sc($_,$i) ne sc($_,$i-1);
    $c|=8 if sc($_,$i-1) ne sc($p,$i-1);
    $out.=substr($BOX,$c,1) if 's' eq $opt_s;
    $out.=sprintf"%1x",$c if 'h' eq $opt_s;
  }
  print "$out\n";
}

sub sc # (str, index)
{
  return ' ' if 0>$_[1] || $_[1]>=length($_[0]);
  return substr($_[0],$_[1],1);
}
