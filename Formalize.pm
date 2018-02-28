package Formalize;

use BOSS::Config;

use Capability::CoreferenceResolution;
use Capability::LogicForm;
# use Capability::TextAnalysis;
use Manager::Dialog qw(Message QueryUser);
use MyFRDCSA;

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);
use Text::Wrap qw(wrap $columns $huge);
use WordNet::QueryData;

# use WordNet::SenseRelate::AllWords;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => 
  [ qw /

	Config MyQueryData MySenseRelate Synset2Cyc QueryData2Synset
	Synset2QueryData MyLogicForm ResultsCache Type UseCoreferenceResolution
	CoreferenceResolver

	/ ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	-t <type>		Set the type

	-u [<host> <port>]	Run as a UniLang agent
";

  $UNIVERSAL::agent->DoNotDaemonize(1);
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"formalize");
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }
  $self->Type($conf->{'-t'} or "logicform");
  $self->ResultsCache({});
  if ($self->Type eq "logicform") {
    $self->MyLogicForm
      (Capability::LogicForm->new);
  } elsif ($self->Type eq "custom") {
    $self->LoadDBs;
    # $self->Calibrate;
    $columns = 100;
    print "Creating QueryData object\n";
    $self->MyQueryData
      (WordNet::QueryData->new("/usr/local/WordNet-2.0/dict"));
    my %options = (
		   wordnet => $self->MyQueryData,
		   measure => 'WordNet::Similarity::lesk',
		  );
    print "Creating SenseRelate object\n";
    $self->MySenseRelate
      (WordNet::SenseRelate::AllWords->new(%options));
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
  # do we pre-process it to avoid embarrassing terminological mistakes
  my $sentences = get_sentences($args{Text});
  my @res;
  foreach my $sentence (@$sentences) {
    $sentence =~ s/\s+/ /g;
    push @res, $self->FormalizeSentence
      (Sentence => $sentence);
  }
  return \@res;
}

sub SimpleProcessSentence {
  my ($self,%args) = @_;
  my $sentence = $args{Sentence};
  my @words;
  my @lint;
  # load a dictionary
  $sentence =~ s/\n/ /g;
  $sentence =~ s/\s+/ /g;
  $sentence =~ s/^\W*//;
  $sentence .= " ";
  my @i1 = $sentence =~ /(\w+)(\W+)/g;
  foreach my $s (@i1) {
    if ($s =~ /^\w+$/) {
      push @words, $s;
    } else {
      push @lint, $s;
    }
  }
  # now take words and wsd them
  if (@words and @words < 20) {
    my @res = $self->MySenseRelate->disambiguate (window => 2,
				  tagged => 0,
				  scheme => 'normal',
				  context => [@words],
				 );
    print join (' ', @res), "\n";
    return \@res;
    # do the seen thing
    my $i = 0;
    foreach my $wqd (@res) {
      my $word = $words[$i];
      my $lin = $lint[$i];
      if (! $seen->{$wqd}) {
	$seen->{$wqd} = 1;
	my @text = $self->MyQueryData->querySense("$wqd", "glos");
	my $glos;
	if (@text) {
	  $glos = $text[0];
	}
	if ($glos) {
	  # print "$word$lin\n".wrap("\t| $wqd - ", "\t| ", $glos)."\n";
	  my $constant = $wqd;
	  $constant =~ s/\#/-/g;
	  print "\#\$$constant ";
	} else {
	  print "?$word?$lin";
	}
      } else {
	print "$word$lin";
      }
      ++$i;
    }
    print "\n\n";
  }
}

sub ProcessSentence {
  my ($self,%args) = @_;
  my $sentence = $args{Sentence};
  my @words;
  my @lint;
  # load a dictionary
  $sentence =~ s/\n/ /g;
  $sentence =~ s/\s+/ /g;
  $sentence =~ s/^\W*//;
  $sentence .= " ";
  my @i1 = $sentence =~ /(\w+)(\W+)/g;
  foreach my $s (@i1) {
    if ($s =~ /^\w+$/) {
      push @words, $s;
    } else {
      push @lint, $s;
    }
  }
  # now take words and wsd them
  if (@words and @words < 20) {
    my @res = $self->MySenseRelate->disambiguate (window => 2,
				  tagged => 0,
				  scheme => 'normal',
				  context => [@words],
				 );
    # print join (' ', @res), "\n";
    # do the seen thing
    my $i = 0;
    foreach my $wqd (@res) {
      my $word = $words[$i];
      my $lin = $lint[$i];
      if (! $seen->{$wqd}) {
	$seen->{$wqd} = 1;
	my @text = $self->MyQueryData->querySense("$wqd", "glos");
	my $glos;
	if (@text) {
	  $glos = $text[0];
	}
	if ($glos) {
	  # print "$word$lin\n".wrap("\t| $wqd - ", "\t| ", $glos)."\n";
	  my $constant = $wqd;
	  $constant =~ s/\#/-/g;
	  print "\#\$$constant ";
	} else {
	  print "?$word?$lin";
	}
      } else {
	print "$word$lin";
      }
      ++$i;
    }
    print "\n\n";
  }
}

