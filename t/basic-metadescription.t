use strict;
use warnings;
use Scalar::Util qw(refaddr);
use Test::More tests => 11;

{ package Foo;
  use MooseX::MetaDescription;
  use Moose;
  
  has 'an_attribute' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      description => {
          type => 'String',
      },
  );
  
  has 'foo' => ( is => 'ro' );
  
}

my $foo = Foo->new(an_attribute => 'hello, world');
isa_ok $foo, 'Foo', '$foo';
isa_ok $foo->meta, 'MooseX::MetaDescription::Meta::Class', q{$foo's metaclass};

ok $foo->meta->get_attribute('an_attribute')->can('metadescription'),
  'an_attribute can metadescription';
ok !$foo->meta->get_attribute('foo')->can('metadescription'),
  'foo cannot metadescription';

# TODO: make sure hierarchy makes sense:
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

sub is_ref($$;$) { is(refaddr($_[0]), refaddr($_[1]), $_[2]) }
my $foo_desc = $foo->meta->metadescription;
my $an_attribute_desc = $foo->meta->get_attribute('an_attribute')->metadescription;
isa_ok $foo_desc, 'MooseX::MetaDescription::Description::Container';
isa_ok $an_attribute_desc, 'MooseX::MetaDescription::Description';

is $foo_desc->name, 'Foo', 'correct name for Foo container';
is $an_attribute_desc->name, 'an_attribute', 'correct name for an_attribute';

is_ref $foo_desc->class, $foo->meta, 'description class == metaclass';

is_ref 
  $foo_desc->attribute('an_attribute'), 
  $foo->meta->get_attribute('an_attribute')->metadescription,
  'container -> attribute == attribute -> metadescription';

is_deeply [keys %{$foo_desc->attributes}], ['an_attribute'],
  'no extra descriptions';
