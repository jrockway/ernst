package Ernst::Description::Trait::Region;
use Moose::Role;
use Template::Refine::Processor::Rule::Select;

has 'region' => (
    is        => 'ro',
    does      => 'Template::Refine::Processor::Rule::Select',
    required  => 1,
);

sub region_selector {
    my $self = shift;
    return $self->region;
}

1;
