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

sub dummy {
    log_info("this is just", ["dummy"], "info");
    log_warn("this is just", ["dummy"], "warn");
    log_error("this is just", ["dummy"], "error");
    return 1;
}

####
# TEST SECTION
####
if ($0 eq __FILE__) {
    use Test::More;
    ok(1, "Compile test");

    is(dummy(), 1, "dummy test");

    done_testing();
}

exit;
