package Ernst::Interpreter::Context;
use Moose;

use overload (
    '&{}' => sub { 
        my $self = shift;
        return sub {
            $self->reinvoke(@_);
        };
    },
    fallback => 'yes',
);

has 'self' => (
    does     => 'Ernst::Interpreter',
    is       => 'ro',
    required => 1,
);

has 'initial_type' => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

sub reinvoke {
    my $self = shift;
    $self->self->interpret(@_);
}

1;
