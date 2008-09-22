package Ernst::Description::DateTime;
use Moose;
use DateTime::Format::Strptime;
use DateTime;

extends 'Ernst::Description::Value';

with 'Ernst::Description::Trait::PostProcess';

has 'format' => (
    is       => 'ro',
    isa      => 'Str',
    default  => '%T',
);

my $mk_format = sub {
    my $format = shift;
    return sub {
        my $date = shift;
        return $date unless blessed $date; # already formatted?
        return DateTime::Format::Strptime->new(
            pattern => $format,
            locale  => 'en_US',
        )->format_datetime($date);
    };
};

has '+postprocess' => (
    lazy    => 1,
    default => sub {
        my $self = shift;
        $mk_format->($self->format);
    },
);

1;
