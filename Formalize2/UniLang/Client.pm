package Formalize2::UniLang::Client;

# see Formalize2;

use UniLang::Util::TempAgent;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyTempAgent Receiver /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyTempAgent
    (UniLang::Util::TempAgent->new
     (
      RandName => "Formalize2-Client",
     ));
  $self->Receiver("Formalize2");
  my @res = $self->MyTempAgent->MyAgent->QueryAgent
    (
     Receiver => $self->Receiver,
     Data => {
	      StartServer => 1,
	      Fast => $args{Fast},
	     },
    );
}

sub StartServer {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "StartServer",
     _RPC_Args => [%args],
    );
  return $res[0];
}

sub FormalizeText {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "FormalizeText",
     _RPC_Args => [%args],
    );
  return $res[0];
}

sub FormalizeToFreeKBS {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "FormalizeToFreeKBS",
     _RPC_Args => [%args],
    );
  return $res[0];
}

1;
