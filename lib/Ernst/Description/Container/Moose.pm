package Ernst::Description::Container::Moose;
use Moose;
use MooseX::AttributeHelpers;

extends 'Ernst::Description::Container';

has 'class' => (
    isa      => 'Ernst::Meta::Class',
    is       => 'ro',
    required => 1,
);

# this becomes the attribute name when a class has_a <one of these>
has '+name' => (
    lazy    => 1,
    default => sub { shift->class->name },
);

# this is always the class name that this container was created from
has '+container_name' => (
    lazy    => 1,
    default => sub { shift->class->name },
);

has '+attributes' => (
    lazy    => 1,
    default => sub {
        my $self = shift;
        my @attrs = $self->class->compute_all_applicable_attributes;
        my %map = map { $_->name => $_ } @attrs;

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
