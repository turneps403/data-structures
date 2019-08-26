=pod

    The main idea is trying to build a linked-list data structure without Perl-hashes
    and use only functions and lists. Cause codebase can look offbeat.

=cut

package LinkedList::Node;
use strict;
use warnings;

=pod

    LinkedList::Node
        is a container which holds information about
        stored information and link to the next sibling

=cut

sub DATA() { 0 }
sub NEXT() { 1 }

sub new {
    bless [$_[1], $_[2]], $_[0];
}

sub _accessor {
    my ($self, $idx) = @_;
    if (@_ > 2) {
        $self->[$idx] = $_[2];
    } else {
        $self->[$idx];
    }
}

sub next {
    # may be we need check here inheritance of setting object
    shift->_accessor(NEXT(), @_);
}

sub data {
    shift->_accessor(DATA(), @_);
}

1;

package LinkedList;
use strict;
use warnings;

=pod

    LinkedList
        is a start point to manage chains of LinkedList::Node

=cut

sub  HEAD()     { 0 }
sub  LENGTH()   { 1 }

sub new {
    # if allow add here head node, then we need count current deep length
    bless [undef, 0], shift;
}

sub head {
    my $self = shift;
    if (@_ == 0) {
        $self->[HEAD()];
    } else {
        # may be here need traverse in head object to refresh length value
        # may be we need check inheritance of head object
        $self->[HEAD()] = $_[0];
    }
}

sub len { shift->[LENGTH()] }
sub inc_len { shift->[LENGTH()]++ }
sub dec_len { shift->[LENGTH()]-- }


sub add {
    my $self = shift;
    my $val = $_[0];
    my $new_node = LinkedList::Node->new($val);
    unless ($self->head) {
        $self->head($new_node);
    } else {
        my $start = $self->head;
        while ($start->next) {
            $start = $start->next;
        }
        $start->next($new_node);
    }
    $self->inc_len;
    return;
}

sub find {
    my $self = shift;
    my $val = shift;
    my $start = $self->head;
    while ($start) {
        # eq gets warn when works with undefined value
        unless (ref $val ? $val->($start->data) : ($val eq $start->data)) {
            $start = $start->next;
        } else {
            return $start;
        }
    }
    return;
}

sub add_or_replace {
    my $self = shift;
    my ($val, $compare_sub) = @_;
    my $found = $self->find($compare_sub || $val);
    if ($found) {
        $found->data($val);
    } else {
        $self->add($val);
    }
}

sub del {
    my $self = shift;
    my $val = shift;
    my $start = $self->head;
    my $prev = undef;
    while ($start) {
        # eq gets warn when works with undefined value
        if (ref $val ? $val->($start->data) : ($val eq $start->data)) {
            if ($prev) {
                $prev->next($start->next);
            } else {
                $self->head($start->next);
            }
            $self->dec_len;
            return 1;
        } else {
            $prev = $start;
            $start = $start->next;
        }
    }
    return 0;
}

if ($0 eq __FILE__) {
    # something like:
    # $> perl LinkedList.pm
    use Test::More;

    $DB::signal = 1;

    my $ll = LinkedList->new();
    is(ref $ll, 'LinkedList', "Check ref of blessed value");
    is($ll->add("one"), undef, "Add One");
    is($ll->add("two"), undef, "Add Two");
    is($ll->add("three"), undef, "Add Three");

    is($ll->del("two"), 1, "Del Two");
    is($ll->del("two"), 0, "Del Two twice");

    done_testing();

    exit();
}

1;
__END__
