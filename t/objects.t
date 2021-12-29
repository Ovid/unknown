use Test::Most;

use lib 'lib', 't/lib';
use Unknown::Values 'object';
use UnknownUtils 'array_ok';

subtest 'Basics' => sub {
    my @cases = (
        {
            thing   => unknown,
            message => 'We should be able to get a NULL object',
        },
        {
            thing   => unknown->foo,
            message => 'Methods should return the NULL object',
        },
        {
            thing   => unknown->foo->bar->baz,
            message => 'Method chains should return the NULL object',
        },
        {
            thing   => unknown->isa('Unknown::Values::Instance::Object'),
            message => 'isa() should return an unknown',
            type    => 'Unknown::Values::Instance',
        },
        {
            thing   => unknown->can('some_method'),
            message => 'can() should return an unknown',
            type    => 'Unknown::Values::Instance',
        },
        {
            thing   => unknown->DOES('some_method'),
            message => 'DOES() should return an unknown',
            type    => 'Unknown::Values::Instance',
        },
        {
            thing   => unknown->VERSION('some_method'),
            message => 'VERSION() should return an unknown',
            type    => 'Unknown::Values::Instance',
        },
    );
    foreach my $case (@cases) {
        my $type = $case->{type} // 'Unknown::Values::Instance::Object';
        is ref $case->{thing}, $type, $case->{message};
    }
};

subtest 'Unknown::Values null objects should behave like `unknown`' => sub {
    ok !( 1 == unknown ), 'Direct comparisons to unknown should fail (==)';
    ok !( unknown == unknown ), '... and unknown should not be == to itself';
    ok !( unknown eq unknown ), '... and unknown should not be eq to itself';
    ok !( 2 <= unknown ), 'Direct comparisons to unknown should fail (<=)';
    ok !( 3 >= unknown ), 'Direct comparisons to unknown should fail (>=)';
    ok !( 4 > unknown ),  'Direct comparisons to unknown should fail (>)';
    ok !( 5 < unknown ),  'Direct comparisons to unknown should fail (<)';
    ok !( 6 != unknown ),
      'Direct negative comparisons to unknown should fail (!=)';
    ok !( 6 ne unknown ),
      'Direct negative comparisons to unknown should fail (ne)';
    ok !( unknown ne unknown ),
      'Negative comparisons of unknown to unknown should fail (ne)';
    my $value = unknown;
    ok is_unknown($value), 'is_unknown should tell us if a value is unknown';
    ok !is_unknown(42),    '... or not';

    my @array   = ( 1, 2, 3, $value, 4, 5 );
    my @less    = grep { $_ < 4 } @array;
    my @greater = grep { $_ > 3 } @array;

  # XXX FIXME Switched to array_ok because something about Test::Differences's
  # eq_or_diff is breaking this
    array_ok \@less, [ 1, 2, 3 ], 'unknown values are not returned with <';
    array_ok \@greater, [ 4, 5 ], 'unknown values are not returned with >';

    array_ok [ grep { is_unknown $_ } @array ], [unknown],
      '... but you can look for unknown values';
    my @sorted = sort { $a <=> $b } ( 4, 1, unknown, 5, unknown, unknown, 7 );
    array_ok \@sorted, [ 1, 4, 5, 7, unknown, unknown, unknown ],
      'Unknown values should sort at the end of the list';
    @sorted = sort { $b <=> $a } ( 4, 1, unknown, 5, unknown, unknown, 7 );
    array_ok \@sorted, [ unknown, unknown, unknown, 7, 5, 4, 1 ],
      '... but the sort to the front in reverse';
};

#package Person {
#    sub new {
#        my ( $class, %arg_for ) = @_;
#        if ( $arg_for{

done_testing;
