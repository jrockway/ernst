package TestApp::View::ErnstTT;
use Moose;
use Ernst::Interpreter::TT;

extends 'Catalyst::View::TT';

around process => sub {
    my ($next, $self, $c, @args) = @_;

    my $flavor = $c->stash->{flavor};
    
    if($flavor){
        my @ernst = grep { eval { $c->stash->{$_}->meta->metadescription->does('Ernst::Description::Trait::TT::Class') } } 
          keys %{$c->stash};

        my $i = Ernst::Interpreter::TT->new;
        for my $key (@ernst){
            $c->stash->{$key. '_rendered'} = $i->interpret($c->stash->{$key}, $flavor);
        }
    }

    $self->$next($c, @args);
};
  
1;
