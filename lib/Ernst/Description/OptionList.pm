package Ernst::Description::OptionList;
use Ernst::Description::Base;
use Ernst::Description::String;

extends 'Ernst::Description::Value';

has 'options' => (
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    required   => 1,
    auto_deref => 1,
);

sub is_option {
    my ($self, $string) = @_;
    foreach my $option ($self->options){
        return 1 if $option eq $string;
    }
    return;
}

1;
