use strict;
use warnings;
use Test::Exception;
use Test::More tests => 7;

{ my @MD = ( traits => ['MetaDescription'] ); 

  package Language;
  use MooseX::MetaDescription;
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
  use MooseX::MetaDescription;
  use Moose;

  has 'languages' => (
      @MD,
      is          => 'ro',
      isa         => 'ArrayRef[Language]',
      auto_deref  => 1,
      description => {
          type      => 'Container',
          type_args => {
              contains    => Language->meta->metadescription,
              cardinality => '+',
          },
      },
  );
}

my $doc;
lives_ok {
    $doc = Document->new( languages => [
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

my $t = $doc->meta->metadescription->attribute('languages')->type;
ok !$t->is_required_cardinality([]);
ok $t->is_required_cardinality([1]);
ok $t->is_required_cardinality([1,2]);

my $attrs;
lives_ok { $attrs = [attributes($doc->meta->metadescription)] };

is_deeply $attrs,
  [ [ languages => [ [ name => 'String' ], [ encoding => 'String' ] ] ] ],
  'structure of $doc metadescription looks good';

# return a list of [ attribute_name => type ] pairs
sub attributes {
    my $container = shift;
    my @result;
    foreach my $name ($container->attribute_names) {
        my $attr = $container->attribute($name);
        if($attr->type->name eq 'Container'){
            push @result, [ $name => [ attributes($attr->type->contains) ]];
        }
        else {
            push @result, [ $name => $attr->type->name ];
        }
    }
    return @result;
}
