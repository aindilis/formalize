#!/usr/bin/perl -w

use UniLang::Agent::Agent;

use PerlLib::SwissArmyKnife;


$UNIVERSAL::agent = UniLang::Agent::Agent->new
  (Name => "Formalize2-Client",
   ReceiveHandler => \&Receive);

$UNIVERSAL::agent->DoNotDaemonize(1);

$UNIVERSAL::agent->Register
  (Host => defined $conf->{-u}->{'<host>'} ?
   $conf->{-u}->{'<host>'} : "localhost",
   Port => defined $conf->{-u}->{'<port>'} ?
   $conf->{-u}->{'<port>'} : "9000");



sub Receive {
  my %args = @_;
  print Dumper({Args => \%args});
}

my $contents = "(cyclify \"This is a test of the system.\")";
print Dumper({"Formalize2WithResearchCyc::Contents" => $contents});

print "Accepting sentences from user.\n";
while (1) {
  my $s = <STDIN>;
  chomp $s;
  my $res = $UNIVERSAL::agent->QueryAgent
    (
     Receiver => "Formalize2",
     Data => {
	      Command => 'formalize',
	      Text => $s,
	      Method => 'ResearchCyc',
	   },
  );
  print Dumper($res);
}
