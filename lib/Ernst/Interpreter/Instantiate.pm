package Ernst::Interpreter::Instantiate;
use Moose;

has 'description' => (
    isa      => 'Ernst::Description::Container::Moose',
    is       => 'ro',
    required => 1,
);

sub create_instance {
    my ($self, $attributes) = @_;
    my $metaclass = $self->description->class;
    return $metaclass->name->new( $attributes );
}

1;
