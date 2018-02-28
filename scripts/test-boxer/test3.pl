#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $text = read_file("output.txt");



my $rec = 0;
foreach my $line (split /\n/, $text) {
  if ($line =~ /^%%% /) {
    ++$rec;
  } elsif ($rec == 1) {
    if ($rec) {
      push @res, $line;
    }
  }
}

my $text2 = join("\n",@res);
$text2 =~ s/^\s*//s;

print $text2."\n";
