package Ernst::Description;
use Ernst;

my $PACKAGE      = __PACKAGE__;
my $SHORTEN_TYPE = qr/^${PACKAGE}::(.+)$/;

has 'name' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    traits      => ['MetaDescription'],
    description => {
        type => 'String',
    },
);

has 'type' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    traits      => ['MetaDescription'],
    description => {
        type => 'String',
    },
    default     => sub {
        my $self  = shift;
        
        for my $c (ref $self, $self->meta->superclasses) {
            return $1 if $c =~ /$SHORTEN_TYPE/o;
        }
        
        confess 'Something has gone horribly wrong; cannot guess the type of ',
          ref $self;
    }
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

sub type_isa {
    my ($self, $compare) = @_;
    grep { /^$compare$/ } $self->types;
};

sub subtypes {
    
}

sub types {
    my $self = shift;
    my $p = __PACKAGE__; # this package is the stopping point for search up @ISA
    map { /$SHORTEN_TYPE/o; $1||'' } grep { $_->isa($p) } $self->meta->linearized_isa;
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

  $description->type_isa('Foo');    # yes
  $description->type_isa('Bar');    # yes
  $description->type_isa('');       # yes
  $description->type_isa('String'); # no

  my @types = $description->types; # '', 'Foo', 'Bar'

Or do something for each supertype:

  my $baz = Bazify->new(
      description => $description,
      data        => { some => 'data' },
  );

  given($description->types) {
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

  my @subtypes = Ernst::Description::Foo->subtypes; # 'Bar', 'Quux'

=head1 ATTRIBUTES

=head2 name

The name of this attribute.

=head2 type

The name of this attribute's type.

=head2 is_mutable

Whether this attribute can be modified after construction.

=head1 METHODS

Note: the type methods are "relative" to C<Ernst::Description>.  For
example, C<Ernst::Description::Foo> has the type 'Foo'.

=head2 type_isa( $String )

Returns true if this attribute's type isa C<$String>.

=head2 subtypes

Returns a list of types that extend this attribute's type.

XXX: move to metaclass

=head2 types

Returns a list of types that this attribute's type inherits from.

XXX: move to metaclass


