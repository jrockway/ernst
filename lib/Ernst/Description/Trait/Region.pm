package Ernst::Description::Trait::Region;
use Moose::Role;
use Template::Refine::Processor::Rule::Select::XPath;

has 'region' => (
    is        => 'ro',
    isa       => 'Str',
    required  => 1,
);

sub region_selector {
    my $self = shift;
    my $region = $self->region;

    return Template::Refine::Processor::Rule::Select::XPath->new(
        pattern => $region,
    );
}

# TODO: validate XPath syntax in BUILD

1;
