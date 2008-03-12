package MooseX::MetaDescription::Meta::Attribute;
use Moose::Role;
use MooseX::MetaDescription::Description::Moose;
use Moose::Meta::Class;
use Moose::Util ();

my %ANON_CLASSES;

has 'metadescription' => (
    is       => 'ro',
    isa      => 'MooseX::MetaDescription::Description',
    lazy     => 1,
    weak_ref => 1,
    default  => sub {
        my $self = shift;
        
        my @traits = 
          map {
              my $trait = $_;
              my $trait_class;
              if($trait =~ /^[+](.+)$/){
                  $trait_class = $1;
              }
              else {
                  $trait_class = 
                    qq{MooseX::MetaDescription::Description::Trait::$trait};
                  if($trait_class->can('register_implementation')){
                      $trait_class = $trait_class->register_implementat;
                  }
              }
              
              Class::MOP::load_class($trait_class);
              $trait_class;
          } @{$self->description->{traits}||[]};

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

# the user's description definition, don't introspect this; look
# at the metadescription object instead
has 'description' => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
);

1;

__END__

=head1 NAME

MooseX::MetaDescription::Meta::Attribute - the attribute metaclass
trait for attributes with metadescriptions

=head1 SYNOPSIS

