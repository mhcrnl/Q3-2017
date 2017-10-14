package GBMenu;

use XML::DOM;
use Tk;
use Tk::Adjuster;
use Data::Dumper;

$| = 1;

sub import_menu {
	my($app, $file_name, $eval_handler) = @_;
	
	#Get MainWindow ref from Application object
	my $mw = $app->{mw};
	
	my $parser = new XML::DOM::Parser;
	my $doc = $parser->parsefile ($file_name);
	$app->TRACE("Done parsing $file_name...", 1);

	#Create menubar and pack it
	my $menu_bar = $mw->Menu();
	$mw->configure(-menu=>$menu_bar);

	#Top level menus are defined in <menu> tags
	my $top_levels = $doc->getDocumentElement->getElementsByTagName("menu",0);
	my $n = $top_levels->getLength;

	$app->TRACE("$n top-level menu items to process", 1);
	
	for (my $i = 0; $i < $n; $i++) {
		my $top_level = $top_levels->item($i);
		$app->TRACE("Top level menu: " . $top_level->getAttribute("label"), 1);

		#Add menu button
		my $atts = getMenuAtts($top_level);
		
		my $menub = $menu_bar->cascade(%$atts);
		recurse($top_level, $menub, $eval_handler);
	}

	$doc->dispose();
	return $menu_bar;
}



sub import_plugins {
	my(%params) = @_;
	
	my $app = $params{app};
	my $file_name = $params{file_name};
	my $plugin_name = $params{plugin} if $params{plugin};
	
	#Get MainWindow ref from Application object
	my $mw = $app->{mw};

	$app->TRACE("Parsing plugin file $file_name", 1);
	my $parser = new XML::DOM::Parser;
	my $doc = $parser->parsefile($file_name);
	$app->TRACE("Done parsing plugin file...", 1);
	my $plugins = $doc->getDocumentElement->getElementsByTagName("plugin",0);
	my $n = $plugins->getLength;
	
	$app->TRACE("$n plugins to process", 1);
	
	#Create adjuster object for resizable plugins
	for (my $i = 0; $i < $n; $i++) {
		my $plugin = $plugins->item($i);
		my $att = $plugin->getAttribute("name");
		$app->TRACE("Plugin: " . $att, 1);
		
		if ($plugin_name and $att ne $plugin_name) {
			$app->TRACE("Skipping $att",1);
			next;
		}
		
		#Add plugin and pack it
		my $atts = getPluginAtts($plugin);
	    $app->TRACE("Attributes:\n" . Dumper($atts), 5);
		my $pack_info = getPackInfo(delete($atts->{'pack'}));
		my $class = delete($atts->{class_name});
	    $app->TRACE("Pack info:\n" . Dumper($pack_info), 5);
	
		#Import the source file and instantiate the widget
		eval {
			require "Guido/Plugin/" . $class . ".pm";
			
			#Some plugins don't provide UI
			if ("Guido::Plugin::$class"->isa("Tk::Widget")) {
				#If there is a UI then load as widget
				my $wdg_plugin = $mw->$class(%$atts);				
				$app->TRACE("Packing plugin", 1);
				$wdg_plugin->packAdjust(%$pack_info);
				$wdg_plugin->init_plugin($app);
				$wdg_plugin->place_menus($app);
				$app->plugins($class, $wdg_plugin);
			}
			else {
				#Else load as plain ol' module
				my $plugin = "Guido::Plugin::$class"->new(%$atts);
				$plugin->init_plugin($app);
				$plugin->place_menus($app);
				$app->plugins($class, $plugin);
			}
		};
		if ($@) {
			warn "Initialization of plugin $class failed: $@\n";
			return 0;
		}
	}

	$doc->dispose();
	return 1;
}


sub recurse {
	my($node, $parent_mnu, $eval_handler) = @_;

	foreach my $subnode ($node->getChildNodes) {
		if ($subnode->getNodeType == ELEMENT_NODE) {
			my $label = $subnode->getAttribute("label");
			if ($subnode->getNodeName eq 'menuitem') {
				my $atts = getMenuAtts($subnode, $eval_handler);
				my $type = delete $atts->{'-type'};
				my $command = delete $atts->{'-command'};
				
				if ($command =~ /^sub\s*\{/) {
					$atts->{'-command'} = &$eval_handler($command);
				}
				else {
					$atts->{'-command'} = $command;
				}

				$parent_mnu->command(%$atts);
			}
			elsif ($subnode->getNodeName eq 'menu') {
				my $atts = getMenuAtts($subnode);
				$parent_mnu->cascade(-label=>$atts->{-label});
				recurse($subnode, $submenu);
			}
		}
	}		
}

sub getMenuAtts {
	my($node, $eval_handler) = @_;
	my $atts = {};
	my $node_map = $node->getAttributes;

	for (my $i = 0; $i < $node_map->getLength; $i++) {
		my $att = $node_map->item($i);
		my $name = $att->getName;
		next if $name eq 'name';
		my $value = $att->getValue;

		$atts->{'-' . $name} = $value; 
	}
    return $atts;
}

sub getPluginAtts {
	my($node) = @_;
	my $atts = {};
    my $node_map = $node->getAttributes;
	for (my $i = 0; $i < $node_map->getLength; $i++) {
	    my $att = $node_map->item($i);
	    my $name = $att->getName;
	    next if $name eq 'name';
	    my $value = $att->getValue();
#	    $value =~ s|^\&|\&main\:\:| if $value !~ /::/;
#	    $value = eval "\\$value" if $value =~ /^(\&|sub\s*\{)/;
		$atts->{$name} = $value; 
	}
    return $atts;
}

sub setOpt {
  my($widget, $option, $value) = @_;
  eval {$widget->$configure($option => $value)};
}

sub getPackInfo {
  my($string) = @_;
  my %atts;
  map {
    my($key,$value) = split(/=/);
    $atts{$key} = $value;
  } split(/;/,$string);
  return \%atts;
}

