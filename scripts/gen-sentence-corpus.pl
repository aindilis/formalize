#!/usr/bin/perl -w

use PerlLib::MySQL;

use Data::Dumper;

my $mysql = PerlLib::MySQL->new
  (DBName => "unilang");

my $res = $mysql->Do(Statement => "select * from messages where Sender='UniLang-Client'");
foreach my $data (map {$_->{Contents}} values %$res) {
  if (length($data) > 50) {
    print $data."\n";
  }
}
