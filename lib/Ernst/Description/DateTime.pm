package Ernst::Description::DateTime;
use Moose;
use DateTime;
use DateTime::Format::Strptime;
use DateTime::Format::DateParse;

extends 'Ernst::Description::Value';

with 'Ernst::Description::Trait::PostProcess',
  'Ernst::Description::Trait::Transform';

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

has '+transform_source' => (
    lazy    => 1,
    default => sub { [shift->name] },
);

has '+transform_rule' => (
    lazy    => 1,
    default => sub {
        sub {
            DateTime::Format::DateParse->parse_datetime($_[0]);
        },
    },
);

1;
