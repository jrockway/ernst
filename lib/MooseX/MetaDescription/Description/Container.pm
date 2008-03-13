package MooseX::MetaDescription::Description::Container;
use Moose;
use MooseX::AttributeHelpers;

extends 'MooseX::MetaDescription::Description';

has 'attributes' => (
    metaclass => 'Collection::Hash',
    isa       => 'HashRef[MooseX::MetaDescription::Description]',
    is        => 'ro',
    provides  => {
        get  => 'attribute',
        keys => 'attribute_names',
    },
);

1;

__END__

=head1 NAME

MooseX::MetaDescription::Description::Container - encapsulates a
class's metadescription

=head1 SYNOPSIS

  my $container = MooseX::MetaDescription::Description::Container->new(
      attributes => {
          foo => MooseX::MetaDescription::Description->new,
      }
  );

=head1 METHODS

The class inherits from L<MooseX::MetaDescription::Description>.

=head2 attribute($name)

Returns the attribute metadescription class for the attribute C<$name>.

=head2 attributes

Returns a hash mapping attribute names to attribute metadescription classes.