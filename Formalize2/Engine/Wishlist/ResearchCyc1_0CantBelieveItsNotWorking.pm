package Formalize2::Engine::ResearchCyc1_0;

use PerlLib::SwissArmyKnife;

use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / CycOutputFile /

  ];

sub init {
  my ($self,%args) = @_;
  $self_>CycOutputFile("/tmp/rcyc10.input");
}

sub Execute {
  my ($self,%args) = @_;
}

sub Formalize {
  my ($self,%args) = @_;
  my $sentences = get_sentences($args{Text});
  my @results;
  foreach my $sentence (@$sentences) {
    push @results, $self->Cyclify(Text => $sentence);
  }
  return \@results;
}

sub Cyclify {
  my ($self,%args) = @_;
  my $command = '/var/lib/myfrdcsa/codebases/internal/formalize/scripts/cyclify-sentences.pl -f '.shell_quote($self_>CycOutputFile).' 2> /dev/null';
  WriteFile($self->CycOutputFile,$args{Text});
  print $command."\n";
  my $res = `$command`;
  print Dumper($res);
  my $result = DeDumper($res);
  return $result;
}

1;
