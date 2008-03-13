package MooseX::MetaDescription::Description::Moose;
use Moose::Role;

has 'attribute' => (
    is       => 'ro',
    does     => 'MooseX::MetaDescription::Meta::Attribute',
    required => 1,
);

1;

__END__

=head1 NAME

MooseX::MetaDescription::Description::Moose
