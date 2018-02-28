#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use KBS2::Util;
use PerlLib::SwissArmyKnife;
use PerlLib::Util;

use AI::Prolog::Parser;
use Data::Dumper;

my $text = read_file("output.txt");

my $rec = 0;
foreach my $line (split /\n/, $text) {
  if ($line =~ /^%%% /) {
    ++$rec;
  } elsif ($rec == 1) {
    if ($rec) {
      push @res, $line;
    }
  }
}

my $text2 = join("\n",@res);
$text2 =~ s/^\s*//s;

$text2 =~ s/\\\'/'/g;
$text = $text2;
print $text."\n";

my $context = "Org::FRDCSA::CHAP";
my $db = AI::Prolog::Parser->consult($text);
my $ie = KBS2::ImportExport->new;
my $client = KBS2::Client->new;

my @all;
my $i = 1;

foreach my $key (keys %{$db->{'ht'}}) {
  my $clause = $db->{'ht'}->{$key};
  do {
    my $item = $clause;
    my $string = $item->to_string;
    my $cleanedtext = $string;
    $cleanedtext =~ s/[\n\r\t]+/ /g;
    $cleanedtext =~ s/\s+/ /g;
    my @list;
    do {
      push @list, ConvertItemToKBS(Item => $item->term);
      $item = $item->next;
    } while (defined $item);
    my $length = scalar @list;
    if ($length > 1) {
      my $entailment = shift @list;
      push @all,
	(
	 # ["has-text", $i, $cleanedtext],
	 # ["rule", $i, ["entails",["and", @list], $entailment]],
	 ["implies",["and", @list], $entailment],
	);
      ++$i;
    } elsif ($length == 1) {
      push @all, $list[0];
    } else {
      print "WTF?\n";
    }
    $clause = $clause->{next_clause};
  } while (defined $clause);
}

$client->Send
  (
   Context => $context,
   ClearContext => 1,
   QueryAgent => 1,
  );
foreach my $assertion (@all) {
  my $res = $ie->Convert
    (
     Input => [$assertion],
     InputType => "Interlingua",
     OutputType => "KIF String",
    );
  if ($res->{Success}) {
    print $res->{Output}."\n";
  }
  print Dumper([$assertion]);
  if (0) {
    my $res2 = $client->Send
      (
       QueryAgent => 1,
       Assert => [$assertion],
       InputType => "Interlingua",
       Context => $context,
       Flags => {
		 AssertWithoutCheckingConsistency => 1,
		},
      );
  }
}

sub ConvertItemToKBS {
  my %args = @_;
  my @res;
  my $item = $args{Item};
  my $ref = ref $item;
  if ($ref eq "AI::Prolog::Term") {
    if (defined $item->{functor} and ! scalar @{$item->{args}}) {
      return $item->{functor};
    } elsif (defined $item->{functor} and scalar @{$item->{args}}) {
      push @res, $item->{functor};
      # now get out the args
      foreach my $arg (@{$item->{args}}) {
	push @res, ConvertItemToKBS(Item => $arg);
      }
      return \@res;
    } elsif (defined $item->{varname}) {
      my $varname = $item->{varname};
      return \*{"::?$varname"}
    }
  } elsif ($ref eq "AI::Prolog::Term::Number") {
    return $item->{functor};
  }
  # print Dumper($item);
  return $item;
}




# theoretical_range(piece(white, pawn), move, square(A, 2), square(A, 4)) :- 
# 	true
# ("theoretical_range" ("piece" "white" "pawn") "move" ("square" "A" "2") ("square" "A" "4"))
