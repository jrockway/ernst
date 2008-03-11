package MooseX::MetaDescription::Description;
use Moose;
use MooseX::MetaDescription::TypeLibrary;

has 'name' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'type' => (
    is       => 'ro',
    isa      => 'MooseX::MetaDescription::Type',
    coerce   => 1,
    required => 1,
);

has 'type_args' => (
    is         => 'ro',
    isa        => 'HashRef',
    auto_deref => 1,
    predicate  => 'has_type_args',
);

has 'is_writable' => (
    is       => 'ro',
    isa      => 'Bool',
    required => 1,
);

sub BUILD {
    my $self = shift;
    if($self->has_type_args){
        my $new_type = (ref $self->type)->new( $self->type_args );
        $self->meta->get_attribute('type')->set_value( $self, $new_type );
    }
}

1;

__END__

=head1 NAME

MooseX::MetaDescription::Description - a metadescription of a single
attribute

=head1 SYNOPSIS

  my $desc = Some::Container->attribute('foo');

  my $name = $desc->name;
  my $type = $desc->type->name;

  say "This attribute is called '$name' and is a '$type'";

  if($desc->does('MooseX::MetaDescription::Trait::CSS')){
     # now you know you can call "css"
     my $css_class = $desc->css->class;
  }
