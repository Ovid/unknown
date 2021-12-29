use strict;
use warnings;

# ABSTRACT: Internal null value object for the "Unknown::Values" distribution

package Unknown::Values::Instance::Object;
use Unknown::Values::Instance;

my $CORE_UNKNOWN = Unknown::Values::Instance->new;

use Carp 'confess';
use base 'Unknown::Values::Instance';

sub to_string {
    confess("Attempt to coerce unknown value to a string");
}

sub isa     {$CORE_UNKNOWN}
sub can     {$CORE_UNKNOWN}
sub DOES    {$CORE_UNKNOWN}
sub VERSION {$CORE_UNKNOWN}

sub AUTOLOAD { $_[0] }

1;
