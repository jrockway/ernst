package MooseX::MetaDescription::Meta::Attribute;
use Moose::Role;
use MooseX::MetaDescription::Description::Moose;
use Moose::Meta::Class;
use Moose::Util ();

sub _get_type {
    my $type = shift;
    confess "type must be a string, not a $type"
      if ref $type;
    
    my $class = "MooseX::MetaDescription::Description::$type";
    Class::MOP::load_class($class);
    
    return $class;
}

has 'metadescription' => (
    is       => 'ro',
    isa      => 'MooseX::MetaDescription::Description',
    lazy     => 1,
    weak_ref => 1,
    default  => sub {
        my $self = shift;

        my @traits = (
            'MooseX::MetaDescription::Description::Moose', # for the attribute attribute
            $self->trait_class_names,
        );

        my $desc = $self->description;
        my $base = _get_type(delete $desc->{type});

        my $class = Moose::Meta::Class->create_anon_class(
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
                      qq{MooseX::MetaDescription::Description::Trait::$_};
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

MooseX::MetaDescription::Meta::Attribute - the attribute metaclass
trait for attributes with metadescriptions

=head1 SYNOPSIS

  use Moose;

  has
