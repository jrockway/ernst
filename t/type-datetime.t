use strict;
use warnings;
use Test::More tests => 3;
use DateTime;

{ package Class;
  use Ernst;

  has 'date' => (
      is          => 'ro',
      isa         => 'DateTime',
      traits      => ['MetaDescription'],
      description => {
          type   => 'DateTime',
          format => '%e %b %Y %H:%M %p',
      },
  );
}

my $c = Class->new(
    date => DateTime->new(
        year   => 2009,
        month  => 1,
        day    => 10,
        hour   => 9,
        minute => 0,
        second => 0,
    ),
);
ok $c;

my $fmt = $c->meta->metadescription->get_attribute('date')->postprocess;
ok $fmt;

is $fmt->($c->date), '10 Jan 2009 09:00 AM';
