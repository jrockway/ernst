package Ernst::Description::Container::Moose;
use Ernst;
use Moose;
use MooseX::AttributeHelpers;

extends 'Ernst::Description::Container';

has 'class' => (
    isa      => 'Ernst::Meta::Class',
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

Ernst::Description::Container::Moose - a
Ernst::Description::Container for Moose classes

=head1 SYNOPSIS

  my $container = Ernst::Description::Container::Moose->new(
      class => Some::Moose::Class->meta,
  );

  my @attributes = $container->attribute_names;

  ...

=head1 METHODS

This class inherits from
L<Ernst::Description::Container> and
L<Ernst::Description>.
