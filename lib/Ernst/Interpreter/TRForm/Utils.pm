package Ernst::Interpreter::TRForm::Utils;
use strict;
use warnings;
use Template::Refine::Processor::Rule;
use Template::Refine::Processor::Rule::Select::XPath;
use UNIVERSAL::require;

use Sub::Exporter -setup => {
    exports => [qw/simple_replace/],
};

sub simple_replace {
    my ($frag, $xpath, $type, $code) = @_;

    $type = "Template::Refine::Processor::Rule::Transform::$type";
    $type->require;

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
