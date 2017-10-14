package Guido::SourceFile::TkComposite::DelegateMethod;

use strict;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

use vars qw( @ISA );
@ISA = qw();

use Class::MethodMaker get_set => [ qw / name target / ];
use Data::Dumper;

$VERSION = '0.01';

my $app;

sub new {
  my ($class, %attribs) = @_;
  my $self = {
    name => $attribs{name},
    target => $attribs{target},
  };
  return bless $self => $class;
}

sub to_node {
  my($self, %params) = @_;
  my $node = $params{xml_doc}->createElement('DelegateMethod');
  $node->setAttribute("name", $self->name);
  $node->setAttribute("target", $self->target);
  return $node;
}

sub to_code {
  my ($self) = @_;
  my $name = $self->name;
  my $target = $self->target;
  my $code = qq|\$cw->Delegates($target => '$name');|;
}

1;
