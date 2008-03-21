package Ernst::Meta::Description::Class;
use Moose;

extends 'Ernst::Meta::Class';

my $TOP_PACKAGE  = 'Ernst::Description';
my $SHORTEN_TYPE = qr/^${TOP_PACKAGE}::(.+)$/;

sub type {
    my $self = shift;

    return q{} if $self->name eq $TOP_PACKAGE;
    for my $class ($self->name, $self->linearized_isa){
        return $1 if $class->meta->name =~ /$SHORTEN_TYPE/o;
    }
    
    confess 'Cannot determine type of '. $self->name;
}

sub type_isa {
    my ($self, $compare) = @_;
    grep { /^$compare$/ } $self->types;
};

sub subtypes {
    my $self = shift;
    my $class = $self->name;

    no strict 'refs';
    return $self->type,
      map { my $p = "${class}::". substr $_,0,-2; eval { $p->meta->subtypes } } 
        grep { /^(.+)::$/ } 
          keys %{$class . '::'};
}

sub types {
    my $self = shift;
    return 
      map { /$SHORTEN_TYPE/o; $1||'' } 
        grep { $_->isa($TOP_PACKAGE) } $self->linearized_isa;
}

1;

__END__

=head1 NAME

Ernst::Meta::Description::Class - metaclass for description classes

=head1 SYNOPSIS

See L<Ernst::Description>.

=head1 METHODS

=head2 type

=head2 type_isa

=head2 subtypes

=head2 types

