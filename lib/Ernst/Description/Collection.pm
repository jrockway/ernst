package Ernst::Description::Collection;
use Ernst;
use Ernst::TypeLibrary;
use Sub::AliasedUnderscore qw(transformed);

extends 'Ernst::Description';

has 'description' => (
    isa         => 'Ernst::Description',
    is          => 'ro',
    required    => 1,
    traits      => ['MetaDescription'],
    description => {
        type => 'String',
    },
);

has 'cardinality' => (
    isa         => 'ContainerCardinality',
    is          => 'ro',
    required    => 1,
    traits      => ['MetaDescription'],
    description => {
        type    => 'OptionList',
        options => [qw/+ ? * 1/],
    },
);

sub is_required_cardinality {
    my ($self, $array) = @_;
    return unless ref $array eq 'ARRAY';
    
    my %rules = (
        '+' => transformed { $_ > 0 },
        '?' => transformed { $_ == 0 || $_ == 1 },
        '*' => transformed { 1 },
        '1' => transformed { $_ == 1 },
    );
    
    return $rules{$self->cardinality}->(scalar @$array);
}

1;
