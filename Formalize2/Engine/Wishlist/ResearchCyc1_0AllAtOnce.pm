package Formalize2::Engine::ResearchCyc1_0;

use PerlLib::SwissArmyKnife;

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
  my $command = '/var/lib/myfrdcsa/codebases/internal/formalize/scripts/cyclify-sentences.pl -f '.shell_quote($self_>CycOutputFile).' 2> /dev/null';
  WriteFile($self->CycOutputFile,$args{Text});
  my $res = `$command`;
  my $result = DeDumper($res);
  return $result;
}

1;
