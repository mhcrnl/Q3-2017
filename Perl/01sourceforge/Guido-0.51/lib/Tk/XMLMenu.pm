package Tk::XMLMenu;

use XML::DOM;
use Tk;
use Data::Dumper;

sub import_menu {
	my($app, $file_name, $eval_handler) = @_;
	
	#Get MainWindow ref from Application object
	my $mw = $app->{mw};
	
	my $parser = new XML::DOM::Parser;
	my $doc = $parser->parsefile ($file_name);

	#Create menubar and pack it
	my $menu_bar = $mw->Menu();
	$mw->configure(-menu=>$menu_bar);

	#Top level menus are defined in <menu> tags
	my $top_levels = $doc->getDocumentElement->getElementsByTagName("menu",0);
	my $n = $top_levels->getLength;
	
	for (my $i = 0; $i < $n; $i++) {
		my $top_level = $top_levels->item($i);

		#Add menu button
		my $atts = getMenuAtts($top_level);
		
		my $menub = $menu_bar->cascade(%$atts);
		recurse($top_level, $menub, $eval_handler);
	}

	$doc->dispose();
	return $menu_bar;
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
			elsif ($subnode->getNodeName eq 'separator') {
				$parent_mnu->separator();
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

1;