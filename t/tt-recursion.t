use strict;
use warnings;
use Ernst::Interpreter::TT;
use Test::More tests => 5;

{ package Class;
  use Ernst;
  
  __PACKAGE__->meta->metadescription->apply_role(
      'Ernst::Description::Trait::TT', {
          templates => {
              test => '[[% foo %] [% bar %]]',
          },
      },
  );
  
  has [qw/foo bar/] => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      required    => 1,
      description => {
          type      => 'String',
          traits    => ['TT'],
          templates => {
              test => '[[% attribute.name %]: [% value %]]',
          },
      },
  );
  
  package Collection;
  use Ernst;
  
  __PACKAGE__->meta->metadescription->apply_role(
      'Ernst::Description::Trait::TT', {
          templates => {
              test => 'class: [% attributes.class %]'
          },
      },
  );
  
  has class => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Class',
      required    => 1,
      description => {
          traits    => ['TT'],
          templates => {
              test => '[% original %] (foo is [% value.foo %])',
          },
      },
  );
}

my $class = Class->new( foo => 'foo', bar => 'bar' );
ok $class;
my $i = Ernst::Interpreter::TT->new;
ok $i;

is $i->interpret($class, 'test'), '[[foo: foo] [bar: bar]]';

my $collection = Collection->new( class => $class );
ok $collection;
is $i->interpret($collection, 'test'), 'class: [[foo: foo] [bar: bar]] (foo is foo)';
