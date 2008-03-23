use strict;
use warnings;
use Test::Exception;
use Test::More tests => 13;
use Carp qw(confess);

use ok 'Ernst::Description::Collection';

{
    no warnings;
    use Ernst::Meta::Attribute;
    # don't want to guess attribute types
    sub Ernst::Meta::Attribute::_guess_type {
        confess 'Disabled for testing' 
    };
}

{ my @MD = ( traits => ['MetaDescription'] ); 

  package Language;
  use Ernst;
  use Moose;

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
  use Moose;

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
}

my $doc;
lives_ok {
    $doc = Document->new( 
        
        primary_lanaguage => Language->new(
            name     => 'Foo',
            encoding => 'utf-42',
        ),
        
        alternate_languages => [
            Language->new( 
                name     => 'English',
                encoding => 'us-ascii',
            ),
            Language->new(
                name     => 'Japanese',
                encoding => 'utf-8',
            ),
        ]);
};

ok $doc;

ok(Language->meta->metadescription, 'Language has metadescription');
ok(Document->meta->metadescription, 'Document has metadescription');

ok $doc->meta->get_attribute('alternate_languages')->metadescription;

my $t = $doc->meta->metadescription->get_attribute('alternate_languages');
ok !$t->is_required_cardinality([]);
ok $t->is_required_cardinality([1]);
ok $t->is_required_cardinality([1,2]);

my $attrs;
lives_ok { $attrs = [attributes(Language->meta->metadescription)] };
is_deeply $attrs, [ [ 'name' => 'String'], [encoding => 'String' ]],
  'Language has right attributes';

lives_ok { $attrs = [attributes($doc->meta->metadescription)] };
is_deeply $attrs, [ [ primary_language =>
                        [ 'Container::Moose (Language)' =>
                            [ name => 'String' ],
                            [ encoding => 'String' ],
                        ]
                    ],
                    [ alternate_languages =>
                        [ 'Collection (+Language)' =>
                          [ name => 'String' ],
                          [ encoding => 'String' ],
                        ],
                    ]],
  'structure of $doc metadescription looks good';

# return a list of [ attribute_name => type ] pairs
sub attributes {
    my $container = shift;
    my @result;
    foreach my $name ($container->get_attribute_list) {
        my $attr = $container->get_attribute($name);
        if($attr->meta->type_isa('Collection')){
            push @result, [ 
                $name => [ 
                    sprintf("Collection (%s%s)", $attr->cardinality,
                            $attr->inside_type->name),
                    attributes($attr->inside_type),
                ]
            ];
        }
        elsif($attr->meta->type_isa('Container::Moose')){
            push @result, [ 
                $name => [ 
                    sprintf("%s (%s)", $attr->meta->type, $attr->class->name),
                    attributes($attr),
                ]
            ];
        }
        else {
            push @result, [ $name => $attr->meta->type ];
        }
    }
    return @result;
}
