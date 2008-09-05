use strict;
use warnings;
use Test::More tests => 10;
use Test::Exception;

use ok 'Ernst::Interpreter::TRForm';

{ package Class;
  use Ernst;

  __PACKAGE__->meta->metadescription->apply_role(
      'Ernst::Description::Trait::Representation', {
          representations => {
              test => q{
                  <form>
                    <div id="attribute">
                        <span class="label">Attribute Label</span>: <input type="text">
                    </div>
                    <div id="test">
                      <p class="instructions">Lorem ipsum dolor (sit) amit.</p>
                      <span class="label">Field</span>:
                      <input type="text">
                    </div>
                  </form>
              },
          },
      },
  );

  has 'test' => (
      is          => 'ro',
      isa         => 'Str',
      traits      => ['MetaDescription'],
      required    => 1,
      description => {
          traits             => [qw/Region Editable Friendly/],
          editable           => 1,
          initially_editable => 1,
          label              => 'Test Field',
          instructions       => 'Fill in some test data here.',
          region             => {
              test => q|//*[@id='test']|,
          },
      },
  );

  has 'attribute' => (
      is          => 'ro',
      isa         => 'Str',
      traits      => ['MetaDescription'],
      required    => 1,
      description => {
          traits             => [qw/Region Editable/],
          editable           => 1,
          initially_editable => 1,
          region             => {
              test => q|//*[@id='attribute']|,
          },
      },
  );

}

my $md = Class->meta->metadescription;
ok $md;

my $i = Ernst::Interpreter::TRForm->new_with_traits(
    traits    => [qw/Namespace Label Instructions/],
    class     => Class->meta,
    flavor    => 'test',
    namespace => '',
);
ok $i;

my $result;
lives_ok {
    $result = $i->interpret(undef);
} 'interpret lived';

ok( $result = $result->render );
like $result, qr/<input[^>]+name="attribute"/, 'attribute field name added to input';
like $result, qr/<input[^>]+name="test"/, 'test field name added to input';
like $result, qr/Test Field[*]/, 'field label added';
like $result, qr/Fill in some test data here[.]/, 'field instructions added';

chomp(my $exact = <<HERE);
<form>
                    <div id="attribute">
                        <span class="label">Attribute Label*</span>: <input type="text" name="attribute"/></div>
                    <div id="test">
                      <p class="instructions">Fill in some test data here.</p>
                      <span class="label">Test Field*</span>:
                      <input type="text" name="test"/></div>
                  </form>
HERE

is $result, $exact, 'got exact expected HTML';
