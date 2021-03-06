package Catmandu::Fix::retain_field;

use Catmandu::Sane;
use Catmandu::Util qw(:is :data);
use Moo;

has path  => (is => 'ro', required => 1);
has key   => (is => 'ro', required => 1);
has guard => (is => 'ro');

around BUILDARGS => sub {
    my ($orig, $class, $path) = @_;
    my ($p, $key, $guard) = parse_data_path($path);
    $orig->($class, path => $p, key => $key, guard => $guard);
};

sub fix {
    my ($self, $data) = @_;

    my $key = $self->key;
    my $guard = $self->guard;
    for my $match (grep ref, data_at($self->path, $data)) {
        if (is_array_ref($match)) {
            splice @$match, 0, @$match, grep { $guard->($_) } get_data($match, $key);
        } else {
            for (keys %$match) {
                delete $match->{$_} unless $_ eq $key && $guard->($match->{$_});
            }
        }
    }

    $data;
}

=head1 NAME

Catmandu::Fix::retain_field - delete everything from a field except 

=head1 SYNOPSIS

   # Delete every key from foo except bar
   retain_field('foo.bar');

=head1 SEE ALSO

L<Catmandu::Fix>

=cut

1;
