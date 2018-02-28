#!/usr/bin/perl -w

use Data::Dumper;

sub Parse {
  my ($c) = (@_);
  $c =~ s/;.*//mg;
  my $tokens = [split //,$c];
  my $cnt = 0;
  my $stack = [];
  my $symbol = "";
  my $isstring = 0;
  do {
    $char = shift @$tokens;
    if ($char =~ /\"/) {
      if ($isstring) {
	$isstring = 0;
	if (length $symbol) {
	  push @{$stack->[$cnt]},'"'.$symbol.'"';
	  $symbol = "";
	}
      } else {
	$isstring = 1;
      }
    } elsif ($isstring) {
      $symbol .= $char;
    } elsif ($char =~ /\(/) {
      ++$cnt;
      $stack->[$cnt] = [];
      $symbol = "";
    } elsif ($char =~ /[\s\n]/) {
      if (length $symbol) {
	push @{$stack->[$cnt]},$symbol;
	$symbol = "";
      }
    } elsif ($char =~ /\)/) {
      # now $stack->[$cnt] holds all of  our objects, and so just have
      # to move those into the right place
      if (length $symbol) {
	push @{$stack->[$cnt]},$symbol;
	$symbol = "";
      }
      my @a = @{$stack->[$cnt]};
      $stack->[$cnt] = undef;
      --$cnt;
      push @{$stack->[$cnt]}, \@a;
    } else {
      if ($char !~ /\s/) {
	$symbol .= $char;
      }
    }
  } while (@$tokens);
  $domain = $stack->[0];
  if (! defined $domain and defined $symbol) {
    return [$symbol];
  }
  return $domain;
}

my $c = `cat cyc-to-synset.raw`;
my $p = Parse($c);
my @res;
foreach my $e (@{$p->[0]}) {
  $e->[1] =~ s/"//g;
  push @res, $e;
}
print Dumper(\@res);
