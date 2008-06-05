package Ernst::Description::String;
use Ernst::Description::Base;

extends 'Ernst::Description::Value';

# min/max length

has "${_}_length" => (
    is        => 'ro',
    isa       => 'Int',
    predicate => "has_${_}_length",
) for qw/min max expected/;

# form field size

has 'rows' => (
    is      => 'ro',
    isa     => 'Int',
    deafult => sub { 1 },
);

has 'cols' => (
    is      => 'ro',
    isa     => 'Int',
    deafult => sub { 50 },
);
    
1;
