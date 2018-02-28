package Formalize2::Engine::ResearchCyc1_0;

use KBS2::Util;
use PerlLib::SwissArmyKnife;
use System::Cyc::Util;
use UniLang::Agent::Agent;

use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
  my $res = $UNIVERSAL::agent->QueryAgent
    (
     Receiver => "Cyc",
     Data => {
	      Connect => 1,
	      _DoNotLog => 1,
	     },
    );
  print Dumper($res) if $UNIVERSAL::debug;
}

sub Execute {
  my ($self,%args) = @_;
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
  my $contents = '(cyclify '.QuoteForCyclify(Text => $sentence).')';
  print Dumper({"Formalize2::Engine::ResearchCyc1_0->CyclifySentence/Contents" => $contents}) if $UNIVERSAL::debug;
  my $res = $UNIVERSAL::agent->QueryAgent
    (
     Receiver => "Cyc",
     Data => {
	      SubLQuery => $contents,
	      _DoNotLog => 1,
	     },
    );
  if (exists $res->{Data} and exists $res->{Data}{Result} and exists $res->{Data}{Result}[0]) {
    return $res->{Data}{Result}[0];
  } else {
    # FIXME: throw an error
  }
}

1;
