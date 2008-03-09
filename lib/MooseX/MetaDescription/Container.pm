package MooseX::MetaDescription::Container;
use feature ':5.10';
use Moose;
use MooseX::AttributeHelpers;

has 'class' => (
    isa      => 'MooseX::MetaDescription::Meta::Class',
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

1;

__END__

=head1 NAME

MooseX::MetaDescription::Container - encapsulates a class's metadescription

=head1 SYNOPSIS

How to get a C<MooseX::MetaDescription::Container> for Some::Class:

  my $one_of_these = Some::Class->meta->metadescription;

=head1 METHODS

=head2 attribute($name)

Returns the attribute metadescription class for the attribute C<$name>.

=head2 attribute_map

Returns a hash mapping attribute names to attribute metadescription classes.
