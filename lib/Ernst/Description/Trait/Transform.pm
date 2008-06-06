package Ernst::Description::Trait::Transform;
use Moose::Role;
use Moose::Util::TypeConstraints;

has 'transform_source' => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    lazy    => 1,
    default => sub { [shift->name] },
);

has 'transform_rule' => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

1;
