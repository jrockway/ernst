package Ernst::Interpreter::TRForm::Trait::Instructions;
use Moose::Role;
use Ernst::Interpreter::TRForm::Utils qw(simple_replace);

around transform_attribute => sub {
    my ($next, $self, $attribute, $fragment, $instance) = @_;

    if( $attribute->metadescription->does('Ernst::Description::Trait::Friendly') &&
          (my $i = $attribute->metadescription->instructions)
      ){
        $fragment = simple_replace(
            $fragment,
            '//*[@class="instructions"]',
            'Replace::WithText' => sub { $i },
        ),
    }

    return $self->$next($attribute, $fragment, $instance);
};

1;
