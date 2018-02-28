#!/usr/bin/perl -w

use PerlLib::WSD;

my $wsd = PerlLib::WSD->new();
while (1) {
  my $s = <STDIN>;
  chomp $s;
  $wsd->ProcessSentence
    (Sentence => $s);
}
