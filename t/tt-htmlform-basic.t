use strict;
use warnings;
use Test::More tests => 9;

use ok 'Ernst::Interpreter::TT::HTMLForm';

{ package Form;
  use Ernst;

  __PACKAGE__->meta->metadescription->apply_role(
      'Ernst::Description::Trait::TT', {
          templates => {
              test => '[% class.name %][% biography %][% username %]',
          },
      },
  );
  has 'id' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      required    => 1,
      description => {
          type               => 'String',
          traits             => [qw/TT Editable Friendly/],
          label              => 'ID',
          editable           => 0,
          initially_editable => 0,
      },
  );

  has 'username' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      required    => 1,
      description => {
          type               => 'String',
          traits             => [qw/TT Editable Friendly/],
          label              => 'Desired username',
          initially_editable => 1,
          editable           => 0,
          instructions       => 'The username can contain any characters.  Choose wisely; you may not change it after registration.',
          templates          => {
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
          traits     => [qw/TT Editable/],
          templates  => {
              view => '<div class="long_essay">[% value | html %]</div>',
              edit => '<div class="rich_text">[% next %]</div>',
              # use default test
          },
      },
  );
}

my $form = Form->new( id => 42, username => 'jrockway', biography => '<OH HAI>' );
isa_ok $form, 'Form';
ok $form->meta->metadescription;
is_deeply [$form->meta->metadescription->get_attribute_list],
  [qw/id username biography/];


my $i = Ernst::Interpreter::TT::HTMLForm->new;
ok $i;

my $view = $i->interpret($form, 'view');
is $view, '<div id="view_class_Form"><ul><li><span id="view_id">ID: 42</span></li><li><b>jrockway</b></li><li><div class="long_essay">&lt;OH HAI&gt;</div></li></ul></div>',
  'render as view worked';

$i->add_default_attribute_template(
    'test', '', '[% value %]',
);

my $test = $i->interpret($form, 'test');
is $test, 'Form<OH HAI>jrockway', 'render as test worked';

my $initial_edit = $i->interpret('Form', 'edit', { action => 'ACTION' });
is $initial_edit, '<form id="edit_class_Form" method="post" action="ACTION"><ul><li><span id="view_id">ID: </span></li><li><label for="username" id="username_label">Desired username<span class="required">*</span></label><input type="text" class="field text medium" name="username" id="username" value="" /><p class="instruct">The username can contain any characters.  Choose wisely; you may not change it after registration.</p></li><li><div class="rich_text"><label for="biography" id="biography_label">Biography</label><input type="text" class="field text medium" name="biography" id="biography" value="" /></div></li><li><input type="submit" name="do_submit" value="Submit" /></li></ul> </form>', 
  'initial edit worked';

my $edit = $i->interpret($form, 'edit', { action => 'ACTION' });
is $edit, '<form id="edit_class_Form" method="post" action="ACTION"><ul><li><span id="view_id">ID: 42</span></li><li><b>jrockway</b></li><li><div class="rich_text"><label for="biography" id="biography_label">Biography</label><input type="text" class="field text medium" name="biography" id="biography" value="&lt;OH HAI&gt;" /></div></li><li><input type="submit" name="do_submit" value="Submit" /></li></ul> </form>',
  'render as edit worked';
