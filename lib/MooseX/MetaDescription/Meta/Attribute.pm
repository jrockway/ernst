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
        my $class = my $super = 'MooseX::MetaDescription::Description::Moose';
        
        # stolen from Moose::Meta::Class::_process_attribute
        my @traits = @{$self->description->{traits}||[]};
        if(@traits){
            my $anon_role_key = join '|', @traits;
            
            if($ANON_CLASSES{$anon_role_key}){
                $class = $ANON_CLASSES{$anon_role_key};
            }
            else {
                $class = Moose::Meta::Class->create_anon_class(
                    superclasses => [$super],
                );

                $ANON_CLASSES{$anon_role_key} = $class;
                
            
                my @trait_classes;
                foreach my $trait (@traits){
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
                    push @trait_classes, $trait_class;
                }
                
                Moose::Util::apply_all_roles($class, @trait_classes);
            }

            $class = $class->name;
        }

        return $class->new(
            attribute => $self,
            %{$self->description},
        );
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

