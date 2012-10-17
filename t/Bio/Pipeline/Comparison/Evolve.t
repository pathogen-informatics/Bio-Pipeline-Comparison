#!/usr/bin/env perl
use strict;
use warnings;
BEGIN { unshift( @INC, './lib' ) }
BEGIN {
    use Test::Most;
    use_ok('Bio::Pipeline::Comparison::Evolve');
}

# randomly evolve
ok(my $obj = Bio::Pipeline::Comparison::Evolve->new(input_filename => 't/data/reference.fa',_snp_rate => 0.1), 'initalise randome evolution');
ok($obj->evolve(), 'randomly evolve the genome');
is('t/data/reference.fa.evolved.fa', $obj->output_filename, 'Default output name');


# evolve towards a known value
my $base_change_probability = {
    'A' => {
        'G' => 1
    },
    'C' => {
        'T' => 1
    }
};

ok($obj = Bio::Pipeline::Comparison::Evolve->new(
  input_filename => 't/data/reference_only_CA.fa',
  _snp_rate => 1,
  _base_change_probability => $base_change_probability
), 'initalise known evolution');
ok($obj->evolve(), 'evolve the genome with known values');

compare_files('t/data/reference_only_CA.fa.evolved.fa', 't/data/expected_reference_only_CA.fa');

done_testing();

sub compare_files
{
  my($expected_file, $actual_file) = @_;
  ok((-e $actual_file),' results file exist');
  ok((-e $expected_file)," $expected_file expected file exist");
  local $/ = undef;
  open(EXPECTED, $expected_file);
  open(ACTUAL, $actual_file);
  my $expected_line = <EXPECTED>;
  my $actual_line = <ACTUAL>;
  
  my @split_expected  = split(/\n/,$expected_line);
  my @split_actual  = split(/\n/,$actual_line);
  my @sorted_expected = sort(@split_expected);
  my @sorted_actual  = sort(@split_actual);
  
  is_deeply(\@sorted_expected,\@sorted_actual, "Content matches expected $expected_file");
}
