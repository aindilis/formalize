#!/usr/bin/perl -w

use KBS::Client;
use KBS::Util qw(FormulaToString PrettyPrintSubL);

use Data::Dumper;

my $logicforms =
  [
   [
    'this (x1)',
    'be (e4, x1, e6)',
    'first (e6)',
    'time (e6)',
    'I (x2)',
    'have (e5, x2, e6)',
    'try (e6, x2, x3)',
    'this (x3)'
   ],
   [
    'I (x1)',
    'wonder (e3, x1, e4)',
    'how (e4)',
    'well (e4)',
    'it (x2)',
    'work (e4, x2)'
   ],
  ];

my $kbs = KBS::Client->new;

foreach my $logicform (@$logicforms) {
  my @logicformula = ("and");
  foreach my $line (@$logicform) {
    if ($line =~ /^(.+) \((.+)\)$/) {
      my @formula;
      my $predicate = $1;
      push @formula, $predicate;
      my $variables = $2;
      foreach my $var (split /, /,$variables) {
	push @formula, \*{"::?$var"};
      }
      push @logicformula, \@formula;
    } else {
      print "ERROR\n";
      print Dumper($logicform);
    }
  }
  print PrettyPrintSubL
    (String => FormulaToString
     (
      Type => "Emacs",
      Formula => \@logicformula,
     ))."\n";
  $kbs->Send
    (
     Method => "MySQL2",
     Database => "freekbs2",
     Context => "default",
     Assert => \@logicformula,
    );
}
