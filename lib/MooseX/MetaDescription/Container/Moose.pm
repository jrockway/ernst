package MooseX::MetaDescription::Container::Moose;
use Moose;
use MooseX::AttributeHelpers;
use MooseX::MetaDescription::Description;

extends 'MooseX::MetaDescription::Container';

has 'class' => (
    isa      => 'MooseX::MetaDescription::Meta::Class',
    is       => 'ro',
    required => 1,
);

has '+attributes' => (
    lazy    => 1,
    default => sub {
        my $self = shift;
        my %map = %{$self->class->get_attribute_map};
        my @have_descriptions = 
          grep { $map{$_}->isa('MooseX::MetaDescription::Meta::Attribute') } 
            keys %map;
        
        my %result;
        @result{@have_descriptions} = 
          map { $_->metadescription } @map{@have_descriptions};
        return \%result;
    },
);

1;

__END__

=head1 NAME

MooseX::MetaDescription::Container::Moose - a
MooseX::MetaDescription::Container for Moose classes

=head1 SYNOPSIS

  my $container = MooseX::MetaDescription::Container::Moose->new(
      class => Some::Moose::Class->meta,
  );

  my @attributes = $container->attribute_names;

  ...

=head1 METHODS

=head2 attribute($name)

Returns the attribute metadescription class for the attribute C<$name>.

=head2 attributes

Returns a hash mapping attribute names to attribute metadescription classes.
