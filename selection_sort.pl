#!/usr/local/bin/perl
use strict;
use warnings;

sub selection_sort {
    my @arr = @_;

    for my $i (0..$#arr-1) {
        my $test = $arr[$i];
        my $swap_i = $i;
        for my $j ($i+1 .. $#arr) {
            if ($test > $arr[$j]) {
                $swap_i = $j;
                $test = $arr[$j];
            }
        }
        ($arr[$i], $arr[$swap_i]) = ($arr[$swap_i], $arr[$i]);
    }

    return @arr;
}

if ($0 eq __FILE__) {
    use Test::More;

    #my @list = (4,2,5,64,35,21);
    #is(join(',', selection_sort(@list)), join(',', sort { $a <=> $b } @list), "Test with ".join(',',@list) );
    for (1.. 10) {
        my @list = map {int rand(100)} (1..10);
        is(join(',', selection_sort(@list)), join(',', sort { $a <=> $b } @list), "Test with ".join(',',@list) );
    }

    my @list = ();
    is(join(',', selection_sort(@list)), join(',', sort { $a <=> $b } @list), "Test with ".join(',',@list) );

    @list = (12);
    is(join(',', selection_sort(@list)), join(',', sort { $a <=> $b } @list), "Test with ".join(',',@list) );

    @list = (12,34,2);
    is(join(',', selection_sort(@list)), join(',', sort { $a <=> $b } @list), "Test with ".join(',',@list) );
}

exit;