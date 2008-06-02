package Ernst::Interpreter::TT;
use Moose;
use Template;

with 'Ernst::Interpreter';

has 'engine' => (
    is      => 'ro',
    isa     => 'Template',
    default => sub {
        Template->new,
    },
);

sub lookup_attribute_template {
    my ($self, $attr, $flavor) = @_;
    return $attr->templates->{$flavor};
}

sub lookup_class_template {
    my ($self, $desc, $flavor) = @_;
    return $desc->templates->{$flavor};
}

sub interpret {
    my ($self, $instance, $flavor, $extra_vars) = @_;
    my $desc = $instance->meta->metadescription;

    confess "$instance cannot be rendered with the TT interpreter"
      unless $desc->does('Ernst::Description::Trait::TT');


    my %rendered_attributes;
    for my $attr (
        grep { $desc->get_attribute($_)->does('Ernst::Description::Trait::TT') } 
          $desc->get_attribute_list
      ){
        $rendered_attributes{$attr} = $self->render_attribute(
            $desc->get_attribute($attr),
            $instance,
            $flavor,
            $extra_vars,
        );
    }
    
    my $template = $self->lookup_class_template($desc, $flavor);

    return $self->_render_template($template, {
        %rendered_attributes,
        attributes      => \%rendered_attributes,
        attribute_order => [$desc->get_attribute_list],
        description     => $desc,
        class           => $desc->class,
        name            => $desc->name,
        instance        => $instance,
        %{ $extra_vars || {} }, # TODO: warn when this conflicts
    });
}

sub render_attribute {
    my ($self, $desc, $instance, $flavor, $extra_vars) = @_;

    my $template = $self->lookup_attribute_template($desc, $flavor);
    return $self->_render_attribute
      ($desc, $instance, $extra_vars, $template);
}

sub _render_attribute {
    my ($self, $desc, $instance, $extra_vars, $template) = @_;

    return $self->_render_template($template, {
        description => $desc,
        name        => $desc->name,
        label       => (eval { $desc->label } || ucfirst $desc->name ),
        attribute   => $desc->attribute,
        value       => (eval { $desc->attribute->get_value($instance) } || ''),
        %{ $extra_vars || {} }, # TODO: warn when this conflicts
    });
}

sub _render_template {
    my ($self, $template, $stash) = @_;
    my $output;

    $template = $template->($stash) if ref $template && ref $template eq 'CODE';

    $self->engine->process(\$template, $stash, \$output);
    return $output;
}

1;
