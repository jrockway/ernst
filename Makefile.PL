use inc::Module::Install;

name 'Ernst';
all_from 'lib/Ernst.pm';

requires 'Data::Thunk';
requires 'DateTime';
requires 'DateTime::Format::DateParse';
requires 'DateTime::Format::Strptime';
requires 'List::MoreUtils';
requires 'Module::Pluggable::Object';
requires 'Moose' => '0.48';
requires 'Moose::Autobox';
requires 'MooseX::AttributeHelpers' => '0.09';
requires 'MooseX::MetaDescription';
requires 'MooseX::Traits';
requires 'Sub::AliasedUnderscore';
build_requires 'Test::Exception';
build_requires 'Test::More';
build_requires 'Test::TableDriven';
build_requires 'ok';


WriteAll();
