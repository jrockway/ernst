use strict;
use warnings;
use Test::More tests => 2;

use Ernst::Interpreter::TT;

my $i = 0;

{ package Class;
  use Ernst;

  __PACKAGE__->meta->metadescription->apply_role(
      'Ernst::Description::Trait::TT::Class', {
      flavors => [qw/view/],
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
              }
          },
      },
  );
}

my $tt = Ernst::Interpreter::TT->new;
my $class = Class->new( foo => 'hello' );

my $view_0 = $tt->interpret($class, 'view');
is $view_0, '<div id="view_class_Class">0: changed<br /></div>';

$i = 1;
my $view_1 = $tt->interpret($class, 'view');
is $view_1, '<div id="view_class_Class">1: changed<br /></div>';
