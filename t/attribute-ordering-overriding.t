use strict;
use warnings;
use Ernst::Description;
use Test::More tests => 1;

{ package Superclass;
  use Ernst;
  
  has foo => ( 
      is          => 'ro', 
      isa         => 'Num', 
      traits      => ['MetaDescription'],
      description => {
          type => 'Value',
      }
  );

  package Class;
  use Ernst;
  extends 'Superclass';

  has '+foo' => (
      isa => 'Int',
  );
}

my @attributes = Class->meta->metadescription->get_attribute_list;
is_deeply \@attributes, [qw/foo/];

