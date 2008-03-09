use strict;
use warnings;
use Scalar::Util qw(refaddr);
use Test::More tests => 4;

{ package Foo;
  use MooseX::MetaDescription;
  use Moose;
  
  has 'an_attribute' => (
      metaclass => 'MetaDescription',
      is        => 'ro',
      isa       => 'Str',
      type      => 'String',
  );

  has 'foo' => ( is => 'ro' );
      
}

my $foo = Foo->new(an_attribute => 'hello, world');
my $foo_desc = $foo->meta->metadescription;
my $an_attribute_desc = $foo->meta->get_attribute_map->{an_attribute}->metadescription;

# make sure classes make sense

isa_ok $foo_desc, 'MooseX::MetaDescription::Container';
isa_ok $an_attribute_desc, 'MooseX::MetaDescription::Description';
for('MooseX::MetaDescription::Meta::Attribute'){ # topicalizer.  <3
    is   ref $foo->meta->get_attribute_map->{an_attribute}, $_;
    isnt ref $foo->meta->get_attribute_map->{foo}, $_;
}

# make sure hierarchy makes sense:
# 1 $foo->meta: << MX::MD::Meta::Class >>
# 2   metadescription: << MX::MD::Container >>
# 3     class [1]
# 4     attributes:
# 5       an_attribute: << MX::MD::Description >>
# 6         attribute: << MX::MD::Meta::Attribute >>
# 7   attributes:
# 8     an_attribute: [6]
# 9        metadescription: [5]
# 10    foo: << M::Meta::Attribute >>

