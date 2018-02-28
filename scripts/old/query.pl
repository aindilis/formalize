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
	    'org.opencyc.cycobject.CycVariable',
	    'org.opencyc.api.CycAccess',
	    'org.opencyc.cycobject.CycFort',
	   ],
  ;

print "Creating CycAcess object...\n";

my $cyc = org::opencyc::api::CycAccess->new("localhost", 3600);

print "Begin program.\n";

my $query = $cyc->current()->makeCycList
  ('(#$synonymousExternalConcept ?THING #$WordNet-Version2_0 "V00099639")');

my $thingVariable = org::opencyc::cycobject::CycVariable->new("THING");
# my $thingVariable = CycObjectFactory::makeCycVariable("?THING");

print Dumper($cyc->askWithVariable
  (
   $query,
   $thingVariable,
   $cyc->getConstantByName("WordNetMappingMt"),
  )->cyclify);

# print Dumper($cyc->getIsas($cyc->getKnownConstantByName("Person"))->cyclify);

# print "Closing connection to Cyc.\n";

$cyc->close();

