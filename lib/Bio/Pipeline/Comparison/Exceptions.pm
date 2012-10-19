package Bio::Pipeline::Comparison::Exceptions;

use Exception::Class (
    Bio::Pipeline::Comparison::Exceptions::InvalidTabixFile         => { description => 'The VCF file needs to be compressed with bgzip and indexed with tabix.' },
    Bio::Pipeline::Comparison::Exceptions::FileDontExist            => { description => 'The file doesnt exist.'},
);  

1;