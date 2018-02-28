#!/usr/bin/perl -w

use Capability::TextAnalysis;
use Sayer;

use Data::Dumper;

my $sayer =
  Sayer->new
     (
      DBName => "sayer_test",
     );

my $ta = Capability::TextAnalysis->new
     (
      Sayer => $sayer,
      DontSkip => {
		   "Tokenization" => 1,
		   "TermExtraction" => 1,
		   "DateExtraction" => 1,
		   "NounPhraseExtraction" => 1,
		   "SemanticAnnotation" => 1,
		   "CoreferenceResolution" => 1,
		  },
     );

print Dumper
  ($ta->AnalyzeText
   (Text => "This is the first time I have tried this.  I wonder how well it will work.  Hopefully, well."));
