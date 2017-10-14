# MODINFO module Guido::ConfigDialog
package Guido::ConfigDialog;
# MODINFO dependency module strict
use strict;

# MODINFO dependency module Tk
use Tk;
# MODINFO dependency module Tk::NoteBook
use Tk::NoteBook; #Creates tabbed pages
# MODINFO dependency module Tk::DialogBox
use Tk::DialogBox;
# MODINFO dependency module Guido::PropertyPageDialog
use Guido::PropertyPageDialog;
# MODINFO dependency module Data::Dumper
use Data::Dumper;

# MODINFO dependency module vars
use vars qw( @ISA );
# MODINFO dependency module Tk::DialogBox
use Tk::DialogBox;
# MODINFO parent_class Tk::DialogBox
@ISA = qw( Tk::DialogBox );

#use base qw(Tk::DialogBox);

# MODINFO dependency module Tk::widgets
use Tk::widgets qw(LabEntry NumEntry Checkbutton HList Frame);

Construct Tk::Widget 'ConfigDialog';

my $app;


# MODINFO function Populate  Called by TK to initialize the dialog
# MODINFO paramhash args
# MODINFO key       -config Configuration data structure to use
# MODINFO key       -app    Reference to Application object
sub Populate {

	my ($cw, $args) = @_;

	$args->{-title} = 'Guido Configuation Options';
	$args->{-buttons} = ['Accept', 'Cancel'];
	my $config_orig = delete $args->{-config};
	$app = delete $args->{-app};
	
	my $dumper = new Data::Dumper([$config_orig]);
	my $config;
	$dumper->Names(["config"]);
	eval($dumper->Dump());
	$cw->SUPER::Populate($args);
	$cw->{_config_} = $config;
	
	my $w = $cw->add('NoteBook')->pack(-expand=>1, -fill=>'both');
	
	##
	#General options
	##
	
	#Create general page
	my $general_page = $w->add(
		"general", 
		-label=>"General"
	);
	
	#Startup geo
	$general_page->LabEntry(
		-textvariable=>\$config->{startup}->{geometry},
		-label=>"Startup Geometry",
		-labelPack=>[-side=>'left'],
	)->pack();
	
	##
	#Memory settings
	##
	
	my $memory_page = $w->add(
		"memory",
		-label=>"Memory",
	);
	
	my $memory_frame = $memory_page->Frame()->pack();
	
	#Max MRU list
	my $mru_frame = $memory_frame->Frame()->grid(-col=>0,-row=>0);
	my $mru_lbl = $mru_frame->Label(
		-text => 'Max Recent Files',
	)->pack(-side=>'left');
	my $mru = $mru_frame->NumEntry(
		-minvalue=>0,
		-maxvalue=>15,
		-textvariable=>\$config->{max_mru},
		-width=>2,
	)->pack(-side=>'left');
	
	
	#Remember last geo
	my $last_geo = $memory_frame->Checkbutton(
		-variable=>\$config->{startup}->{remember_last_geo},
		-text=>'Remember last geometry',
	)->grid(-col=>0,-row=>1);
	
	#Remember last project(s)
	my $last_project = $memory_frame->Checkbutton(
		-variable=>\$config->{startup}->{load_last_project},
		-text=>'Remember last project(s)',
	)->grid(-col=>0,-row=>2);
	
	##
	#Plugins settings
	##
	my $plugins_page = $w->add(
		"plugins",
		-label=>"Plugins",
	);
	
	my $hl_plugins = $plugins_page->Scrolled(
			'HList',
			-header=>1,
			-columns=>4,
			-scrollbars=>'osoe',
			-selectbackground=> 'SeaGreen3',
		)->pack(
			-anchor=>'nw',
			-expand=>1,
			-fill=>'both',
	);
	
	$cw->{hl_plugins} = $hl_plugins;
	
	$hl_plugins->header('create', 0, -text=> 'Hide');
	$hl_plugins->header('create', 1, -text=> 'Class Name');
	$hl_plugins->header('create', 2, -text=> 'Display Name');
	$hl_plugins->header('create', 3, -text=> 'Pack Settings');
	
	my $frm_buttons = $plugins_page->Frame()->pack(-side=>'bottom');
	
	my $btn_add_plugin = $frm_buttons->Button(
		-text=>'Add', 
		-command=>[\&_e_add_plugin, $cw],
	)->pack(-side=>'left');
	
	my $btn_rmv_plugin = $frm_buttons->Button(
		-text=>'Remove Selected', 
		-command=>[\&_e_remove_plugin, $cw],
	)->pack(-side=>'left');
		
	$cw->_refresh_plugin_list();

	##
	#Macro settings
	##
	my $macros_page = $w->add(
		"macros",
		-label=>"Macros",
	);

	my $hl_macros = $macros_page->Scrolled(
			'HList',
			-header=>1,
			-columns=>3,
			-scrollbars=>'osoe',
			-selectbackground=> 'SeaGreen3',
		)->pack(
			-anchor=>'nw',
			-expand=>1,
			-fill=>'both',
	);
	
	$cw->{hl_macros} = $hl_macros;
	
	$hl_macros->header('create', 0, -text=> 'Group Name');
	$hl_macros->header('create', 1, -text=> 'Package Name');
	$hl_macros->header('create', 2, -text=> 'File Path');
	
	my $frm_macro_buttons = $macros_page->Frame()->pack(-side=>'bottom');
	
	my $btn_add_macro = $frm_macro_buttons->Button(
		-text=>'Add', 
		-command=>[\&_e_add_macro, $cw],
	)->pack(-side=>'left');
	
	my $btn_rmv_macro = $frm_macro_buttons->Button(
		-text=>'Remove Selected', 
		-command=>[\&_e_remove_macro, $cw],
	)->pack(-side=>'left');
	
	
	$cw->_refresh_macro_list();


	foreach my $plugin (keys %{$app->{plugins}}) {
		my $plugin_ref = $app->{plugins}->{$plugin};
		next unless $plugin_ref->can("editor");
		my $config_page = $w->add(
			$plugin,
			-label=>$plugin,
		);
		my $config = $plugin_ref->editor(
			$config_page, 
			$cw->{_config_}
		)->pack(
			-expand=>1,
			-fill=>'both',
		);
	}

}

