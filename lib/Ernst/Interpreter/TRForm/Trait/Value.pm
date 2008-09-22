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

    if( $attribute->metadescription->does('Ernst::Description::Trait::PostProcess') ){
        local $_ = $value;
        $value = $attribute->metadescription->postprocess->($value);
    }

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
                elsif($type eq 'img'){
                    $copy->setAttribute( src => $value );
                }
                else {
                    $copy->removeChildNodes;

                    if( $attribute->metadescription->
                          does('Ernst::Description::Trait::PassthroughHTML') &&
                            $attribute->metadescription->pass_html ){

                        my $v = Template::Refine::Fragment->new_from_string(
                            $value,
                        );
                        $copy->addChild( $v->fragment );
                    }
                    else {
                        $copy->addChild( XML::LibXML::Text->new($value) );
                    }
                }

                return $copy;
            },
        );
    }
    return $self->$next($attribute, $fragment, $instance);
};

1;
