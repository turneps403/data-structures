#!/usr/local/bin/perl
use strict;
use warnings;

=pod

    Algorithm explain
    https://www.youtube.com/watch?v=MtQL_ll5KhQ&list=PLqM7alHXFySHrGIxeBOo4-mKO4H8j2knW&index=1

=cut

$DB::signal = 1;

sub _refresh_heap_from_head {
    my $heap = shift;
    return if @$heap < 2;

    my $check_arr_pos = 0;
    while ($check_arr_pos < @$heap) {
        my $left_heap_pos = ($check_arr_pos + 1) << 1;
        my $right_heap_pos = (($check_arr_pos + 1) << 1) | 1;
        my $left_arr_pos = $left_heap_pos - 1;
        last if $left_arr_pos > $#$heap;
        my $right_arr_pos = $right_heap_pos - 1;

        my $side_arr_pos = $left_arr_pos;
        if (
            $right_arr_pos < @$heap
            and $heap->[$right_arr_pos] > $heap->[$left_arr_pos]
        ) {
            $side_arr_pos = $right_arr_pos;
        }

        if ($heap->[$side_arr_pos] > $heap->[$check_arr_pos]) {
            ($heap->[$side_arr_pos], $heap->[$check_arr_pos]) = ($heap->[$check_arr_pos], $heap->[$side_arr_pos]);
            $check_arr_pos = $side_arr_pos;
        } else {
            last;
        }
    }
    return;
}

sub _improve_max_heap {
    # with respect of tail
    my $heap = shift;
    return if @$heap < 2;

    my $tail_arr_pos = $#$heap;
    my $tail_val = $heap->[$tail_arr_pos];
    my $parent_heap_pos = ($tail_arr_pos + 1) >> 1;
    while ($parent_heap_pos) {
        my $parent_arr_pos = $parent_heap_pos - 1;
        if ($tail_val > $heap->[$parent_arr_pos]) {
            # big value move up
            ($heap->[$parent_arr_pos], $heap->[$tail_arr_pos]) = ($heap->[$tail_arr_pos], $heap->[$parent_arr_pos]);
            $tail_arr_pos = $parent_arr_pos;
            $tail_val = $heap->[$tail_arr_pos];
            $parent_heap_pos = ($tail_arr_pos + 1) >> 1;
        } else {
            last;
        }
    }

    return;
}

sub _build_max_heap {
    my @arr = @_;
    my @heap = ();
    while (@arr) {
        my $el = shift @arr;
        push @heap, $el;
        _improve_max_heap(\@heap);
    }
    return @heap;
}

sub heap_sort {
    my @arr = @_;

    my @ret = ();
    my @heap = _build_max_heap(@arr);
    while (@heap) {
        ($heap[0], $heap[-1]) = ($heap[-1], $heap[0]);
        unshift @ret, pop @heap;
        _refresh_heap_from_head(\@heap);
    }

    return @ret;
}

if ($0 eq __FILE__) {
    use Test::More;

    my @list = (4, 10, 3, 5, 1);
    is( join(',', heap_sort(@list)), join(',', sort {$a <=> $b} @list), "Test ".join(',', @list));

    for (1.. 10) {
        my @list = map {int rand(100)} (1..10);
        is(join(',', heap_sort(@list)), join(',', sort { $a <=> $b } @list), "Test with ".join(',',@list) );
    }

    my @list = ();
    is(join(',', heap_sort(@list)), join(',', sort { $a <=> $b } @list), "Test with ".join(',',@list) );

    @list = (12);
    is(join(',', heap_sort(@list)), join(',', sort { $a <=> $b } @list), "Test with ".join(',',@list) );

    @list = (12,34,2);
    is(join(',', heap_sort(@list)), join(',', sort { $a <=> $b } @list), "Test with ".join(',',@list) );

    done_testing();
}

exit;