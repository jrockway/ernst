package Ernst::Interpreter;
use Ernst;
use MooseX::AttributeHelpers;
use List::MoreUtils qw(uniq);
use Sub::Name;

has 'handlers' => (
    metaclass => 'Collection::Hash',
    isa       => 'HashRef[CodeRef]',
    default   => sub { 
        +{
            "" => sub { warn 'Reached default root action!'; return },
        };
    },
    provides => {
        get    => 'get_handler',
        exists => 'handler_exists',
    },
);

sub interpret {
    my $self = shift;
    my $desc = shift;
    
    my %result;
    foreach my $name ($desc->get_attribute_list){
        my $attr = $desc->get_attribute($name);
        $result{$name} = $self->interpret_attribute($attr);
    }
    return \%result;
}

sub interpret_attribute {
    my ($self, $attr) = @_;

    my @types = reverse grep { $self->handler_exists($_) } $attr->meta->types;
    
    {
        my @utypes = uniq @types;
        confess 'some types are repeated in the type graph for '. 
          $attr->meta->type. '!!!'
            unless @utypes == @types;
    }

    my $next = subname '<Ernst interpreter>::invalid_next' =>
      sub { confess "Attempt to 'next' above the top level!" };
    for my $this (map { $self->get_handler($_) } @types){
        my $old_next = $next;
        $next = sub { unshift @_, $old_next; goto $this };
    }
    
    return $next->($attr);
}

1;

__END__

=head1 NAME

Ernst::Interpreter - a basic interpreter of Ernst descriptions
