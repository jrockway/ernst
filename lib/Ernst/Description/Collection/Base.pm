package Ernst::Description::Collection::Base;
use Moose::Role;

require Ernst::Meta::Attribute;
use Data::Thunk;

has 'description' => (
    isa         => 'Ernst::Description',
    is          => 'ro',
    required    => 1,
    traits      => ['MetaDescription'],
    description => {
        type => '',
    },
);

1;
