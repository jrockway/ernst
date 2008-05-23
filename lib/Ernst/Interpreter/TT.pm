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
    $str =~ s/\s+[.](\s+)[.]/$1/g; # nice.
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
                    [% label | html %]: [% value | html %]
                },
                edit => flatten q{
                    <label for="[% name | html %]"
                           . .id="[% name | html %]_label">[% label | html %]: </label>
                    <input type="text"
                           . .name="[% name | html %]"
                           . .id="[% name | html %]"
                           . .value="[% value | html %]" />
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
                [% FOREACH attr IN attribute_order %]
                [% attributes.$attr %]<br />
                [% END %]
                </div>
            },
            edit => flatten q{
                <form id="edit_class_[% name | html %]" method="post" action="[% action | html %]">
                [% FOREACH attr IN attribute_order %]
                [% attributes.$attr %]<br />
                [% END %]
                <br /><input type="submit" name="do_submit" value="Submit" />
                </form>
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
        attributes      => \%rendered_attributes,
        attribute_order => [$desc->get_attribute_list],
        description     => $desc,
        class           => $desc->class,
        name            => $desc->name,
        instance        => $instance,
        %{ $extra_vars || {} }, # TODO: warn when this conflicts
    });
}

sub _render_template {
    my ($self, $template, $vars) = @_;
    my $output;
    $self->engine->process(\$template, $vars, \$output);
    return $output;
}

sub _reflavor_attribute {
    my ($self, $desc, $instance, $flavor) = @_;

    if($flavor eq 'edit'){
        if(!$desc->does('Ernst::Description::Trait::Editable')){
            return 'view';
        }

        if(!blessed $instance){
            return 'view' if !$desc->initially_editable;
        }
        else {
            return 'view' if !$desc->editable;
        }
    }

    return $flavor;
}


sub render_attribute {
    my ($self, $desc, $instance, $flavor, $extra_vars) = @_;

    # if they request edit, but we can't edit this attribute, use the
    # view template instead
    $flavor = $self->_reflavor_attribute($desc, $instance, $flavor);

    # lookup applicable templates (for "next")
    my @templates =
      grep { defined }
        ($desc->templates->{$flavor},
         map { eval { $self->_lookup_attribute_template_flavors($_)->{$flavor} } }
           $desc->meta->types);

    confess "no templates for ". $desc->name unless @templates;

    # render the templates in reverse order (for "next")
    my $next = '';
    for my $template (reverse @templates){
        $next = $self->_render_attribute
          ($desc, $instance, $extra_vars, $template, $next);
    }

    return $next; # this is the most specific template
}

sub _render_attribute {
    my ($self, $desc, $instance, $extra_vars, $template, $next) = @_;

    my $stash = {
        description => $desc,
        name        => $desc->name,
        label       => (eval { $desc->label } || ucfirst $desc->name ),
        attribute   => $desc->attribute,
        value       => (eval { $desc->attribute->get_value($instance) } || ''),
        next        => $next,
        %{ $extra_vars || {} }, # TODO: warn when this conflicts
    };

    $template = $template->($stash) if ref $template && ref $template eq 'CODE';

    return $self->_render_template($template, $stash);

}

1;
