#!/usr/bin/perl -w

use UniLang::Agent::Agent;

use PerlLib::SwissArmyKnife;
use System::Cyc::ResearchCyc1_0::Java::CycAccess;

use Inline::Java qw(caught);

# my $contents = '(cyclify "This is a test of the system.")';
my $contents = '(cyclify "Modern computers support the Advanced Configuration and Power Interface (ACPI) to allow intelligent power management on your system and to query battery and configuration status.")';
print Dumper({"Formalize2WithResearchCyc::Contents" => $contents});

my $cycaccess = System::Cyc::ResearchCyc1_0::Java::CycAccess->new
  ();
# $cycaccess->cyc(System::Cyc::ResearchCyc1_0::Java::CycAccess::org::opencyc::api::CycAccess->new("justin.frdcsa.org",3614));

my $cyclist = $cycaccess->makeCycList($contents); # '(#$isa ?X #$Researcher)'),
# my $cyclist = $cycaccess->makeCycList('(#$isa ?X #$Researcher)'),
print Dumper($cyclist);
my $mt = $cycaccess->getKnownConstantByName("EverythingPSC");
my $properties;
eval {
  $properties = $cycaccess->createInferenceParams();
};
if ($@) {
  print $@->getMessage()."\n";
}


my $result;
eval {
  print Dumper($cycaccess->converseObject($cyclist)->toString());
} ;
if ($@) {
  print $@->getMessage."\n";
}
