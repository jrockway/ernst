package Ernst::Description::Trait::WithTemplates;
use Moose::Role;
use MooseX::AttributeHelpers;

has 'templates' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'HashRef',
    required  => 0,
    default   => sub { +{} },
);

1;
