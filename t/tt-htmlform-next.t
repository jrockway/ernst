use strict;
use warnings;
use Test::More tests => 1;

use Ernst::Interpreter::TT::HTMLForm;

{ package Class;
  use Ernst;

  __PACKAGE__->meta->metadescription->apply_role(
      'Ernst::Description::Trait::TT', {
          templates => {
              foo => 'foo: [% foo %]',
          },
      },
  );

  has 'foo' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      description => {
          type      => 'String',
          traits    => ['TT'],
          templates => {
              foo => '<1>[% next %]</1>',
          },
      },
  );
}

my $i = Ernst::Interpreter::TT::HTMLForm->new( default_attribute_templates => {} );
$i->add_default_attribute_template( 'foo', 'String', '<string>[% next %]</string>' );
$i->add_default_attribute_template( 'foo', '', '[% value %]' );

my $class = Class->new( foo => 'foo' );
my $output = $i->interpret($class, 'foo');

is $output, 'foo: <1><string>foo</string></1>';
