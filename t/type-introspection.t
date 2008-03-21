use strict;
use warnings;
use Test::More tests => 21;

use ok 'Ernst::Description';
use ok 'Ernst::Description::Container';
use ok 'Ernst::Description::Container::Moose';
use ok 'Ernst::Description::String';
use ok 'Ernst::Description::Integer';
use ok 'Ernst::Description::Boolean';
use ok 'Ernst::Description::Collection';

is_deeply 
  [Ernst::Description->meta->types],
  [''],
  'no supertypes of the Description';

is_deeply 
  [Ernst::Description::String->meta->types],
  ['String', ''],
  'only Description is a supertype of String';

is_deeply 
  [Ernst::Description::Container::Moose->meta->types],
  ['Container::Moose', 'Container', ''],
  q{Container::Moose -> Container -> ''};

ok(Ernst::Description::String->meta->type_isa('String'));
ok(Ernst::Description::String->meta->type_isa(''));
ok(Ernst::Description::Container::Moose->meta->type_isa('Container::Moose'));
ok(Ernst::Description::Container::Moose->meta->type_isa('Container'));
ok(Ernst::Description::Container::Moose->meta->type_isa(''));
ok(!Ernst::Description::Container::Moose->meta->type_isa('String'));

is(Ernst::Description::String->meta->type, 'String');

is(Ernst::Description::Container->meta->type, 'Container');
is(Ernst::Description::Container::Moose->meta->type, 'Container::Moose');

is_deeply
  [Ernst::Description::Container->meta->subtypes],
  ['Container', 'Container::Moose'],
  'subtypes of Description::Container are correct';

is_deeply
  [sort Ernst::Description->meta->subtypes],
  [sort '',qw/Container::Moose Container String Integer Boolean Collection/],
  'subtypes of Description are correct';

