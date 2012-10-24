#!/usr/bin/env perl
use strict;
use warnings;
use Cwd 'abs_path';
use Data::Dumper;
BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Pipeline::Comparison::Report::ParseVCFCompare');
}

ok((my $obj = Bio::Pipeline::Comparison::Report::ParseVCFCompare->new(
      known_variant_filename    => 't/data/no_overlap/known_no_overlap.vcf.gz', 
      observed_variant_filename => 't/data/no_overlap/observed_no_overlap.vcf.gz',
      'vcf_compare_exec'        => abs_path('bin/vcf-compare')
      )
    ), 'Initialise all variants the same');
my @expected_no_overlap =  (
          {
            'files_to_percentage' => [
                {
                  'percentage' => '100.0',
                  'file_name' => 't/data/no_overlap/observed_no_overlap.vcf.gz'
                }
              ],
              'number_of_sites' => '5'
          },
          {
            'files_to_percentage' => [
              {
                'file_name' => 't/data/no_overlap/known_no_overlap.vcf.gz',
                'percentage' => '100.0',
              }
            ],
            'number_of_sites' => '5'
          }
        );
is_deeply($obj->_raw_venn_diagram_results, \@expected_no_overlap, 'Results from no overlap' );



ok((my $obj_fn = Bio::Pipeline::Comparison::Report::ParseVCFCompare->new(
      known_variant_filename    => 't/data/false_negatives/known_false_negatives.vcf.gz', 
      observed_variant_filename => 't/data/false_negatives/observed_false_negatives.vcf.gz',
      'vcf_compare_exec'        => abs_path('bin/vcf-compare')
      )
    ), 'Initialise variants with false negatives');
my @expected_fn =  
  (
    {
      'files_to_percentage' => [
                                 {
                                   'file_name' => 't/data/false_negatives/known_false_negatives.vcf.gz',
                                   'percentage' => '40.0'
                                 }
                               ],
      'number_of_sites' => '2'
    },
    {
      'files_to_percentage' => [
                                 {
                                   'file_name' => 't/data/false_negatives/known_false_negatives.vcf.gz',
                                   'percentage' => '60.0'
                                 },
                                 {
                                   'file_name' => 't/data/false_negatives/observed_false_negatives.vcf.gz',
                                   'percentage' => '100.0'
                                 }
                               ],
      'number_of_sites' => '3'
    }
);

is_deeply($obj_fn->_raw_venn_diagram_results, \@expected_fn, 'Results from false negatives' );



ok((my $obj_fp = Bio::Pipeline::Comparison::Report::ParseVCFCompare->new(
      known_variant_filename    => 't/data/false_positives/known_false_positives.vcf.gz', 
      observed_variant_filename => 't/data/false_positives/observed_false_positives.vcf.gz',
      'vcf_compare_exec'        => abs_path('bin/vcf-compare')
      )
    ), 'Initialise variants with false positives');
my @expected_fp =  
  (
    {
      'files_to_percentage' => [
                                 {
                                   'file_name' => 't/data/false_positives/observed_false_positives.vcf.gz',
                                   'percentage' => '16.7'
                                 }
                               ],
      'number_of_sites' => '1'
    },
    {
      'files_to_percentage' => [
                                 {
                                   'file_name' => 't/data/false_positives/known_false_positives.vcf.gz',
                                   'percentage' => '100.0'
                                 },
                                 {
                                   'file_name' => 't/data/false_positives/observed_false_positives.vcf.gz',
                                   'percentage' => '83.3'
                                 }
                               ],
      'number_of_sites' => '5'
    }
);

is_deeply($obj_fp->_raw_venn_diagram_results, \@expected_fp, 'Results from false positives' );




ok((my $obj_fp_and_fn = Bio::Pipeline::Comparison::Report::ParseVCFCompare->new(
      known_variant_filename    => 't/data/false_positives_and_negatives/known_false_positives_and_negatives.vcf.gz', 
      observed_variant_filename => 't/data/false_positives_and_negatives/observed_false_positives_and_negatives.vcf.gz',
      'vcf_compare_exec'        => abs_path('bin/vcf-compare')
      )
    ), 'Initialise variants with false positives and false negatives');
my @expected_fp_and_fn =  
  (
    {
       'files_to_percentage' => [
                                  {
                                    'file_name' => 't/data/false_positives_and_negatives/observed_false_positives_and_negatives.vcf.gz',
                                    'percentage' => '25.0'
                                  }
                                ],
       'number_of_sites' => '1'
     },
     {
       'files_to_percentage' => [
                                  {
                                    'file_name' => 't/data/false_positives_and_negatives/known_false_positives_and_negatives.vcf.gz',
                                    'percentage' => '25.0'
                                  }
                                ],
       'number_of_sites' => '1'
     },
     {
       'files_to_percentage' => [
                                  {
                                    'file_name' => 't/data/false_positives_and_negatives/known_false_positives_and_negatives.vcf.gz',
                                    'percentage' => '75.0'
                                  },
                                  {
                                    'file_name' => 't/data/false_positives_and_negatives/observed_false_positives_and_negatives.vcf.gz',
                                    'percentage' => '75.0'
                                  }
                                ],
       'number_of_sites' => '3'
     }
);

is_deeply($obj_fp_and_fn->_raw_venn_diagram_results, \@expected_fp_and_fn, 'Results from false positives and false negatives' );



done_testing();

