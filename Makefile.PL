use inc::Module::Install;

name 'Ernst';
all_from 'lib/Ernst.pm';

requires 'Data::Thunk';
requires 'Moose' => '0.39_01';
requires 'MooseX::AttributeHelpers';
requires 'Sub::AliasedUnderscore';
build_requires 'Test::More';
build_requires 'Test::TableDriven';
build_requires 'ok';


WriteAll();
