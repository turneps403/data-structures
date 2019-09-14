#!/usr/local/bin/perl
use strict;
use warnings;

$DB::signal = 1;

sub _merge {
    my ($left, $right) = @_;
    my @ret = ();

    while (@$left and @$right) {
        if ($left->[0] <= $right->[0]) {
            push @ret, shift @$left;
        } else {
            push @ret, shift @$right;
        }
    }
    push @ret, @$left, @$right;

    return @ret;
}

sub merge_sort {
    my @arr = @_;
    return @arr if @arr < 2;

    my @left = @arr[0 .. int($#arr/2)];
    my @right = @arr[int($#arr/2) + 1 .. $#arr];

    @left = merge_sort(@left);
    @right = merge_sort(@right);

    return _merge(\@left, \@right);
}

if ($0 eq __FILE__) {
    use Test::More;

    for (1..10) {
        my @list = map { int rand(200) } (1..5);
        is(join(',', merge_sort(@list)), join(',', sort{$a<=>$b} @list), "First test with ".join(',', @list));

        #my @sort_list = (5,61,165,165,175);
        #my @rand_list = (165,5,61,175,165);
        #is(join(',', merge_sort(@rand_list)), join(',', @sort_list), "First test with ".join(',', @rand_list));
    }
}

exit;