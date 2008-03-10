package MooseX::MetaDescription::Meta::Class;
use Moose;
use MooseX::MetaDescription::Container::Moose;

extends 'Moose::Meta::Class';

has 'metadescription' => (
    is       => 'ro',
    isa      => 'MooseX::MetaDescription::Container',
    lazy     => 1,
    weak_ref => 1,
    default  => sub {
        my $self = shift;
        MooseX::MetaDescription::Container::Moose->new( class => $self );
    },
);

1;
__END__

=head1 NAME

MooseX::MetaDescription::Meta::Class - the metaclass for classes with
metadescriptions

=head1 SYNOPSIS
