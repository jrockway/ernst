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
    my ($self, $old_instance, $new_attributes, $args) = @_;

    my $clone = $args->{clone};

    ## change "undef" to the class name (so we can $old_instance->meta)
    $old_instance ||= $self->description->class->name;

    ## find which attributes are editable
    my @attributes = $self->_grep(
        sub { $_[1]->does('Ernst::Description::Trait::Editable') },
        $self->description->get_attribute_list,
    );

    ## grep out things that can't be edited
    ## if $old_instance is a class, then we look at initially_editable
    ## otherwise we look at editable
    my $test = blessed $old_instance ? 'editable' : 'initially_editable';
    @attributes = $self->_grep(
        sub { $_[1]->$test },
        @attributes,
    );

    ## now we find attributes that have transform rules
    my @transformable = $self->_grep(
        sub { $_[1]->does('Ernst::Description::Trait::Transform') },
        @attributes,
    );

    ## then we run the transformations, keeping track of errors
    my %errors;
    my %direct_attributes = %{ $new_attributes->hslice(\@attributes) || {} };
    foreach my $name (@transformable){
        my $desc   = $self->description->get_attribute($name);
        my @source = @{ $desc->transform_source };
        my $rule   = $desc->transform_rule;

        eval {
            $direct_attributes{$name} = $rule->(
                map { $new_attributes->{$_} } @source
            );
        };
        if(my $error = $@){
            $errors{$name} = $self->_parse_error($error);
        }
    }

    ## treat the empty string as undef (so '' isn't a valid Str)
    foreach my $key (keys %direct_attributes){
        no warnings;
        $direct_attributes{$key} = undef if $direct_attributes{$key} eq '';
    }

    ## delete ignorable attributes
    foreach my $name (keys %direct_attributes){
        my $desc = $self->description->get_attribute($name);

        # delete if ignorable
        delete $direct_attributes{$name} and next
          if $desc->ignore_if->($direct_attributes{$name});

        # delete if blank and not required
        delete $direct_attributes{$name} and next
          if !defined $direct_attributes{$name} &&
             !$self->description->class->get_attribute($name)->is_required;
    }

    ## now we run the Moose validations on each attribute
    eval {
        $self->validate($old_instance, \%direct_attributes);
    };

    ## now we take those errors and combine them with the transform errors
    ## (hash of array of errors: { column => [ error, ... ], column 2 => ... }
    my $errors = $@ || {};

    foreach my $key (keys %errors){
        my $other = $errors->{$key};
        if($other){
            $errors->{$key} = [ $errors{$key}, $other ];
        }
        else {
            $errors->{$key} = [ $errors{$key} ];
        }
    }
    foreach my $key (grep { !ref $errors->{$_} } keys %$errors){
        $errors->{$key} = [ $errors->{$key} ];
    }

    die { errors => $errors } if keys %$errors > 0;

    ## ok, we have valid data! create an instance

    if(!blessed $old_instance){
        # create a new instance
        my $metaclass = $self->description->class;
        return $metaclass->name->new( %direct_attributes );
    }

    # or update the old one
    my $instance = $clone ? $old_instance->meta->clone_instance($old_instance) :
                            $old_instance;
    foreach my $name (keys %direct_attributes){
        my $value = $direct_attributes{$name};
        $instance->meta->get_attribute($name)->set_value($instance, $value);
    }
    return $instance;
}

sub _parse_error {
    my ($self, $error) = @_;
    my ($msg) = ($error =~ /^(.+) at (?:\S+) line/);
    return $msg || $error;
}

sub validate {
    my ($self, $old_instance, $direct_attributes) = @_;
    my %errors;
    my $meta_instance = $old_instance->meta->get_meta_instance();
    my $trial_instance = $meta_instance->create_instance();
    foreach my $attr_name (keys %$direct_attributes) {
        my $attr = $self->description->class->get_attribute($attr_name);

        eval {
            # this is the logic that Moose itself uses for the
            # "Attribute (foo) is required" message
            die 'This field is required'
              if !defined $direct_attributes->{$attr_name} &&
                $attr->is_required && !$attr->has_default && !$attr->has_builder;

            $attr->initialize_instance_slot(
                $meta_instance,
                $trial_instance,
                $direct_attributes
            );
        };
        if(my $error = $@){
            $errors{$attr->name} = $self->_parse_error($error);
        }
    }
    die \%errors if keys %errors > 0;

    return; # no errors
}

1;
