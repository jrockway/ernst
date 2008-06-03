use strict;
use warnings;
use Test::More tests => 14;

use Test::Exception;

use ok 'Ernst::Interpreter::Edit';

{ package Class;
  use Ernst;
  
  has 'uuid' => (
      is      => 'ro',
      isa     => 'Int',
      default => sub { 42 },
      traits  => ['MetaDescription'],
  );
  
  has 'name' => (
      is          => 'ro',
      isa         => 'Str',
      required    => 1,
      traits      => ['MetaDescription'],
      description => {
          traits             => ['Editable'],
          initially_editable => 1,
          editable           => 0,
      },
  );
  
  has 'description' => (
      is          => 'ro',
      isa         => 'Str',
      required    => 1,
      traits      => ['MetaDescription'],
      description => {
          traits             => ['Editable'],
          initially_editable => 1,
          editable           => 1,
      },
  );
}

my $editor = Ernst::Interpreter::Edit->new(description => Class->meta->metadescription);
ok $editor;

my $instance = 
  $editor->interpret(undef, { uuid => 1, name => 'name', description => 'desc' });

isa_ok $instance, 'Class';
is $instance->uuid, '42', 'non-editable attribute ignored';
is $instance->name, 'name';
is $instance->description, 'desc';

my $new_instance =
  $editor->interpret($instance, 
                     { uuid => 1, name => 'new name', description => 'new desc' });

is $new_instance->uuid, '42', 'still non-editable';
is $new_instance->name, 'name', 'not editable after initial edit';
is $new_instance->description, 'new desc', 'changed ok';

is $instance->description, 'desc', 'made a copy';

dies_ok {
    $editor->interpret(undef, {});
} 'required fields are required';

my $error = $@;
is ref $error, 'HASH', 'got an error hashref';
ok $error->{errors}{name}, 'got an error message for "name"';
ok $error->{errors}{description}, 'got an error message for "description"';