# MODINFO function Show Displays the dialog
# MODINFO param grab Type of grab to take (see Tk docs)
# MODINFO retval HASHREF
sub Show {
	my($cw, $grab) = @_;
	$cw->withdraw;
	$cw->geometry('500x400');
	my $btn = $cw->SUPER::Show($grab);
	if ($btn eq 'Accept') {
		return $cw->{_config_};
	}
	else {
		return undef;
	}
}

# MODINFO function Cancel Cancels the dialog box
sub Cancel {
	my($cw) = @_;
}

sub _e_add_plugin {
	my($cw) = @_;
	my $config = $cw->{_config_};
	
	my $name_dialog = $cw->DialogBox(
		-title=>"Enter plugin information",
		-buttons=>['Ok', 'Cancel'],
	);
	
	my ($package_name, $display_name);

	my $lab_package = $name_dialog->add(
		'Label',
		-text=>'Perl package name',
	)->grid(-row=>0, -col=>0);
	my $ety_package = $name_dialog->add(
		'Entry',
		-textvariable=>\$package_name,
	)->grid(-row=>0, -col=>1);

	my $lab_display_pkg_name = $name_dialog->add(
		'Label',
		-text=>'Display name',
	)->grid(-row=>1, -col=>0);
	my $ety_display = $name_dialog->add(
		'Entry',
		-textvariable=>\$display_name,
	)->grid(-row=>1, -col=>1);
		
	my $response = $name_dialog->Show();
	
	return if $response eq 'Cancel';
	
	push(@{$config->{plugins}->{plugin}}, 
		{
			class_name => $package_name,
			plugin_name => $display_name,
			pack => '',
		}
	);
	$cw->_refresh_plugin_list();
}

