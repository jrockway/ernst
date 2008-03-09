use strict;
use warnings;
use Scalar::Util qw(refaddr);
use Test::More tests => 2;

{ package Foo;
  use MooseX::MetaDescription;
  use Moose;
  
  has 'an_attribute' => (
      metaclass => 'MetaDescription',
      is        => 'ro',
      isa       => 'Str',
      type      => 'String',
  );
}

my $foo = Foo->new(an_attribute => 'hello, world');
my $foo_desc = $foo->meta->metadescription;
my $an_attribute_desc = $foo->meta->get_attribute_map->{an_attribute}->metadescription;

isa_ok $foo_desc, 'MooseX::MetaDescription::Container';
isa_ok $an_attribute_desc, 'MooseX::MetaDescription::Description';

