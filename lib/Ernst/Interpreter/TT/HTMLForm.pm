package Ernst::Interpreter::TT::HTMLForm;
use Moose;
use MooseX::AttributeHelpers;

extends 'Ernst::Interpreter::TT';

sub flatten($){
    my $str = shift;
    chomp $str;
    $str =~ s/^\s+//g;
    $str =~ s/\s+$//g;
    $str =~ s/\s+[.](\s+)[.]/$1/g; # nice.
    $str =~ s/\n\s*//g;
    return $str;
}

has 'default_attribute_templates' => (
    is        => 'ro',
    isa       => 'HashRef[HashRef[Str | CodeRef]]', # TODO: HashRef[HashRef[Template]]
    default   => sub {
        return +{
            "" => {
                view => flatten q{
                    <span id="view_[% name %]">
                        [% label | html %]: [% value | html %]
                    </span>
                },
                edit => \&_assemble_edit_html,
            },
        };
    },
);

has 'default_class_templates' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'HashRef[Str | CodeRef]', # TODO: HashRef[Template]
    provides  => {
        set => 'add_default_class_template',
    },
    default   => sub {
        return +{
            view => flatten q{
                <div id="view_class_[% name | html %]">
                <ul>
                    [% FOREACH attr IN attribute_order %]
                        <li>[% attributes.$attr %]</li>
                    [% END %]
                </ul>
                </div>
            },
            edit => flatten q{
                <form id="edit_class_[% name | html %]" method="post"
                      . .class="ernst_htmlform"
                      . .action="[% action | html %]">
                <ul>
                    [% IF errors %]
                        <p id="ernst_errors" class="ernst_error">
                            Please correct the following errors and resubmit.
                        </p>
                        [% IF errors.CLASS %]
                            <p id="ernst_[% class %]_error" class="ernst_error">
                                [% errors.CLASS | html %]
                            </p>
                        [% END %]
                    [% END %]

                    [% FOREACH attr IN attribute_order %]
                        <li>[% attributes.$attr %]</li>
                    [% END %]
                    <li><input type="submit" name="do_submit" value="Submit" /></li>
                </ul> 
                </form>
            },
        };
    },
);

sub add_default_attribute_template {
    my ($self, $flavor, $type, $template) = @_;
    $self->default_attribute_templates->{$type}{$flavor} = $template;
}

sub _assemble_edit_html {
    my $args = shift;
    my $desc = $args->{description};
    
    my $html = flatten q{
        <label for="[% name | html %]"
            . .id="[% name | html %]_label">[% label | html %]
    };

    # required?
    if($desc->attribute->is_required){
        $html .= '<span class="required">*</span>'; # probably do the * in CSS also
    }
    $html .= "</label>";

    # error?
    if($args->{errors}{$desc->name}){
        $html .= flatten q{
               [% FOREACH error IN errors.$name %]
                   <p class="ernst_error">[% error | html %]</p>
               [% END %]
        };
    }

    $html .= flatten q{
        <input type="text"
            . .class="ernst_field ernst_[% description.meta.type %]"
            . .name="[% name | html %]"
            . .id="[% name | html %]"
            . .value="[% value | html %]" />
    };
    if($desc->does('Ernst::Description::Trait::Friendly')){
        if(defined (my $instructions = $desc->instructions)){
            $html .= flatten q{
                <p class="instruct">[% description.instructions | html %]</p>
            };
        }
    }

    return $html;
}

around lookup_attribute_template => sub {
    my ($next, $self, $attr, $flavor) = @_;

    my $template = $self->$next($attr, $flavor);
    return $template if $template;
    
    for my $type ($attr->meta->types){
        $template = $self->default_attribute_templates->{$type};
        $template ||= {};
        $template = $template->{$flavor};
        return $template if $template;
    }

    confess 'Failed to find an attribute template for '. $attr->name;
};

around lookup_class_template => sub {
    my ($next, $self, $desc, $flavor) = @_;
    my $template = $self->$next($desc, $flavor);
    return $template if $template;
    $template = $self->default_class_templates->{$flavor};
    return $template if $template;
    
    confess 'Failed to find a class template for '. $desc->name;
};

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

override render_attribute => sub {
    my ($self, $desc, $instance, $flavor, $extra_vars) = @_;

    # if they request edit, but we can't edit this attribute, use the
    # view template instead
    $flavor = $self->_reflavor_attribute($desc, $instance, $flavor);

    # lookup applicable templates (for "next")
    my @templates =
      grep { defined }
        ($self->lookup_attribute_template($desc, $flavor),
         map { $self->default_attribute_templates->{$_}{$flavor} }
           $desc->meta->types);

    # render the templates in reverse order (for "next")
    my $next = '';
    for my $template (reverse @templates){
        $extra_vars->{next} = $next;
        $next = $self->_render_attribute
          ($desc, $instance, $extra_vars, $template);
    }

    return $next; # this is the most specific template
};

1;
