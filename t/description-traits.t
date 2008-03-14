use strict;
use warnings;
use Test::More tests => 12;

{ package Ernst::Description::Trait::DoesThisWork;
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
  use Ernst;
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

my $desc = $container->get_attribute('attribute');
ok $desc, 'got description for attribute';

is $desc->name, 'attribute', 'correct name';
is $desc->type, 'String', 'correct type';

ok $desc->does('Ernst::Description::Trait::DoesThisWork'),
  'applied DoesThisWork trait ok';

is $desc->did_it_work, '1', 'did_it_work is true!';
is $desc->some_configurable_argument, 'amazingly this works',
  q{the trait's BUILD works};

# make sure attribute and attribute2 have the same description class
is ref $container->get_attribute('attribute'),
   ref $container->get_attribute('attribute2'),
  'attribute and attribute2 have the same type (due to same traits)';

isnt ref $container->get_attribute('attribute3'),
     ref $container->get_attribute('attribute'),
  'attribute3 has a different type';

# check read-only-ness
ok $container->get_attribute('attribute')->is_mutable;
ok !$container->get_attribute('attribute2')->is_mutable;
