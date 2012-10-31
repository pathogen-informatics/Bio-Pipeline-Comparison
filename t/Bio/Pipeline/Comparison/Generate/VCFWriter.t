#!/usr/bin/env perl
use strict;
use warnings;
BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Pipeline::Comparison::Generate::VCFWriter');
}

ok( my $obj = Bio::Pipeline::Comparison::Generate::VCFWriter->new( output_filename => 'my_snps.vcf.gz' ),
    'Initialise VCF writer' );
ok( $obj->add_snp( 1234, 'T', 'A', 'Chr1' ), 'Add a SNP' );
ok( $obj->add_snp( 1345,  'T', 'C', 'Chr2'  ), 'Add another SNP' );
ok( $obj->create_file(), 'Write the VCF file' );
ok( ( -e 'my_snps.vcf.gz' ), 'Output file exists' );
ok( ( -e 'my_snps.vcf.gz.tbi' ), 'Indexed output file exists' );
is( 'my_snps', $obj->evolved_name, 'reasonable default name' );

compare_files('t/data/expected_added_snps.vcf.gz', 'my_snps.vcf.gz');

unlink('my_snps.vcf.gz');
unlink('my_snps.vcf.gz.tbi');

done_testing();

sub compare_files {
    my ( $expected_file, $actual_file ) = @_;
    ok( ( -e $actual_file ),   ' results file exist' );
    ok( ( -e $expected_file ), " $expected_file expected file exist" );
    local $/ = undef;
    
    if($expected_file =~ /gz$/)
    {
      open( EXPECTED, "gunzip -c ".$expected_file.'|' );
    }
    else
    {
      open( EXPECTED, $expected_file );
    }
    if($actual_file =~ /gz$/)
    {
      open( ACTUAL,   "gunzip -c ".$actual_file.'|');
    }
    else
    {
      open( ACTUAL,   $actual_file );
    }
    my $expected_line = <EXPECTED>;
    my $actual_line   = <ACTUAL>;

    my @split_expected = split( /\n/, $expected_line );
    my @split_actual   = split( /\n/, $actual_line );
    my @sorted_expected = sort(@split_expected);
    my @sorted_actual   = sort(@split_actual);

    is_deeply( \@sorted_expected, \@sorted_actual, "Content matches expected $expected_file" );
}
