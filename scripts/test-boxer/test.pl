#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::CAndC;

my $candc = System::CAndC->new;

sub LogicForm {
  my (%args) = @_;
  my $res = $candc->NonServerLogicForm
    (
     Text => $args{Text},
    );
  return $res;
}

# "has-nlu-style-annotation function"

my $start = "A function has this predicate if there is a function which
  postprocesses the result into a style usable by the NLU system.";

print "hi\n";
my $text = LogicForm(Text => $start);
print "hi\n";

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

print $text2."\n";
