use strict;
use warnings;
use Test::More tests => 3;

use Ernst::Interpreter::Instantiate;

{
    package Class;
    use Ernst;

    has $_ => (
        is          => 'ro',
        isa         => 'Str',
        traits      => ['MetaDescription'],
        description => {},
    ) for qw/foo bar/;

}

my $interpreter = Ernst::Interpreter::Instantiate->new(
    description => Class->meta->metadescription,
);

my $instance = $interpreter->create_instance( { foo => foo => bar => bar => } );
isa_ok $instance, 'Class';
is $instance->foo, 'foo';
is $instance->bar, 'bar';
