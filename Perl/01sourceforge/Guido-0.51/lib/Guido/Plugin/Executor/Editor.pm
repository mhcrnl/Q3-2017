package Guido::Plugin::Executor::Editor;

use Tk;
use Tk::NoteBook; #Creates tabbed pages
use Guido::PropertyPageDialog;
use Data::Dumper;
use base qw(Tk::Frame);
use Tk::widgets qw(LabEntry HList Frame);

Construct Tk::Widget 'Editor';

sub Populate {
	my ($cw, $args) = @_;

	$cw->{_config_} = delete $args->{-config};

	my $w = $cw->NoteBook()->pack(-expand=>1,-fill=>'both');
	
	my $frm_mimetypes = $w->add(
		"mimetypes", 
		-label=>"Mime Types"
	);
	
	my $hl_mimetypes = $frm_mimetypes->Scrolled(
			'HList',
			-header=>1,
			-columns=>2,
			-scrollbars=>'osoe',
			-selectbackground=> 'SeaGreen3',
		)->pack(
			-anchor=>'nw',
			-expand=>1,
			-fill=>'both',
	);
	
	$cw->Advertise('hl_mimetypes' => $hl_mimetypes);
	
	$hl_mimetypes->header('create', 0, -text=> 'Extension');
	$hl_mimetypes->header('create', 1, -text=> 'Mime Type');
	
	my $frm_typebuttons = $frm_mimetypes->Frame()->pack(-side=>'bottom');
	
	my $btn_add = $frm_typebuttons->Button(
		-text=>'Add', 
		-command=>[\&_e_add_mimetype, $cw],
	)->pack(-side=>'left');
	
	my $btn_rmv = $frm_typebuttons->Button(
		-text=>'Remove Selected', 
		-command=>[\&_e_remove_mimetype, $cw],
	)->pack(-side=>'left');
	
	##
	#Mime handlers editor
	##
	
	my $frm_mimehandlers = $w->add(
		"mimehandlers", 
		-label=>"Mime Handlers"
	);
	
	my $hl_mimehandlers = $frm_mimehandlers->Scrolled(
			'HList',
			-header=>1,
			-columns=>2,
			-scrollbars=>'osoe',
			-selectbackground=> 'SeaGreen3',
		)->pack(
			-anchor=>'nw',
			-expand=>1,
			-fill=>'both',
	);

	$cw->Advertise('hl_mimehandlers' => $hl_mimehandlers);

	
	$hl_mimehandlers->header('create', 0, -text=> 'Mime Type');
	$hl_mimehandlers->header('create', 1, -text=> 'Program Path');
	$hl_mimehandlers->header('create', 1, -text=> 'Program Path');
	
	my $frm_handlerbuttons = $frm_mimehandlers->Frame()->pack(-side=>'bottom');
	
	my $btn_add_handler = $frm_handlerbuttons->Button(
		-text=>'Add', 
		-command=>[\&_e_add_mimehandler, $cw],
	)->pack(-side=>'left');
	
	my $btn_rmv_handler = $frm_handlerbuttons->Button(
		-text=>'Remove Selected', 
		-command=>[\&_e_remove_mimehandler, $cw],
	)->pack(-side=>'left');
	
	$cw->_refresh_mimetypes();
	$cw->_refresh_mimehandlers();
}

sub _refresh_mimetypes {
	my($cw) = @_;
	my $hl_mimetypes = $cw->Subwidget("hl_mimetypes");
	my $config = $cw->{_config_};
	#print Dumper $config;
	
	$hl_mimetypes->delete('all');
	my $i = 0;
	my $mime_list = $config->{plugindata}->{Executor}->{mimemaps}->{mimemap};
	my $mimetypes = {};
	foreach my $mimetype (@$mime_list) {
		$mimetypes->{$mimetype->{suffix}} = $mimetype->{mimetype};
	}
	
	
	foreach my $suffix (sort keys %$mimetypes) {
		$hl_mimetypes->add($i);
		
		$hl_mimetypes->itemCreate($i, 0, -text=>$suffix);
		$hl_mimetypes->itemCreate($i, 1, -text=>$mimetypes->{$suffix});
		++$i;
	}
}

sub _refresh_mimehandlers {
	my($cw) = @_;
	my $hlist = $cw->Subwidget("hl_mimehandlers");
	my $config = $cw->{_config_};
	#print Dumper $config;
	
	$hlist->delete('all');
	my $i = 0;
	my $list = $config->{plugindata}->{Executor}->{mimehandlers}->{mimehandler};
	my $items = {};
	foreach my $item (@$list) {
		$items->{$item->{mimetype}} = $item->{path};
	}
	
	
	foreach my $item (sort keys %$items) {
		$hlist->add($i);
		$hlist->itemCreate($i, 0, -text=>$item);
		$hlist->itemCreate($i, 1, -text=>$items->{$item});
		++$i;
	}
}


