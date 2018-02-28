package Formalize2::Engine::CAndC;

use Capability::Tokenize;

use Lingua::EN::Sentence qw(get_sentences);
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / CAndCDir/

  ];

sub init {
  my ($self,%args) = @_;
  $self->CAndCDir('/var/lib/myfrdcsa/sandbox/candc-1.00/candc-1.00');
}

sub Execute {
  my ($self,%args) = @_;
}

sub Formalize {
  my ($self,%args) = @_;
  print "a\n";
  my $io1 = IO::File->new();
  $io1->open(">/tmp/candctext") or die;
  print $io1 tokenize_treebank($args{Text});
  $io1->close;
  print "b\n";
  my $io2 = IO::File->new();
  $io2->open(">/tmp/tmp.txt") or die;
  print "c\n";
  my $dir = `pwd`;
  my $qdir = shell_quote($self->CAndCDir);
  my $c1 =  "cd $qdir && bin/candc --input /tmp/candctext --models models/boxer > /tmp/test.ccg";
  print $io2 "$c1\n";
  system $c1;
  print "d\n";
  my $c2 = "cd $qdir && bin/boxer --input /tmp/test.ccg"; # --box true --flat true`;
  print $io2 "$c2\n";
  my $res1 = `$c2`;
  print "e\n";
  $io2->close;
  return $res1;
}

1;
