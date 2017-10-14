# MODINFO module Guido::MacroLoader
package Guido::MacroLoader;

# MODINFO dependency module XML::DOM
use XML::DOM;
# MODINFO dependency module Data::Dumper
use Data::Dumper;
# MODINFO dependency module strict
use strict;

# MODINFO constructor new
# MODINFO paramhash attribs
# MODINFO key app         Guido::Application Reference to the Guido::Application object
# MODINFO key config_file STRING             Filename of the configuration file that the configuration is in
sub new {
	my($class, %attribs) = @_;
	my $self = {
		app => $attribs{app},
		config_file => $attribs{config_file},
	};
	return bless $self => $class;
}

# MODINFO function import_macros
# MODINFO paramhash params
# MODINFO key macro STRING Individual macros to import, if not all of them
sub import_macros {
	my($self, %params) = @_;
	
	my $macro_name = $params{macro} if $params{macro};

	my $app = $self->{app};
	my $file_name = $self->{config_file};
	
	#Get MainWindow ref from Application object
	my $mw = $app->{mw};

	#Parse the XML config file
#	$app->TRACE("Parsing configuration file $file_name", 1);
#	my $parser = new XML::DOM::Parser;
#	my $doc = $parser->parsefile($file_name);
#	$app->TRACE("Done parsing macro file...", 2);
#	my $macros_node = $doc->getDocumentElement->getElementsByTagName("macros", 0);
#	if ($macros_node->getLength == 0) {
#		$app->TRACE(text=>"No macro node in configuration, skipping macro load",1);
#		return 0;
#	}
#	my $macros = $macros_node->item(0)->getElementsByTagName("macro", 0);
#	print Dumper $self->{app}->{config};
#	exit;

	my $macros = $self->{app}->{config}->{macros}->{macro};
	return if !$macros;
#	my $n = $macros->getLength;
	
	$app->TRACE(scalar(@$macros) . " macros to import", 3);
	
	foreach my $macro_def (@$macros) {
		#my $macro = $macros->item($i);
		my $group_name = $macro_def->{"group_name"};
		my $package_name = $macro_def->{"package_name"};
		my $file_path = $macro_def->{"file_path"};
		Guido::Application::splash_status("Loading macros..." . $group_name);
		$app->TRACE("Macros: " . $group_name, 3);
		
		
#		if (%INC{$package_name} eq "") {
#			$app->ERROR("Macro package name mismatch",1);
#			next;
#		}
		
		#Add macro to the macro menus

		eval {
			require $file_path;
		};
		
		#If any errors occurred, report them
		if ($@) {
			$app->ERROR(
				title	=>"Macro Init Error",
				text	=>"Initialization of macro group $group_name failed: $@\n",
			);
		}
		else {
			my $namespace = $package_name . '::';
			my @subs;
			no strict 'refs';
			foreach my $sym (values %{$namespace}) {
				if (defined(&$sym)) {
					my($sub_name) = $sym =~ /\*$namespace(.+)/;
					push(@subs, $sub_name) ;
				}
			}
			$app->TRACE("Subroutines found: " . join("\n", @subs, ), 1);
			my $main_menu = $app->{menu};
			my $macro_menu;
			eval {
				$macro_menu = $main_menu->entrycget('Macros', '-menu');
			};
			if (!$macro_menu) {
				$app->TRACE("Couldn't find Macros menu.  Macro loading halted.", 1);
				return 0;
			}
			my $group_menu = $macro_menu->Menu();
			$macro_menu->insert('end', 'cascade', 
				-label=>$group_name, 
				-menu=>$group_menu,
			);
			
			if(!$group_menu) {
				$app->ERROR(title=>"Group menu add failure", text=>"Couldn't add menu item for macro group $group_name.  Macro loading halted.");
				return 0;
			}
			
			foreach my $sub (@subs) {
				my $macro_item = $group_menu->insert('end', 'command',
					-label=>$sub,
					-command=> [\&{"$namespace$sub"}, $app],
				);
			}
		}
	}

#	$doc->dispose();
	return 1;
}


1;

