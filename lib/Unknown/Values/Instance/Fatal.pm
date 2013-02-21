use strict;
use warnings;

# ABSTRACT: Internal fatal value object for the "Unknown::Values" distribution

package Unknown::Values::Instance::Fatal;
use Carp 'confess';
use base 'Unknown::Values::Instance';

sub bool {
    confess("Boolean operations not allowed with 'fatal unknown' objects");
}

sub compare {
    confess("Comparison operations not allowed with 'fatal unknown' objects");

}

sub sort {
    confess("Sorting operations not allowed with 'fatal unknown' objects");
}

sub to_string {
    confess("Printing not allowed with 'fatal unknown' objects");
}

1;
