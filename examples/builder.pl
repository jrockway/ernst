#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';

use FindBin qw($Bin);
use lib ("$Bin/../lib", "$Bin/lib");

use TermReader;
use YAML;

my $i = TermReader->new();
say Dump($i->interpret(Document->meta->metadescription));

BEGIN {
  my @MD = ( traits => ['MetaDescription'] ); 

  package Language;
  use Ernst;

  my @str = (
      @MD,
      is          => 'ro',
      isa         => 'Str',
      description => {
          type => 'String',
      },
  );

  has 'name'     => @str;
  has 'encoding' => @str;
  
  package Document;
  use Ernst;

  has 'primary_language' => (
      @MD,
      is          => 'ro',
      isa         => 'Language',
      description => {
          type => Language->meta->metadescription,
      },
  );

  has 'alternate_languages' => (
      @MD,
      is          => 'ro',
      isa         => 'ArrayRef[Language]',
      auto_deref  => 1,
      description => {
          type        => 'Collection',
          inside_type => Language->meta->metadescription,
          cardinality => '+',
      },
  );

  has 'foo_bar_map' => (
      @MD,
      is          => 'ro',
      isa         => 'HashRef[Str]',
      auto_deref  => 1,
      description => {
          type        => 'Collection::Map',
          inside_type => 'String',
      },
  );
}

