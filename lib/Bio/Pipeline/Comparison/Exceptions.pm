package Bio::Pipeline::Comparison::Exceptions;

# ABSTRACT: Custom exceptions

=head1 SYNOPSIS

Custom exceptions

=head1 SEE ALSO

=for :list
* L<Bio::Pipeline::Comparison>

=cut


use Exception::Class (
    Bio::Pipeline::Comparison::Exceptions::InvalidTabixFile         => { description => 'The VCF file needs to be compressed with bgzip and indexed with tabix.' },
    Bio::Pipeline::Comparison::Exceptions::FileDontExist            => { description => 'The file doesnt exist.'},
    Bio::Pipeline::Comparison::Exceptions::VCFCompare               => { description => 'Something when wrong when running vcf-compare'},
);  

1;