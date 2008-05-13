use strict;
use warnings;
use Test::More tests => 4;

{
    package Role;
    use Moose::Role;
    sub it_worked { 1 };

    has 'required' => (
        is       => 'ro',
        isa      => 'Int',
        required => 1,
    );

    package Class;
    use Ernst;
    
    __PACKAGE__->meta->metadescription->apply_role('Role', { required => 42 });

}

ok( Class->meta->metadescription->can('apply_role') );
ok( Class->meta->metadescription->does('Role') );
ok( Class->meta->metadescription->it_worked );
is( Class->meta->metadescription->required, 42 );
