use strict;
use warnings;
use Test::More tests => 9;
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
                        <span class="label">Label</span>: <input type="text">
                    </div>
                    <div id="test">
                      <p class="instructions">Lorem ipsum dolor (sit) amit.</p>
                      <p class="label">Field:</p>
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

my $i = Ernst::Interpreter::TRForm->new(
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
like $result, qr/Test Field[*]/, 'field label added';
like $result, qr/Fill in some test data here[.]/, 'field instructions added';
like $result, qr/<input[^>]+name="test"/, 'field name added to input';

chomp(my $exact = <<HERE);
<form>
                    <div id="attribute">
                        <span class="label">attribute</span>: <input type="text" name="attribute"/></div>
                    <div id="test">
                      <p class="instructions">Fill in some test data here.</p>
                      <p class="label">Test Field*</p>
                      <input type="text" name="test"/></div>
                  </form>
HERE

is $result, $exact, 'got exact expected HTML';
