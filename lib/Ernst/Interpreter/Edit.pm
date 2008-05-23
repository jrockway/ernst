package Ernst::Interpreter::Edit;
use Moose;
use Moose::Autobox;

has 'description' => (
    isa      => 'Ernst::Description::Container::Moose',
    is       => 'ro',
    required => 1,
);

sub interpret {
    my ($self, $old_instance, $new_attributes) = @_;

    my @attributes = grep {
        my $a = $self->description->get_attribute($_);
        $a->does('Ernst::Description::Trait::Editable')
    } $self->description->get_attribute_list;
    
    if(!blessed $old_instance){
        @attributes = grep {
            $self->description->get_attribute($_)->initially_editable;
        } @attributes;
    }
    else {
        @attributes = grep {
            $self->description->get_attribute($_)->editable;
        } @attributes;
    }

    my %new_attributes = %{ $new_attributes->hslice(\@attributes) || {} };
    if(!blessed $old_instance){
        my $metaclass = $self->description->class;
        return $metaclass->name->new( %new_attributes );
    }

    my $instance = $old_instance->meta->clone_instance($old_instance);
    foreach my $name (keys %new_attributes){
        my $value = $new_attributes{$name};
        $instance->meta->get_attribute($name)->set_value($instance, $value);
    }
    return $instance;
}

1;
