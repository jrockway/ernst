package TestApp::Controller::Records;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Ernst::Interpreter::Edit;

sub all :Path Args(0) {
    my ($self, $c) = @_;
    my $dh = $c->model('Records')->directory->open;
    my @ids = map { /([\-0-9A-F]+).json/i; $1 } grep { /.json$/ } $dh->read;
    $c->stash->{ids}      = \@ids;
    $c->stash->{template} = 'show_all.tt';
}

sub view :Local Args(1) {
    my ($self, $c, $id) = @_;
    my $record = $c->model('Records')->lookup($id);
    $c->stash->{flavor} = 'view';
    $c->stash->{template} = 'view.tt';
    $c->stash->{object} = $record;
}

sub process_submit {
    my ($self, $c, $obj) = @_;
    
    eval {
        my $edit = Ernst::Interpreter::Edit->new(
            description => TestApp::Backend::Record->meta->metadescription,
        );
        my $record = $edit->interpret($obj, $c->req->params);
        $c->model('Records')->store($record);
        $c->res->redirect($c->uri_for('/records/view', $record->get_id));
    };
    
    if(my $errors = $@){
        $c->stash->{flavor} = 'edit';
        $c->stash->{template} = 'edit.tt';
        $c->stash->{object} = $obj;
        $c->stash->{extra_ernst_args}{errors} =
          eval { $errors->{errors} } || 
            { CLASS => "Internal error: $errors" };
        $c->stash->{extra_ernst_args}{values} = $c->req->params;
        $c->stash->{template} = 'edit.tt';
        $c->detach;
    }
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
        $self->process_submit($c, $record);
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
        $self->process_submit($c, 'TestApp::Backend::Record');
    }
}

sub search :Local Args(2){
    my ($self, $c, $key, $value) = @_;
    my @records = $c->model('Records')->search({ $key => $value });
    warn scalar @records;
    $c->stash->{ids}      = [map { $_->get_id } @records];
    $c->stash->{template} = 'show_all.tt';
}

1;
