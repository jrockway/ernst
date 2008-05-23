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

sub interpret {
    my ($self, $instance, $flavor) = @_;
    my $desc = $instance->meta->metadescription;

    confess "$instance cannot be rendered with the TT interpreter"
      unless $desc->does('Ernst::Description::Trait::TT::Class');
    
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
        die 'no';
        return;
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
    my $template = $desc->templates->{$flavor};
    my $value    = $instance->meta->
      get_meta_instance->get_slot_value($instance, $desc->name);

    return $self->_render_template($template, {
        description => $desc,
        name        => $desc->name,
        attribute   => $desc->attribute,
        value       => $value,
        default     => 'NOT YET IMPLEMENTED',
    });
}

1;
