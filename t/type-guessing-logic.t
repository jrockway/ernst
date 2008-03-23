use strict;
use warnings;

BEGIN {
    package My::Attribute;
    use Moose;
    with 'Ernst::Meta::Attribute';

    package Foo;
    use Ernst;
    
    has 'bar' => ( 
        traits      => ['MetaDescription'],
        is          => 'ro',
        description => { type => 'String' },
    );
}


use Test::TableDriven (
    type_class => [
        ['String'                      => 'Ernst::Description::String'],
        ['+Ernst::Description::String' => 'Ernst::Description::String'],
        [ Foo->meta->metadescription->get_attribute('bar') =>
            Foo->meta->metadescription->get_attribute('bar')
        ],
        ['Collection' => 'Ernst::Description::Collection'],
    ],
    guess => {
        Str => 'String',
        Foo => Foo->meta->metadescription,
        
    },
);

sub type_class {
    my $input = shift;
    return Ernst::Meta::Attribute::_get_type_class($input);
}

sub guess {
    my $input = shift;

    my $class = ref Foo->meta->get_attribute('bar');
    no strict;
    local *{ "${class}::_isa_metadata" } = sub { $input };
    Ernst::Meta::Attribute::_guess_type($class)->{type};
}

runtests;
