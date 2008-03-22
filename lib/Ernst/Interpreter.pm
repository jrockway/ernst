package Ernst::Interpreter;
use Ernst;
use MooseX::AttributeHelpers;
use List::MoreUtils qw(uniq);

has 'handlers' => (
    metaclass => 'Collection::Hash',
    isa       => 'HashRef[CodeRef]',
    default   => sub { 
        "" => sub { warn 'Reached default root action!'; return },
    },
    provides => {
        get    => 'handler',
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
    warn join ':', $attr->meta->types;
    my @types = uniq reverse grep { $self->handler_exists($_) } $attr->meta->types;
    
    warn join '<->', map { "'$_'". (defined $_ ? 'YES' : 'NO') } @types;

    my @handlers = ( (map { warn $_; $self->handler($_) } @types), 
                     sub { confess "There is no next handler!" } );
    warn "OH NOES";
    warn @handlers;

    my $i = 0;
    use Moose::Autobox;
    return sub {
        my ($self, $attr) = @_;
        warn "Running iteration $i on $self ($attr)";
        $handlers[$i]->( sub { my ($attr) = @_; $i++; $self->($attr) }, $attr );
    }->y->($attr);
}

1;

__END__

=head1 NAME

Ernst::Interpreter - a basic interpreter of Ernst descriptions
