package Formalize2::Engine::Base;

use BOSS::Config;

use Capability::CoreferenceResolution::UniLang::Client;
use Capability::LogicForm;
use Capability::TextAnalysis;
use KBS2::ImportExport;
use Manager::Dialog qw(Message QueryUser);
use MyFRDCSA;
use PerlLib::ToText;

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);
use String::ShellQuote;
use Text::Wrap qw(wrap $columns $huge);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => 
  [ qw /

	Config Synset2Cyc QueryData2Synset Synset2QueryData
	MyLogicForm ResultsCache MyCoreferenceResolution MyImportExport
	MyToText PreprocessingOnly MySayer MyTextAnalysis

	/ ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	-f			Use the faster but less accurate 'Mogura' Enju

	-u [<host> <port>]	Run as a UniLang agent
";
  $UNIVERSAL::agent->DoNotDaemonize(1);
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"formalize");
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  $self->ResultsCache({});
  $self->LoadDBs;
  $self->MyImportExport
    (KBS2::ImportExport->new);

  $self->PreprocessingOnly
    ($args{PreprocessingOnly} || 0);
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }
}

sub StartServer {
  my ($self,%args) = @_;
  if (! defined $self->MyLogicForm and ! $self->PreprocessingOnly) {
    $self->MyLogicForm
      (Capability::LogicForm->new
       (
	Fast => exists $conf->{'-f'} || $args{Fast},
       ));
    $self->MyLogicForm->StartServer();
  }
}

sub LoadDBs {
  my ($self,%args) = @_;
  print "Loading the Cyc2Synset mapping.\n";
  my $c = `cat "$UNIVERSAL::systemdir/data/Cyc2Synset/cyc2synset.mapping.pl"`;
  my $e = eval $c;
  my $synset2cyc = {};
  foreach my $ref (@$e) {
    $synset2cyc->{$ref->[1]} = $ref->[0];
  }

  $self->Synset2Cyc($synset2cyc);

  print "Loading the Synset2QueryData mapping.\n";
  $c = `cat "$UNIVERSAL::systemdir/data/Synset2QueryData/synset2querydata.mapping.pl"`;
  $e = eval $c;
  my $synset2querydata = $e->[0];
  my $querydata2synset = $e->[1];
  $self->Synset2QueryData($synset2querydata);
  $self->QueryData2Synset($querydata2synset);
}

sub FormalizeText {
  my ($self,%args) = @_;
  # break a text down and wsd it, formalize it
  my $text = $args{Text};
  my @formulae;
  if ($args{CoreferenceResolution}) {
    # replace the text with resolved coreferences
    $self->LoadCoreferenceResolution;
    my $res = $self->MyCoreferenceResolution->ReplaceCoreferences
      (
       Text => $text,
       WithEntities => 1,
      );
    # add a more correct reconstruction of the text
    $text = join(" ", @{$res->{String}});

    print "Text: $text\n";
    # add formulae about the sets (coref entities), for instance,
    # "her" implies the entity is a female, etc., could also add
    # "named" or some such stuff
    # push @formulae, ["isa", ?X1, "Female"];

    # with RTE we need to capture these names in order to map entites
    # in the Hypothesis to the proper coref_entity
  }

  if ($args{TextAnalysis}) {
    if (! defined $self->MySayer) {
      $self->MySayer
	(Sayer->new
	 (
	  DBName => $args{DBName} || "sayer_formalize2_preprocessing",
	 ));
    }
    if (! defined $self->MyTextAnalysis) {
      $self->MyTextAnalysis
	(Capability::TextAnalysis->new
	 (
	  Sayer => $self->MySayer,
	  DontSkip => $args{TextAnalysis}->{DontSkip},
	 ));
    }
    my $results = $self->MyTextAnalysis->AnalyzeText
      (Text => $text);
    # now need to integrate this into the analysis somehow
    print Dumper($results);
    # do date normalization, among other things
  }

  if ($self->PreprocessingOnly) {
    return {
	    Success => 0,
	    Reasons => {
			"preprocessing only" => 1,
		       },
	   };
  }

  # do we pre-process it to avoid embarrassing terminological mistakes
  my $sentences = get_sentences($text);
  my @res;
  foreach my $sentence (@$sentences) {
    $sentence =~ s/\s+/ /g;
    push @res, $self->FormalizeSentence
      (
       Sentence => $sentence,
       OutputType => $args{OutputType},
       Method => $args{Method},
       WSD => $args{WSD},
      );
  }
  return {
	  Success => 1,
	  Results => \@res,
	 };
}

