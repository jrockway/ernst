package MooseX::MetaDescription::Description::OptionList;
use MooseX::MetaDescription;
use Moose;
use MooseX::MetaDescription::Description::String;

extends 'MooseX::MetaDescription::Description';

has 'options' => (
    is          => 'ro',
    isa         => 'ArrayRef[Str]',
    required    => 1,
    auto_deref  => 1,
    traits      => ['MetaDescription'],
    description => {
        type        => 'Collection',
        cardinality => '+',
        description => 
          MooseX::MetaDescription::Description::String->meta->metadescription,
    },
);

sub is_option {
    my ($self, $string) = @_;
    foreach my $option ($self->options){
        return 1 if $option eq $string;
    }
    return;
}

1;
