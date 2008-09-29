package Ernst::Interpreter::TRForm::Utils;
use strict;
use warnings;
use Template::Refine::Processor::Rule;
use Template::Refine::Processor::Rule::Select::XPath;

use Sub::Exporter -setup => {
    exports => [qw/simple_replace/],
};

sub simple_replace {
    my ($frag, $xpath, $type, $code) = @_;

    $type = "Template::Refine::Processor::Rule::Transform::$type";
    Class::MOP::load_class($type);

    return $frag->process(
        Template::Refine::Processor::Rule->new(
            selector => Template::Refine::Processor::Rule::Select::XPath->new(
                pattern => $xpath,
            ),
            transformer => $type->new(
                replacement => $code,
            ),
        ),
    );
}

1;
