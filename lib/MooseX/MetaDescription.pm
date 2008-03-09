package MooseX::MetaDescription;

require Moose;
use MooseX::MetaDescription::Meta::Class;
use MooseX::MetaDescription::Meta::Attribute;

sub import {
    my $caller = caller;
    Moose::init_meta(
        $caller, 
        undef, # Moose::Object
        'MooseX::MetaDescription::Meta::Class'
    );
}

package Moose::Meta::Attribute::Custom::MetaDescription;
sub register_implementation { 'MooseX::MetaDescription::Meta::Attribute' }

1;

__END__

=head1 NAME

MooseX::MetaDescription - a metadescription framework for Moose classes

=head1 SYNOPSIS

Declare a class like this:

  package User::Profile;
  use MooseX::MetaDescription;
  use Moose;

  has 'username' => (
      metaclass  => 'MetaDescription',
      is         => 'ro',
      isa        => 'Str',
      traits     => [
          'MetaDescription::Validation',
          'MetaDescription::HTML',
      ],
      html       => { type => 'text' },
      validation => {
          rules => {
              'MetaDescription::Validation::Length' => {
                  min => 1,
                  max => 20,
               },
          },
      },
  );
 
  has 'biography' => (
      metaclass  => 'MetaDescription',
      is         => 'ro',
      isa        => 'Str',
      traits     => [
          'MetaDescription::Validation',
          'MetaDescription::HTML',
          'MetaDescription::CSS',
      ],
      html       => { 
          type => 'textarea', 
          rows => 25, 
          cols => 80
      },
      css        => { class => 'rich_textarea' },
      validation => {
          rules => {
              'MetaDescription::Validation::WordCount' => {
                  min => 1,
                  max => 400,
               },
              'MetaDescription::Validation::Profanity::EN' => {},
          ],
      },
  );

Then introspect it:

  my $essay_description =
      User::Profile->meta->get_attribute_map->{pleasant_essay}->metadescription;

  my $class_description = User::Profile->meta->metadescription;
  my $essay_description = $class_description->metadescription_for('pleasant_essay');

Then do some other stuff, perhaps:

  my $form = My::Web::Form->new( class => 'User::Profile' );
  $form->to_html;

