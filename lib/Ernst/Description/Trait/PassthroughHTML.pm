package Ernst::Description::Trait::PassthroughHTML;
use Moose::Role;

has 'pass_html' => (
    is       => 'ro',
    isa      => 'Bool',
    default  => sub { 1 },
    required => 1,
);

1;
