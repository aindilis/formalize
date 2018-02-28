#!/usr/bin/perl -w

use UniLang::Agent::Agent;

use PerlLib::SwissArmyKnife;
use System::Cyc::ResearchCyc1_0::Java::CycAccess;

use Inline::Java qw(caught);

my $debug = 0;

print "Loading cyc\n" if $debug;
my $cycaccess = System::Cyc::ResearchCyc1_0::Java::CycAccess->new();
print "Done loading cyc\n" if $debug;

my $result;
eval {
  print "Starting Query\n" if $debug;
  $result = $cycaccess->getImpreciseParaphrase
    ('(#$siblings #$Hera-TheGoddess #$Demeter-TheGoddess)');
};
if ($@) {
  print $@->getMessage."\n";
}

print $result."\n";

my $result1;
eval {
  print "Starting Query\n" if $debug;
  $result1 = $cycaccess->getImpreciseParaphrase
    ('(#$siblings #$Hera-TheGoddess #$Demeter-TheGoddess)');
};
if ($@) {
  print $@->getMessage."\n";
}

print $result1."\n";
