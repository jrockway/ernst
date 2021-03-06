package Ernst::Meta::Attribute;
use Moose::Role;
use MooseX::MetaDescription;
use Moose::Util ();
use Ernst::Util;

with 'MooseX::MetaDescription::Meta::Trait';

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
    
    if(my $outer_type = $MOOSE_ERNST_TYPEMAP->{$outer}){
        if($inner){
            my $inner_type = Ernst::Util::get_type_class(_guess_type($inner));
            $outer_type->{inside_type} = $inner_type->{type};
            $outer_type->{cardinality} = '*';
        }

        return $outer_type;
    }
    
    if($isa->isa('UNIVERSAL') && 
         $isa->can('meta') && 
           $isa->meta->can('metadescription')){
        return +{ 
            type => $isa->meta->metadescription,
        },
    }
    
    confess "cannot map moose type '$isa' to an Ernst type";
}

has '+metadescription_classname' => (
    default => sub { 'Ernst::Description::Moose' }
);

has 'metadescription' => (
    is       => 'ro',
    isa      => 'Ernst::Description',
    lazy     => 1,
    weak_ref => 1, # created description points back to us via attribute key
    default  => sub {
        require Ernst::Description::Moose;
        require Ernst::Meta::Description::Class;
        my $self = shift;

        my @traits = (
            $self->metadescription_classname, # for the attribute attribute
            $self->trait_class_names,
        );
        
        # we want a private copy
        my $desc = { %{$self->description} };

        # guess type if one isn't provided
        if(!$desc->{type}){
            $desc = { %{$self->_guess_type}, %$desc };
        }
        
        # validate type
        for my $t ($desc->{type}){
            confess 'No type provided for ', $self->name
              unless $t;
            
            confess 'An unblessed reference cannot be used as a type'
              if ref $t && !blessed $t;
        
            confess "You supplied a reference as the type, but $t is not an ",
                    "Ernst::Description"
                if ref $t && !$desc->{type}->isa('Ernst::Description');
        }
        
        my $base = Ernst::Util::get_type_class(delete $desc->{type});

        my $class = Ernst::Meta::Description::Class->create_anon_class(
            superclasses => [ref $base || $base],
            roles        => [@traits],
            cache        => 1,
        );
        
        my @args = (
            attribute  => $self, # for Ernst::Description::Moose 
            descriptor => $self, # for MooseX::MetaDescription::Meta::Trait
            name       => $self->name,
            is_mutable => (
                $self->has_writer || $self->has_accessor
            ),
            %$desc
        );

        $class->make_immutable;
        
        # if an instance was passed, clone it and rebless it into our
        # new subclass
        if(ref $base){
            my $copy = $base->meta->clone_object($base);
            $class->rebless_instance($copy, @args);
            return $copy;
        }
        # otherwise, create a fresh instance
        return $class->name->new(@args);
    }
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
                my $LITERAL_CLASS = Ernst::Util::literal_class_regex;
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
