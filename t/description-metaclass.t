use strict;
use warnings;
use Test::More tests => 3;

use Ernst::Description;
use Ernst::Description::String;

isa_ok(Ernst::Description->meta, 'Ernst::Meta::Description::Class');

my $d = Ernst::Description->new( name => 'foo' );
isa_ok($d->meta, 'Ernst::Meta::Description::Class');

my $s = Ernst::Description::String->new( name => 'bar' );
isa_ok($s->meta, 'Ernst::Meta::Description::Class');