sub ConvertNaturalLanguageToInterLingua {
  my ($self,%args) = (@_);
  
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

sub FormalizeSentence {
  my ($self,%args) = @_;
  # we want to integrate enju here
  my $sentence = $args{Sentence};
  if (exists $self->ResultsCache->{$sentence}) {
    return $self->ResultsCache->{$sentence};
  } else {
    if (1) {
      $self->LoadCoreferenceResolver;
      my $res = $self->CoreferenceResolver->ReplaceCoreferences
	(Text => $sentence);
      $sentence = $res->{Text};
      print Dumper($sentence);
    }
    my $res;
    if ($self->Type eq "logicform") {
      $res = $self->MyLogicForm->LogicForm
	(Text => $sentence)->[0];

    } elsif ($self->Type eq "researchcyc") {
      $Data::Dumper::Useqq = 1;
      my $thing = Dumper($sentence);
      chomp $thing;
      my $item;
      if ($thing =~ /^\$VAR1 = (\[\s+)?(\"(.*)\")(\s+\])?;$/sm) {
	$item = $3;
      } elsif ($thing =~ /^\$VAR1 = (.+);$/) {
	$item = $1;
      }
      $Data::Dumper::Useqq = 0;
      # print "(cyclify-stanford \"$item\")"."\n";
      # print "Prequeryagent\n";
      $res = $UNIVERSAL::agent->QueryAgent
	(
	 Receiver => "OpenCyc",
	 Contents => "(cyclify-stanford \"$item\")",
	);
      # print "Postqueryagent\n";
    } elsif ($self->Type eq "custom") {
      foreach my $key (@{$self->SimpleProcessSentence
			   (Sentence => $sentence)}) {
	if (exists $self->QueryData2Synset->{$key}) {
	  my $synset = $self->QueryData2Synset->{$key};
	  if (exists $self->Synset2Cyc->{$synset}) {
	    my $cycl = PrettyGenerate
	      (Structure => $self->Synset2Cyc->{$synset});
	    $res .= "$key\t\t$synset\t\t$cycl\n";
	  } else {
	    $res .= "$key\t\t$synset\n";
	  }
	} else {
	  $res .= "$key\n";
	}
      }
    }
    $self->ResultsCache->{$sentence} = $res;
    return $res;
  }
}

sub Calibrate {
  my ($self,%args) = @_;
  foreach my $key (keys %{$self->QueryData2Synset}) {
    my $synset = $self->QueryData2Synset->{$key};
    if (exists $self->Synset2Cyc->{$synset}) {
      my $cycl = PrettyGenerate
	(Structure => $self->Synset2Cyc->{$synset});
      print "$key\t\t$synset\t\t$cycl\n";
    } else {
      print "$key\t\t$synset\n";
    }
  }
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};
  my $it = $m->Contents;
  if ($it) {
    # process the args in very much the same fashion as the regular args
    # for now, just do something simple
    if ($it =~ /^(quit|exit)$/i) {
      $UNIVERSAL::agent->Deregister;
      exit(0);
    }
    $UNIVERSAL::agent->SendContents
      (
       Receiver => $args{Message}->Sender,
       Data => {
		_DoNotLog => 1,
		Results => $self->FormalizeText(Text => $args{Message}->Contents),
	       },
      );
  }
  if (exists $m->Data->{_RPC_Sub}) {
    my $rpc_sub = $m->Data->{_RPC_Sub};
    my $sub = eval "sub {\$self->MyWSD->$rpc_sub(\@_)}";
    $UNIVERSAL::agent->SendContents
      (
       Receiver => $m->Sender,
       Data => {
		_DoNotLog => 1,
		_RPC_Results => [$sub->(@{$m->Data->{_RPC_Args}})],
	       },
      );
  }

}

sub Execute {
  my ($self,%args) = @_;
  print "Accepting sentences from user.\n";
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    # enter in to a listening loop
    while (1) {
      $UNIVERSAL::agent->Listen(TimeOut => 10);
    }
  } else {
    while (1) {
      my $s = <STDIN>;
      chomp $s;
      $self->FormalizeText
	(Text => $s);
    }
  }
}

sub LoadCoreferenceResolver {
  my ($self,%args) = @_;
  if (! $self->CoreferenceResolver) {
    $self->CoreferenceResolver
      (Capability::CoreferenceResolution->new);
  }
}


1;
