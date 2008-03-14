package Ernst;

use Moose;
use Ernst::Meta::Class;
use Ernst::Meta::Attribute;

sub import {
    my $caller = caller;
    
    strict->import;
    warnings->import;
    
    Moose::init_meta(
        $caller, 
        undef, # Moose::Object
        'Ernst::Meta::Class'
    );
    
    Moose->import({ into => $caller });
}

package Moose::Meta::Attribute::Custom::Trait::MetaDescription;
sub register_implementation { 'Ernst::Meta::Attribute' }

1;

__END__

=head1 NAME

Ernst - a metadescription framework for Moose classes

=head1 SYNOPSIS
