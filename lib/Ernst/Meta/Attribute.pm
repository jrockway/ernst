package Ernst::Meta::Attribute;
use Moose::Role;
use Moose::Util ();

sub _get_type_class {
    my $type = shift;

    confess "type must be a string, not a $type"
      if ref $type;
    
    my $class = "Ernst::Description::$type";
    Class::MOP::load_class($class);
    
    return $class;
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
        
        my $type = $desc->{type} or confess
          "The attribute '", $self->name, "' must have a type in its description";
        my $base = _get_type_class($type);

        my $class = Ernst::Meta::Class->create_anon_class(
            superclasses => [$base],
            roles        => [@traits],
            cache        => 1,
        );

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
    is            => 'ro',
    isa           => 'HashRef',
    required      => 1,
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
                if(/^[+](.+)$/){
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
