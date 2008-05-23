package TestApp::Backend::Record;
use Ernst;
use Data::UUID;

with 'MooseX::Storage::Directory::Id';

__PACKAGE__->meta->metadescription->apply_role(
    'Ernst::Description::Trait::TT::Class', {
        flavors   => [qw/view edit/],
    },
);

has 'uuid' => (
    traits  => ['MetaDescription'],
    is      => 'ro',
    isa     => 'Str',
    default => sub { Data::UUID->new->create_str },
    description => {
        type       => 'String',
        min_length => 0,
        max_length => 8,
        traits     => ['TT'],
        templates  => {
        },
    }
);

sub get_id { return shift->uuid }

has 'username' => (
    traits      => ['MetaDescription'],
    is          => 'ro',
    isa         => 'Str',
    description => {
        type               => 'String',
        min_length         => 0,
        max_length         => 8,
        traits             => [qw/TT Editable/],
        initially_editable => 1,
        editable           => 0,
        templates          => {
        },
    },
);

has 'biography' => (
    traits      => ['MetaDescription'],
    is          => 'ro',
    isa         => 'Str',
    description => {
        type           => 'String',
        min_length     => 0,
        average_length => '3000',
        traits         => [qw/TT Editable/],
        templates      => {
        },
    },
);

has 'age' => (
    traits      => ['MetaDescription'],
    is          => 'ro',
    isa         => 'Int',
    description => {
        type       => 'Integer',
        traits     => [qw/TT Editable/],
        templates  => {
        },
    },
);

1;
