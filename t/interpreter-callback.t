use strict;
use warnings;
use Test::Exception;
use Test::More tests => 13;

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

use ok 'Ernst::Interpreter::Callback';

my $top;
my $string;
my $continue_after_top = 0;

my $basic = Ernst::Interpreter::Callback->new(
    handlers => {
        ""      => sub { shift; $top = [ @_ ]; $continue_after_top && $_[0]->() },
        String  => sub { 
            my ($reinvoke, $next, $attr) = @_; 
            $string = [ $next, $attr ];
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

# check that handlers have good names in stack trace

$continue_after_top = 1;
eval { $basic->interpret(Class->meta->metadescription) };
my $stack = $@;
ok $stack, 'got stack trace';

my @lines = split /$/m, $stack;
like $lines[0], qr/^Attempt to 'next'/;
like $lines[1], qr/<Ernst interpreter>::invalid_next/;
like $lines[2], qr/<Ernst interpreter>::__HANDLER__::Top_Level/;
like $lines[3], qr/<Ernst interpreter>::__HANDLER__::String/;
unlike $lines[4], qr/__HANDLER__/, q{that's all of the handlers};
