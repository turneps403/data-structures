=pod

    Thank you, Gayle Laakmann McDowell!
    https://www.youtube.com/watch?v=shs0KM3wKv8

=cut

package HashTable::Item;
use strict;
use warnings;

sub KEY() {0}
sub VAL() {1}

sub new {
    bless [$_[1], $_[2]], $_[0];
}

sub key { shift->[KEY()] }
sub val { shift->[VAL()] }

1;

package HashTable;
use strict;
use warnings;

use LinkedList;

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
    srand($_[0]);
    my $pos = int( rand(scalar @$self) );
    srand();
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
    my $item = HashTable::Item->new($key, $val);
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


if ($0 eq __FILE__) {
    use Test::More;

    $DB::signal = 1;

    my $t = HashTable->new();
    is($t->add("foo", 12), 1, "First add test");
    is($t->add("foo", 13), 1, "Next add test");

    is($t->get("foo"), 13, "Read test");

    done_testing();

    exit();
}

1;
__END__

