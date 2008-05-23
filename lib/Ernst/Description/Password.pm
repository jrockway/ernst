package Ernst::Description::Password;
use Ernst;

extends 'Ernst::Description::Value';
with qw/Ernst::Description::Trait::Editable 
        Ernst::Description::Trait::Transform
        Ernst::Description::Trait::TT
       /;

has '+ignore_if' => ( default => sub { sub { length $_[0] == 0 } } );
has '+transform_source' => ( default => sub { [qw/password password_again/] } );
has '+transform_rule' => (
    default => sub { 
        sub {
            my ($a, $b) = @_;
            die 'passwords do not match' unless $a eq $b;
            $a;
        }
    }
);

has '+templates' => ( default => sub { +{
    view => 'Password: [hidden]',
    edit => 'Password: <input type="password" name="password" />  Confirm: <input type="password" name="password_again" />',
}});

1;
