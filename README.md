# NAME

Unknown::Values - Use 'unknown' values instead of undef ones

# VERSION

version 0.102

# SYNOPSIS

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

Or:

    use Unknown::Values ':FATAL';
    my $value = unknown;

    if ( 3 < $value ) { ... } # fatal error

    if ( is_unknown $value ) { # not a fatal error
        ...
    }

Or:

    # see documentation Unknown::Values::Instance::Object
    use Unknown::Values ':OBJECT';    # NULL Object pattern

    my $employee = unknown;

    if ( $employee->salary < $threshold ) {
        # we will never get to here
    }

# DESCRIPTION

This code is alpha. Some behavior may change. The module name may change.

This module provides you with two new keywords, `unknown` and `is_unknown`.

`unknown` is conceptually similar to the SQL `NULL` value. From the point
of view of logic, this often an improvement over `undef` values. Consider the
following code, used to give underpaid employees a pay raise:

    foreach my $employee (@employees) {
        if ( $employee->annual_salary < $threshold ) {
            increase_salary($employee);
        }
    }

Who got a salary increase? Ordinarily that would be:

- Every employee with a salary less than `$threshold`.
- Every employee with an undefined salary.

Why are we giving salary increases to employees whose salary is undefined?
Consider the types of employees who might have undefined annual salaries:

- Unpaid interns
- Volunteers
- Hourly employees

    We don't know in advance how many hours a week they will work.

- CEO

    Maybe it's a private company so his salary is confidential.

- New employee

    Their salary has not yet been entered in the database.

If, however, the `$employee->salary` method returns `unknown`, the
comparison will _always_ return false, thus ensuring that anyone with an
unknown salary will not have their salary increased.

As another example, consider the following statements:

    my @numbers = ( 1,2,3,4,unknown,5,6,unknown,7 );
    my @less    = grep { $_ < 5 } @numbers; # 1,2,3,4
    my @greater = grep { $_ > 4 } @numbers; # 5,6,7

In other words, `unknown` comparisons return false because we can't know how
they compare to other values. Now replace the above with `undef`:

    my @numbers = ( 1,2,3,4,undef,5,6,undef,7 );
    my @less    = grep { $_ < 5 } @numbers; # 1,2,3,4,undef,undef
    my @greater = grep { $_ > 4 } @numbers; # undef,5,6,undef,7

In other words, you're probably getting garbage.

# EXPORTS

## `unknown`

    my $value = unknown;

A safer replacement for `undef`. Conceptually, `unknown` behaves very
similarly to SQL's `NULL`.

Note that comparisons will return false, but stringification is always a fatal
This ensures that you cannot accidentally use unknown values as hash keys or
array indices:

    my $unknown = Person->fetch($id);
    print $unknown;             # fatal
    $cache{$unknown}   = $id;   # fatal
    $ordered[$unknown] = $id;   # fatal

## `is_unknown`

    if ( is_unknown $value ) { ... }

Test if a value is `unknown`. Do _not_ use `$value->isa(...)` because
the class is blessed into is not guaranteed.

# FUNCTIONS

## `unknown`

Use `unknown` instead of `undef` when you don't want the value to default to
false.

## `is_unknown`

Test whether a given value is `unknown`.

    my $value1 = unknown;
    my $value2 = undef;
    my $value3 = 0;
    my $value4 = 1;

    if ( is_unknown $value1 ) {
        ... this is the only one for which this function returns true
    }

Defaults to `$_`:

    foreach (@things) {
        if ( is_unknown ) {
            # do something
        }
    }

If you have specified `use Unknown::Values ':FATAL'`, this is the _only_
safe use for `unknown` values. Any other use is fatal.

# NULL Objects

If you're a fan of the NULL object pattern, you can do this:

    use Unknown::Values ':OBJECT';

    my $unknown = unknown;
    if ( $unknown->foo->bar->baz > $limit ) {
        # we will never get here
    }

