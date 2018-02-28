package Formalize2::Util::Preprocess;

use Capability::TextAnalysis;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MySayer MyTextAnalysis /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MySayer
    (Sayer->new
     (
      DBName => $args{DBName},
     ));

  $self->MyTextAnalysis
    (Capability::TextAnalysis->new
     (
      Sayer => $self->MySayer,
      DontSkip => {
		   "Tokenization" => 1,
		   "TermExtraction" => 1,
		   "DateExtraction" => 1,
		   "NounPhraseExtraction" => 1,
		  },
     ));
}

sub Preprocess {
  my ($self,%args) = @_;
  # analyze the text, normalize the dates, etc.  How do we do this,
  # actually, we're going to have to create an object that represents
  # text, and all the assertions about it....???
}

1;
