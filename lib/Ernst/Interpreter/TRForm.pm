package Ernst::Interpreter::TRForm;
use Moose;
use Moose::Util::TypeConstraints;
use Template::Refine::Fragment;
use Template::Refine::Processor::Rule;
use Template::Refine::Processor::Rule::Transform::Replace;
use Template::Refine::Processor::Rule::Select::XPath;
use UNIVERSAL::require;

with 'Ernst::Interpreter';

use Ernst::Interpreter::TRForm::Namespace;


has 'class' => (
    is       => 'ro',
    isa      => 'Moose::Meta::Class',
    required => 1,
);

has 'flavor' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'namespace' => (
    is       => 'ro',
    isa      => 'Ernst::Interpreter::TRForm::Namespace',
    default  => sub { Ernst::Interpreter::TRForm::Namespace->new( namespace => [] ) },
    required => 1,
    coerce   => 1,
);

sub interpret {
    my ($self, $instance) = @_;

    my $desc = $self->class->metadescription;

    confess "$instance must consume the 'Representation' Ernst trait"
      unless $desc->does('Ernst::Description::Trait::Representation');

    my $flavor = $self->flavor;
    my $template = $desc->representation_for($flavor) ||
      confess "$instance does not contain a representation for the '$flavor' flavor";

    my $frag = Template::Refine::Fragment->new_from_string($template);

    my @attributes = map { $self->class->get_attribute($_) }
      $self->class->metadescription->get_attribute_list;

    for my $attribute (@attributes){
        $frag = $self->_transform_attribute(
            $frag,
            $attribute,
            $instance,
        );
    }

    return $frag;
}

sub _transform_attribute {
    my ($self, $fragment, $attribute, $instance) = @_;

    # maybe ignore instead of dying?
    confess "'@{[$attribute->name]}' cannot select a region"
      unless $attribute->metadescription->does('Ernst::Description::Trait::Region');

    my $rule = Template::Refine::Processor::Rule->new(
        selector    => $attribute->metadescription->selector_for($self->flavor),
        transformer => $self->_make_replacer($attribute, $instance),
    );

    return $fragment->process($rule);
}

sub _simple_replace {
    my ($frag, $xpath, $type, $code) = @_;

    $type = "Template::Refine::Processor::Rule::Transform::$type";
    $type->require;

    return $frag->process(
        Template::Refine::Processor::Rule->new(
            selector => Template::Refine::Processor::Rule::Select::XPath->new(
                pattern => $xpath,
            ),
            transformer => $type->new(
                replacement => $code,
            ),
        ),
    );
}

sub _make_replacer {
    my ($self, $attribute, $instance) = @_;

    my $namespace = $self->namespace->recurse($attribute->name);

    return Template::Refine::Processor::Rule::Transform::Replace->new(
        replacement => sub {
            my $md   = $attribute->metadescription;
            my $node = shift;
            my $frag = Template::Refine::Fragment->new_from_string(
                $node->toString,
            );

            # add name to the input
            $frag = _simple_replace(
                $frag, '//input',
                Replace =>
                  sub {
                      my $n = shift->cloneNode(1);
                      $n->setAttribute( name => $namespace->to_string );
                      return $n;
                  },
            );

            # replace label
            $frag = _simple_replace(
                $frag, '//*[@class="label"]',
                'Replace::WithText' => sub { $self->_label($attribute, $instance) }
            );

            # replace instructions
            if($md->does('Ernst::Description::Trait::Friendly') &&
                 (my $instructions = $md->instructions)){
                $frag = _simple_replace(
                    $frag, '//*[@class="instructions"]',
                    'Replace::WithText' => sub { $instructions }
                );
            }

            return $frag->fragment;
        }
    );
}

sub _label {
    my ($self, $attribute, $instance) = @_;
    my $label = $attribute->name;
    if($attribute->metadescription->does('Ernst::Description::Trait::Friendly')){
        $label = $attribute->metadescription->label;
    }
    # move "text" like this out into a "style" class
    $label .= '*' if $attribute->is_required;
    return $label;
}

sub _instructions {
    my ($self, $attribute, $instance) = @_;
    return
}

1;

__END__

=head1 NAME

Ernst::Interpreter::TRForm - Template::Refine-based forms

=cut
