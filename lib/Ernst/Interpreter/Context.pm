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

has 'interpreter' => (
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
    $self->interpreter->interpret(@_);
}

1;
