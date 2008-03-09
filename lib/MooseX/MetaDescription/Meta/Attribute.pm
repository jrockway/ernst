package MooseX::MetaDescription::Meta::Attribute;
use Moose;
use MooseX::MetaDescription::Description;

extends 'Moose::Meta::Attribute';

has 'metadescription' => (
    is       => 'ro',
    isa      => 'MooseX::MetaDescription::Description',
    lazy     => 1,
    weak_ref => 1,
    default  => sub {
        my $self = shift;
        MooseX::MetaDescription::Description->new( attribute => $self );
    },
);

1;

__END__

=head1 NAME

MooseX::MetaDescription::Meta::Attribute - the attribute metaclass for
attributes with metadescriptions

=head1 SYNOPSIS
