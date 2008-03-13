package MooseX::MetaDescription::Description::Collection;
use Moose;
use MooseX::MetaDescription::TypeLibrary;
use Sub::AliasedUnderscore qw(transformed);

extends 'MooseX::MetaDescription::Description';

has 'description' => (
    isa      => 'MooseX::MetaDescription::Description',
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
