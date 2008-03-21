use strict;
use warnings;
use Test::More tests => 7;
use Test::Exception;

{ package Class;
  use Ernst;

  has 'a' => (
      traits => ['MetaDescription'],
      is     => 'ro',
      isa    => 'Str',
  );
}

ok (Class->meta->metadescription);
ok my $m = Class->meta->get_attribute('a')->metadescription;

is $m->meta->type, 'String', 'type mapped ok';

# check all the cases

my $metaclass = Moose::Meta::Class->create_anon_class(
    superclasses => ['Moose::Meta::Attribute'],
    roles        => ['Ernst::Meta::Attribute'],
);

lives_ok {
    my $meta = $metaclass->name->new(
        'test', isa => 'Class',
    );
    
    is $meta->metadescription->name, 'test', 'attr name is test';
    is $meta->metadescription->meta->type, 'Wrapper', 'attr type is Wrapper';
    isa_ok $meta->metadescription, 'Ernst::Description::Wrapper';
};
