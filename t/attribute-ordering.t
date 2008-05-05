use strict;
use warnings;
use Test::More tests => 1;

# a long list to minimize coincidences
my @order = qw/d c a b q w e r t y u i o p/;

{ package Class;
  use Ernst;

  my @def = (
      is          => 'ro',
      isa         => 'Str',
      traits      => ['MetaDescription'],
      description => {},
  );
  
  has $_ => @def for @order;
}

is_deeply([Class->meta->metadescription->get_attribute_list], \@order,
          'attribute ordering is correct');
