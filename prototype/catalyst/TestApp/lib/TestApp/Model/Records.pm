package TestApp::Model::Records;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

use TestApp::Backend::Record;

__PACKAGE__->config( class => 'MooseX::Storage::Directory' );

sub prepare_arguments {
    my ($self, $app) = @_;
    return {
        class     => TestApp::Backend::Record->meta,
        directory => $app->path_to('root','data'),
    }
}

1;
