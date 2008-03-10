package MooseX::MetaDescription::TypeLibrary;
use Moose;

use Moose::Util::TypeConstraints;
use MooseX::MetaDescription::Type;

coerce 'MooseX::MetaDescription::Type'
  => from 'Str',
  => via {
      my $type = $_;
      my $class = "MooseX::MetaDescription::Type::$type";
      Class::MOP::load_class($class);
      $class->new;
  };


1;

__END__

=head1 NAME

MooseX::MetaDescription::TypeLibrary - internal Moose types for
MooseX::MetaDescription

=head1 SYNOPSIS

  << picture of you not using this module >>

=head1 DESCRIPTION

I need type constraints in a class that has a "type" attribute, so I
can't just declare the types inline.  Instead, they're in this
package.

Exports and classes don't mix.
