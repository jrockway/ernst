use inc::Module::Install;

name 'Ernst';
all_from 'lib/Ernst.pm';

requires 'Data::Thunk';
requires 'List::MoreUtils';
requires 'Module::Pluggable::Object';
requires 'Moose' => '0.45';
requires 'Moose::Autobox';
requires 'MooseX::AttributeHelpers';
requires 'Sub::AliasedUnderscore';
build_requires 'Test::Exception';
build_requires 'Test::More';
build_requires 'Test::TableDriven';
build_requires 'ok';


WriteAll();
