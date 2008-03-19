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
        # XXX: i don't think so
        type                => 'Wrapper',
        wrapped_description => lazy {
            Ernst::Description->meta->metadescription;
        },
    },
);

1;
