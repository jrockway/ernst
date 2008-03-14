package Ernst::Description::Container;
use Ernst;
use MooseX::AttributeHelpers;
use Data::Thunk 'lazy';

extends 'Ernst::Description';

has 'attributes' => (
    reader        => 'get_attribute_map',
    metaclass     => 'Collection::Hash',
    isa           => 'HashRef[Ernst::Description]',
    is            => 'ro',
    provides      => {
        get  => 'get_attribute',
        keys => 'get_attribute_list',
    },
    traits        => ['MetaDescription'],
    description   => {
        type        => 'Collection',
        description => lazy {
            Ernst::Description->meta->metadescription;
        },
        cardinality => '*',
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
