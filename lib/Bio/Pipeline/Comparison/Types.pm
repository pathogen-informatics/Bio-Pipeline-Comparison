package Bio::Pipeline::Comparison::Types;

# ABSTRACT: Moose types to use for validation

=head1 SYNOPSIS

Moose types to use for validation

=head1 SEE ALSO

=for :list
* L<Bio::Pipeline::Comparison>

=cut

use Moose;
use Moose::Util::TypeConstraints;
use Bio::Pipeline::Comparison::Validate::Executable;

subtype 'Bio::Pipeline::Comparison::Executable',
  as 'Str',
  where { Bio::Pipeline::Comparison::Validate::Executable->new()->does_executable_exist($_) };


no Moose;
no Moose::Util::TypeConstraints;
__PACKAGE__->meta->make_immutable;
1;
