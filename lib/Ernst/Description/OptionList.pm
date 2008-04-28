package Ernst::Description::OptionList;
use Ernst;
use Ernst::Description::String;

extends 'Ernst::Description::Value';

has 'options' => (
    is          => 'ro',
    isa         => 'ArrayRef[Str]',
    required    => 1,
    auto_deref  => 1,
    traits      => ['MetaDescription'],
    description => {
        type        => 'Collection',
        cardinality => '+',
        inside_type => 'String',
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
