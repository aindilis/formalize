#!/usr/bin/perl -w

my $string = '((#$and (#$isa (#$InstanceFn "?ANDREW2") #$MaleHuman) (#$givenNames
(#$InstanceFn "?ANDREW2") "Andrew") (#$isa ?WAS3 (#$ThingDescribableAsFn
(#$WordFn "here") #$Adverb)) :COMPLEMENT) (#$and (#$isa (#$InstanceFn
"?ANDREW2") #$HomoSapiens) (#$lastName (#$InstanceFn "?ANDREW2") "Andrew")
(#$isa ?WAS3 (#$ThingDescribableAsFn (#$WordFn "here") #$Adverb))
:COMPLEMENT))';

# my $string2 = '(#$isa ?X #$Andy)';
# use KBS::Util qw(PrettyPrintSubL);

# print PrettyPrintSubL
#   (String => $string);

use Manager::Misc::Light;

my $m = Manager::Misc::Light->new;
my $domain = $m->Parse
  (Contents => $string);

print $m->PrettyGenerate(Structure => $domain)."\n";
