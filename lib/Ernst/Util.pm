package Ernst::Util;
use strict;
use warnings;

use Carp qw(confess);

my $LITERAL_CLASS = qr/^[+](.+)$/;

sub literal_class_regex {
    return $LITERAL_CLASS;
}

sub get_type_class {
    my $type = shift;
    confess 'No type provided' unless defined $type;

    my $class;
    if(ref $type){
        return $type;
    }
    elsif($type =~ /$LITERAL_CLASS/o){
        # +Literal::Type::Class
        $class = $1;
    }
    else {
        if($type ne ''){
            $class = "Ernst::Description::$type";
        }
        else {
            $class = 'Ernst::Description';
        }
    }

    Class::MOP::load_class($class);
    return $class;
}

1;
