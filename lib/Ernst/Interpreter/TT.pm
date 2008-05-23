package Ernst::Interpreter::TT;
use Moose;
use Template;
use MooseX::AttributeHelpers;
use 5.010; # smart match

sub flatten($){
    my $str = shift;
    chomp $str;
    $str =~ s/^\s+//g;
    $str =~ s/\s+$//g;
    $str =~ s/\n\s*//g;
    return $str;
}

with 'Ernst::Interpreter';

has 'engine' => (
    is      => 'ro',
    isa     => 'Template',
    default => sub {
        Template->new,
    },
);

# +{ type0 => { flavor0 => ..., flavor1 => .. }, type1 => ... }
has 'default_attribute_templates' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'HashRef[HashRef[Str]]', # TODO: HashRef[HashRef[Template]]
    provides  => {
        get => '_lookup_attribute_template_flavors',
    },
    default   => sub {
        return +{
            "" => {
                view => flatten q{
                    <div id="[% name | html %]_view">
                      [% name | html %]: [% value | html %]
                    </div>
                },
                edit => flatten q{
                    <label for="[% name | html %]"
                           id="[% name | html %]_label">[% name | html %]</label>
                    <input type="text"
                           name="[% name | html %]"
                           id="[% name | html %]"
                           value="[% value | html %]" />
                },
            },
        };
    },
);

has 'default_class_templates' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'HashRef[Str]', # TODO: HashRef[Template]
    provides  => {
        get => '_lookup_class_template',
        set => 'add_default_class_template',
    },
    default   => sub {
        return +{
            view => flatten q{
                <div id="view_class_[% name | html %]">
                [% FOREACH attr IN attributes.keys %]
                  [% attributes.$attr %]
                [% END %]
                </div>
            },
            edit => flatten q{
                <form id="edit_class_[% name | html %]" method="post" action="[% action | html %]">
                [% FOREACH attr IN attributes.keys %]
                  [% attributes.$attr %]
                [% END %]
                </div>
            },
        };
    },
);

# TODO: allow something like inner/augment
sub _lookup_attribute_template {
    my ($self, $attr, $flavor) = @_;
    for my $type ($attr->meta->types) {
        my $template = eval { $self->_lookup_attribute_template_flavors($type)->{$flavor} };
        return $template if $template;
    }
    confess "No default $flavor template for $attr (".
      join(',', $attr->meta->types).
      ")";
}

sub add_default_attribute_template {
    my ($self, $flavor, $type, $template) = @_;
    my $templates = $self->default_attribute_templates;
    $templates->{$type}{$flavor} = $template;
    return;
}

sub interpret {
    my ($self, $instance, $flavor, $extra_vars) = @_;
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
            $extra_vars,
        );
    }

    my $template = $desc->templates->{$flavor} || 
      $self->_lookup_class_template($flavor);

    return $self->_render_template($template, {
        %rendered_attributes,
        attributes  => \%rendered_attributes,
        description => $desc,
        class       => $desc->class,
        name        => $desc->name,
        %{ $extra_vars || {} }, # TODO: warn when this conflicts
    });
}

sub _render_template {
    my ($self, $template, $vars) = @_;
    my $output;
    $self->engine->process(\$template, $vars, \$output);
    return $output;
}

sub render_attribute {
    my ($self, $desc, $instance, $flavor, $extra_vars) = @_;
    my $template = $desc->templates->{$flavor} || 
      $self->_lookup_attribute_template($desc, $flavor);
    
    my $value    = $instance->meta->
      get_meta_instance->get_slot_value($instance, $desc->name);

    return $self->_render_template($template, {
        description => $desc,
        name        => $desc->name,
        attribute   => $desc->attribute,
        value       => $desc->attribute->get_value($instance),
        inner       => 'NOT YET IMPLEMENTED',
        %{ $extra_vars || {} }, # TODO: warn when this conflicts
    });
}

1;
