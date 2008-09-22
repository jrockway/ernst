package Ernst::Interpreter::TRForm::Trait::Value;
use Moose::Role;
use Ernst::Interpreter::TRForm::Utils qw(simple_replace);

has 'value_replacement_region' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub { '//input | //textarea' },
);

around transform_attribute => sub {
    my ($next, $self, $attribute, $fragment, $instance) = @_;

    my $value = eval { $attribute->get_value($instance) };

    if(defined $value){
        $fragment = simple_replace(
            $fragment,
            $self->value_replacement_region,
            'Replace' => sub {
                my $n = shift;
                my $copy = $n->cloneNode(1);

                my $type = $n->nodeName;
                if($type eq 'input'){
                    $copy->setAttribute( value => $value );
                }

                else {
                    $copy->removeChildNodes;
                    $copy->addChild( XML::LibXML::Text->new($value) );
                }

                return $copy;
            },
        );
    }
    return $self->$next($attribute, $fragment, $instance);
};

1;
