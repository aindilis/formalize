#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my @res;
my $c = read_file('temp.txt');
foreach my $line (split /\n/, $c) {
  $line =~ s/\(/ /sg;
  $line =~ s/\)/ /sg;
  if ($line =~ /^\d+:\d+\.\d+\s+(.+)$/) {
    push @res, $1;
  }
}
print join("\n",map {"(cyclify \"$_\")"} @res);
