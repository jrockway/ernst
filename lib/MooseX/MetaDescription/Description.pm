package MooseX::MetaDescription::Description;
use Moose;

has 'name' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'type' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => sub {
        my $self  = shift;
        
        my $p = __PACKAGE__;
        for my $c (ref $self, $self->meta->superclasses) {
            if ( $c =~ /^${p}::(.+)$/ ) {
                return $1;
            }
        }
        
        confess 'Something has gone horribly wrong; cannot guess the type of ',
          ref $self;
    }
);

has 'is_mutable' => (
    is       => 'ro',
    isa      => 'Bool',
    default  => sub { 0 },
);

sub types {
    my $self = shift;
    my $p = __PACKAGE__; # this package is the stopping point for search up @ISA
    map { s/^${p}:?:?//; $_ } grep { $_->isa($p) } $self->meta->linearized_isa;
}

1;


__END__

=head1 NAME

MooseX::MetaDescription::Description - a metadescription of a single
attribute

=head1 SYNOPSIS
