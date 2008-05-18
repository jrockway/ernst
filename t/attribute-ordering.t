use strict;
use warnings;
use Test::More tests => 4;

{
    package Ernst::Description::Trait::Generation;
    use Moose::Role;
    has 'generation' => ( is => 'ro', isa => 'Int', default => 1 );

    my @def = (
        is     => 'ro',
        isa    => 'Str',
        traits => ['MetaDescription'],
    );

    sub mk::desc($) { # just a hack to save me from typing
        return (
            description => {
                traits     => ['Generation'],
                generation => shift,
            },
        );
    }
    
    package Superclass;
    use Ernst;

    has $_ => (@def, mk::desc(1)) for qw/a b foo/;

    package Class;
    use Ernst;
    extends 'Superclass';

    # a long list to minimize coincidences
    my @order = qw/d c a b q w e r t y u i o p/;
    has $_ => (@def, mk::desc(2)) for @order;
}

is_deeply(
    [Superclass->meta->metadescription->get_attribute_list],
    [qw/a b foo/],
    'attribute ordering for Superclass is correct'
);

is_deeply(
    [map {$_->generation} 
       map { Superclass->meta->metadescription->get_attribute($_) }
         Superclass->meta->metadescription->get_attribute_list],
    [1,1,1],
    'correct generation for Superclass attributes',
);

is_deeply(
    [Class->meta->metadescription->get_attribute_list],
    [qw/a b foo d c q w e r t y u i o p/],
    'attribute ordering for Class is correct'
);

is_deeply(
    [map {$_->generation} 
       map { Class->meta->metadescription->get_attribute($_) }
         Class->meta->metadescription->get_attribute_list],
    [2,2,1,2,2,2,2,2,2,2,2,2,2,2,2],
    'correct generation for Class attributes',
);
