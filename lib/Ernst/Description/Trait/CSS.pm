package Ernst::Description::Trait::CSS;
use Moose::Role;

has 'id' => (
    is      => 'ro',
    isa     => 'Undef | Str',
    default => sub { undef },
);

has 'classes' => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
);

1;
