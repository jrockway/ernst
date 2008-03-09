package MooseX::MetaDescription::Meta::Class;
use Moose;
use MooseX::MetaDescription::Container;

extends 'Moose::Meta::Class';

has 'metadescription' => (
    is       => 'ro',
    isa      => 'MooseX::MetaDescription::Container',
    weak_ref => 1,
    default => sub {
        my $self = shift;
        MooseX::MetaDescription::Container->new( class => $self );
    },
);

1;
