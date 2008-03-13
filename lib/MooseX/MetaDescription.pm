package MooseX::MetaDescription;

require Moose;
use MooseX::MetaDescription::Meta::Class;
use MooseX::MetaDescription::Meta::Attribute;

sub import {
    my $caller = caller;
    Moose::init_meta(
        $caller, 
        undef, # Moose::Object
        'MooseX::MetaDescription::Meta::Class'
    );
}

package Moose::Meta::Attribute::Custom::Trait::MetaDescription;
sub register_implementation { 'MooseX::MetaDescription::Meta::Attribute' }

1;

__END__

=head1 NAME

MooseX::MetaDescription - a metadescription framework for Moose classes

=head1 SYNOPSIS
