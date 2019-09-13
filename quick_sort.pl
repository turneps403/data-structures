#!/usr/local/bin/perl
use strict;
use warnings;

use Test::More;

$DB::signal = 1;

=pod

    Quicksort
    https://www.youtube.com/watch?v=MZaf_9IZCrc
    thanks for this video which made my comprehending of this algorithm clear

=cut

sub qsort {
    my $list = shift;
    return $list if @$list < 2;

    my $i = -1;
    my $p = $#$list;
    for my $j (0..$#$list-1) {
        if ($list->[$j] < $list->[$p]) {
            $i++;
            ($list->[$j], $list->[$i]) = ($list->[$i], $list->[$j]);
        }
    }
    ($list->[$i+1], $list->[$p]) = ($list->[$p], $list->[$i+1]);

    my $ret = [@{qsort([@$list[0..$i]])}, $list->[$i+1], @{qsort([@$list[$i+2..$#$list]])}];
    return $ret;
}

sub correct_sort {
    my $list = shift;
    [sort { $a <=> $b } @$list];
}

if ($0 eq __FILE__) {
    for (1..10) {
        my $list = [map { int(rand(1000)) } (1..1500)];
        is(join(',', @{qsort([@$list])}), join(',', @{correct_sort([@$list])}), "Test");

    }

    done_testing();

    exit;
}

