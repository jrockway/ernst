package Ernst::Description::Trait::TT::Class;
use Moose::Role;
use MooseX::AttributeHelpers;
with 'Ernst::Description::Trait::WithTemplates';

has 'flavors' => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef[Str]',
);

1;
