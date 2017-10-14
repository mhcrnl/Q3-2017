package Guido::SourceFile::TkComposite::Mapper;
use strict;
use vars qw/ @ISA /;
use Tk;
use Tk::NoteBook; #Creates tabbed pages
use Guido::PropertyPageDialog;
use Guido::SourceFile::TkComposite::DelegateProperty;
use Guido::SourceFile::TkComposite::DelegateMethod;
use Data::Dumper;
use Tk::DialogBox;
@ISA = qw(Tk::DialogBox);
use Tk::widgets qw(LabEntry HList Frame);

Construct Tk::Widget 'Mapper';

sub Populate {
	my ($cw, $args) = @_;

	$cw->{_object_} = delete $args->{-object};
	$args->{-title} = "Delegates for " . $cw->{_object_}->name;
	$args->{-buttons} = ['Done'];
	$cw->SUPER::Populate($args);
	my $w = $cw->NoteBook()->pack(-expand=>1,-fill=>'both');
	
	my $frm_properties = $w->add(
		"properties", 
		-label=>"Delegate Properties"
	);
	
	my $hl_properties = $frm_properties->Scrolled(
			'HList',
			-header=>1,
			-columns=>5,
			-scrollbars=>'osoe',
			-selectbackground=> 'SeaGreen3',
		)->pack(
			-anchor=>'nw',
			-expand=>1,
			-fill=>'both',
	);
	
	$cw->Advertise('hl_properties' => $hl_properties);
	
	$hl_properties->header('create', 0, -text => 'Name');
	$hl_properties->header('create', 1, -text => 'Apply-To');
	$hl_properties->header('create', 2, -text => 'DBName');
	$hl_properties->header('create', 3, -text => 'DBClass');
	$hl_properties->header('create', 4, -text => 'Default');
	
	##
	#Property maps editor
	##

	my $frm_propbuttons = $frm_properties->Frame()->pack(-side=>'bottom');
	
	my $btn_add = $frm_propbuttons->Button(
		-text=>'Add', 
		-command=>[\&_e_add_property, $cw],
	)->pack(-side=>'left');
	
	my $btn_rmv = $frm_propbuttons->Button(
		-text=>'Remove Selected', 
		-command=>[\&_e_remove_property, $cw],
	)->pack(-side=>'left');
	
	##
	#Method maps editor
	##
	
	my $frm_methods = $w->add(
		"methods", 
		-label=>"Delegate Methods"
	);
	
	my $hl_methods = $frm_methods->Scrolled(
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

	$cw->Advertise('hl_methods' => $hl_methods);

	
	$hl_methods->header('create', 0, -text=> 'Method');
	$hl_methods->header('create', 1, -text=> 'Widget');

	
	my $frm_methbuttons = $frm_methods->Frame()->pack(-side=>'bottom');
	
	my $btn_add_method = $frm_methbuttons->Button(
		-text=>'Add', 
		-command=>[\&_e_add_method, $cw],
	)->pack(-side=>'left');
	
	my $btn_rmv_method = $frm_methbuttons->Button(
		-text=>'Remove Selected', 
		-command=>[\&_e_remove_method, $cw],
	)->pack(-side=>'left');

	$cw->_refresh_properties();
	$cw->_refresh_methods();
}

sub _refresh_properties {
	my($cw) = @_;
	my $hl_properties = $cw->Subwidget("hl_properties");
	my $object = $cw->{_object_};
	
	$hl_properties->delete('all');
	my $i = 0;
	my @properties = @{$cw->{_object_}->delegate_properties};
	foreach my $dprop (@properties)  {
	  $hl_properties->add($i);
	  $hl_properties->itemCreate($i, 0, -text=>$dprop->name);
	  $hl_properties->itemCreate($i, 1, -text=>$dprop->target);
	  $hl_properties->itemCreate($i, 2, -text=>$dprop->dbname);
	  $hl_properties->itemCreate($i, 3, -text=>$dprop->dbclass);
	  $hl_properties->itemCreate($i, 4, -text=>$dprop->default);
	  ++$i;
	}
}

###################
sub _refresh_methods {
	my($cw) = @_;
	my $hl_methods = $cw->Subwidget("hl_methods");
	
	$hl_methods->delete('all');
	my $i = 0;
	my @methods = @{$cw->{_object_}->delegate_methods};
	foreach my $dmeth (@methods)  {
	  $hl_methods->add($i);
	  $hl_methods->itemCreate($i, 0, -text=>$dmeth->name);
	  $hl_methods->itemCreate($i, 1, -text=>$dmeth->target);
	  ++$i;
	}
}


sub _e_add_property {
	my($cw) = @_;
	
	my $name_dialog = $cw->DialogBox(
		-title=>"Enter Delegate Property Information",
		-buttons=>['Ok', 'Cancel'],
	);
	
	my ($name, $target, $dbname, $dbclass, $default);

	my $lab_name = $name_dialog->add(
		'Label',
		-text=>'Name',
	)->grid(-row=>0, -col=>0);
	my $ety_name = $name_dialog->add(
		'Entry',
		-textvariable=>\$name,
	)->grid(-row=>0, -col=>1);

	my $lab_target = $name_dialog->add(
		'Label',
		-text=>'Target',
	)->grid(-row=>1, -col=>0);
	my $ety_target = $name_dialog->add(
		'Entry',
		-textvariable=>\$target,
	)->grid(-row=>1, -col=>1);

	my $lab_dbname = $name_dialog->add(
		'Label',
		-text=>'DBName',
	)->grid(-row=>2, -col=>0);
	my $ety_dbname = $name_dialog->add(
		'Entry',
		-textvariable=>\$dbname,
	)->grid(-row=>2, -col=>1);

	my $lab_dbclass = $name_dialog->add(
		'Label',
		-text=>'DBClass',
	)->grid(-row=>3, -col=>0);
	my $ety_dbclass = $name_dialog->add(
		'Entry',
		-textvariable=>\$dbclass,
	)->grid(-row=>3, -col=>1);

	my $lab_default = $name_dialog->add(
		'Label',
		-text=>'Default',
	)->grid(-row=>4, -col=>0);
	my $ety_default = $name_dialog->add(
		'Entry',
		-textvariable=>\$default,
	)->grid(-row=>4, -col=>1);

		
	my $response = $name_dialog->Show();
	
	return if $response eq 'Cancel';
	
	my $existing_props = $cw->{_object_}->delegate_properties;
	my $already_exists = 0;
	
	foreach my $existing_prop (@$existing_props) {
		if ($existing_prop->name eq $name) {
			$already_exists = 1;
		}
	}

	if ($already_exists) {
		$cw->Dialog(
			-title=>"Delegate Property Already Exists",
			-text=>"This delegate property already exists in the configuration, please remove the current definition before trying to add a new one.",
			-buttons => ['OK'],
			-default_button => 'OK',
		)->Show();

		return;
	}
	else {	
		push(@{$cw->{_object_}->delegate_properties}, 
		     new Guido::SourceFile::TkComposite::DelegateProperty(
				name => $name,
				target => $target,
				dbname => $dbname,
                                dbclass => $dbclass,
                                default => $default,
		     )
		);
		$cw->_refresh_properties();
	}
}

sub _e_remove_property {
	my($cw) = @_;
	my $hlist = $cw->Subwidget("hl_properties");
	my $current_items = $cw->{_object_}->delegate_properties;
	my $current_row = $hlist->info('selection');
	return if !defined($current_row);
	
	my $remove_name = $hlist->itemCget($current_row, 0, '-text');
	return if !$remove_name;
	
	my @keep = ();
	foreach my $current_item (@$current_items) {
		unless ($current_item->name eq $remove_name) {
			push(@keep, $current_item);
		      }
		
	}
	$cw->{_object_}->{delegate_properties} = \@keep;
	$cw->_refresh_properties();	
}

sub _e_add_method {
	my($cw) = @_;
	my $object = $cw->{_object_};
	my $name_dialog = $cw->DialogBox(
		-title=>"Enter Delegate Method Information",
		-buttons=>['Ok', 'Cancel'],
	);
	
	my ($method_name, $target);

	my $lab_method_name = $name_dialog->add(
		'Label',
		-text=>'Method Name',
	)->grid(-row=>0, -col=>0);
	my $ety_method_name = $name_dialog->add(
		'Entry',
		-textvariable=>\$method_name,
#		-state=>'readonly',
	)->grid(-row=>0, -col=>1);
	
#	foreach my $existing_type (@$existing_types) {
#		$bty_mimetype->insert('end', $existing_type->{mimetype});
#	}

	my $lab_target = $name_dialog->add(
		'Label',
		-text=>'Target Widget',
	)->grid(-row=>1, -col=>0);
	my $ety_target = $name_dialog->add(
		'Entry',
		-textvariable=>\$target,
	)->grid(-row=>1, -col=>1);
		
	my $response = $name_dialog->Show();
	
	return if $response eq 'Cancel';
	
	#Check for pre-existing instance of this method name
	my $already_exists = 0;
	foreach my $method (@{$object->delegate_methods}) {
		if ($method->{name} eq $method_name) {
			$already_exists = 1
		}
	}

	if ($already_exists) {
		$cw->Dialog(
			-title=>"Delegate Method Already Exists",
			-text=>"This method already has a target defined in the configuration, please remove the current definition before trying to add a new one.",
			-buttons => ['OK'],
			-default_button => 'OK',
		)->Show();

		return;
	}
	else {	
		push(@{$object->{delegate_methods}}, 
			new Guido::SourceFile::TkComposite::DelegateMethod(
				name => $method_name,
				target => $target,
			)
		);
		$cw->_refresh_methods();
	}
}

sub _e_remove_method {
	my($cw) = @_;
	my $hlist = $cw->Subwidget("hl_methods");
	my $current_items = $cw->{_object_}->delegate_methods;
	my $current_row = $hlist->info('selection');
	return if !defined($current_row);
	
	my $remove_name = $hlist->itemCget($current_row, 0, '-text');
	return if !$remove_name;
	
	my @keep = ();
	foreach my $current_item (@$current_items) {
		unless ($current_item->name eq $remove_name) {
			push(@keep, $current_item);
		      }
		
	}
	$cw->{_object_}->{delegate_methods} = \@keep;
	$cw->_refresh_methods();	
}

sub Show {
	my($cw, $grab) = @_;
	$cw->withdraw;
	$cw->geometry('500x400');
	my $btn = $cw->SUPER::Show($grab);
	if ($btn eq 'Accept') {
		return 1;
	}
	else {
		return 0;
	}
}

sub Cancel {
	my($cw) = @_;
}

1;

