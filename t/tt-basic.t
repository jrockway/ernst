use strict;
use warnings;
use Test::More tests => 8;

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
              edit => '<div class="rich_text">[% next %]</div>',
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
is $view, '<div id="view_class_Form"><div class="long_essay">&lt;OH HAI&gt;</div><b>jrockway</b></div>',
  'render as view worked';

$i->add_default_attribute_template(
    'test', '', '[% value %]',
);

my $test = $i->interpret($form, 'test');
is $test, 'Form<OH HAI>jrockway', 'render as test worked';

my $edit = $i->interpret($form, 'edit', { action => 'ACTION' });
is $edit, '<form id="edit_class_Form" method="post" action="ACTION"><div class="rich_text"><label for="biography" id="biography_label">biography</label><input type="text" name="biography" id="biography" value="&lt;OH HAI&gt;" /></div><label for="username" id="username_label">username</label><input type="text" name="username" id="username" value="jrockway" /></form>',
  'render as edit worked';
