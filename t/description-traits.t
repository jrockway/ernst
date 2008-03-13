use strict;
use warnings;
use Test::More tests => 12;

{ package MooseX::MetaDescription::Description::Trait::DoesThisWork;
  use Moose::Role;
  has 'did_it_work' => (
      is      => 'ro',
      isa     => 'Bool',
      default => 1,
  );

  has 'some_configurable_argument' => (
      is       => 'ro',
      isa      => 'Str',
      required => 1,
  );

}

{ package Class;
  use MooseX::MetaDescription;
  use Moose;

  my @def = (
      traits      => ['MetaDescription'],
      is          => 'rw',
      isa         => 'Str',
      description => {
          type                       => 'String',
          traits                     => ['DoesThisWork'],
          some_configurable_argument => 'amazingly this works',
      },
  );
  
  has 'attribute'  => @def;
  has 'attribute2' => (@def, is => 'ro');
  
  has 'attribute3' => (
      @def,
      description => {
          type => 'String',
      },
  );
  
}

my $foo = Class->new( attribute => 'Hello' );
isa_ok $foo, 'Class', '$foo';

my $container = Class->meta->metadescription;
ok $container, 'got container';

my $desc = $container->attribute('attribute');
ok $desc, 'got description for attribute';

is $desc->name, 'attribute', 'correct name';
is $desc->type, 'String', 'correct type';

ok $desc->does('MooseX::MetaDescription::Description::Trait::DoesThisWork'),
  'applied DoesThisWork trait ok';

is $desc->did_it_work, '1', 'did_it_work is true!';
is $desc->some_configurable_argument, 'amazingly this works',
  q{the trait's BUILD works};

# make sure attribute and attribute2 have the same description class
is ref $container->attribute('attribute'),
   ref $container->attribute('attribute2'),
  'attribute and attribute2 have the same type (due to same traits)';

isnt ref $container->attribute('attribute3'),
     ref $container->attribute('attribute'),
  'attribute3 has a different type';

# check read-only-ness
ok $container->attribute('attribute')->is_mutable;
ok !$container->attribute('attribute2')->is_mutable;
