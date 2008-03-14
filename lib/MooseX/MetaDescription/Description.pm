package MooseX::MetaDescription::Description;
use MooseX::MetaDescription;
use Moose;

my $PACKAGE      = __PACKAGE__;
my $SHORTEN_TYPE = qr/^${PACKAGE}::(.+)$/;

has 'name' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    traits      => ['MetaDescription'],
    description => {
        type => 'String',
    },
);

has 'type' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    traits      => ['MetaDescription'],
    description => {
        type => 'String',
    },
    default     => sub {
        my $self  = shift;
        
        for my $c (ref $self, $self->meta->superclasses) {
            return $1 if $c =~ /$SHORTEN_TYPE/o;
        }
        
        confess 'Something has gone horribly wrong; cannot guess the type of ',
          ref $self;
    }
);

has 'is_mutable' => (
    is          => 'ro',
    isa         => 'Bool',
    traits      => ['MetaDescription'],
    description => {
        type => 'Boolean',
    },
    default  => sub { 0 },
);

sub type_isa {
    my ($self, $compare) = @_;
    grep { /^$compare$/ } $self->types;
};

sub subtypes {
    
}

sub types {
    my $self = shift;
    my $p = __PACKAGE__; # this package is the stopping point for search up @ISA
    map { /$SHORTEN_TYPE/o; $1||'' } grep { $_->isa($p) } $self->meta->linearized_isa;
}

1;


__END__

=head1 NAME

MooseX::MetaDescription::Description - a metadescription of a single
attribute

=head1 SYNOPSIS
