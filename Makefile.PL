use inc::Module::Install;

name 'MooseX-MetaDescription';
all_from 'lib/MooseX/MetaDescription.pm';

requires 'Data::Thunk';
requires 'Moose' => '0.39_01';
requires 'MooseX::AttributeHelpers';
requires 'Sub::AliasedUnderscore';
build_requires 'Test::More';
build_requires 'ok';


WriteAll();
