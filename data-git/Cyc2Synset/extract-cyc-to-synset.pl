#!/usr/bin/perl

use strict; use warnings;
use Data::Dumper;

use CYCAPI;

BEGIN {
  $ENV{CLASSPATH} .= ":/opt/opencyc-1.0/api/java/build/OpenCyc.jar:/opt/opencyc-1.0/api/java/lib/jakarta-oro-2.0.4.jar";
}

print "Processing libraries...\n";

use Inline Java  => 'STUDY',
  AUTOSTUDY => 1,
  STUDY => [
	    'java.util.ArrayList',
	    'java.util.AbstractList$Itr',
	    'org.opencyc.cycobject.CycVariable',
	    'org.opencyc.api.CycAccess',
	    'org.opencyc.cycobject.CycFort',
	   ],
  ;
use Inline::Java qw(cast) ;

print "Creating CycAcess object...\n";

my $cyc = org::opencyc::api::CycAccess->new("localhost", 3600);

print "Begin program.\n";

my $query = $cyc->current()->makeCycList
  ('(#$synonymousExternalConcept ?THING #$WordNet-Version2_0 ?CHARACTERSTRING)');

my $thingVariable = org::opencyc::cycobject::CycVariable->new("THING");
# my $thingVariable = CycObjectFactory::makeCycVariable("?THING");
my $characterstringVariable = org::opencyc::cycobject::CycVariable->new("CHARACTERSTRING");

my $variables = java::util::ArrayList->new();
$variables->add($thingVariable);
$variables->add($characterstringVariable);

my $response = $cyc->askWithVariables
  (
   $query,
   $variables,
   $cyc->getConstantByName("WordNetMappingMt"),
  );

my $iterator = $response->iterator();
print Dumper($response->cyclify);
exit(0);
my $hash = {};
while ($iterator->hasNext()) {
  my $item = $iterator->next();
  $hash->{$item->first()->toString} = $item->second()->toString;
}
print Dumper($hash);

print "Closing connection to Cyc.\n";

$cyc->close();
