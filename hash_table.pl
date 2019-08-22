#/usr/local/bin/perl
use strict;
use warnings;

package LinkedList::Node;

sub new {
    my $class = shift;
    my $params = ref $_[0] eq 'HASH' ? $_[0] : {@_};
    
    bless {
        data => $params->{data},
        next => UNIVERSAL::isa($params->{next}, __PACKAGE__) ? $params->{next} : undef,
    }, $class;
}

sub _accessor {
    my $self = shift;
    my $key = shift;
    if (@_) {
        $self->{$key} = $_[0];
        return;
    } else {
        return $self->{$key};
    }
}

sub next {
    shift->_accessor("next", @_);
}

sub data {
    shift->_accessor("data", @_);
}

1;

package LinkedList;

sub new {
    bless {head => undef, length => 0}, shift;
}

sub head { shift->{head} }

sub len { shift->{length} }

sub add {
    my $self = shift;
    die "No value to add" unless @_;
    my $val = $_[0];
    my $new_node = LinkedList::Node->new(data => $val);
    unless ($self->{head}) {
        $self->{head} = $new_node;
    } else {
        my $start = $self->{head};
        while ($start->next) {
            $start = $start->next;
        }
        $start->next($new_node);
    }
    $self->{length}++;
    return;
}

sub find {
    my $self = shift;
    my $val = shift;
    my $start = $self->{head};
    while ($start) {
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
        if (ref $val ? $val->($start->data) : ($val eq $start->data)) {
            if ($prev) {
                $prev->next($start->next);
            } else {
                $self->{head} = $start->next;
            }
            $self->{length}--;
            return 1;
        } else {
            $prev = $start;
            $start = $start->next;
        }
    }
    return 0;
}

1;

package HashTable::Item;

sub new {
    my $class = shift;
    my $params = @_==1 ? $_[0] : {@_};
    bless {
        key => $params->{key},
        val => $params->{val}
    }, $class;
}

sub key { shift->{key} }
sub val { shift->{val} }

1;

package HashTable;

$HashTable::grow_rate = 2;
$HashTable::llist_max_len = 3;

sub new {
    my ($class, $init_len) = @_;
    $init_len ||= 5;

    my $arr = [];
    $#$arr = --$init_len;

    bless $arr, $class;
}

sub _get_hash {
    my ($self, $key) = @_;
    $key = "$key";
    my $hash = 0;
    for (unpack "L*S*C*", pack "A*", $key) {
        $hash ^= $_;
    }
    return $hash;
}

sub _choose_spot {
    my $self = shift;
    my $rand = rand();
    srand($_[0]);
    my $pos = int( rand(scalar @$self) );
    srand($rand);
    return $pos;
}

sub _rebuild {
    my $self = shift;
    my $new_self = HashTable->new(int(@$self * $HashTable::grow_rate));
    for (@$self) {
        next unless $_;
        my $start = $_->head;
        while ($start) {
            $new_self->add($start->data);
            $start = $start->next;
        }
    }
    @$self = @$new_self;
    return;
}

sub add {
    my $self = shift;
    my ($key, $val) = @_;
    my $ui32hash = $self->_get_hash($key);
    my $pos = $self->_choose_spot($ui32hash);
    $self->[$pos] ||= LinkedList->new();
    if ($self->[$pos]->len >= $HashTable::llist_max_len) {
        $self->_rehash();
        $pos = $self->_choose_spot($ui32hash);
    }
    my $item = HashTable::Item->new(key => $key, val => $val);
    $self->[$pos]->add_or_replace($item, sub { shift->key eq $item->key });
    return 1; 
}

sub get {
    my $self = shift;
    my ($key, $default) = @_;
    my $ui32hash = $self->_get_hash($key);
    my $pos = $self->_choose_spot($ui32hash);
    return $default unless $self->[$pos];
    my $found = $self->[$pos]->find(sub { shift->key eq $key });
    return defined $found ? $found->data->val : $default; 
}

1;
package main;

if ($0 eq __FILE__) {
    use Test::More;

    $DB::signal = 1;

    my $t = HashTable->new();
    is($t->add("foo", 12), 1, "First add test");
    is($t->add("foo", 13), 1, "Next add test");

    is($t->get("foo"), 13, "Read test");

    done_testing();

    exit();
} else {
    1;
}


