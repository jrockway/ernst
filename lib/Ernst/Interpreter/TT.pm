package Ernst::Interpreter::TT;
use Moose;
use Template;
use 5.010; # smart match

with 'Ernst::Interpreter';

has 'engine' => (
    is      => 'ro',
    isa     => 'Template',
    default => sub {
        Template->new,
    },
);

sub interpret {
    my ($self, $instance, $flavor) = @_;
    my $desc = $instance->meta->metadescription;

    confess "$instance cannot be rendered with the TT interpreter"
      unless $desc->does('Ernst::Description::Trait::TT::Class');

    confess "$instance does not have a '$flavor' flavor"
      unless $desc->flavors ~~ $flavor;
    
    my %rendered_attributes;
    for my $attr ($desc->get_attribute_list){
        $rendered_attributes{$attr} = $self->render_attribute(
            $desc->get_attribute($attr),
            $instance,
            $flavor,
        );
    }

    my $template = $desc->templates->{$flavor};
    if($template){
        return $self->_render_template($template, {
            %rendered_attributes,
            description => $desc,
            class       => $desc->class,
        });
    }
    
    return join '', map { $rendered_attributes{$_} } $desc->get_attribute_list;
}

sub _render_template {
    my ($self, $template, $vars) = @_;
    my $output;
    $self->engine->process(\$template, $vars, \$output);
    return $output;
}

sub render_attribute {
    my ($self, $desc, $instance, $flavor) = @_;
    my $template = $desc->templates->{$flavor} || '[% value %]';
    my $value    = $instance->meta->
      get_meta_instance->get_slot_value($instance, $desc->name);

    return $self->_render_template($template, {
        description => $desc,
        name        => $desc->name,
        attribute   => $desc->attribute,
        value       => $desc->attribute->get_value($instance),
        default     => 'NOT YET IMPLEMENTED',
    });
}

1;
