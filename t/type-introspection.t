use strict;
use warnings;
use Test::More tests => 10;

use ok 'MooseX::MetaDescription::Description';
use ok 'MooseX::MetaDescription::Description::Container';
use ok 'MooseX::MetaDescription::Description::Container::Moose';
use ok 'MooseX::MetaDescription::Description::String';
use ok 'MooseX::MetaDescription::Description::Integer';
use ok 'MooseX::MetaDescription::Description::Boolean';
use ok 'MooseX::MetaDescription::Description::Collection';

is_deeply 
  [MooseX::MetaDescription::Description->types],
  [''],
  'no supertypes of the Description';

is_deeply 
  [MooseX::MetaDescription::Description::String->types],
  ['String', ''],
  'only Description is a supertype of String';

is_deeply 
  [MooseX::MetaDescription::Description::Container::Moose->types],
  ['Container::Moose', 'Container', ''],
  q{Container::Moose -> Container -> ''};
