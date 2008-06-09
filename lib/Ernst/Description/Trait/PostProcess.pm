package Ernst::Description::Trait::PostProcess;
use Moose::Role;
use Moose::Util::TypeConstraints;

has 'postprocess' => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

1;
