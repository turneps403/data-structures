#!/usr/bin/perl
use strict;
use warnings;

my $f_mem = {};
sub factor {
    my $int = shift;
    return 1 unless $int;
    return $f_mem->{$int} ||= $int * ($f_mem->{$int - 1} ||= factor($int - 1));
}

sub factor_perl {
    $_[0] ? $f_mem->{$_[0]} ||= $_[0] * ($f_mem->{$_[0] - 1} ||= factor($_[0] - 1)) : 1
}

sub factor_perl_pretty {
    $_[0] ?
            $f_mem->{$_[0]}
            ||= $_[0] * ($f_mem->{$_[0] - 1} ||= factor($_[0] - 1))
        :
            1
}

if ($0 eq __FILE__) {
    use Test::More;

    my $wiki_fac = {
        0 => 1,
        1 => 1,
        2 => 2,
        3 => 6,
        4 => 24
    };

    for (sort {$a <=> $b} keys %$wiki_fac) {
        is(factor_perl_pretty($_), $wiki_fac->{$_}, "Test with ${_}!");
    }

    done_testing();
}

exit;