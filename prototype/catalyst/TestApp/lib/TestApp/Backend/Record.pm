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
            edit => 'uuid: <tt>[% value %]</tt><input type="hidden" name="uuid" value="[% value %]" />',
        },
    }
);

sub get_id { return shift->uuid }

has 'username' => (
    traits      => ['MetaDescription'],
    is          => 'ro',
    isa         => 'Str',
    description => {
        type       => 'String',
        min_length => 0,
        max_length => 8,
        traits     => ['TT'],
        templates  => {
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
        traits         => ['TT'],
        templates      => {
        },
    },
);

1;
