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

has 'allow_freeform_input' => (
    is      => 'ro',
    isa     => 'Bool',
    default => sub { undef },
);

sub is_option {
    my ($self, $string) = @_;

    # always an option if free-form is allowed
    return 1 if $self->allow_freeform_input && $string;

    # otherwise, see if it's in the list
    foreach my $option ($self->options){
        return 1 if $option eq $string;
    }

    # not in the list
    return;
}

1;