See [Unknown::Values::Instance::Object](https://metacpan.org/pod/Unknown%3A%3AValues%3A%3AInstance%3A%3AObject) for more information.

# SORTING

`unknown` values sort to the end of the list, unless you reverse the sort.

    my @sorted = sort { $a <=> $b } ( 4, 1, unknown, 5, unknown, unknown, 7 );
    eq_or_diff \@sorted, [ 1, 4, 5, 7, unknown, unknown, unknown ],
      'Unknown values should sort at the end of the list';
    my @sorted = sort { $b <=> $a } ( 4, 1, unknown, 5, unknown, unknown, 7 );
    eq_or_diff \@sorted, [ unknown, unknown, unknown, 7, 5, 4, 1 ],
      '... but the sort to the front in reverse';

This is a bit arbitrary, but some decision had to be made and I thought that
you'd rather deal with known values first:

    my @things = sort @other_things;
    foreach (@things) {
        last if is_unknown;
        # work with known values
    }

Note that if you specify `use Unknown::Values 'fatal'`, sorting an
unknown value is fatal.

# EQUALITY

An `unknown` value is equal to nothing becuase we don't know what it's value
is (duh). This means that if an employee's salary is unknown, the following
will **not** work:

    if ( $employee->salary == unknown ) { # eq fails, too
        ...
    }

Use the `is_unknown` function instead.

    if ( is_unknown $employee->salary ) {
        ...
    }

We also assume that inequality fails:

    if ( 6 != unknown ) {
        ... always false
    }
    if ( 'Ovid' ne unknown ) {
        ... always false
    }

**Note**: That's actually problematic because an unknown value should be equal
to itself but not equal to _other_ unknown values. From the standpoint of
pure logic, it's wrong, but it's so awfully convenient that we've allowed it.
We might revisit this.

Note that if you specify `use Unknown::Values 'fatal'`, testing for
equality is fatal.

# ILLEGAL OPERATIONS

Attempting to use `unknown` values in ways that don't make sense is a fatal
error (unless you specified `use Unknown::Values 'fatal'`, in which case,
using `unknown` values in _any_ way other than with `is_unknown` is fatal).

    my $value1;
    $value1 += 1; # results in 1

    my $value2 = unknown;
    $value2 += 1; # fatal

This is a side-effect of not allowing stuff like this if one of these values
is `unknown`.

    my $total = $price * $tax_rate;

If you want `+=` to work, properly initialize the variable to a value:

    my $value = 0;
    $value += 1;

# BUGS

Probably plenty.

# WARNING

Conditional assignment does not work, but THIS IS NOT A BUG!

    my $value = unknown;
    $value ||= 1;   # this is a no-op, as is //=
    $value++;       # fatal!

This is not a bug because we cannot positively state whether $value is true or
defined, thus meaning that `||=` and `//=` must both return `unknown`
values. To fix this, either assign a value when you declare the variable:

    my $value = 1;

Or test to see if it's `unknown`:

    $value = 1 if is_unknown $value;

# LOGIC

We follow Kleene's traditional 3VL (three-value logic). See `t/logic.t` for
verification.

Note that if you specify `use Unknown::Values 'fatal'`, all boolean
checks with `unknown` values are fatal. Use `is_unknown` to test for unknown
values.

## Logical Negation

    !unknown is unknown

## Logical And

    true    && unknown is unknown
    false   && unknown is false
    unknown && unknown is unknown

## Logical Or

    true    || unknown is true
    false   || unknown is unknown
    unknown || unknown is unknown

# WHAT IS WRONG WITH UNDEF?

Currently `undef` has three different coercions: false, zero, or the empty
string. Sometimes those are correct, but not always. Further, by design, it
doesn't always emit warnings:

    $ perl -Mstrict -Mwarnings -E 'my $foo; say ++$foo'
    1
    $ perl -Mstrict -Mwarnings -E 'my $foo; say $foo + 1'
    Use of uninitialized value $foo in addition (+) at -e line 1.
    1

And because it has no precise definition, `undef` might mean any of a number
of things:

- The value's not applicable
- It's not known
- It's not available
- It's restricted
- Something else?

In other words, the behavior of `undef` is overloaded, its meaning is
ambiguous and you are not guaranteed to have warnings if you use it
incorrectly.

Now think about SQL's `NULL` value. It's problematic, but no alternative has
taken hold for simple reason: its meaning is clear and its behavior is
unambiguous. It states quite clearly that 'if I don't have a value, I will
treat that value as "unknown" via a set of well-defined rules'.

An `unknown` value behaves very much like the SQL `NULL`. It's behavior is
consistent and predictable. It's meaning is unambiguous. If used incorrectly,
it's a fatal error.

# NOTES

See also:
[http://stackoverflow.com/questions/7078837/why-doesnt-sql-support-null-instead-of-is-null](http://stackoverflow.com/questions/7078837/why-doesnt-sql-support-null-instead-of-is-null)

This module is an attempt to squeeze three-value logic into Perl, even though
it's a bit of an awkward fit. Further, there are several reasons why something
could fail to have a value, including "not yet known" (what this module is
about), "not applicable" (something the programmer handles explicitly),
"privileged" (you can't have the credit card number), an
"empty set" (this is not zero), and so on. Empty sets are always equal to one another
(there is, technically, only one empty set), but which of the others should be
comparable?

`<undef == undef`> throws a warning, but allows the program to
continue. Is throws the warning because it can't know if this comparison is
appropriate or not. For the case of unknown values, we explicitly know the
comparison is not appropriate and thus we don't allow it.

# TODO

Should there be a `fatal` variant which dies even if you try to compare
unknown to something else? (Currently, we `confess()` if we try other,
improper operations such as math.

# AN INTERESTING THOUGHT

Should the `compare()` function return an `unknown` which returns false in
booleans? That might be useful when chaining boolean tests.

More importantly, should every `unknown` return a sequentially different
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

That has to be false because `6 != $value1` _must_ return a `unknown`
and `7 != $value1` should return a different unknown and their cascaded
unknown value should fail. However, the following _must_ be true:

    if ( ( 6 != $value1 ) == ( 6 != $value1 ) ) {
        ... always true!
    }

Because `6 != $value1` should always return the same `unknown`. Here's
why. We assume, for the sake of argument, that the unknown `$value1` has a
value, but we don't know it. Let's say that value is 4. The above reduces to
this:

    if ( ( 6 != 4 ) == ( 6 != 4 ) ) {

Since `6 != 4` is true, we get this:

    if ( 1 == 1 ) {

Ah, but what if `<$value1`>'s hidden value was actually 6? Then we get this:

    if ( ( 6 != 6 ) == ( 6 != 6 ) ) {

Since `6 != 6` is false, we get this:

    if ( 0 == 0 ) {

In other words, there's a lot of interesting things we could do, but this
would likely involve a fair amount of work breaking out the code for each and
every operator and ensuring that it's handled correctly.

Of course, this would eat up both memory and performance and certainly be
filled with fiddly bugs.

# AUTHOR

Curtis "Ovid" Poe <ovid@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2021 by Curtis "Ovid" Poe.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
