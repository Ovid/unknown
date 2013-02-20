use strict;
use warnings;

# ABSTRACT: Use 'unknown' values instead of undef ones

package Unknown::Values;

use 5.01000;
use Unknown::Values::Instance;

use base 'Exporter';
use Scalar::Util 'blessed';
our @EXPORT = qw(unknown is_unknown);
use constant unknown => Unknown::Values::Instance->new;

sub is_unknown(_) {
    defined $_[0]
      && blessed( $_[0] )
      && $_[0]->isa("Unknown::Values::Instance");
}

1;

__END__

=head1 SYNOPSIS

    use Unknown::Values;

    my $value = unknown;
    my @array = ( 1, 2, 3, $value, 4, 5 );
    my @less    = grep { $_ < 4 } @array;   # (1,2,3)
    my @greater = grep { $_ > 3 } @array;   # (4,5)

    my @underpaid;
    foreach my $employee (@employees) {
        
        # this will never return true if salary is "unknown"
        if ( $employee->salary < $threshold ) {
            push @underpaid => $employee;
        }
    }

=head1 EXPORTS

=head2 C<unknown>

    my $value = unknown;

A safer replacement for C<undef>. Conceptually, C<unknown> behaves very
similarly to SQL's C<NULL>.

=head2 C<is_unknown>

    if ( is_unknown $value ) { ... }

Test if a value is C<unknown>. Do I<not> use C<< $value->isa(...) >> because
the class is blessed into is not guaranteed.

=head1 DESCRIPTION

This code is alpha. Some behavior may change. The module name may change.

This module provides you with two new keywords, C<unknown> and C<is_unknown>.
From the point of view of logic, the is often an improvement over C<undef>
values. Consider the following code, used to give underpaid employees a pay
raise:

    foreach my $employee (@employees) {
        if ( $employee->annual_salary < $threshold ) {
            increase_salary($employee);
        }
    }

Who got a salary increase? Ordinarily that would be:

=over 4

=item * Every employee with a salary less than C<$threshold>.

=item * Every employee with an undefined salary.

=back

Why are we giving salary increases to employees whose salary is undefined?
Consider the types of employees who might have undefined annual salaries:

=over 4

=item * Unpaid interns

=item * Volunteers

=item * Hourly employees

We don't know in advance how many hours a week they will work.

=item * CEO

Maybe it's a private company so his salary is confidential.

=item * New employee

Their salary has not yet been entered in the database.

=back

If, however, the C<< $employee->salary >> method returns C<unknown>, the
comparison will I<always> return false, thus ensuring that anyone with an
unknown salary will not have their salary increased.

As another example, consider the following statements:

    my @numbers = ( 1,2,3,4,unknown,5,6,unknown,7 );
    my @less    = grep { $_ < 5 } @numbers; # 1,2,3,4
    my @greater = grep { $_ > 4 } @numbers; # 5,6,7

In other words, C<unknown> comparisons return false because we can't know how
they compare to other values. Now replace the above with C<undef>:

    my @numbers = ( 1,2,3,4,undef,5,6,undef,7 );
    my @less    = grep { $_ < 5 } @numbers; # 1,2,3,4,undef,undef
    my @greater = grep { $_ > 4 } @numbers; # undef,5,6,undef,7

In other words, you're probably getting garbage.

=head1 FUNCTIONS

=head2 C<unknown>

Use C<unknown> instead of C<undef> when you don't want the value to default to
false.

=head2 C<is_unknown>

Test whether a given value is C<unknown>.

    my $value1 = unknown;
    my $value2 = undef;
    my $value3 = 0;
    my $value4 = 1;

    if ( is_unknown $value1 ) {
        ... this is the only one for which this function returns true
    }

=head1 EQUALITY

An C<unknown> value is equal to nothing becuase we don't know what it's value
is (duh). This means that if an employee's salary is unknown, the following
will B<not> work:

    if ( $employee->salary == unknown ) { # eq fails, too
        ...
    }

Use the C<is_unknown> function instead.

    if ( is_unknown $employee->salary ) {
        ...
    }

We also assume that inequality holds fails:

    if ( 6 != unknown ) {
        ... always false
    }
    if ( 'Ovid' ne unknown ) {
        ... always false
    }

B<Note>: That's actually problematic because an unknown value doesn't mean a
non-existent value, just an unknown one, so the value I<might> be equal, but
we don't know it. From the standpoint of pure logic, it's wrong, but it's so
awfully convenient that we've allowed it. We might revisit this.

