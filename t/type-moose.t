use strict;
use warnings;
use Test::More tests => 7;
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
is $m->class->name, 'Class';
is_deeply [sort $m->get_attribute_list], [sort qw/a me/];
is $m->get_attribute('me'), $m, 'm->me == m';
