use strict;
use warnings;
use Test::More tests => 2;

{
    package Class;
    use Ernst;

    has 'awesome_message' => (
        traits      => ['MetaDescription'],
        isa         => 'Str',
        is          => 'ro',
        description => {
            type => 'String',
        },
    );

}

use ok 'Ernst::Interpreter';

my $top;
my $string = "OH HAI";

my $basic = Ernst::Interpreter->new(
    handlers => {
        ""      => sub { $top = [ @_ ]; 0 },
        String  => sub { my ($next, $attr) = @_; $next->($attr); $string },
    },
);

my $out = $basic->interpret(Class->meta->metadescription);

is_deeply $out, { awesome_message => 'OH HAI' }, 'it worked';
