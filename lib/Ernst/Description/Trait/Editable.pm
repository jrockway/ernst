package Ernst::Description::Trait::Editable;
use Moose::Role;

has 'initially_editable' => (
    is      => 'ro',
    isa     => 'Bool',
    default => sub { 1 },
);

has 'editable' => (
    is      => 'ro',
    isa     => 'Bool',
    default => sub { 1 },
);

has 'ignore_if' => (
    is      => 'ro',
    isa     => 'CodeRef',
    default => sub { sub { 0 } },
);

1;
