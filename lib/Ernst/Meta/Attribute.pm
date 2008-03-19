package Ernst::Meta::Attribute;
use Moose::Role;
use Moose::Util ();

my $LITERAL_CLASS = qr/^[+](.+)$/;

sub _get_type_class {
    my $type = shift;

    # +Literal::Type::Class
    return $1 if $type =~ /$LITERAL_CLASS/o;
    
    # Ernst::Description::$type
    if(!ref $type){
        my $class = "Ernst::Description::$type";
        Class::MOP::load_class($class);
        return $class;
    }

    # <some instance of Ernst::Description subclass>
    else {
        confess "type must be a Ernst::Description, not a $type"
          unless $type->isa('Ernst::Description');
        return _get_type_class('+'. ref $type);
    }
}

sub _guess_type {
    my $self = shift;

    my $MOOSE_ERNST_TYPEMAP = {
        Str      => { type => 'String'          },
        Int      => { type => 'Integer'         },
        Bool     => { type => 'Boolean'         },
        ArrayRef => { type => 'Collection'      },
        HashRef  => { type => 'Collection::Map' },
    };

    my $isa = $self->_isa_metadata;
    (my ($outer, $inner)) = $isa =~ /^(.+)(\[.+\])?$/;
    
    for($MOOSE_ERNST_TYPEMAP->{$outer}){
        if($_){
            if($inner){
                my $inner_type = _get_type_class(_guess_type($inner));
                $_->{description} = $inner_type;
                $_->{cardinality} = '*';
            }
            return $_;
        }
    }

    if($isa->isa('UNIVERSAL') && $isa->can('meta') && $isa->meta->can('metadescription')){
        return { 
            type                => 'Wrapper',
            wrapped_description => $isa->meta->metadescription,
        },
    }
    
    confess "cannot map moose type '$isa' to an Ernst type";
}

has 'metadescription' => (
    is       => 'ro',
    isa      => 'Ernst::Description',
    lazy     => 1,
    weak_ref => 1,
    default  => sub {
        require Ernst::Description::Moose;
        require Ernst::Meta::Class;
        my $self = shift;

        my @traits = (
            'Ernst::Description::Moose', # for the attribute attribute
            $self->trait_class_names,
        );
        
        my $desc = $self->description;

        if(!$desc->{type}){
            $desc = { %{$self->_guess_type}, %$desc };
        }

        my $type = $desc->{type} or
          confess
            "The attribute '", $self->name, "' must have a type in its description";

        my $base = _get_type_class($type);
        $desc->{type} = $base;

        my $class = Ernst::Meta::Class->create_anon_class(
            superclasses => [$base],
            roles        => [@traits],
            cache        => 1,
        );

        delete $desc->{type}; # let type calculate itself
        return $class->name->new(
            attribute  => $self, 
            name       => $self->name,
            is_mutable => (
                $self->has_writer || $self->has_accessor
            ),
            %$desc
        );
    },
);

has 'description' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { +{} }, # we can guess everything now
);

has 'trait_class_names' => (
    is         => 'ro',
    isa        => 'ArrayRef[ClassName]',
    lazy       => 1,
    auto_deref => 1,
    default    => sub {
        my $self = shift;
        return [
            map {
                my $trait_class;
                if(/$LITERAL_CLASS/o){
                    $trait_class = $1;
                }
                else {
                    $trait_class =
                      qq{Ernst::Description::Trait::$_};
                }

                Class::MOP::load_class($trait_class);
                $trait_class;
            } @{$self->description->{traits}||[]}
        ];
    },
);

1;

__END__

=head1 NAME

Ernst::Meta::Attribute - the attribute metaclass
trait for attributes with metadescriptions

=head1 SYNOPSIS

  use Moose;

  has
