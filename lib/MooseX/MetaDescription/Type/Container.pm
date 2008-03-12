package MooseX::MetaDescription::Type::Container;
use Moose;
use MooseX::MetaDescription::TypeLibrary;
use Sub::AliasedUnderscore qw(transformed);

extends 'MooseX::MetaDescription::Type';

has 'contains' => (
    isa      => 'MooseX::MetaDescription::Container',
    is       => 'ro',
    required => 1,
);

has 'cardinality' => (
    isa      => 'ContainerCardinality',
    is       => 'ro',
    required => 1,
);

sub is_required_cardinality {
    my ($self, $array) = @_;
    return unless ref $array == 'ARRAY';
    
    my %rules = (
        '+' => transformed { $_ > 0 },
        '?' => transformed { $_ == 0 || $_ == 1 },
        '*' => transformed { 1 },
        '1' => transformed { $_ == 1 },
    );

    return $rules{$self->cardinality}->(scalar @$array);
}

1;
