use strict;
use warnings;
use Test::More tests => 16;

use ok 'Ernst::Description';
use ok 'Ernst::Description::Container';
use ok 'Ernst::Description::Container::Moose';
use ok 'Ernst::Description::String';
use ok 'Ernst::Description::Integer';
use ok 'Ernst::Description::Boolean';
use ok 'Ernst::Description::Collection';

is_deeply 
  [Ernst::Description->types],
  [''],
  'no supertypes of the Description';

is_deeply 
  [Ernst::Description::String->types],
  ['String', ''],
  'only Description is a supertype of String';

is_deeply 
  [Ernst::Description::Container::Moose->types],
  ['Container::Moose', 'Container', ''],
  q{Container::Moose -> Container -> ''};

ok(Ernst::Description::String->type_isa('String'));
ok(Ernst::Description::String->type_isa(''));
ok(Ernst::Description::Container::Moose->type_isa('Container::Moose'));
ok(Ernst::Description::Container::Moose->type_isa('Container'));
ok(Ernst::Description::Container::Moose->type_isa(''));
ok(!Ernst::Description::Container::Moose->type_isa('String'));
