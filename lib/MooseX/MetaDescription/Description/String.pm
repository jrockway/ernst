package MooseX::MetaDescription::Description::String;
use Moose;

extends 'MooseX::MetaDescription::Description';

# min/max length

has "${_}_length" => (
    is        => 'ro',
    isa       => 'Int',
    predicate => "has_${_}_length",
) for qw/min max expected/;

# expected_length is for guessing the size of text fields if there is
# no max length, but the expected length is 10, then we'll use a
# smaller text field

1;