package Ernst::Description::Trait::Region;
use Moose::Role;
use MooseX::AttributeHelpers;

has 'region' => (
    metaclass => 'Collection::ImmutableHash',
    is        => 'ro',
    isa       => 'HashRef[Str]',
    required  => 1,
    provides  => {
        get => 'region_selector_for',
    },
);

sub selector_for {
    my ($self, $flavor) = @_;
    require Template::Refine::Processor::Rule::Select::XPath;
    return Template::Refine::Processor::Rule::Select::XPath->new(
        pattern => $self->region_selector_for($flavor),
    );
}

1;
