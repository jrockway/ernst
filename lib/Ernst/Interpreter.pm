package Ernst::Interpreter;
use Ernst;
use MooseX::AttributeHelpers;
use List::MoreUtils qw(uniq);
use Sub::Name;

my %default_handlers = (
    "" => sub { warn 'Reached default root action!'; return },
    "Container" => sub {
        my ($self, $next, $attr) = @_;
        my %result;
        foreach my $name ($attr->get_attribute_list){
            my $attr = $attr->get_attribute($name);
            $result{$name} = $self->($attr);
        }
        return \%result;
    }
);

has 'handlers' => (
    metaclass => 'Collection::Hash',
    isa       => 'HashRef[CodeRef]',
    default   => sub { \%default_handlers },
    provides  => {
        keys   => 'available_handlers',
        get    => 'get_handler',
        set    => '_set_handler',
        exists => 'handler_exists',
    },
);

sub BUILD {
    my $self = shift;

    # add in the defaults
    for my $default (keys %default_handlers){
        $self->_set_handler($default, $default_handlers{$default})
          if !$self->get_handler($default);
    }
    
    for my $name ($self->available_handlers){
        my $handler = $self->get_handler($name);
        $name ||= 'Top_Level';
        subname "<Ernst interpreter>::__HANDLER__::$name" =>
          $handler;
    }
}

sub interpret {
    my ($self, $attr) = @_;
    my @types = reverse grep { $self->handler_exists($_) } $attr->meta->types;
    
    {
        my @utypes = uniq @types;
        confess 'some types are repeated in the type graph for '. 
          $attr->meta->type. '!!!'
            unless @utypes == @types;
    }

    my $reinvoke = sub {
        my $attr = shift;
        @_ = ($self, $attr);
        goto \&interpret;
    };
    
    my $next = subname '<Ernst interpreter>::invalid_next' =>
      sub { confess "Attempt to 'next' above the top level!" };

    for my $this (map { $self->get_handler($_) } @types){
        my $old_next = $next;
        $next = sub { unshift @_, $reinvoke, $old_next; goto $this };
    }
    
    return $next->($attr);
}

1;

__END__

=head1 NAME

Ernst::Interpreter - a basic interpreter of Ernst descriptions
