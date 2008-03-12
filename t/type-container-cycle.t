use strict;
use warnings;
use Test::More tests => 1;

{ 
    package Foo;
    use MooseX::MetaDescription;
    use Moose;
    
    has 'parent' => (
        traits      => ['MetaDescription'],
        is          => 'ro',
        isa         => 'Foo',
        description => {
            type      => 'Container',
            type_args => {
                contains    => Foo->meta->metadescription,
                cardinality => '1',
            },
        },
    );
}

# TODO: change the type to Container::Weak and change semantics
# the below is more of a failure than a success:

my $cycle = Foo->meta->metadescription->attribute('parent');
is $cycle, $cycle->type->contains->attribute('parent');
