package Bio::Pipeline::Comparison::Report::InputParameters;

# ABSTRACT: Take in a set of input parameters for the evalute pipeline functionality, validate them, then manipulate them into a usable set.

=head1 SYNOPSIS

Take in a set of input parameters for the evalute pipeline functionality, validate them, then manipulate them into a usable set.

use Bio::Pipeline::Comparison::Report::InputParameters;
my $obj = Bio::Pipeline::Comparison::Report::InputParameters->new(known_variant_filenames => ['abc.1.vcf.gz'], observed_variant_filenames => ['efg.1.vcf.gz']);
$obj->known_to_observed_mappings

=method known_to_observed_mappings

Returns an array of hashes with pairs of filenames, including full paths, 'known_filename' for the known, and 'observed_filename' for the observed.

=head1 SEE ALSO

=for :list
* L<Bio::Pipeline::Comparison>

=cut

use Moose;
use Try::Tiny;
use Bio::SeqIO;
use Bio::Pipeline::Comparison::Exceptions;
use Vcf;

has 'known_variant_filenames'    => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'observed_variant_filenames' => ( is => 'ro', isa => 'ArrayRef', required => 1 );

has 'known_to_observed_mappings' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_known_to_observed_mappings' );

sub _build_known_to_observed_mappings
{
  my ($self) = @_;
  $self->_validate_input_files();
  my @known_to_observed_mappings;
  
  if(@{$self->known_variant_filenames} == 1)
  {
    #1 to N, expand into pairs
    for my $known_filename (@{$self->known_variant_filenames})
    {
      for my $observed_filename (@{$self->observed_variant_filenames})
      {
        push(@known_to_observed_mappings, { known_filename => $known_filename, observed_filename => $observed_filename });
      }
    }
  }
  elsif(@{$self->known_variant_filenames} == @{$self->observed_variant_filenames})
  {
    # N to N, pairs
    for(my $i = 0; $i < @{$self->known_variant_filenames}; $i++)
    {
      push(@known_to_observed_mappings, { known_filename => $self->known_variant_filenames->[$i], observed_filename => $self->observed_variant_filenames->[$i] });
    }
  }
  return \@known_to_observed_mappings;
}

sub _validate_input_files
{
   my ($self) = @_;
   $self->_check_files_exist($self->known_variant_filenames);
   $self->_check_files_exist($self->observed_variant_filenames);
   $self->_check_varient_files_are_valid($self->known_variant_filenames);
   $self->_check_varient_files_are_valid($self->observed_variant_filenames);
   1;
}

sub _check_files_exist
{
  my ($self, $filenames) = @_;
  for my $filename (@{$filenames})
  {
    unless(-e $filename)
    {
      Bio::Pipeline::Comparison::Exceptions::FileDontExist->throw( error => "Cant access the file $filename");
    }
  }
}

sub _check_varient_files_are_valid
{
  my ($self, $filenames) = @_;
  for my $filename (@{$filenames})
  {
     $self->_check_varient_file_is_valid($filename);
  }
}

sub _check_varient_file_is_valid
{
  my ($self, $filename) = @_;
  try{
    my $vcf = Vcf->new(file => $filename); 
    $vcf->get_chromosomes();
  }
  catch
  {
    Bio::Pipeline::Comparison::Exceptions::InvalidTabixFile->throw( error => "The VCF file $filename needs to be compressed with bgzip and indexed with tabix.");
  };
  
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

