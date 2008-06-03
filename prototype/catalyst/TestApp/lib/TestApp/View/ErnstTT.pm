package TestApp::View::ErnstTT;
use Moose;
use Ernst::Interpreter::TT::HTMLForm;

extends 'Catalyst::View::TT';

around process => sub {
    my ($next, $self, $c, @args) = @_;

    my $flavor = $c->stash->{flavor};
    
    if($flavor){
        my @ernst = grep { eval { $c->stash->{$_}->meta->metadescription->does('Ernst::Description::Trait::TT') } } 
          keys %{$c->stash};

        my $i = Ernst::Interpreter::TT::HTMLForm->new;
        for my $key (@ernst){
            $c->stash->{$key. '_rendered'} = $i->interpret($c->stash->{$key}, $flavor, $c->stash->{extra_ernst_args});
        }
    }

    $self->$next($c, @args);
};
  
1;