sub FormalizeSentence {
  my ($self,%args) = @_;
  if (! defined $self->MyLogicForm) {
    $self->StartServer;
  }

  my $sentence = $args{Sentence};

  # need to clean the sentence up a bit

  my $res;
  my $properties = Dumper(\%args);
  if (exists $self->ResultsCache->{$properties}->{$sentence}) {
    return $self->ResultsCache->{$properties}->{$sentence};
  } else {
    # we want to annotate the items with entity markup
    if ((! defined $args{Method}) or ($args{Method} eq "Custom")) {
      $res = $self->Formalize2WithCustom(%args);
    } elsif ($args{Method} eq "ResearchCyc") {
      $res = $self->Formalize2WithResearchCyc(%args);
    } elsif ($args{Method} eq "CAndC") {
      $res = $self->Formalize2WithCAndC(%args);
    } elsif ($args{Method} eq "RelEx") {
      $res = $self->Formalize2WithRelEx(%args);
    } elsif ($args{Method} eq "APE") {
      $res = $self->Formalize2WithAPE(%args);
    } elsif ($args{Method} eq "E2C") {
      $res = $self->Formalize2WithE2C(%args);
    } elsif ($args{Method} eq "CELT") {
      $res = $self->Formalize2WithCELT(%args);
    }
  }
  $self->ResultsCache->{$properties}->{$sentence} = $res;
  return $res;
}

sub PrettyGenerate {
  my (%args) = (@_);
  my $structure = $args{Structure};
  $args{Indent} = $args{Indent} || 0;
  my $retval;
  my $indentation = (" " x $args{Indent});
  if (ref $args{Structure} ne "ARRAY") {
    $retval = "$indentation$args{Structure}";
  } else {
    $retval = "$indentation(";
    my $total = scalar @$structure;
    my $cnt = 0;
    foreach my $x (@$structure) {
      ++$cnt;
      if (ref $x eq "ARRAY") {
	my $c = PrettyGenerate(Structure => $x,
			       Indent => $args{Indent} + 1);
	$retval .= "\n$c";
	# $retval .= "\n" unless $cnt == $total;
      } else {
	$retval .= "$x";
	$retval .= " " unless $cnt == $total;
      }
    }
    $retval .= ")";
  }
  return $retval;
}

sub FormalizeToFreeKBS {
  my ($self,%args) = @_;
  if ($args{File}) {
    return {
	    Success => 0,
	    Reasons => {
			"No such file" => 1,
		       },
	   } if ! -f $args{File};
  }
  # do various things here to ensure this is text
  if (! defined $self->MyToText) {
    $self->MyToText(PerlLib::ToText->new);
  }
  my $res = $self->MyToText->ToText
    (
     File => $args{File},
     String => $args{String},
    );
  if ($res->{Success}) {
    # now we take the result and formalize this, then add it to the KB
    my $text = $res->{Text};
    # need to clean the text up here a bit
    # blah blah blah FIXME
    my $res2 = $self->FormalizeText
      (
       Text => $text,
      );

    my $method = $args{Method} || "MySQL2";
    my $database = $args{Database} || "freekbs2";
    my $context = $args{Context} || "Formalize";
    my $store = "$method:$database:$context";

    foreach my $res2 (@{$res2->{Results}}) {
      if ($res2->{Success}) {
	# now we have the logic form, assert into the KB
	my $res3 = $self->MyImportExport->Convert
	  (
	   Input => $res2->{Output},
	   InputType => "Interlingua",
	   OutputType => "Emacs String",
	   PrettyPrint => 1,
	  );
	if ($res3->{Success}) {
	  my $command = "$store assert ".$res3->{Output};
	  print $command."\n";
	  # fix this for KBS2
	  $UNIVERSAL::agent->QueryAgent
	    (
	     Receiver => "KBS",
	     Contents => $command,
	     Data => {
		      _DoNotLog => 1,
		     },
	    );
	}
      }
    }
  }
}

sub Formalize2WithCustom {
  my ($self,%args) = @_;
  my $sentence = $args{Sentence};
  my $res2 = $self->MyLogicForm->LogicForm
    (
     Text => $sentence,
     Type => "Object",
     WSD => $args{WSD},
    );

  if ($res2->{Success}) {
    my @lfs;
    foreach my $hash (@{$res2->{Result}}) {
      my @lf;
      # now update the logic forms
      foreach my $word ($hash->{Sentence}->SortedWords) {
	if (defined $word->WQD and exists $word->WQD->{WQD}) {
	  my $res3 = $self->ConvertWQD2CycL
	    (
	     WQD => $word->WQD->{WQD},
	    );
	  if ($res3->{Success}) {
	    $word->CycL
	      ($res3->{Result});
	  }
	}
	$word->GenerateLogicForm;
	if (defined $word->LogicForm) {
	  push @lf, $word->LogicForm->Print;
	} else {
	  if (defined $word) {
	    # print "logicform undefined\n";
	  } else {
	    # print "word undefined\n";
	  }
	}
      }
      push @lfs, \@lf;
    }
    my $res4 = $self->MyImportExport->Convert
      (
       Input => \@lfs,
       InputType => "Logic Forms",
       OutputType => $args{OutputType} || "Interlingua",
      );
    return $res4;
  } else {
    return $res2;
  }
}

sub LoadCoreferenceResolution {
  my ($self,%args) = @_;
  if (! $self->MyCoreferenceResolution) {
    $self->MyCoreferenceResolution
      (Capability::CoreferenceResolution::UniLang::Client->new);
  }
}

1;
