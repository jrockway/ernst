use strict;
use warnings;
use Test::More tests => 17;

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
