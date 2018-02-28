#!/usr/bin/perl -w

use Data::Dumper;
use Rival::String::Tokenizer2;

use Lingua::EN::Sentence qw(get_sentences);

print "Loading the Cyc2Synset mapping.\n";
my $c = `cat "/var/lib/myfrdcsa/codebases/internal/formalize/data/Cyc2Synset/cyc2synset.mapping.pl"`;
my $e = eval $c;
my $synset2cyc = {};
foreach my $ref (@$e) {
  $synset2cyc->{$ref->[1]} = $ref->[0];
}

print "Loading the Synset2QueryData mapping.\n";
$c = `cat "/var/lib/myfrdcsa/codebases/internal/formalize/data/Synset2QueryData/synset2querydata.mapping.pl"`;
$e = eval $c;
my $synset2querydata = $e->[0];
my $querydata2synset = $e->[1];

print "Done loading.\n";

# now extract all the different senses

my ($words, $pos, $num) = ({},{},{});
foreach my $key (keys %$querydata2synset) {
  my @tmp = split /#/, $key;
  $words->{$tmp[0]}->{$tmp[1]}->{$tmp[2]} = 1;
  $pos->{$tmp[1]} = 1;
  $num->{$tmp[2]} = 1;
}

print Dumper($pos,$num);
my $tokenizer = Rival::String::Tokenizer2->new;

foreach my $data (split /\n/, `cat test-sentences`) {
  foreach my $sentence (@{get_sentences($data)}) {
    # print $sentence."\n";
    # tokenize it here
    my $tokens = $tokenizer->Tokenize(Text => $sentence);
    foreach my $token (@$tokens) {
      Process($token);
    }
  }
}

sub Process {
  my $token = shift;
  my $key = $token;
  $key =~ s/ /_/g;
  if (! exists $words->{$key}) {
    $key = lc($key);
  }
  if (exists $words->{$key}) {
    # now retrieve all the sets
    my @res;
    foreach my $pos1 (keys %{$words->{$key}}) {
      foreach my $num1 (keys %{$words->{$key}->{$pos1}}) {
	# here they are
	push @res, "$key#$pos1#$num1";
      }
    }
    # print Dumper([$token,\@res]);
    my @res2;
    foreach my $item (@res) {
      my $synset = $querydata2synset->{$item};
      if (exists $synset2cyc->{$synset}) {
	push @res2, [$key,$synset,$synset2cyc->{$synset}];
      }
    }
    print Dumper(\@res2);
  } else {
    print $token."\n";
  }
}
