package MooseX::MetaDescription::Description;
use feature ':5.10';
use Moose;

has attribute => (
    is       => 'ro',
    isa      => 'MooseX::MetaDescription::Meta::Attribute',
    weaken   => 1,
    required => 1,
);

1;

__END__
