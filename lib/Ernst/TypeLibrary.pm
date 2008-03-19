package Ernst::TypeLibrary;
use Moose;

use Moose::Util::TypeConstraints;

subtype 'ContainerCardinality'
  => as 'Str',
  => where { /^[+*?1]/ },
  => message { 'cardinality must be +, *, ?, or 1' };

1;

__END__

=head1 NAME

Ernst::TypeLibrary - internal Moose types for
Ernst

=head1 SYNOPSIS

  << picture of you not using this module >>

