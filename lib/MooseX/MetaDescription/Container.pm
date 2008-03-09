package MooseX::MetaDescription::Container;
use Moose;
use MooseX::AttributeHelpers;
use MooseX::MetaDescription::Description;

has 'class' => (
    isa      => 'MooseX::MetaDescription::Meta::Class',
    is       => 'ro',
    required => 1,
);

has 'attributes' => (
    metaclass => 'Collection::Hash',
    isa       => 'HashRef[MooseX::MetaDescription::Description]',
    is        => 'ro',
    lazy      => 1,
    default   => sub {
        my $self = shift;
        my %map = %{$self->class->get_attribute_map};
        my @have_descriptions = 
          grep { $map{$_}->isa('MooseX::MetaDescription::Meta::Attribute') } 
            keys %map;
        
        my %result;
        @result{@have_descriptions} = 
          map { $_->metadescription } @map{@have_descriptions};
        return \%result;
    },
    provides => {
        get => 'attribute',
    },
);

1;

__END__

=head1 NAME

MooseX::MetaDescription::Container - encapsulates a class's metadescription

=head1 SYNOPSIS

How to get a C<MooseX::MetaDescription::Container> for Some::Class:

  my $one_of_these = Some::Class->meta->metadescription;

=head1 METHODS

=head2 attribute($name)

Returns the attribute metadescription class for the attribute C<$name>.

=head2 attributes

Returns a hash mapping attribute names to attribute metadescription classes.
