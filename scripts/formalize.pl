#!/usr/bin/perl -w

use Formalize;

use Data::Dumper;

print "Loading Formalize.\n";
my $formalize = Formalize->new();

if (@ARGV) {
  my $f = shift;
  if (-f $f) {
    my $c = `cat "$f"`;
    $formalize->FormalizeText
      (Text => $c);
  }
} else {
  print "Accepting sentences from user.\n";
  while (1) {
    my $s = <STDIN>;
    chomp $s;
    $formalize->FormalizeText
      (Text => $s);
  }
}
