#!/usr/bin/env perl
use strict;
use warnings;
use File::Path qw(remove_tree);
BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::Pipeline::Comparison::Generate::EvolvedSet');
}

ok(my $obj = Bio::Pipeline::Comparison::Generate::EvolvedSet->new(
  input_filename   => 't/data/reference.fa', 
  number_of_genomes => 5,
), 'initialise creating a set of evolved genomes with default output directory');
ok($obj->evolve, 'Create the evolved genomes');

ok(($obj->create_archive()),'Create a tgz archive');
ok((-e 'reference.tgz'), 'Check the archive exists'); 

ok((-d 'reference'), 'default output directory exists');
ok((-d 'reference/evolved_references'), 'evolved references directory');
ok((-d 'reference/vcfs'), 'vcfs directory');

ok((-e 'reference/evolved_references/reference.1.fa'), 'reference file exists');
ok((-e 'reference/evolved_references/reference.2.fa'), 'reference file exists');
ok((-e 'reference/evolved_references/reference.3.fa'), 'reference file exists');
ok((-e 'reference/evolved_references/reference.4.fa'), 'reference file exists');
ok((-e 'reference/evolved_references/reference.5.fa'), 'reference file exists');
        
ok((-e 'reference/vcfs/reference.1.vcf.gz'), 'vcf file exists');
ok((-e 'reference/vcfs/reference.2.vcf.gz'), 'vcf file exists');
ok((-e 'reference/vcfs/reference.3.vcf.gz'), 'vcf file exists');
ok((-e 'reference/vcfs/reference.4.vcf.gz'), 'vcf file exists');
ok((-e 'reference/vcfs/reference.5.vcf.gz'), 'vcf file exists');

unlink('reference.tgz');
remove_tree('reference');


done_testing();
