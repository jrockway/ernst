package Ernst::Description::Trait::Friendly;
use Moose::Role;

has 'label' => (
    is       => 'ro',
    isa      => 'Str',
    default  => sub {
        my $self = shift;
        ucfirst $self->name;
    },
);

has 'instructions' => (
    is      => 'ro',
    isa     => 'Str | Undef',
    default => sub { undef },
);

1;
