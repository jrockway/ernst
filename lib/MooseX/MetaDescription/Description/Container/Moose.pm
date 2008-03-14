package MooseX::MetaDescription::Description::Container::Moose;
use MooseX::MetaDescription;
use Moose;
use MooseX::AttributeHelpers;

extends 'MooseX::MetaDescription::Description::Container';

has 'class' => (
    isa      => 'MooseX::MetaDescription::Meta::Class',
    is       => 'ro',
    required => 1,
);

has '+name' => (
    lazy    => 1,
    default => sub { shift->class->name },
);

has '+attributes' => (
    lazy    => 1,
    default => sub {
        my $self = shift;
        my %map = %{$self->class->get_attribute_map};
        my @have_descriptions = grep { 
            # XXX: does_role seems to not work here; checking "can" instead
            # which is rather flaky
            $map{$_}->can('metadescription')
        } keys %map;
        
        my %result;
        @result{@have_descriptions} = 
          map { $_->metadescription } @map{@have_descriptions};
        return \%result;
    },
);

1;
#
__END__

=head1 NAME

MooseX::MetaDescription::Description::Container::Moose - a
MooseX::MetaDescription::Description::Container for Moose classes

=head1 SYNOPSIS

  my $container = MooseX::MetaDescription::Description::Container::Moose->new(
      class => Some::Moose::Class->meta,
  );

  my @attributes = $container->attribute_names;

  ...

=head1 METHODS

This class inherits from
L<MooseX::MetaDescription::Description::Container> and
L<MooseX::MetaDescription::Description>.
