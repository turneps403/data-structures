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

sub knapsack {
    my ($total_weight, $weights) = @_;
    return unless $total_weight > 0;
    my @range = (0)x$total_weight;
    for my $w (keys %$weights) {
        for my $i (0 .. $#range) {
            if ($i < $w - 1) {
                # not influent yet
                next;
            } else {
                my $prev_weight = $i - $w > -1 ? $range[$i - $w] : 0;
                if ($prev_weight + $weights->{$w} > $range[$i]) {
                    $range[$i] = $prev_weight + $weights->{$w};
                }
            }
        }
    }
    log_info("Range:", \@range);
    return $range[-1];
}

####
# TEST SECTION
####
if ($0 eq __FILE__) {
    use Test::More;
    ok(1, "Compile test");

    is(knapsack(6, {2 => 30, 4 => 70, 3 => 50, 5 => 60}), 100, "knapsack 6");
    is(knapsack(5, {2 => 30, 4 => 70, 3 => 50, 5 => 60}), 80, "knapsack 5");

    done_testing();
}

exit;
