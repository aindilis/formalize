#!/usr/bin/perl -w

use Data::Dumper;

use System::Enju;

my $enju = System::Enju->new;

$enju->StartServer;
while ($i = <>) {
  chomp $i;
  print Dumper
    ($enju->ApplyEnjuToSentence
     (
      Sentence => $i,
      Type => "LogicForm",
     ));
}
