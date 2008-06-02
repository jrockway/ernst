use strict;
use warnings;
use Test::More tests => 3;

use Ernst::Interpreter::TT;

my $i = 0;

{ package Class;
  use Ernst;

  __PACKAGE__->meta->metadescription->apply_role(
      'Ernst::Description::Trait::TT', {
      templates => {
          view => '[% FOREACH a IN attributes.keys %][% attributes.$a %][% END %]',
          foo  => sub { "$i" },
      },
  });
  
  has 'foo' => (
      is          => 'ro',
      isa         => 'Str',
      traits      => ['MetaDescription'],
      description => {
          traits    => ['TT'],
          templates => {
              view => sub {
                  my $args = shift;
                  $args->{value} = 'changed';
                  if($i == 0){
                      return '0: [% value %]';
                  }
                  return '1: [% value %]';
              },
              foo => '',
          },
      },
  );
}

my $tt = Ernst::Interpreter::TT->new;
my $class = Class->new( foo => 'hello' );

my $view_0 = $tt->interpret($class, 'view');
is $view_0, '0: changed';

$i = 1;
my $view_1 = $tt->interpret($class, 'view');
is $view_1, '1: changed';

$i = 2;
my $foo = $tt->interpret($class, 'foo');
is $foo, '2';
