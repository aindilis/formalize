#!/usr/bin/perl -w

use Data::Dumper;

# load the other map

# print "Loading the Cyc2Synset mapping.\n";
my $c = `cat "../Cyc2Synset/cyc2synset.mapping.pl"`;
my $e = eval $c;
my $synset2cyc = {};
foreach my $ref (@$e) {
  $synset2cyc->{$ref->[1]} = $ref->[0];
}


my $ref = {
	   A => 'data.adj',
	   R => 'data.adv',
	   N => 'data.noun',
	   V => 'data.verb',
	  };

my ($mapping, $imapping,$phrases) = ({},{});
foreach my $type (keys %$ref) {
  my $file = "/usr/local/WordNet-2.0/dict/".$ref->{$type};
  # print "<$file>\n";
  foreach my $line (split /\n/,`cat "$file"`) {
    if ($line =~ /^(\S+) (\S+) (\S+) (\S+) (\S+) (\S+) /) {
      # then we have an item
      my ($synsetid,$phrase,$index) = ($1,$5,$4);
      my $a = uc($type.$synsetid);
      if (exists $synset2cyc->{$a}) {
	$phrases->{$phrase}++;
	my $b = "$phrase#".lc($type)."#".$phrases->{$phrase};
	$mapping->{$a} = $b;
	$imapping->{$b} = $a;
      }
    } else {
      # print $line."\n";
    }
  }
}

print Dumper([$mapping,$imapping]);