sub _e_add_mimetype {
	my($cw) = @_;
	my $config = $cw->{_config_};
	
	my $name_dialog = $cw->DialogBox(
		-title=>"Enter mime-type information",
		-buttons=>['Ok', 'Cancel'],
	);
	
	my ($mimetype, $suffix);

	my $lab_mimetype = $name_dialog->add(
		'Label',
		-text=>'Mime-Type Name',
	)->grid(-row=>0, -col=>0);
	my $ety_mimetype = $name_dialog->add(
		'Entry',
		-textvariable=>\$mimetype,
	)->grid(-row=>0, -col=>1);

	my $lab_suffix = $name_dialog->add(
		'Label',
		-text=>'File Suffix',
	)->grid(-row=>1, -col=>0);
	my $ety_suffix = $name_dialog->add(
		'Entry',
		-textvariable=>\$suffix,
	)->grid(-row=>1, -col=>1);
		
	my $response = $name_dialog->Show();
	
	return if $response eq 'Cancel';
	
	$suffix = ".$suffix" if $suffix !~ /^\./;
	
	my $existing_types = $config->{plugindata}->{Executor}->{mimemaps}->{mimemap};
	my $already_exists = 0;
	
	foreach my $existing_type (@$existing_types) {
		if ($existing_type->{suffix} eq $suffix) {
			$already_exists = 1
		}
	}

	if ($already_exists) {
		$cw->Dialog(
			-title=>"Mime-Type Already Exists",
			-text=>"This mime-type already exists in the configuration, please remove the current definition before trying to add a new one.",
			-buttons => ['OK'],
			-default_button => 'OK',
		)->Show();

		return;
	}
	else {	
		push(@{$config->{plugindata}->{Executor}->{mimemaps}->{mimemap}}, 
			{
				mimetype => $mimetype,
				suffix => $suffix,
			}
		);
		$cw->_refresh_mimetypes();
	}
}

sub _e_remove_mimetype {
	my($cw) = @_;
	my $hlist = $cw->Subwidget("hl_mimetypes");
	my $config = $cw->{_config_};
	my $current_items = $config->{plugindata}->{Executor}->{mimemaps}->{mimemap};
#	print Dumper $current_items;
	
	my $current_row = $hlist->info('selection');
#	print "$current_row\n";
	return if !defined($current_row);
	
	my $remove_name = $hlist->itemCget($current_row, 0, '-text');
#	print "$remove_name\n";
	return if !$remove_name;
	
	my @keep = ();
	foreach my $current_item (@$current_items) {
#		print $current_item->{suffix} . ":" . $remove_name . "\n";
		unless ($current_item->{suffix} eq $remove_name) {
#			print "pushed\n";
			push(@keep, $current_item);
		}
	}
	@$current_items = @keep;
	$cw->_refresh_mimetypes();	
}

sub _e_add_mimehandler {
	my($cw) = @_;
	my $config = $cw->{_config_};
	
	my $name_dialog = $cw->DialogBox(
		-title=>"Enter mime-handler information",
		-buttons=>['Ok', 'Cancel'],
	);
	
	my ($mimetype, $path);
	my $existing_types = $config->{plugindata}->{Executor}->{mimemaps}->{mimemap};
	my $existing_handlers = $config->{plugindata}->{Executor}->{mimehandlers}->{mimehandler};

	my $lab_mimetype = $name_dialog->add(
		'Label',
		-text=>'Mime-Type Name',
	)->grid(-row=>0, -col=>0);
	my $bty_mimetype = $name_dialog->add(
		'BrowseEntry',
		-variable=>\$mimetype,
		-state=>'readonly',
	)->grid(-row=>0, -col=>1);
	
	foreach my $existing_type (@$existing_types) {
		$bty_mimetype->insert('end', $existing_type->{mimetype});
	}

	my $lab_path = $name_dialog->add(
		'Label',
		-text=>'Path to Executible',
	)->grid(-row=>1, -col=>0);
	my $ety_path = $name_dialog->add(
		'Entry',
		-textvariable=>\$path,
	)->grid(-row=>1, -col=>1);
		
	my $response = $name_dialog->Show();
	
	return if $response eq 'Cancel';
	
	#Check for pre-existing instance of this mime-type in config
	my $already_exists = 0;
	foreach my $existing_handlers (@$existing_handlers) {
		if ($existing_handlers->{mimetype} eq $mimetype) {
			$already_exists = 1
		}
	}

	if ($already_exists) {
		$cw->Dialog(
			-title=>"Mime-Type Already Exists",
			-text=>"This mime-type already has a handler defined in the configuration, please remove the current definition before trying to add a new one.",
			-buttons => ['OK'],
			-default_button => 'OK',
		)->Show();

		return;
	}
	else {	
		push(@{$config->{plugindata}->{Executor}->{mimehandlers}->{mimehandler}}, 
			{
				mimetype => $mimetype,
				path => $path,
			}
		);
		$cw->_refresh_mimehandlers();
	}
}

sub _e_remove_mimehandler {
	my($cw) = @_;
	my $hlist = $cw->Subwidget("hl_mimehandlers");
	my $config = $cw->{_config_};
	my $current_items = $config->{plugindata}->{Executor}->{mimehandlers}->{mimehandler};
	
	my $current_row = $hlist->info('selection');
	return if !defined($current_row);
	
	my $remove_name = $hlist->itemCget($current_row, 0, '-text');
	return if !$remove_name;
	
	my @keep = ();
	foreach my $current_item (@$current_items) {
		unless ($current_item->{mimetype} eq $remove_name) {
			push(@keep, $current_item);
		}
	}
	@$current_items = @keep;
	$cw->_refresh_mimehandlers();	
}


1;

