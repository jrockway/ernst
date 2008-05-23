package TestApp::Controller::Records;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Ernst::Interpreter::Instantiate;

sub view :Local Args(1) {
    my ($self, $c, $id) = @_;
    my $record = $c->model('Records')->lookup($id);
    $c->stash->{flavor} = 'view';
    $c->stash->{template} = 'view.tt';
    $c->stash->{object} = $record;
}

sub edit :Local Args(1) {
    my ($self, $c, $id) = @_;
    my $record = $c->model('Records')->lookup($id);
    if($c->req->method eq 'GET'){
        $c->stash->{flavor} = 'edit';
        $c->stash->{template} = 'edit.tt';
        $c->stash->{object} = $record;
    }
    else {
        my $new = Ernst::Interpreter::Instantiate->new(
            description => TestApp::Backend::Record->meta->metadescription,
        );
        $record = $new->create_instance($c->req->params);
        $c->model('Records')->store($record);
        $c->res->redirect($c->uri_for('/records/view', $record->get_id));
    }
}

sub create :Local Args(0) {
    my ($self, $c) = @_;

    if($c->req->method eq 'GET'){
        $c->stash->{flavor} = 'edit';
        $c->stash->{template} = 'edit.tt';
        $c->stash->{object} = 'TestApp::Backend::Record';
    }
    else {
        my $new = Ernst::Interpreter::Instantiate->new(
            description => TestApp::Backend::Record->meta->metadescription,
        );
        my $record = $new->create_instance($c->req->params);
        $c->model('Records')->store($record);
        $c->res->redirect($c->uri_for('/records/view', $record->get_id));
    }
}

1;