sub _e_remove_plugin {
	my($cw) = @_;
	my $hl_plugins = $cw->{hl_plugins};
	my $config = $cw->{_config_};
	
	my $plugin_row = $hl_plugins->info('selection');
	my $plugin_name = $hl_plugins->itemCget($plugin_row, 1, '-text');
	return if $plugin_name eq "";
	my @keep = ();
	while (my $plugin = shift @{$config->{plugins}->{plugin}}) {
		push(@keep, $plugin) unless $plugin->{class_name} eq $plugin_name;
	}
	$config->{plugins}->{plugin} = \@keep;
	$cw->_refresh_plugin_list();
}

sub _e_set_packinfo {
	my($cw, $plugin_name, $packinfo) = @_;
	my $pdlg_packinfo = $cw->PropertyPageDialog(
		-title=>"Pack Info for $plugin_name",
		-append_props=>$packinfo,
	);
	my $new_packinfo = $pdlg_packinfo->Show();
	return if !$new_packinfo;
}

sub _refresh_plugin_list {
	my($cw) = @_;
	my $hl_plugins = $cw->{hl_plugins};
	my $config = $cw->{_config_};
	
	$hl_plugins->delete('all');
	my $i = 0;
	my $plugin_list = $config->{plugins}->{plugin};
	my $plugins = {};
	foreach my $plugin (@$plugin_list) {
		$plugins->{$plugin->{class_name}} = $plugin;
	}
	
	
	foreach my $plugin_name (sort keys %$plugins) {
		$hl_plugins->add($i);
		my $ckb_display = $hl_plugins->Checkbutton(
			-variable=>\$plugins->{$plugin_name}->{no_display},
			-height=>1, 
			-width=>1, 
			-padx=>0, 
			-pady=>0,
		);
		
		#my $packstring = $plugins->{$plugin_name}->{'pack'};
		#my %packinfo = split(/[;=]/, $packstring);
		#if (!%packinfo) {
		#	%packinfo = $app->plugins($plugin_name)->packInfo();
		#}
		#my $btn_packinfo = $hl_plugins->Button(
		#	-command=>[\&_e_set_packinfo, $cw, $plugin_name, \%packinfo],
		#	-text=> '...',
		#);
		my $ety_packinfo = $hl_plugins->Entry(
			-textvariable=>\$plugins->{$plugin_name}->{'pack'},
		);

		# If the plugin's display method returns 0, we select the
		#  'hide' option automatically, disable the checkbox,
		#  blank out the packinfo text and disable it, too
		if(!$app->plugins($plugin_name)->display()) {
		    $plugins->{$plugin_name}->{no_display} = 1;
		    $plugins->{$plugin_name}->{pack} = '';
		    $ckb_display->configure(-state=>'disabled');
		    $ety_packinfo->configure(-state=>'disabled');
		}
		
		$hl_plugins->itemCreate($i, 0, -itemtype=>"window", -window=>$ckb_display);	
		$hl_plugins->itemCreate($i, 1, -text=>$plugin_name);
		$hl_plugins->itemCreate($i, 2, -text=>$plugins->{$plugin_name}->{plugin_name});
		$hl_plugins->itemCreate($i, 3, -itemtype=>"window", -window=>$ety_packinfo);
		++$i;
	}
}


