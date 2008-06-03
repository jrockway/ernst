package Ernst::Description::Password;
use Ernst::Description::Base;

extends 'Ernst::Description::Value';
with qw/Ernst::Description::Trait::Editable 
        Ernst::Description::Trait::Transform
        Ernst::Description::Trait::TT
       /;

has '+ignore_if' => ( default => sub { sub { !$_[0] || length $_[0] == 0 } } );
has '+transform_source' => ( default => sub { [qw/password password_again/] } );
has '+transform_rule' => (
    default => sub { 
        sub {
            my ($a, $b) = @_;
            die 'The passwords do not match.' unless $a eq $b;
            $a;
        }
    }
);

has '+templates' => ( default => sub { +{
    view => 'Password: [hidden]',
    edit => 'Password: <input type="password" name="password" />  Confirm: <input type="password" name="password_again" />[% FOREACH error IN errors.$name %]<p class="ernst_error">[% error | html %]</p>[% END %]',
}});

1;
