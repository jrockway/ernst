package Ernst::Description::Wrapper;
use Ernst;
use Data::Thunk;

# wraps a class metadescription as an attribute
# totally unnecessary, i'm thinking... but let's try it for now

extends 'Ernst::Description';

has 'wrapped_description' => (
    is          => 'ro',
    isa         => 'Ernst::Description::Container',
    traits      => ['MetaDescription'],
    description => {
        type        => 'Container',
        cardinality => 1,
        description => lazy {
            Ernst::Description::Container->meta->metadescription;
        },
    },
);
1;
