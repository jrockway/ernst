use strict;
use warnings;

use Test::More tests => 8;
use Test::Exception;

my $html = q{
    <form>
      <div id="attribute">
          1. <span class="value" />
          2. <span class="value" />
      </div>
    </form>
};

{ package Class;
  use Ernst;
  use Template::Refine;

  has 'attribute' => (
      is          => 'ro',
      isa         => 'ArrayRef[Str]',
      traits      => ['MetaDescription'],
      required    => 1,
      description => {
          type        => 'Collection',
          inside_type => 'String',
          cardinality => '*',
          traits      => [qw/Region/],
          region      => css('#attribute'),
      },
  );
}

use Ernst::Interpreter::TRForm;

my $md = Class->meta->metadescription;
ok $md;
ok $md->get_attribute('attribute');

my $i = Ernst::Interpreter::TRForm->new_with_traits(
    traits                   => [qw/Value/],
    value_replacement_region => '//span[@class="value"]',
    representation           => $html,
    class                    => Class->meta,
);
ok $i;

my $instance = Class->new( attribute => [qw/foo bar/] );

my $result;
lives_ok {
    $result = $i->interpret($instance);
} 'interpret lived';

ok( $result = $result->render );
like $result, qr{1[.] <span class="value">foo</span>}, 'got foo';
like $result, qr{2[.] <span class="value">bar</span>}, 'got bar';

chomp(my $exact = <<HERE);
<form>
      <div id="attribute">
          1. <span class="value">foo</span>
          2. <span class="value">bar</span>
      </div>
    </form>
HERE

is $result, $exact, 'got exact expected HTML';
