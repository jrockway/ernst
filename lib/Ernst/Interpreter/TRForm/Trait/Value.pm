package Ernst::Interpreter::TRForm::Trait::Value;
use Moose::Role;
use Scalar::Util qw(reftype);
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

                # this lets us control element attributes + #text content
                if(ref $value && reftype($value) eq 'HASH' && exists $value->{$type}){
                    my $control = $value->{$type};
                    confess 'ref "value" must be a HashRef[HashRef[Str]'
                      unless reftype $control eq 'HASH';

                    # replace text (node-specific, or general)
                    my $text = delete $control->{'#text'};
                    $text = $value->{'#text'} unless defined $text;

                    $copy = _textize($copy, $attribute, $text) if $text;

                    # now add attributes specific to this node type
                    for my $attribute (keys %{$value->{$type}}){
                        $copy->setAttribute( $attribute => $control->{$attribute} );
                    }
                }

                # some HTML elements put "text" in weird places
                elsif($type eq 'input'){
                    $copy->setAttribute( value => $value );
                }
                elsif($type eq 'img'){
                    $copy->setAttribute( src => $value );
                }

                # normal ones just make "text" their children
                else {
                     $value = $value->{'#text'}
                      if ref $value && reftype($value) eq 'HASH';
                    $copy = _textize($copy, $attribute, $value);
                }

                return $copy;
            },
        );
    }

    return $self->$next($attribute, $fragment, $instance);
};

sub _textize {
    my ($node, $attribute, $value) = @_;
    $node->removeChildNodes;

    if( $attribute->metadescription->
          does('Ernst::Description::Trait::PassthroughHTML') &&
            $attribute->metadescription->pass_html ){

        my $v = Template::Refine::Fragment->new_from_string(
            $value,
        );
        $node->addChild( $v->fragment );
    }
    else {
        $node->addChild( XML::LibXML::Text->new($value) );
    }

    return $node;
}

1;
