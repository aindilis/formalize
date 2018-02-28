#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;
use PerlLib::ToText;
use System::Cyc::ResearchCyc1_0::Java::CycAccess;
use UniLang::Agent::Agent;

use Inline::Java qw(caught);
use Lingua::EN::Sentence qw(get_sentences);

$specification = q(
	-o		One at a time

	-f <files>...	Files to process
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

if (! exists $conf->{'-f'}) {
  die "Need to specify files\n";
}

foreach my $file (@{$conf->{'-f'}}) {
  if (! -f $file) {
    die "File doesn't exist: <$file>\n";
  }
}

my $cycaccess = System::Cyc::ResearchCyc1_0::Java::CycAccess->new();
my $mt = $cycaccess->getKnownConstantByName("EverythingPSC");
my $properties;
eval {
  $properties = $cycaccess->createInferenceParams();
};
if ($@) {
  print $@->getMessage()."\n";
}

my $totext = PerlLib::ToText->new();

my @results;
foreach my $file (@{$conf->{'-f'}}) {
  my $res = $totext->ToText(File => $file);
  if ($res->{Success}) {
    my $sentences = get_sentences($res->{Text});
    foreach my $sentence (@$sentences) {
      my $res = CyclifySentence(Sentence => $sentence);
      print Dumper($res) if exists $conf->{'-o'};
      push @results, $res;
    }
  }
}
print Dumper(\@results) unless exists $conf->{'-o'};

sub CyclifySentence {
  my (%args) = (@_);
  my $sentence = $args{Sentence};
  $sentence =~ s/\s+/ /sg;
  $sentence =~ s/^\s//s;
  $sentence =~ s/\s$//s;
  my $contents = '(cyclify "'.shell_quote($sentence).'")';
  my $cyclist = $cycaccess->makeCycList($contents);
  my $result;
  eval {
    $result = $cycaccess->converseObject($cyclist)->toString();
  } ;
  if ($@) {
    return [$sentence,'CYC_ERROR: '.$@->getMessage];
  } elsif ($result) {
    return [$sentence,$result];
  } else {
    return [$sentence,'CYC_UNKNOWN_ERROR'];
  }
}
