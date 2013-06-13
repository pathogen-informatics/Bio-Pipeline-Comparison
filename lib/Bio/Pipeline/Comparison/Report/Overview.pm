package Bio::Pipeline::Comparison::Report::Overview;

# ABSTRACT: Aggregate together the results of multiple VCF comparisons

=head1 SYNOPSIS

Aggregate together the results of multiple VCF comparisons

   use Bio::Pipeline::Comparison::Report::Overview;
   my $obj = Bio::Pipeline::Comparison::Report::Overview->new(
     known_to_observed_mappings    => [
       {
         known_filename    => 'known.1.vcf.gz', 
         observed_filename => 'observed.1.vcf.gz'
         }
     ],
   );
   $obj->total_false_positives;
   $obj->total_false_negatives;

=head1 SEE ALSO

=for :list
* L<Bio::Pipeline::Comparison>

=cut

use Moose;
use Bio::Pipeline::Comparison::Report::ParseVCFCompare;

has 'known_to_observed_mappings'    => ( is => 'rw', isa  => 'ArrayRef', required => 1 );
has 'vcf_compare_exec'              => ( is => 'ro', isa  => 'Bio::Pipeline::Comparison::Executable', default => 'vcf-compare' );

has '_parse_vcf_comparison_objects' => ( is => 'rw', isa  => 'ArrayRef[Bio::Pipeline::Comparison::Report::ParseVCFCompare]', lazy => 1, builder => '_build__parse_vcf_comparison_objects' );


sub total_false_positives
{
  my ($self) = @_;
  my $total_fp = 0 ;
  for my $parse_vcf_object (@{$self->_parse_vcf_comparison_objects})
  {
    $total_fp += $parse_vcf_object->number_of_false_positives;
  }
  return $total_fp;
}

sub total_false_negatives
{
  my ($self) = @_;
  my $total_fn = 0 ;
  for my $parse_vcf_object (@{$self->_parse_vcf_comparison_objects})
  {
    $total_fn += $parse_vcf_object->number_of_false_negatives;
  }
  return $total_fn;
}

sub total_number_of_known_variants
{
  my ($self) = @_;
  my $total_fn = 0 ;
  for my $parse_vcf_object (@{$self->_parse_vcf_comparison_objects})
  {
    $total_fn += $parse_vcf_object->number_of_known_variants;
  }
  return $total_fn;
}


sub report_to_str
{
  my ($self) = @_;
  my $output = "";
  $output =  join("\t", ("Known","Observed", "Variants", "No. FP", "No. FN", 'FP%', 'FN%' )). "\n";

  for my $parse_vcf_object (@{$self->_parse_vcf_comparison_objects})
  {
    $output .= $self->_format_report_row(
      $parse_vcf_object->known_variant_filename,
      $parse_vcf_object->observed_variant_filename,
      $parse_vcf_object->number_of_known_variants,
      $parse_vcf_object->number_of_false_positives, 
      $parse_vcf_object->number_of_false_negatives
    ) . "\n";
  }
  
  
  $output .= $self->_format_report_row("","Total",
    $self->total_number_of_known_variants,
    $self->total_false_positives, 
    $self->total_false_negatives
  ) . "\n";
  
  return $output;
}


sub _format_report_row
{
   my ($self, $known_name, $observed_name, $num_variants, $fp, $fn ) = @_;
   return join("\t", 
     ($known_name, 
       $observed_name,
       $num_variants,
       $fp, 
       $fn,
       $fp*100/$num_variants,
       $fn*100/$num_variants  
     )
   );
}

sub _build__parse_vcf_comparison_objects
{
  my ($self) = @_;
  my @parse_vcf_comparision_objects;
  
  for my $known_to_observed_filenames (@{$self->known_to_observed_mappings})
  {
    my $parse_vcf = Bio::Pipeline::Comparison::Report::ParseVCFCompare->new(
      known_variant_filename    => $known_to_observed_filenames->{known_filename},
      observed_variant_filename => $known_to_observed_filenames->{observed_filename},
      vcf_compare_exec          => $self->vcf_compare_exec
    );
    push(@parse_vcf_comparision_objects,$parse_vcf);
  }
  return \@parse_vcf_comparision_objects;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
