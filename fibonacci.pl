#!/usr/local/bin/perl
use strict;
use warnings;

# choose your fibonacci
*fibonacci = \&fibonacci_in_prod;

sub fibonacci_in_prod {
    # time complexity O(1)
    my $n = shift;
    my $res = ( (1 + 5**0.5) / 2 )**$n / 5**0.5;
    return $res - int($res) < 0.5 ? int($res) : int($res) + 1;
}

my $_cache = {};
sub fibonacci_cahce {
    $_[0] < 2 ? $_[0] : ($_cache->{$_[0]} ||= (fibonacci($_[0]-1) + fibonacci($_[0]-2)));
}

sub fibonacci_perl_style {
    # time complexity O(2**k) cause every n will born subtree with 2 nodes
    # not sure but k is log(N), where N is total call of all recursions
    $_[0] < 2 ? $_[0] : (fibonacci($_[0]-1) + fibonacci($_[0]-2));
}

sub fibonacci_clear {
    my $n = shift;
    if ($n < 2) {
        return $n;
    } else {
        return fibonacci($n-1) + fibonacci($n-2)
    }
}

if ($0 eq __FILE__) {
    use Test::More;

    my $fib_test = {
        0  => 0,
        1  => 1,

        2  => 1,
        3  => 2,
        4  => 3,
        5  => 5,
        6  => 8,
        7  => 13,
        8  => 21,
        9  => 34,
        10 => 55,
        11 => 89,
        12 => 144
    };

    for (0 .. 12) {
        is(fibonacci($_), $fib_test->{$_}, "Test fibonacci with ${_}");
    }

    done_testing();
}


exit;
__DATA__