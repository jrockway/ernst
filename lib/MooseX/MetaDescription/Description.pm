package MooseX::MetaDescription::Description;
use Moose;

has 'name' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'is_mutable' => (
    is       => 'ro',
    isa      => 'Bool',
    default  => sub { 0 },
);

1;

__END__

=head1 NAME

MooseX::MetaDescription::Description - a metadescription of a single
attribute

=head1 SYNOPSIS
