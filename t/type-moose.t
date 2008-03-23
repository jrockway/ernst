use strict;
use warnings;
use Test::More tests => 6;
use Test::Exception;

{ package Class;
  use Ernst;

  has 'a' => (
      traits => ['MetaDescription'],
      is     => 'ro',
      isa    => 'Str',
  );

  has 'me' => (
      traits => ['MetaDescription'],
      is     => 'ro',
      isa    => 'Class',
  );

}

ok (Class->meta->metadescription);
ok my $a = Class->meta->get_attribute('a')->metadescription;
is $a->meta->type, 'String', 'type mapped ok';

ok my $m = Class->meta->get_attribute('me')->metadescription;
is $m->name, 'Class';
is $m, Class->meta->metadescription, 'guessed a type correctly';

