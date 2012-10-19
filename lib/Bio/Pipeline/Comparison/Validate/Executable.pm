package Bio::Pipeline::Comparison::Validate::Executable;

# ABSTRACT: Validates the executable is available in the path before running it

=head1 SYNOPSIS

Validates the executable is available in the path before running it

=method does_executable_exist

Returns true if the executable is available in the path

=head1 SEE ALSO

=for :list
* L<Bio::Pipeline::Comparison>

=cut

use Moose;
use File::Which;

sub does_executable_exist
{
  my($self, $exec) = @_;
  # if its a full path then skip over it
  return 1 if($exec =~ m!/!);

  my @full_paths_to_exec = which($exec);
  return 0 if(@full_paths_to_exec == 0);
  
  return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
