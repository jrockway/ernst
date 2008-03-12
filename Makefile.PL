use inc::Module::Install;

name 'MooseX-MetaDescription';
all_from 'lib/MooseX/MetaDescription.pm';

requires 'Moose' => '0.39_01'; # needs M::Meta::Class->create with role support
requires 'MooseX::AttributeHelpers';

build_requires 'Test::More';
build_requires 'ok';

WriteAll();
