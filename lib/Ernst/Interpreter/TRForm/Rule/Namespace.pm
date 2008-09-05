package Ernst::Interpreter::TRForm::Rule::Namespace;
use Moose::Role;
use Ernst::Interpreter::TRForm::Namespace;

has 'namespace' => (
    is       => 'ro',
    isa      => 'Ernst::Interpreter::TRForm::Namespace',
    required => 1,
);

before 'transform_attribute' => sub {
    my ($self, $region, $attribute, $instance) = @_;

};

1;
