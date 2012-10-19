#!/usr/bin/env perl
use strict;
use warnings;
BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Pipeline::Comparison::Report::InputParameters');
}


ok((my $obj = Bio::Pipeline::Comparison::Report::InputParameters->new(
  known_variant_filenames    => ['t/data/expected_reference_only_CA.vcf.gz'], 
  observed_variant_filenames => ['t/data/expected_reference_only_CA.vcf.gz'])), 
  'Initialise the input parameter object'  
);
ok($obj->_validate_input_files, 'Input files are valid');

is_deeply($obj->known_to_observed_mappings, 
  [{ known_filename => 't/data/expected_reference_only_CA.vcf.gz', observed_filename => 't/data/expected_reference_only_CA.vcf.gz' }], 
  'correct pairs returned');

throws_ok( sub{ $obj->_check_files_exist(['file_doesnt_exist'])}, qr/Cant access the file/, 'File doesnt exist so throw an ' );
throws_ok( sub{ $obj->_check_varient_file_is_valid('t/data/expected_reference_only_CA.fa')}, qr/needs to be compressed with bgzip and indexed with tabix/, 'invalid file thows an error');



done_testing();
