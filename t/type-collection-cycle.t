use strict;
use warnings;
use Test::More tests => 1;

{ 
    package Foo;
    use Ernst;
    use Moose;
    
    has 'parent' => (
        traits      => ['MetaDescription'],
        is          => 'ro',
        isa         => 'Foo',
        description => {
            type        => 'Collection',
            description => Foo->meta->metadescription,
            cardinality => '+',
        },
    );
}

# TODO: change the type to Container::Weak and change semantics
# the below is more of a failure than a success:

my $cycle = Foo->meta->metadescription->get_attribute('parent');
is $cycle, $cycle->description->get_attribute('parent');
