package MooseX::MetaDescription::Meta::Attribute;
use Moose::Role;
use MooseX::MetaDescription::Description::Moose;
use Moose::Meta::Class;
use Moose::Util ();

has 'metadescription' => (
    is       => 'ro',
    isa      => 'MooseX::MetaDescription::Description',
    lazy     => 1,
    weak_ref => 1,
    default  => sub {
        my $self = shift;

        my @traits = $self->trait_classes;

        my $base = 'MooseX::MetaDescription::Description::Moose';
        my @args = ( attribute => $self, %{$self->description} );

        if(@traits){
            my $class = Moose::Meta::Class->create_anon_class(
                superclasses => [$base],
                roles        => [@traits],
                cache        => 1,
            );
            return $class->name->new(@args);
        }

        return $base->new(@args);
    },
);

has 'description' => (
    is            => 'ro',
    isa           => 'HashRef',
    required      => 1,
);

has 'trait_classes' => (
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
