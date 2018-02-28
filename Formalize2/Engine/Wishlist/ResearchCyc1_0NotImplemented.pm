# sub Formalize2WithResearchCyc {
#   my ($self,%args) = @_;
#   my $sentence = $args{Sentence};
#   $sentence =~ s/"/\\"/g;
#   my $contents = "(cyclify \"$sentence\")";
#   print Dumper({"Formalize2WithResearchCyc::Contents" => $contents});
#   my $res = $UNIVERSAL::agent->QueryAgent
#     (
#      Receiver => "Cyc",
#      Contents => $contents,
#     );
#   print Dumper($res);
# }
