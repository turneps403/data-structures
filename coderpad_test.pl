use strict;
use warnings;

use Data::Dumper qw(Dumper);
use Term::ANSIColor;
use JSON qw(encode_json);
use Scalar::Util qw(blessed);

$Data::Dumper::Indent = 0;
sub _dump { substr(Dumper(shift), length('$VAR1 = '), -1) }

sub _log {
    my $color = shift;
    print join(
        " ", color($color).'[log:'.[caller(1)]->[2].']'.color('reset'),
        map {
          ref $_ ?
            color('bright_white').(blessed($_) ? _dump($_) : encode_json($_)).color('reset')
            : color($color).$_.color('reset')
        } @_
    )."\n";
}

sub log_info {_log('bright_green', @_)}
sub log_warn {_log('bright_yellow', @_)}
sub log_error {_log('bright_red', @_)}

####
# CODE SECTION
####

=pod

    https://leetcode.com/problems/coin-change/

=cut


package CoinNode;

sub new {
    my ($class, $amount, $coins) = @_;
    $DB::signal = 1 if $amount == 1;
    main::log_info("Create node:", $amount, $coins);
    my $self = bless {
        val => $amount,
        leafs => []
    };
    $self->add_leafs($coins);
}

sub amount { $_[0]->{val} }
sub add_leaf {
    my ($self, $amount, $coins) = @_;
    push @{ $self->{leafs} }, ref($self)->new($amount, $coins);
}

sub add_leafs {
    my ($self, $coins) = @_;
    for (@$coins) {
        next if $_ > $self->amount;
        my $leaf_val = $self->amount - $_;
        die [$_] unless $leaf_val;
        eval {
            $self->add_leaf($leaf_val, $coins);
        };
        if (ref $@ eq 'ARRAY') {
            push @{$@}, $_;
            die $@;
        }
    }
}

1;
package main;

sub coins_solution {
    my ($amount, $coins) = @_;
    @$coins = sort {$b <=> $a} @$coins;
    eval { CoinNode->new($amount, $coins) };
    if (ref $@ eq 'ARRAY') {
        log_warn("Solution:", $@);
        return scalar @{$@};
    } elsif ($@) {
        die $@;
    } else {
        log_error("No solution");
        return -1;
    }
}

sub dynamic_coins_choose {
    my ($amount, $coins) = @_;
    $DB::signal = 1;
    my @range = (0)x$amount;
    for my $c (@$coins) {
        my $ind = -1;
        while (($ind += $c) < @range) {
            my $prev_val = $ind == $c-1 ? 0 : $range[$ind - $c];
            if ($range[$ind] == 0 or $prev_val + 1 < $range[$ind]) {
                $range[$ind] = $prev_val + 1;
            }
        }
    }
    log_info("Dynamic version:", \@range);
    return $range[-1] || -1;
}


####
# TEST SECTION
####
if ($0 eq __FILE__) {
    use Test::More;
    ok(1, "Compile test");

    #is(coins_solution(34, [13, 17]), 2, "coins_solution test");
    #is(coins_solution(27, [13, 17]), -1, "coins_solution test");

    is(dynamic_coins_choose(34, [13, 17]), 2, "coins_solution test");
    is(dynamic_coins_choose(27, [13, 17]), -1, "coins_solution test");

    done_testing();
}

exit;
