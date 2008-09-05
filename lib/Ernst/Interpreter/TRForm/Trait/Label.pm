package Ernst::Interpreter::TRForm::Trait::Label;
use Moose::Role;
use Ernst::Interpreter::TRForm::Utils qw(simple_replace);

around transform_attribute => sub {
    my ($next, $self, $attribute, $fragment, $instance) = @_;

    $fragment = simple_replace(
        $fragment,
        '//*[@class="label"]',
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
    # move "text" like this out into a "style" class
    $label .= '*' if $attribute->is_required;
    return $label;
}

1;