=head1 ILLEGAL OPERATIONS

Attempting to use C<unknown> values in ways that don't make sense is a fatal
error.

    my $value1;
    $value1 += 1; # results in 1

    my $value2 = unknown;
    $value2 += 1; # fatal

This is a side-effect of not allowing stuff like this if one of these values
is C<unknown>.

    my $total = $price * $tax_rate;

If you want C<+=> to work, properly initialize the variable to a value:

    my $value = 0;
    $value += 1;

=head1 BUGS

Probably plenty.

=head1 WARNING

Conditional assignment does not work, but THIS IS NOT A BUG!

    my $value = unknown;
    $value ||= 1;   # this is a no-op, as is //=
    $value++;       # fatal!

This is not a bug because we cannot positively state whether $value is true or
defined, thus meaning that C<||=> and C<//=> must both return C<unknown>
values. To fix this, either assign a value when you declare the variable:

    my $value = 1;

Or test to see if it's C<unknown>:

    $value = 1 if is_unknown $value;

=head1 LOGIC

We follow Kleene's traditional 3VL (three-value logic). See C<t/logic.t> for
verification.

=head2 Logical Negation

    !unknown is unknown

=head2 Logical And

    true    && unknown is unknown
    false   && unknown is false
    unknown && unknown is unknown

=head2 Logical Or

    true    || unknown is true
    false   || unknown is unknown
    unknown || unknown is unknown

=head1 NOTES

See also:
L<http://stackoverflow.com/questions/7078837/why-doesnt-sql-support-null-instead-of-is-null>

This module is an attempt to squeeze three-value logic into Perl, even though
it's a bit of an awkward fit. Further, there are several reasons why something
could fail to have a value, including "not yet known" (what this module is
about), "not applicable" (something the programmer handles explicitly),
"privileged" (you can't have the credit card number), an
"empty set" (this is not zero), and so on. Empty sets are always equal to one another
(there is, technically, only one empty set), but which of the others should be
comparable?

C<<undef == undef>> throws a warning, but allows the program to
continue. Is throws the warning because it can't know if this comparison is
appropriate or not. For the case of unknown values, we explicitly know the
comparison is not appropriate and thus we don't allow it.

=head1 TODO

Should there be a C<fatal> variant which dies even if you try to compare
unknown to something else? (Currently, we C<confess()> if we try other,
improper operations such as math.

=head1 AN INTERESTING THOUGHT

Should the C<compare()> function return an C<unknown> which returns false in
booleans? That might be useful when chaining boolean tests.

More importantly, should every C<unknown> return a sequentially different
unknown and thus allow me to say that an unknown is equal to itself but not
equal to other unknowns?  this means that we could do this:

    my $value1 = unknown;
    my $value2 = $value1;

    if ( $value1 == $value2 ) {
        ... always true because it's an instance of a *single* unknown
    }

But that gets confusing because we then have this:

    if ( $value1 == unknown ) {
        ... always false because unknown generates a new unknown
    }

So an unknown sometimes equals unknowns and sometimes doesn't. It only matches
an unknown if it's itself. On the surface this actually seems to be correct,
except that we then have this:

    if ( ( 6 != $value1 ) == ( 7 != $value1 ) ) {
        ... always false
    }

That has to be false because C<< 6 != $value1 >> I<must> return a C<unknown>
and C<< 7 != $value1 >> should return a different unknown and their cascaded
unknown value should fail. However, the following I<must> be true:

    if ( ( 6 != $value1 ) == ( 6 != $value1 ) ) {
        ... always true!
    }

Because C<< 6 != $value1 >> should always return the same C<unknown>. Here's
why. We assume, for the sake of argument, that the unknown C<$value1> has a
value, but we don't know it. Let's say that value is 4. The above reduces to
this:

    if ( ( 6 != 4 ) == ( 6 != 4 ) ) {

Since C<< 6 != 4 >> is true, we get this:

    if ( 1 == 1 ) {

Ah, but what if C<<$value1>>'s hidden value was actually 6? Then we get this:

    if ( ( 6 != 6 ) == ( 6 != 6 ) ) {

Since C<< 6 != 6 >> is false, we get this:

    if ( 0 == 0 ) {

In other words, there's a lot of interesting things we could do, but this
would likely involve a fair amount of work breaking out the code for each and
every operator and ensuring that it's handled correctly.

Of course, this would eat up both memory and performance and certainly be
filled with fiddly bugs.
