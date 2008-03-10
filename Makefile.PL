use inc::Module::Install;

name 'MooseX-MetaDescription';
all_from 'lib/MooseX/MetaDescription.pm';

requires 'Moose';
requires 'MooseX::AttributeHelpers';

build_requires 'Test::More';
build_requires 'ok';

WriteAll();
