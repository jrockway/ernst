package MooseX::MetaDescription::Meta::Class;
use feature ':5.10';
use Moose;
use MooseX::MetaDescription::Container;

extends 'Moose::Meta::Class';

has 'metadescription' => (
    is      => 'ro',
    isa     => 'MooseX::MetaDescription::Container',
    default => sub {
        my $self = shift;
        MooseX::MetaDescription::Container->new( class => $self );
    },
);

1;
