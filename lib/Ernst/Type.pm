package Ernst::Type;
use Moose;

has 'name' => (
    is       => 'ro',
    isa      => 'Str',
    default  => sub {
        my $class = ref shift;
        my $me = __PACKAGE__;
        $class =~ s/^$me :://x;
        return $class;
    }
);

1;
