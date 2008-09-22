package Ernst::Interpreter::TRForm;
use Moose;
use Moose::Util::TypeConstraints;
use Template::Refine::Fragment;
use Template::Refine::Processor::Rule::Transform::Replace;
use Template::Refine::Processor::Rule;
use Template::Refine::Processor::Rule::Select::XPath;

with 'Ernst::Interpreter', 'MooseX::Traits';

has '+_trait_namespace' => ( default => 'Ernst::Interpreter::TRForm::Trait' );

has 'class' => (
    is       => 'ro',
    isa      => 'Moose::Meta::Class',
    required => 1,
);

# not a fan of this; but it lets us let catalyst load the HTML file (etc.)
has 'representation' => (
    is        => 'ro',
    isa       => 'Str',
    required  => 1,
);

sub _get_html_fragment {
    my ($self) = @_;

    return Template::Refine::Fragment->new_from_string($self->representation);
}

sub interpret {
    my ($self, $instance) = @_;

    my $class_fragment = $self->_get_html_fragment;

    my @attributes = map { $self->class->get_attribute($_) }
      $self->class->metadescription->get_attribute_list;

    for my $attribute (@attributes){
        my $region_selector = $self->_get_attribute_region($attribute);
        my $replace = Template::Refine::Processor::Rule::Transform::Replace->new(
            replacement => sub {
                my $node = shift;
                my $region_fragment = Template::Refine::Fragment->new_from_string(
                    $node->toString,
                );

                $region_fragment = $self->transform_attribute(
                    $attribute,
                    $region_fragment,
                    $instance,
                );

                return $region_fragment->fragment;
            }
        );

        my $rule = Template::Refine::Processor::Rule->new(
            selector    => $region_selector,
            transformer => $replace,
        );

        $class_fragment = $class_fragment->process($rule);
    }

    $class_fragment = $self->transform_class($class_fragment, $instance);

    return $class_fragment;
}

sub _get_attribute_region {
    my ($self, $attribute) = @_;

    confess "'@{[$attribute->name]}' cannot select a region"
      unless $attribute->metadescription->does('Ernst::Description::Trait::Region');

    return $attribute->metadescription->region_selector;
}

# hook this with around
sub transform_attribute {
    my ($self, $attribute, $fragment, $instance) = @_;
    return $fragment;
}

# hook this with around
sub transform_class {
    my ($self, $fragment, $instance) = @_;
    return $fragment;
}


1;

__END__

=head1 NAME

Ernst::Interpreter::TRForm - Template::Refine-based forms

=cut
