package Ernst::Description::Base;

use Moose;
use Ernst::Meta::Description::Class;

sub import {
    my $caller = caller;
    
    strict->import;
    warnings->import;

    Moose::init_meta(
        $caller,
        undef, # Moose::Object
        'Ernst::Meta::Description::Class',
    );
    
    Moose->import({ into => $caller });
}

1;
