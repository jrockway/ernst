package Ernst::Interpreter::TRForm::Trait::Label;
use Moose::Role;
use Ernst::Interpreter::TRForm::Utils qw(simple_replace);

has 'required_field_indicator' => (
    is       => 'ro',
    isa      => 'CodeRef',
    default  => sub { sub { my $label = shift; return $label .= '*' } },
    required => 1,
);

has 'label_region' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub { '//*[@class="label"]' },
);

around transform_attribute => sub {
    my ($next, $self, $attribute, $fragment, $instance) = @_;

    $fragment = simple_replace(
        $fragment,
        $self->label_region,
        'Replace::WithText' => sub {
            my $n = shift;
            return $self->_label($attribute, $n->textContent);
        },
    );

    return $self->$next($attribute, $fragment, $instance);
};

sub _label {
    my ($self, $attribute, $label) = @_;
    if($attribute->metadescription->does('Ernst::Description::Trait::Friendly')){
        $label = $attribute->metadescription->label;
    }

    return $self->required_field_indicator->($label) if $attribute->is_required;
    return $label;
}

1;
