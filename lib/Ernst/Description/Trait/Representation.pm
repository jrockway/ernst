package Ernst::Description::Trait::Representation;
use Moose::Role;
use MooseX::AttributeHelpers;

has 'representations' => (
    metaclass => 'Collection::ImmutableHash',
    is        => 'ro',
    isa       => 'HashRef[Str]',
    required  => 1,
    provides  => {
        get => 'representation_for',
    },
);

1;
