package Ernst;

use Moose;
use Ernst::Meta::Class;
use Ernst::Meta::Attribute;

sub import {
    my $caller = caller;
    
    strict->import;
    warnings->import;

    Moose::init_meta(
        $caller,
        undef, # Moose::Object
        'Ernst::Meta::Class',
    );
    
    Moose->import({ into => $caller });
}

package Moose::Meta::Attribute::Custom::Trait::MetaDescription;
sub register_implementation { 'Ernst::Meta::Attribute' }

1;

__END__

=head1 NAME

Ernst - a metadescription framework for Moose classes

=head1 SYNOPSIS

Create a metadescribable Moose class:

  package User;
  use Ernst;

  has 'fullname' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      description => {
          type       => 'String',
          min_length => 1,
      }
  );

  has 'biography' => (
      traits      => ['MetaDescription'],
      is          => 'ro',
      isa         => 'Str',
      description => {
          type            => 'String',
          min_length      => 1,
          expected_length => 3000, # 500-words is average
      }
  );

Then introspect its metadescription:

  my $user_md = User->meta->metadescription;

  foreach my $name ($user_md->get_attribute_list) {
     my $attribute = $user_md->get_attribute($name);
     say $attribute->name, ': ', $attribute->type;
  }

You can also inspect attributes directly (via their metaclass):

  my $fullname_md = User->meta->get_attribute('fullname')->metadescription;
  say 'The fullname is a ', $fullname->type;

