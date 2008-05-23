use strict;
use warnings;
use Test::More tests => 7;

use ok 'Ernst::Interpreter::TT';

{ package Form;
  use Ernst;

  __PACKAGE__->meta->metadescription->apply_role(
      'Ernst::Description::Trait::TT::Class', {
          flavors   => [qw/view edit test/],
          templates => {
              test => '[% class.name %][% biography %][% username %]',
          },
      },
  );

  has 'username' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      description => {
          type       => 'String',
          min_length => 0,
          max_length => 8,
          traits     => ['TT'],
          templates  => {
              view => '<b>[% value | html %]</b>',
              # use default edit and test
          },
      },
  );

  has 'biography' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      description => {
          type       => 'String',
          min_length => 0,
          max_length => 8,
          traits     => ['TT'],
          templates  => {
              view => '<div class="long_essay">[% value | html %]</div>',
              edit => '<div class="rich_text">[% default %]</div>',
              # use default test
          },
      },
  );
}

my $form = Form->new( username => 'jrockway', biography => '<OH HAI>' );
isa_ok $form, 'Form';
ok $form->meta->metadescription;
is_deeply [$form->meta->metadescription->get_attribute_list],
  [qw/username biography/];


my $i = Ernst::Interpreter::TT->new;
ok $i;

my $view = $i->interpret($form, 'view');
is $view, '<b>jrockway</b><div class="long_essay">&lt;OH HAI&gt;</div>',
  'render as view worked';

my $test = $i->interpret($form, 'test');
is $test, 'Form<OH HAI>jrockway', 'render as test worked';

