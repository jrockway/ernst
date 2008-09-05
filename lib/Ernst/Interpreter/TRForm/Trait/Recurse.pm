package Ernst::Interpreter::TRForm::Trait::Recurse;
use Moose::Role;
use Ernst::Interpreter::TRForm::Utils qw(simple_replace);

with 'Ernst::Interpreter::TRForm::Trait::Namespace';

around transform_attribute => sub {
    my ($next, $self, $attribute, $fragment, $instance) = @_;
    if( !$attribute->metadescription->does('Ernst::Description::Trait::NoRecurse') &&
          $attribute->metadescription->meta->type_isa('Container::Moose') ){
        my $namespace = $self->namespace->recurse($attribute->name);

        my %attrs =
          map { $_->init_arg => $_->get_value($self) }
            grep { $_->has_init_arg }
              $self->meta->compute_all_applicable_attributes;

        my $clone = $self->meta->name->new( { %attrs, namespace => $namespace } );
        $fragment = $clone->interpret( $attribute->get_value($instance) );
    }

    return $self->$next($attribute, $fragment, $instance);
};

1;
