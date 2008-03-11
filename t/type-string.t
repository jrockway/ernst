use strict;
use warnings;
use Test::More tests => 3;

{ package Class;
  use MooseX::MetaDescription;
  use Moose;
  
  has 'greeting' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      description => {
          type      => 'String',
          type_args => {
              max_length => 10,
              min_length => 5,
          },
      },
  );
}

# make sure type-specific attributes stick

is(Class->meta->metadescription->attribute('greeting')->type->min_length, 5);
is(Class->meta->metadescription->attribute('greeting')->type->max_length, 10);
ok !Class->meta->metadescription->attribute('greeting')->type->has_expected_length;
