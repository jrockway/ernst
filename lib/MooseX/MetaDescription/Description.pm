package MooseX::MetaDescription::Description;
use Moose;

has attribute => (
    is       => 'ro',
    isa      => 'MooseX::MetaDescription::Meta::Attribute',
    required => 1,
);

1;

__END__
