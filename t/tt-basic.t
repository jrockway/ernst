use strict;
use warnings;
use Test::More tests => 6;

use ok 'Ernst::Interpreter::TT';

{ package Form;
  use Ernst;

  __PACKAGE__->meta->metadescription->apply_role(
      'Ernst::Description::Trait::TT', {
          flavors   => [qw/test/],
          templates => {
              test => '[% class.name %] [% biography %] [% username %]',
          },
      },
  );
  has 'id' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      required    => 1,
      description => {
          type   => 'String',
      },
  );

  has 'username' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      description => {
          type       => 'String',
          traits     => [qw/TT/],
          templates  => {
              test => '[username: [% value %]]',
          },
      },
  );

  has 'biography' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      description => {
          type       => 'String',
          traits     => [qw/TT/],
          templates  => {
              test => '[bio: [% value %]]',
          },
      },
  );
}

my $form = Form->new( id => 42, username => 'jrockway', biography => '<OH HAI>' );
isa_ok $form, 'Form';
ok $form->meta->metadescription;
is_deeply [$form->meta->metadescription->get_attribute_list],
  [qw/id username biography/];

my $i = Ernst::Interpreter::TT->new;
ok $i;

my $rendered = $i->interpret($form, 'test');
is $rendered, 'Form [bio: <OH HAI>] [username: jrockway]', 'correct rendering';
