#!/usr/bin/perl -w

use Formalize2::UniLang::Client;
# Formalize2
use KBS2::ImportExport;

use Data::Dumper;
use File::Slurp;

my $file = shift;
my $contents = read_file($file);

my $client = Formalize2::UniLang::Client->new
  ();
my $importexport = KBS2::ImportExport->new;

if (1) {
  my $res = $client->FormalizeText
    (
     Text => $contents,
     Engine => "CAndC",
    );
  print Dumper($res);
} else {
  my $res = $client->FormalizeText
    (
     Text => $contents,
    );
  my @all;
  if ($res->{Success}) {
    foreach my $res2 (@{$res->{Results}}) {
      if ($res2->{Success}) {
	my $res3 = $importexport->Convert
	  (
	   Input => $res2->{Output},
	   InputType => "Interlingua",
	   OutputType => "KIF String",
	   PrettyPrint => 1,
	  );
	if ($res3->{Success}) {
	  push @all, $res3->{Output};
	}
      }
    }
  }
  print join("\n\n",@all)."\n";
}

# Formalize2
