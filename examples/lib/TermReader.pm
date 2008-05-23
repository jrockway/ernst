package TermReader;
use Moose;
use Term::ReadLine;
use feature ':5.10';

extends 'Ernst::Interpreter::Callback';

has depth => (
    metaclass => 'Counter',
    isa       => 'Int',
    is        => 'ro',
    default   => -1,
    provides  => {
        inc => 'descend',
        dec => 'ascend',
    },
);

has term => (
    is      => 'ro',
    isa     => 'Term::ReadLine',
    lazy    => 1,
    default => sub {
        Term::ReadLine->new;
    },
    handles => { read => 'readline' },
);

has '+handlers' => (
    default => sub { 
        +{
            Value => sub {
                my ($c, $next, $attr) = @_;
                return $c->interpreter->read(
                    sprintf(
                        "%s (%s)> ",
                        eval { $attr->name } || '<unknown name>',
                        $attr->meta->type,
                    ),
                );
            },
            'Collection' => sub {
                my ($c, $next, $attr) = @_;
                my @collection;
                $c->interpreter->say("Defining collection ", $attr->name);
                while(1){
                    if($attr->is_required_cardinality(\@collection)){
                        $c->interpreter->say("The collection is of the correct cardinality.");
                        return \@collection if $c->interpreter->y_or_n_p('Done');
                    }
                    else {
                        $c->interpreter->say("The collection is not of the correct cardinality.");
                    }
                    
                    $c->interpreter->say("Defining an element");
                    push @collection, $c->($attr->inside_type);
                }
            },
            'Collection::Map' => sub {
                my ($c, $next, $attr) = @_;
                $c->interpreter->say("Defining map ", $attr->name);
                
                my %collection;            
                while(1){
                    return \%collection if $c->interpreter->y_or_n_p('Done defining map');
                    
                    $c->interpreter->say("Defining an element");
                    my $inner = $attr->inside_type;
                    my $name = $c->interpreter->read("Key (String)> ");
                    my $element = $c->($inner);
                    
                    $collection{$name} = $element;
                }
            },
            'Container::Moose' => sub {
                my ($c, $next, $attr) = @_;
                $c->interpreter->say($attr->name, " is a Moose class ". $attr->container_name);
                my $attrs = $next->($attr);
                return $attr->class->name->new($attrs);
            },
            Container => sub {
                my ($c, $next, $attr) = @_;
                
                $c->interpreter->say("Defining ", $attr->name);
                
                my %result;
                foreach my $name ($attr->get_attribute_list){
                    my $attr = $attr->get_attribute($name);
                    $c->interpreter->say("Defining $name (". $attr->meta->type. ")")
                      unless $attr->meta->type_isa('Value');
                    $result{$name} = $c->($attr);
                }
                
                return \%result;
            },
        },
    },
);

sub y_or_n_p {
    my $self = shift;
    my $msg  = shift;
    while (1) {
        chomp(my $a = $self->read("$msg? (y or n) "));
        if ($a =~ /^(y|n)$/) {
            return 1 if $1 eq 'y';
            return 0;
        } else {
            $self->say("Please answer y or n!\n");
        }
    }
}
    
sub say {
    shift;
    say @_;
}

# show tree structure
before qw/read y_or_n_p say/ => sub {
    my $self = shift;
    print " "x(4*$self->depth);
};

# update depth when we recurse
before interpret => sub {
    shift->descend;
};
    
after interpret => sub {
    shift->ascend;
};
    
1;
