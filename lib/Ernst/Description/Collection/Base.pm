package Ernst::Description::Collection::Base;
use Moose::Role;
use Data::Thunk;
use Moose::Util::TypeConstraints;
use Ernst::Meta::Attribute;

subtype InsideType
  => as 'Class',
  => where {
      $_->isa('Ernst::Description');
  };

coerce InsideType
  => from 'Str'
  => via { 
      my $class = Ernst::Meta::Attribute::_get_type_class($_);
      return $class if ref $class;
      return $class->meta->metadescription;
  };

has 'inside_type' => (
    isa         => 'InsideType',
    is          => 'ro',
    required    => 1,
    traits      => ['MetaDescription'],
    coerce      => 1,
    description => {
        type => 'String',
    },
);

1;
