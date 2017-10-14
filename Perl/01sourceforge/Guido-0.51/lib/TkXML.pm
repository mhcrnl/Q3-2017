package TkXML;

use strict;
use vars qw/@ISA @EXPORT/;
use XML::DOM;
use Tk;
use Carp;
use Data::Dumper;
require Exporter;
require AutoLoader;

sub new {
	my($class, %attribs) = @_;
	my $caller = caller(0);
	my $self = {
		data_pkg => $attribs{data_pkg},
		top_widget => $attribs{top_widget},
		eval_code => $attribs{eval_code},
		file_path => $attribs{file_path},
		call_pkg => $caller,
	};

	bless $self, $class;
	my $doc;
	my $parser = new XML::DOM::Parser;
	if ($self->{file_path}) {
		$doc = $parser->parsefile($self->{file_path});
	}
	else {
		my $mod = $self->{data_pkg};
		my $path = $mod;
		$path =~ s|::|/|g;
		require "$path.pm";
		my $data = join('', $mod->get_data());
		$doc = $parser->parse($data);
	}	

	if (!$self->{top_widget}) {
		my $attrs = $self->getAtts($doc->getDocumentElement);
		my $geometry = delete $attrs->{-geometry};
		my $title = delete $attrs->{-title};
		$self->{top_widget} = new MainWindow(%$attrs);	
		$self->{top_widget}->geometry($geometry);
		$self->{top_widget}->title($title) if $title;
	}
	else {
		my $attrs = $self->getAtts($doc->getDocumentElement);
		if (!$self->{top_widget}->isa($attrs->{-widget_type})) {
			croak "Widget type mismatch.  The XML data defines a " . 
				$attrs->{-widget_type} . ", but the composite doesn't inherit from that class";
		}
	}

	

	$self->recurse_xml(
		node=>$doc->getDocumentElement(),
		widget=>$self->{top_widget},
	);
	
	$doc->dispose();
	return $self;
}

sub getAtts {
	my($self, $node) = @_;
	my $atts = {};
    my $node_map = $node->getAttributes;
	for (my $i = 0; $i < $node_map->getLength; $i++) {
		my $att = $node_map->item($i);
		next if $att->getName eq 'name';
		my($key, $value) = ($att->getName, $att->getValue);
		if (grep(/^$key$/, qw/textvariable command/)) {
			my $pkg = $self->{call_pkg};
			my $eval_code = $self->{eval_code};
			$value = &$eval_code($value);
			die $@ if !$value;
		}
		$atts->{'-' . $key} = $value; 
	}
    return $atts;
}

sub setOpt {
  my($widget, $option, $value) = @_;
  eval {$widget->configure($option => $value)};
}

sub getPackInfo {
  my($atts) = @_;
  my %atts;
  map {
    my($key,$value) = split(/=/);
    $atts{'-' . $key} = $value;
  } split(/;/,$atts);
  return %atts;
}

sub getGeoInfo {
	my($attrs) = @_;
	my @geo = ();
	if ($attrs->{-pack}) {
		@geo = getPackInfo($attrs->{-pack});
		unshift(@geo, 'pack');
		delete($attrs->{-pack});
	}
	elsif ($attrs->{-place}) {
		@geo = getPackInfo($attrs->{-place});
		unshift(@geo, 'place');
		delete($attrs->{-place});
	}
	elsif ($attrs->{-grid}) {
		@geo = getPackInfo($attrs->{-grid});
		unshift(@geo, 'grid');
		delete($attrs->{-grid});
	}
	else {
		@geo = getPackInfo($attrs->{-pack});
		unshift(@geo, 'pack');
		delete($attrs->{-pack});
	}
	return @geo;
}

sub recurse_xml {
	my($self, %params) = @_;
	my $node = $params{node};
	my $parent_widget = $params{widget};
	for my $primary_widget ($node->getChildNodes) {
		if ($primary_widget->getNodeType == ELEMENT_NODE) {
		    my $widget_type = $primary_widget->getNodeName;
		    my $widget_name = $primary_widget->getAttribute("name");
		    #print "Adding $widget_type\n";
		    my $attrs = $self->getAtts($primary_widget);
			my ($geo_mgr, %geo_attribs) = getGeoInfo($attrs);
			#print "Using $geo_mgr\n";
			#print Dumper $attrs;
		    my $new_widget = $parent_widget->$widget_type(%$attrs);
		    #$new_widget->pack();
		    $new_widget->$geo_mgr(%geo_attribs);
		    #print "Creating $widget_name\n";
		    eval "\$main::$widget_name = \$new_widget";
		    #print $main::entry . "\n";
		    #print "New widget is $new_widget\n";
			if($primary_widget->hasChildNodes()) {
				$self->recurse_xml(
					node=>$primary_widget,
					widget=>$new_widget,
				);
			}
			else {
				#print "$widget_type has no children\n";
			}
		}
	}
}

1;