use strict;
use warnings;
use Test::Exception;
use Test::More tests => 11;

use ok 'MooseX::MetaDescription::Description::Collection';

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
          type        => 'Collection',
          description => Language->meta->metadescription,
          cardinality => '+',
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

ok(Language->meta->metadescription, 'Language has metadescription');
ok(Document->meta->metadescription, 'Document has metadescription');

ok $doc->meta->get_attribute('languages')->metadescription;

my $t = $doc->meta->metadescription->attribute('languages');
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
        if($attr->type eq 'Collection'){
            push @result, [ $name => [ attributes($attr->description) ]];
        }
        else {
            push @result, [ $name => $attr->type ];
        }
    }
    return @result;
}
