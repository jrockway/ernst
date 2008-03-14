package Ernst::Description::Collection::Base;
use Moose::Role;

require Ernst::Meta::Attribute;

has 'description' => (
    isa         => 'Ernst::Description',
    is          => 'ro',
    required    => 1,
    traits      => ['MetaDescription'],
    description => {
        # ???
        type => '+Ernst::Description',
    },
);

1;
