package MooseX::MetaDescription::TypeLibrary;
use Moose;

use Moose::Util::TypeConstraints;
use MooseX::MetaDescription::Type;

subtype 'ContainerCardinality'
  => as 'Str',
  => where { /^[+*?1]/ },
  => message { 'cardinality must be +, *, ?, or 1' };

1;

__END__

=head1 NAME

MooseX::MetaDescription::TypeLibrary - internal Moose types for
MooseX::MetaDescription

=head1 SYNOPSIS

  << picture of you not using this module >>

