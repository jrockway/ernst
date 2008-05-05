package Ernst::Meta::Class;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::AttributeHelpers;

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

has '_attribute_order' => (
    metaclass  => 'Collection::Array',
    is         => 'ro',
    isa        => 'ArrayRef',
    default    => sub { [] },
    auto_deref => 1,
    provides   => {
        push => '_remember_attribute',
    },
);

before 'add_attribute' => sub {
    my ($self, $name, $attribute) = @_;
    $self->_remember_attribute($name);
};

1;
__END__

=head1 NAME

Ernst::Meta::Class - the metaclass for classes with
metadescriptions

=head1 SYNOPSIS

