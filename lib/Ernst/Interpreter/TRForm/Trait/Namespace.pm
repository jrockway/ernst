package Ernst::Interpreter::TRForm::Trait::Namespace;
use Moose::Role;
use Ernst::Interpreter::TRForm::Utils qw(simple_replace);
use Ernst::Interpreter::TRForm::Namespace::Manager;

has 'namespace' => (
    is       => 'ro',
    isa      => 'Ernst::Interpreter::TRForm::Namespace::Manager',
    default  =>
      sub { Ernst::Interpreter::TRForm::Namespace::Manager->new( namespace => [] ) },
    required => 1,
    coerce   => 1,
);

around transform_attribute => sub {
    my ($next, $self, $attribute, $fragment, $instance) = @_;
    my $namespace = $self->namespace->recurse($attribute->name);

    $fragment = simple_replace(
        $fragment,
        '//input | //textarea',
        Replace =>
          sub {
              my $n = shift->cloneNode(1);
              $n->setAttribute( name => $namespace->to_string );
              return $n;
          },
    );

    return $self->$next($attribute, $fragment, $instance);
};

1;
