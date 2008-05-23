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

1;
