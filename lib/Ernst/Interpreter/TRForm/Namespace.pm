package Ernst::Interpreter::TRForm::Namespace;
use Moose;
use Moose::Util::TypeConstraints;

class_type __PACKAGE__;
coerce __PACKAGE__, from 'Str' => via { __PACKAGE__->new_from_string( $_ ) };

has 'namespace' => (
    is         => 'ro',
    isa        => 'Maybe[ArrayRef[Str]]',
    required   => 1,
);

sub new_from_string {
    my ($class, $string) = @_;
    return $class->new( namespace => undef ) if !$string;
    return $class->new( namespace => [
        map { $class->_decode($_) } split /[.]/, $string
    ]);
}

# make the namespace valid HTML

sub _decode {
    my ($class, $str) = @_;
    $str =~ s/\[(\d+)\]/chr $1/eg;
    return $str;
}

sub _encode {
    my ($class, $str) = @_;
    $str =~ s/(\W)/'['. ord($1) .']'/eg;
    return $str;
}

# utils

sub to_string {
    my ($self) = @_;
    return '' if !defined $self->namespace;
    return join '.', map { $self->_encode($_) } @{$self->namespace};
}

sub recurse {
    my ($self, $next) = @_;
    $self->new( namespace => [ @{ $self->namespace || [] }, $next ] );
}

1;
