use strict;
use warnings;
use Test::More tests => 4;

use ok 'MooseX::MetaDescription::Description::String';

{ package Class;
  use MooseX::MetaDescription;
  use Moose;
  
  has 'greeting' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      description => {
          type      => 'String',
          max_length => 10,
          min_length => 5,
      },
  );
}

# make sure type-specific attributes stick

is(Class->meta->metadescription->get_attribute('greeting')->min_length, 5);
is(Class->meta->metadescription->get_attribute('greeting')->max_length, 10);
ok !Class->meta->metadescription->get_attribute('greeting')->has_expected_length;
