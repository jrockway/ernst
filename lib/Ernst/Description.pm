package Ernst::Description;
use Ernst;

extends 'MooseX::MetaDescription::Description';

# NOTE:
# we should fix this, so
# that it is required
# - SL
has '+descriptor' => (required => 0);

has 'name' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    traits      => ['MetaDescription'],
    description => {
        type => 'String',
    },
);

has 'is_mutable' => (
    is          => 'ro',
    isa         => 'Bool',
    traits      => ['MetaDescription'],
    description => {
        type => 'Boolean',
    },
    default  => sub { 0 },
);

sub apply_role {
    my ($self, $role, $args) = @_;
    $role->meta->apply($self, rebless_params => $args || {} );
}

1;


__END__

=head1 NAME

Ernst::Description - attribute description (type) base class

=head1 SYNOPSIS

C<Ernst::Description> is the base of all metadescriptions.  When you
read a class' metadescription, it will be a tree of subclasses of this
class.

Create a type:

  package Ernst::Description::Foo;
  extends 'Ernst::Description';

  package Ernst::Description::Bar;
  extends 'Ernst::Description';
  sub is_valid_bar { my $thingie = shift; frob($thingie) };

Then get an instance of a description:

  my $description = Ernst::Description::Bar->new( name => 'my_bar' );

Inspect the type:

  $description->meta->type_isa('Foo');    # yes
  $description->meta->type_isa('Bar');    # yes
  $description->meta->type_isa('');       # yes
  $description->meta->type_isa('String'); # no

  my @types = $description->meta->types; # '', 'Foo', 'Bar'

Or do something for each supertype:

  my $baz = Bazify->new(
      description => $description,
      data        => { some => 'data' },
  );

  given($description->meta->types) {
      when('Foo')  { $baz->frob_foo;  continue }
      when('Bar')  { $baz->frob_bar;  continue }
      when('Quux') { $baz->frob_quux; continue }
  }

  $baz->to_exception_if_gorch;

You can also find other types that C<type_isa> this type.  This is
useful for building metadescriptions from the metadescription
metadescription:

  package Quux;
  extends 'Ernst::Description::Bar';

  my @subtypes = Ernst::Description::Foo->meta->subtypes; # 'Bar', 'Quux'

=head1 ATTRIBUTES

=head2 name

The name of this attribute.

=head2 is_mutable

Whether this attribute can be modified after construction.

=head1 METHODS

=head2 apply_role

Applies a role (with optional attribute values) to the instance.

=head1 METACLASS METHODS

See also L<Ernst::Meta::Description::Type>.

All of the type methods described below return results that are
"relative" to C<Ernst::Description>.  For example, C<type> will return
'Foo' when invoked on a C<Ernst::Description::Foo>.
C<Ernst::Description> has the type C<''> (the empty string).

The use of the word "type" below might be confusing.  It refers to the
type of the described attribute (or class), not the type of the
description class.  (The type of the description class can be accessed
by accessing the description's metadescription.  Hopefully you won't
need to do this.)

=head2 type

Returns the type.  

   Ernst::Description::String->meta->type; # returns "String"

=head2 type_isa( $String )

Returns true if this type isa C<$String>.

  Ernst::Description::String->meta->type_isa('String');  # True
  Ernst::Description::String->meta->type_isa('');        # True
  Ernst::Description::String->meta->type_isa('Integer'); # False

=head2 subtypes

Returns a list of types that extend this attribute's type.

  Ernst::Description->meta->subtypes; # String, Integer, Boolean, etc.

=head2 types

Returns a list of types that this attribute's type inherits from.

  Ernst::Description::String->meta->types; # ''
  Ernst::Description::String::ReallyLong->meta->types; # '', 'String'
