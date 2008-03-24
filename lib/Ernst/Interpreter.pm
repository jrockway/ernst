package Ernst::Interpreter;
use Ernst;
use MooseX::AttributeHelpers;
use List::MoreUtils qw(uniq);
use Sub::Name;

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

has 'state_class' => (
    isa     => 'ClassName',
    is      => 'ro',
    default => 'Ernst::Interpreter::State',
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

    my $context = $self->state_class->new(
        creator      => $self,
        initial_type => $attr->meta->type,
    );
    
    my $next = subname '<Ernst interpreter>::invalid_next' =>
      sub { confess "Attempt to 'next' above the top level!" };

    for my $this (map { $self->get_handler($_) } @types){
        my $old_next = $next;
        $next = sub { unshift @_, $context, $old_next; goto $this };
    }
    
    return $next->($attr);
}

package Ernst::Interpreter::State;
use Moose;

use overload (
    '&{}' => sub { 
        my $self    = shift;
        my $creator = $self->creator;
        return sub {
            my $attr = shift;
            @_ = ($creator, $attr);
            goto &{ ref($creator) . '::interpret' };
        };
    },
    fallback => 'yes',
);

has 'creator' => (
    isa      => 'Ernst::Interpreter',
    is       => 'ro',
    required => 1,
);

has 'initial_type' => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

sub reinvoke {
    my $self = shift;
    $self->creator->interpret(@_);
}


1;

__END__

=head1 NAME

Ernst::Interpreter - a basic interpreter of Ernst descriptions
