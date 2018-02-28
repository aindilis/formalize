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
  print Dumper($res);
}

# "has-nlu-style-annotation function"

my $text = "A function has this predicate if there is a function which
  postprocesses the result into a style usable by the NLU system.";

LogicForm(Text => $text);
