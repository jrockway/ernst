package Ernst::Description::OptionList;
use Ernst::Description::Base;
use Ernst::Description::String;

with 'Ernst::Description::Trait::Transform';

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

has '+transform_source' => (
    lazy    => 1,
    default => sub {
        my $name = shift->name;
        return [ $name, "${name}_freeform" ];
    },
);

has '+transform_rule' => (
    default => sub { 
        sub {
            my ($fixed, $free) = @_;
            return $free if $free && !$fixed;
            return $fixed if $fixed && !$free;
        }
    }
);

1;
