use strict;
use warnings;

# ABSTRACT: Internal value object for the "Unknown::Values" distribution

package Unknown::Values::Instance;
use Carp 'confess';

use 5.01000;
my @to_overload;

BEGIN {
    my %to_overload = (
        compare     => [qw{ <=> cmp <= >= < > lt le gt ge == eq != ne}],
        math        => [qw{ + - * / ** atan2 cos sin exp log sqrt int abs }],
        string      => [qw{ qr x }],
        files       => [qw{ <> -X }],
        bits        => [qw{ << >> & | ^ ~ }],
        bool        => [ 'bool', '!' ],
        dereference => [qw< ${} @{} %{} &{} *{} >],
        nomethod    => ['nomethod'],
    );
    while ( my ( $method, $ops ) = each %to_overload ) {
        push @to_overload => $_ => $method foreach @$ops;
    }
}

use overload @to_overload, '""' => sub {'[unknown]'};

sub new {
    my $class = shift;
    state $unknown = bless {} => __PACKAGE__;
    return $unknown;
}

sub bool { __PACKAGE__->new }

sub compare {

    # this suppresses the "use of unitialized value in sort" warnings
    wantarray ? () : 0;
}
sub math { confess("Math cannot be performed on unknown values") }

sub dereference {
    confess("Dereferencing cannot be performed on unknown values");
}

sub files {
    confess("File operations cannot be performed on unknown values");
}

sub string {
    confess("String operations cannot be performed on unknown values");
}

sub bits {
    confess("Bit manipulation cannot be performed on unknown values");
}

sub nomethod {
    if ( defined( my $operator = $_[3] ) ) {
        confess("'$operator' operations are not allowed with unknown values");
    }
    else {

        # XXX seems bit manipulation can trigger this
        confess("Illegal operation performed on unknown value");
    }
}

1;

__END__

=head1 DESCRIPTION

For Internal Use Only! See L<Unknown::Values>.
