package Ernst::Interpreter::Callback;
use Ernst;
use MooseX::AttributeHelpers;
use List::MoreUtils qw(uniq);
use Sub::Name;
use Ernst::Interpreter::Context;

with 'Ernst::Interpreter';

my %default_handlers = (
    "" => sub { 
        my $context = shift;
        warn "Reached default root action for type ",
          $context->initial_type;
          
    },
    "Container" => sub {
        my ($context, $next, $attr) = @_;
        my %result;
        foreach my $name ($attr->get_attribute_list){
            my $attr = $attr->get_attribute($name);
            $result{$name} = $context->($attr);
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

has 'context_class' => (
    isa     => 'ClassName',
    is      => 'ro',
    default => 'Ernst::Interpreter::Context',
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

sub build_context {
    my ($self, $attr, @args) = @_;
    return $self->context_class->new(
        self         => $self,
        initial_type => $attr->meta->type,
        @args,
    );
}

sub interpret {
    my ($self, $attr, @rest) = @_;
    my @types = reverse grep { $self->handler_exists($_) } $attr->meta->types;

    {
        my @utypes = uniq @types;
        confess 'some types are repeated in the type graph for '. 
          $attr->meta->type. '!!!'
            unless @utypes == @types;
    }

    my $context = $self->build_context($attr, @rest);
    
    my $next = subname '<Ernst interpreter>::invalid_next' =>
      sub { confess "Attempt to 'next' above the top level!" };

    for my $this (map { $self->get_handler($_) } @types){
        my $old_next = $next;
        $next = sub { unshift @_, $context, $old_next; goto $this };
    }
    
    return $next->($attr);
}

1;

__END__

=head1 NAME

Ernst::Interpreter::Callback - a basic interpreter of Ernst descriptions
