package Ernst::Meta::Class;
use Moose;
use Moose::Util::TypeConstraints;

extends 'Moose::Meta::Class';

has 'metadescription' => (
    is       => 'ro',
    isa      => 'Ernst::Description::Container',
    lazy     => 1,
    weak_ref => 1,
    default  => sub {
        require Ernst::Description::Container::Moose;

        my $self = shift;
        Ernst::Description::Container::Moose->new(
            class => $self,
        );
    },
);

1;
__END__

=head1 NAME

Ernst::Meta::Class - the metaclass for classes with
metadescriptions

=head1 SYNOPSIS

