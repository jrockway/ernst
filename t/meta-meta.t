use strict;
use warnings;
use Test::More tests => 4;

{ package Foo;
  use MooseX::MetaDescription;
  use Moose;

  has 'a' => (
      is          => 'ro',
      traits      => ['MetaDescription'],
      isa         => 'Str',
      description => {
          type => 'String',
      },
  );
}

my $md = Foo->meta->metadescription->meta->metadescription;

ok $md;
is_deeply [sort $md->get_attribute_list], [sort 'attributes', 'name'];

my $name = $md->get_attribute('name');
is $name->type, 'String';

my $name2 = MooseX::MetaDescription::Description->meta->
  get_attribute('name')->metadescription;
is $name2->type, 'String';
