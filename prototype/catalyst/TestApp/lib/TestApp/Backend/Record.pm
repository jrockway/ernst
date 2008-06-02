package TestApp::Backend::Record;
use Ernst;
use Data::UUID;
use Text::Markdown;

with 'MooseX::Storage::Directory::Id';

__PACKAGE__->meta->metadescription->apply_role(
    'Ernst::Description::Trait::TT',
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
    required    => 1,
    description => {
        type               => 'String',
        min_length         => 0,
        max_length         => 16,
        traits             => [qw/TT Editable Friendly/],
        initially_editable => 1,
        editable           => 0,
        instructions       => 'You may not change this after registration, so choose wisely.',
    },
);

has 'password' => (
    traits      => ['MetaDescription'],
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    description => {
        type => 'Password',
    }
);

has 'biography' => (
    traits      => ['MetaDescription'],
    is          => 'ro',
    isa         => 'Str',
    description => {
        type           => 'String',
        min_length     => 0,
        average_length => '3000',
        traits         => [qw/TT Editable Friendly/],
        friendly       => 'Bio',
        templates      => {
            edit => 'Bio: <textarea name="biography">[% value | html %]</textarea>',
            view => sub {
                my $args = shift;
                my $md = Text::Markdown->new;
                "[% label %]: <div class='markdown'>".
                  $md->markdown($args->{value}).
                    "</div>";
            },
        },
    },
);

has 'age' => (
    traits      => ['MetaDescription'],
    is          => 'ro',
    isa         => 'Int',
    description => {
        type       => 'Integer',
        traits     => [qw/TT Editable Friendly/],
        label      => 'Current age (years)',
        templates  => {
        },
    },
);

1;
