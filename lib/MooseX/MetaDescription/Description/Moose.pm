package MooseX::MetaDescription::Description::Moose;
use Moose;

extends 'MooseX::MetaDescription::Description';

has 'attribute' => (
    is       => 'ro',
    isa      => 'MooseX::MetaDescription::Meta::Attribute',
    required => 1,
);

has 'users_description' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub {
        my $self = shift;
        $self->attribute->description;
    },
);

has '+name' => (
    default => sub { shift->attribute->name },
);

has '+type' => (
    default => sub { shift->attribute->description->{type} },
);

has '+is_writable' => (
    default => sub { shift->attribute->has_writer ? 1 : 0 },
);

has '+traits' => (
    default => sub { shift->attribute->description->{traits} || [] },
);

1;

__END__

=head1 NAME

MooseX::MetaDescription::Description::Moose - a
MooseX::MetaDescription::Description of a Moose class's attribute

=head1 SYNOPSIS

  my $description = MooseX::MetaDescription::Description::Moose->new(
     attribute => Some::Class->meta->get_attribute('attribute'),
  );

=head1 METHODS

See the inherited methods from L<MooseX::MetaDescription::Description>.

=head2 attribute

Returns the attribute metaclass that this instance was created from.
