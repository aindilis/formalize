package Formalize2::Engine::ResearchCyc1_0;

use BOSS::Config;
use PerlLib::SwissArmyKnife;
use PerlLib::ToText;
use System::Cyc::ResearchCyc1_0::Java::CycAccess;
use UniLang::Agent::Agent;

use Inline::Java qw(caught);
use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyCycAccess Mt Properties /

  ];

sub init {
  my ($self,%args) = @_;
  print "1\n";
  $self->MyCycAccess(System::Cyc::ResearchCyc1_0::Java::CycAccess->new());
}

sub Execute {
  my ($self,%args) = @_;
  print "2\n";
  $self->Mt($self->MyCycAccess->getKnownConstantByName("EverythingPSC"));
  print "3\n";
  eval {
    print "4\n";
    $self->Properties($self->MyCycAccess->createInferenceParams());
    print "5\n";
  };
  if ($@) {
    print "6\n";
    print $@->getMessage()."\n";
    print "7\n";
  }
  print "8\n";
}

sub Formalize {
  my ($self,%args) = @_;
  my $sentences = get_sentences($args{Text});
  my @results;
  foreach my $sentence (@$sentences) {
    push @results, $self->CyclifySentence(Sentence => $sentence);
  }
  return \@results;
}

sub CyclifySentence {
  my ($self,%args) = (@_);
  my $sentence = $args{Sentence};
  $sentence =~ s/\s+/ /sg;
  $sentence =~ s/^\s//s;
  $sentence =~ s/\s$//s;
  my $contents = '(cyclify "'.shell_quote($sentence).'")';
  my $cyclist = $self->MyCycAccess->makeCycList($contents);
  my $result;
  eval {
    $result = $self->MyCycAccess->converseObject($cyclist)->toString();
  } ;
  if ($@) {
    return [$sentence,'CYC_ERROR: '.$@->getMessage];
  } elsif ($result) {
    return [$sentence,$result];
  } else {
    return [$sentence,'CYC_UNKNOWN_ERROR'];
  }
}

1;
