use strict;
use warnings;
use Test::More tests => 11;

# test using an object as the description type

{
    package MyStringDescription ;
    use Moose;
    extends 'Ernst::Description::String';

    sub is_my_string { 1 }
}


my $my_string = MyStringDescription->new(
    name       => 'hello string',
    min_length => 8,
);

{

    package Ernst::Description::Trait::Foo;
    use Moose::Role;

    has 'foo_trait' => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    package Class;
    use Ernst;
    has 'string' => (
        traits      => ['MetaDescription'],
        is          => 'ro',
        isa         => 'Str',
        description => {
            type => $my_string,
        },
    );

    package Class2;
    use Ernst;
    has 'string' => (
        traits      => ['MetaDescription'],
        is          => 'ro',
        isa         => 'Str',
        description => {
            type       => $my_string,
            traits     => ['Foo'],
            foo_trait  => 'hello',
            max_length => 42,
        },
    );
}

my $class_string = Class->meta->metadescription->get_attribute('string');
my $class2_string = Class2->meta->metadescription->get_attribute('string');

for my $s ($class_string, $class2_string){
    is $s->name, 'string', 'has correct name';
    ok $s->meta->type_isa('String'), 'custom string isa string';
    ok $s->is_my_string, 'is_my_string method works';
    is $s->min_length, 8, 'attr stuck';
}

is $my_string->name, 'hello string', 'original not modified';

is $class2_string->foo_trait, 'hello', 'custom types can have traits also';
is $class2_string->max_length, 42, 'attrs can be overriden';

