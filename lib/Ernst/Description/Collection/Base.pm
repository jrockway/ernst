package Ernst::Description::Collection::Base;
use Moose::Role;
use Moose::Util::TypeConstraints;
use Ernst::Meta::Attribute;
use Ernst::Util;

subtype InsideType
  => as 'Any', # XXX: this used to be Class, which is not a valid type. investigate.
  => where {
      $_->isa('Ernst::Description');
  };

coerce InsideType
  => from 'Str'
  => via {
      my $class = Ernst::Util::get_type_class($_);
      #return $class if ref $class;
      return $class;
  };

has 'inside_type' => (
    isa      => 'InsideType',
    is       => 'ro',
    required => 1,
    coerce   => 1,
);

1;
