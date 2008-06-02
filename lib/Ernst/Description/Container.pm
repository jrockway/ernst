package Ernst::Description::Container;
use Ernst::Description::Base;
use MooseX::AttributeHelpers;
use Data::Thunk 'lazy';

extends 'Ernst::Description';

# this is for the case where a container becomes an attribute of
# something else, otherwise it will be the same as self->name
has 'container_name' => (
    is      => 'ro',
    isa     => 'Str',
    default => sub { shift->name },
);

has 'attribute_order' => (
    reader     => 'get_attribute_list',
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    auto_deref => 1,
    lazy       => 1,
    default    => sub {
        my $self = shift;
        return [ keys %{$self->get_attribute_map} ];
    }
);

has 'attributes' => (
    reader    => 'get_attribute_map',
    metaclass => 'Collection::Hash',
    isa       => 'HashRef[Ernst::Description]',
    is        => 'ro',
    provides  => {
        get => 'get_attribute',
    },
);

1;

__END__

=head1 NAME

Ernst::Description::Container - encapsulates a
class's metadescription

=head1 SYNOPSIS

  my $container = Ernst::Description::Container->new(
      attributes => {
          foo => Ernst::Description->new,
      }
  );

=head1 METHODS

The class inherits from L<Ernst::Description>.

=head2 get_attribute($name)

Returns the attribute metadescription class for the attribute C<$name>.

=head2 get_attribute_map

Returns a hash mapping attribute names to attribute metadescription classes.

=head2 get_attribute_list

Returns the names of the contained attributes.
