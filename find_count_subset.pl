#!/usr/bin/perl
use strict;
use warnings;

=pod

    Dynamic programming
    https://www.youtube.com/watch?v=nqlNzOcnCfs

=cut

sub find_all_subset {
    my ($num, $data, $_index) = @_;
    $_index ||= [0 .. $#$data];

    my @ret = ();
    for my $index_i (0 .. $#$_index) {
        my $i = $_index->[$index_i];
        if ($data->[$i] == $num) {
            push @ret, [$i];
        } else {
            push @ret, map { [$i, @$_] if $_ } find_all_subset($num - $data->[$i], $data, [@$_index[0 .. $index_i-1, $index_i+1 .. $#$_index]]);
        }
    }

    unless (wantarray) {
        my $filter = {};
        @ret = grep {not $filter->{ join(',', sort @$_) }++} @ret;
    }

    return @ret;
}

if ($0 eq __FILE__) {
    use Test::More;
    ok(1, "Compile test");

    my @list = (1,7,4,6,5); # [7,4], [5,6], [6,4,1]
    is(scalar find_all_subset(11, \@list), 3, "test with ".join(',', @list));
    is(scalar find_all_subset(110, \@list), 0, "test with ".join(',', @list));

    @list = (1);
    is(scalar find_all_subset(1, \@list), 1, "test with ".join(',', @list));
    is(scalar find_all_subset(2, \@list), 0, "test with ".join(',', @list));

    @list = ();
    is(scalar find_all_subset(1, \@list), 0, "test with ".join(',', @list));

    @list = (1,1,2);
    is(scalar find_all_subset(3, \@list), 2, "test with ".join(',', @list));

    @list = (1,-1,2);
    is(scalar find_all_subset(2, \@list), 2, "test with ".join(',', @list));

    done_testing();
}

exit;