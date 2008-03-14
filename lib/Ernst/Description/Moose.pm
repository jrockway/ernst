package Ernst::Description::Moose;
use Moose::Role;

has 'attribute' => (
    is       => 'ro',
    does     => 'Ernst::Meta::Attribute',
    required => 1,
);

1;

__END__

=head1 NAME

Ernst::Description::Moose
