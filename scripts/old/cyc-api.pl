#!/usr/bin/perl

use strict; use warnings;
use Data::Dumper;

use CYCAPI;

BEGIN {
  $ENV{CLASSPATH} .= ":/opt/opencyc-1.0/api/java/build/OpenCyc.jar:/opt/opencyc-1.0/api/java/lib/jakarta-oro-2.0.4.jar";
}

print "Processing libraries...\n";

use Inline Java  => 'STUDY',
  STUDY => [
	    'java.util.ArrayList',
	    'org.opencyc.api.CycAccess',
	    'org.opencyc.cycobject.CycFort',
	   ],
  AUTOSTUDY => 1;

print "Creating CycAcess object...\n";

my $cyc = org::opencyc::api::CycAccess->new("localhost", 3600);

print "Begin program.\n";

# my $mt = $cyc->createMicrotheory
#   ("LordOfTheRingsMt",
#    "This microtheory describes the Lord Of The Rings'",
#    "Microtheory",
#    java::util::ArrayList->new());

print Dumper($cyc->getIsas($cyc->getKnownConstantByName("Person"))->cyclify);

print "Closing connection to Cyc.\n";

$cyc->close();

