package Ernst::Interpreter::Edit;
use Moose;
use Moose::Autobox;

has 'description' => (
    isa      => 'Ernst::Description::Container::Moose',
    is       => 'ro',
    required => 1,
);

sub _grep {
    my ($self, $code, @attrs) = @_;
    return grep { $code->($_, $self->description->get_attribute($_)) } @attrs;
}

sub interpret {
    my ($self, $old_instance, $new_attributes) = @_;

    my @attributes = $self->_grep(
        sub { $_[1]->does('Ernst::Description::Trait::Editable') },
        $self->description->get_attribute_list,
    );
    
    my $test = blessed $old_instance ? 'editable' : 'initially_editable';
    @attributes = $self->_grep(
        sub { $_[1]->$test },
        @attributes,
    );
    
    my @transformable = $self->_grep(
        sub { $_[1]->does('Ernst::Description::Trait::Transform') },
        @attributes,
    );
    
    my %direct_attributes = %{ $new_attributes->hslice(\@attributes) || {} };
    foreach my $name (@transformable){
        my $desc   = $self->description->get_attribute($name);
        my @source = @{ $desc->transform_source };
        my $rule   = $desc->transform_rule;

        $direct_attributes{$name} = $rule->(
            map { $new_attributes->{$_} } @source
        );
    }

    foreach my $name (keys %direct_attributes){
        my $desc = $self->description->get_attribute($name);
        delete $direct_attributes{$name}
          if $desc->ignore_if->($direct_attributes{$name});
    }
    
    if(!blessed $old_instance){
        my $metaclass = $self->description->class;
        return $metaclass->name->new( %direct_attributes );
    }

    my $instance = $old_instance->meta->clone_instance($old_instance);
    foreach my $name (keys %direct_attributes){
        my $value = $direct_attributes{$name};
        $instance->meta->get_attribute($name)->set_value($instance, $value);
    }
    return $instance;
}

1;
