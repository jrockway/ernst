use strict;
use warnings;
use Test::More tests => 5;

use Ernst::Interpreter::Edit;
use Test::Exception;

{ package Class;
  use Ernst;

  has 'password' => (
      is          => 'ro',
      isa         => 'Str',
      required    => 1,
      traits      => ['MetaDescription'],
      description => {
          traits           => [qw/Editable Transform/],
          editable         => 1,
          ignore_if        => sub { length $_[0] == 0 },
          transform_source => [qw/password_once password_again/],
          transform_rule   => sub {
              my ($a, $b) = @_;
              die 'passwords do not match' unless $a eq $b;
              $a;
          },
      },
  );
}

my $edit = Ernst::Interpreter::Edit->new( description => Class->meta->metadescription );
my $c = $edit->interpret(undef, { password_once => 'foo', password_again => 'foo' });
is $c->password, 'foo';

throws_ok {
    $edit->interpret(undef, { password_once => 'foo', password_again => 'bar' });
} qr/passwords do not match/;

$c = $edit->interpret($c, { password_once => 'bar', password_again => 'bar' });
is $c->password, 'bar';

throws_ok {
    $edit->interpret($c, { password_once => 'foo', password_again => 'bar' });
} qr/passwords do not match/;

# dont change password when fields are both empty

$c = $edit->interpret($c, { password_once => '', password_again => '' });
is $c->password, 'bar';
