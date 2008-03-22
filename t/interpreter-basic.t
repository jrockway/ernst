use strict;
use warnings;
use Test::Exception;
use Test::More tests => 7;

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
my $string;

my $basic = Ernst::Interpreter->new(
    handlers => {
        ""      => sub { $top = [ @_ ] },
        String  => sub { 
            my ($next, $attr) = @_; 
            $string = [ @_ ];
            $next->(1234); 
            return "OH HAI";
        },
    },
);

my $out = $basic->interpret(Class->meta->metadescription);
is_deeply $out, { awesome_message => 'OH HAI' }, 'it worked';

is ref $top->[0], 'CODE', 'got code for next after top';
is ref $string->[0], 'CODE', 'got code for next after string';

is_deeply $string, [
    $string->[0],
    Class->meta->metadescription->get_attribute('awesome_message'),
], 'got next after string and awesome_message metadescription';

is_deeply $top, [$top->[0], 1234], 'got new attr and next-next coderef';

dies_ok { $top->[0]->() } 'calling top next fails';