sub _e_add_macro {
	my($cw) = @_;
	my $config = $cw->{_config_};
	
	my $name_dialog = $cw->DialogBox(
		-title=>"Enter macro information",
		-buttons=>['Ok', 'Cancel'],
	);
	
	my ($package_name, $display_name, $file_path);

	my $lab_package = $name_dialog->add(
		'Label',
		-text=>'Perl package name',
	)->grid(-row=>0, -col=>0);
	my $ety_package = $name_dialog->add(
		'Entry',
		-textvariable=>\$package_name,
	)->grid(-row=>0, -col=>1);

	my $lab_display_name = $name_dialog->add(
		'Label',
		-text=>'Display name',
	)->grid(-row=>1, -col=>0);
	my $ety_display_name = $name_dialog->add(
		'Entry',
		-textvariable=>\$display_name,
	)->grid(-row=>1, -col=>1);

	my $lab_display_path = $name_dialog->add(
		'Label',
		-text=>'File path',
	)->grid(-row=>2, -col=>0);
	my $ety_display_path = $name_dialog->add(
		'Entry',
		-textvariable=>\$file_path,
	)->grid(-row=>2, -col=>1);

		
	my $response = $name_dialog->Show();
	
	return if $response eq 'Cancel';
	
	push(@{$config->{macros}->{macro}}, 
		{
			package_name => $package_name,
			group_name => $display_name,
			file_path => $file_path,
		}
	);
	$cw->_refresh_macro_list();
}

sub _e_remove_macro {
	my($cw) = @_;
	my $hl_macros = $cw->{hl_macros};
	my $config = $cw->{_config_};
	
	my $macro_row = $hl_macros->info('selection');
	print "Macro row is: $macro_row\n";
	return unless defined($macro_row);
	my $macro_name = $hl_macros->itemCget($macro_row, 1, '-text');
	print "Macro name is $macro_name\n";
	return if $macro_name eq "";
	my @keep = ();
	while (my $macro = shift @{$config->{macros}->{macro}}) {
		push(@keep, $macro) unless $macro->{package_name} eq $macro_name;
	}
	$config->{macros}->{macros} = \@keep;
	$cw->_refresh_macro_list();
}

sub _refresh_macro_list {
	my($cw) = @_;
	my $hl_macros = $cw->{hl_macros};
	my $config = $cw->{_config_};
	
	$hl_macros->delete('all');
	my $i = 0;
	my $macro_list = $config->{macros}->{macro};
	my $macros = {};
	foreach my $macro (@$macro_list) {
		$macros->{$macro->{package_name}} = $macro;
	}
	
	
	foreach my $macro_name (sort keys %$macros) {
		$hl_macros->add($i);
#		my $ety_packinfo = $hl_macros->Entry(
#			-textvariable=>\$macros->{$macro_name}->{'pack'},
#		);
		$hl_macros->itemCreate($i, 0, -text=>$macros->{$macro_name}->{group_name});
		$hl_macros->itemCreate($i, 1, -text=>$macros->{$macro_name}->{package_name});
		$hl_macros->itemCreate($i, 2, -text=>$macros->{$macro_name}->{file_path});
		++$i;
	}
}

1;
__END__

=head1 NAME

Guido::ConfigDialog - Provides a GUI interface for editing the Guido configuration data structure.

=head1 SYNOPSIS

  my $conf = $self->{mw}->ConfigDialog(-app=>$self, -config=>$orig_config);
  my $new_config = $conf->Show();

=head1 DESCRIPTION

Guido::ConfigDialog is a Tk dialog box for editing the Guido configuration data structure.

=head1 INTERFACE

=head2 Parent Classes

=over 4


=item Tk::DialogBox

=back









=head2 Functions



=over 4



=item sub Populate returns [VOID]

=over 4

=item args as HASH

=over 4

=item -config as Configuration

=item -app as Reference

=back

=back

Called by TK to initialize the dialog


=item sub Show returns [HASHREF]

=over 4

=item grab as Type

=back

Displays the dialog


=item sub Cancel returns [VOID]

Cancels the dialog box



=back





=head2 Dependencies

=over 4

=item module strict

=item module Tk

=item module Tk::NoteBook

=item module Tk::DialogBox

=item module Guido::PropertyPageDialog

=item module Data::Dumper

=item module vars

=item module Tk::DialogBox

=item module Tk::widgets
=back


=head1 KNOWN ISSUES

Known issues should be listed here

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut
