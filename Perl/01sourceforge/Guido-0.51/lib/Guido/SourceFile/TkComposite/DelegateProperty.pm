package Guido::SourceFile::TkComposite::DelegateProperty;

use strict;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

use vars qw( @ISA );
@ISA = qw();

use Class::MethodMaker get_set => [ qw / name target dbname dbclass default / ];
use Data::Dumper;

$VERSION = '0.01';

my $app;

sub new {
  my ($class, %attribs) = @_;
  my $self = {
    name => $attribs{name},
    target => $attribs{target},
    dbname => $attribs{dbname},
    dbclass => $attribs{dbclass},
    default => $attribs{default},
  };
  return bless $self => $class;
}


sub to_node {
  my($self, %params) = @_;
  my $node = $params{xml_doc}->createElement('DelegateProperty');
  $node->setAttribute("name", $self->name);
  $node->setAttribute("target", $self->target);
  $node->setAttribute("dbname", $self->dbname);
  $node->setAttribute("dbclass", $self->dbclass);
  $node->setAttribute("default", $self->default);
  return $node;
}

sub to_code {
  my ($self) = @_;
  my $name = $self->name;
  my $target = $self->target;
  my $dbname = $self->dbname;
  my $dbclass = $self->dbclass;
  my $default = $self->default;
  if ($target !~ /^\$/) {$target = "'$target'"};
  my $params = join("', '", ($dbname, $dbclass, $default));
  $params = $target . ", '" . $params . "'";
  my $code = qq|\$cw->ConfigSpecs('$name', [$params]);|;
  return $code;
}

1;
