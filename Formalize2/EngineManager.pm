package Formalize2::EngineManager;

use Manager::Dialog qw(Message);
use PerlLib::Collection;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / ListOfEngines MyEngines /

  ];

sub init {
  my ($self,%args) = @_;
  Message(Message => "Initializing engines...");
  my $dir = "$UNIVERSAL::systemdir/Formalize2/Engine";
  my @names = sort map {$_ =~ s/.pm$//; $_} grep(/\.pm$/,split /\n/,`ls $dir`);
  $self->ListOfEngines(\@names);
  $self->MyEngines
    (PerlLib::Collection->new
     (Type => "Formalize2::Engine"));
  $self->MyEngines->Contents({});
  foreach my $name (@{$self->ListOfEngines}) {
    Message(Message => "Initializing Formalize2/Engine/$name.pm...");
    require "$dir/$name.pm";
    my $s = "Formalize2::Engine::$name"->new();
    $s->Execute();
    $self->MyEngines->Add
      ($name => $s);
  }
}

1;
