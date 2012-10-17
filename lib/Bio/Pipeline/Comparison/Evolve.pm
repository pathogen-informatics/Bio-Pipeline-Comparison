package Bio::Pipeline::Comparison::Evolve;

# ABSTRACT: Take in a reference genome and evolve it.

=head1 SYNOPSIS

Take in a reference genome and evolve it.

use Bio::Pipeline::Comparison::Evolve;
my $obj = Bio::Pipeline::Comparison::Evolve->new(input_filename => 'reference.fa');
$obj->evolve;
$obj->output_filename;

=method evolve

Evolve the genome and introduce variation.

=method output_filename

Name of the output file. By default it gets generated from the input filename, but you can also pass in a name.

=method _base_change_probability

A Hash containing the mutation probablity of different bases. Can pass in new values or just use the defaults.

=method _snp_rate

The probability of a SNP occuring. Set by default but can be overridden.

=method _evolve_base
Take in a base and randomly evolve it.

=head1 SEE ALSO

=for :list
* L<Bio::Pipeline::Comparison>

=cut

use Moose;
use Bio::SeqIO;

has 'input_filename'  => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_filename' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_output_filename' );

has '_base_change_probability'  => ( is => 'ro', isa => 'HashRef', lazy    => 1, builder => '_build__base_change_probability' );
has '_snp_rate'                 => ( is => 'ro', isa => 'Num',     default => '0.0005' );


# placeholder for proper evolutionary model
sub evolve {
    my ($self) = @_;

    my $in_fasta_obj  = Bio::SeqIO->new( -file => $self->input_filename,         -format => 'Fasta' );
    my $out_fasta_obj = Bio::SeqIO->new( -file => "+>" . $self->output_filename, -format => 'Fasta' );
    while ( my $seq = $in_fasta_obj->next_seq() ) {
        my $sequence_obj = Bio::Seq->new( -display_id => $seq->display_id, -seq => $self->_introduce_snps($seq) );
        $out_fasta_obj->write_seq($sequence_obj);
    }
    return $self;
}


sub _introduce_snps {
    my ( $self, $sequence_obj ) = @_;
    my $evolved_sequence = $sequence_obj->seq();
    for ( my $i =0; $i < length($evolved_sequence) ; $i++ ) {
      substr($evolved_sequence, $i, 1) = $self->_evolve_base(substr($evolved_sequence, $i, 1));
    }

    return $evolved_sequence;
}

sub _evolve_base
{
  my ($self, $base) = @_;
  if(rand(1) <= $self->_snp_rate )
  {
    
    if(defined($self->_base_change_probability->{uc($base)}))
    {
      my $found_base_probabilities  = $self->_base_change_probability->{uc($base)};
      my $base_rand_number = rand(1);
      my $lower_band = 0;
      for my $replacement_base ( keys %$found_base_probabilities)
      {
        
        if($base_rand_number >= $lower_band && $base_rand_number <  $lower_band + $found_base_probabilities->{$replacement_base})
        {
          return $replacement_base;
        }
        $lower_band += $found_base_probabilities->{$replacement_base};
      }
    }
  }
  return $base; 
}


sub _build_output_filename {
    my ($self) = @_;
    join( '.', ( $self->input_filename, 'evolved', 'fa' ) );
}

sub _build__base_change_probability {
    my ($self) = @_;

    # values taken from an evolver example
    my $change_probability = {
        'A' => {
            'C' => 0.25,
            'G' => 0.50,
            'T' => 0.25,
        },
        'C' => {
            'A' => 0.22,
            'G' => 0.22,
            'T' => 0.56
        }
    };
    return $change_probability;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
