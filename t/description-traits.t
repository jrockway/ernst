use strict;
use warnings;
use Test::More tests => 8;

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
  
  has 'attribute' => (
      traits      => ['MetaDescription'],
      is          => 'rw',
      isa         => 'Str',
      description => {
          type                       => 'String',
          traits                     => ['DoesThisWork'],
          some_configurable_argument => 'amazingly this works',
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
is $desc->type->name, 'String', 'correct type';

ok $desc->does('MooseX::MetaDescription::Description::Trait::DoesThisWork'),
  'applied DoesThisWork trait ok';

is $desc->did_it_work, '1', 'did_it_work is true!';
is $desc->some_configurable_argument, 'amazingly this works',
  q{the trait's BUILD works};
