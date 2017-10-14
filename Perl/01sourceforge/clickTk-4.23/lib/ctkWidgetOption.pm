#!/usr/lib/perl
##              -w -d:ptkdb

=pod

=head1 ctkWidgetOption

	This class models the options of a widget.

=head2 Programming notes

=over

=item Base class

	ctkParser

=item Class member

	$debug

=item Data member

	See base class

=back

=head2 Maintenance

	Author:	MARCO
	Date:	01.01.2007
	History
			05.12.2007 refactoring
			10.09.2008 version 1.02 minor enhancements
			28.10.2008 version 1.03
			07.12.2009 version 1.04
			20.12.2011 version 1.05 P093
			21.02.2012 version 1.06
			22.01.2013 version 1.07

=head2 Methods

=cut

package ctkWidgetOption;

use base (qw/ctkParser/);

our $VERSION = 1.07;

our $debug = 0;

sub new {
	my $class = shift;
	my (%args) = @_;
	$class = ref($class) || $class ;
	## my $self = $class->SUPER::new(%args);
	my $self = {};
	bless  $self, $class;
	$self->_init(%args);

	return $self
}

sub destroy {
	my $self = shift;
	$self->SUPER::destroy(@_);
}

sub _init {
	my $self = shift;
	my (%args) = @_;
	## $self->SUPER::_init(%args);

	return 1
}

=head3 preprocessOptions

	Eliminate positional option for scrolled widgets
	like scrolled('listbox', <options>)

=cut

sub preprocessOptions {
	my $self = shift;
	my ($opt) = @_;
	return $opt unless ($opt);

	$opt =~ s/^\s*\'*[A-Za-z_][A-Za-z0-9_]*\'*\s*,//;
	return $opt
}

=head3 split_opt

	input: options string
	output: array of pairs (-param=>value,-param2=>value2,...)

	input  := (option)
	option := name ',' | '=>' value
	name   := \w+
	value  := [\w\s]+

	output := (name,option)

	Processing

		- eliminate positional option by means of message preprocessOptions,
		- resolve qw/qq constructs by means of message parse_qw_array()
		- parse the string by means of message parseString,
		- convert token list into widget options list using message parseWidgetOptions,
		- return option's list or size of the list
		depending on context.

	Note

		the client code set up and sends message split_opt,
		split_opt sends message parse_qw_array(@w)
		parse_qw_array sends message _split_opt($opt)


=cut

sub _split_opt {
	my $self = shift;
	my ($opt) =  @_ ;
	my @rv;
	&main::trace("_split_opt");
	if ($opt) { 		## must return empty array if no options are passed to
		&main::trace("opt = '$opt'");
		$opt = $self->preprocessOptions($opt);
		@rv = $self->parseString($opt);
		@rv = $self->parseWidgetOptions(@rv);
	} else {
		@rv = ();
	}
	&main::trace('_split_opt rv = '.join(' ',@rv));
	return wantarray ? @rv : scalar(@rv);
}

sub split_opt {
	my $self = shift;
	&main::trace("split_opt");
	my @rv = $self->parse_qw_array(@_);
	return wantarray ? @rv : scalar(@rv);
}

=head3 quotate

	Quotate option's values of the given list.

	Argument

		widget constructor statement

	Return

		string containing the same constructor statement but with quotated values.

	Note

		It calls split_opt to parse the options list.

=cut

sub quotate {
	my $self = shift;
	my ($opt_list) = @_;
	my $rv = '';
	&main::trace("quotate  opt_list = '$opt_list'");

	$opt_list = '' unless(defined $opt_list);

	my ($prefix,$suffix) = $opt_list =~ /^\s*([^\(]*\().*(\)[^\)]*)/;
	$prefix = "'Text'," if($opt_list =~ /^\s*.*Text.\s*,/);
	$prefix = "'Listbox'," if($opt_list =~ /^\s*.Listbox.\s*,/);
	&main::trace("prefix = '$prefix'") if(defined($prefix));
	$opt_list =~ s/^\s*([^\(]*\()//;
	$opt_list =~ s/(\)[^\)]*)//;

	if($opt_list !~ /^\s*$/) {
		my (%opt)=$self->split_opt($opt_list);
		foreach my $k(keys %opt) {
			$opt{$k} = "'$opt{$k}'" unless ($opt{$k} =~ /^\'[^\']*\'$/ ||
						$opt{$k} =~ /^\d+$/ ||
						$opt{$k} =~ /^\[[^\]]+\]$/ ||
						$k =~ /(image|variable|command|cmd|choices)$/);
		}
		$rv =  $prefix. join(', ',map{"$_=>$opt{$_}"} keys %opt) . $suffix;
	} else {$rv = "$prefix$suffix"}
	&main::trace("rv='$rv'");
	return $rv;
}

=head3 validateScrolledclassname

	Validate the given class name

		- is a valid widget class in Tk library
		- class definition exists
		- Scrolled definition exists

	Arguments

		- class name of the widget, i.e. 'TextUndo'

	Returns

		The edited warning message or UNDEF if all
		conditions are met

	Notes

		None.

=cut

sub validateScrolledclassname {
	my $self = shift;
	my ($classname) = @_;
	my $rv ; # don't init to '' !
	my $wl = $main::workWidget;
	my $wlw = $wl->widgets();
	my $sw = ($classname =~ /^Scrolled/) ? $classname : "Scrolled$classname" ;

	$classname =~ s/^Scrolled//;

	# $wl->validateUseName("$classname", './'); ### open item : also scan project library


	unless ($wl->validateUseName("Tk::$classname")) {
				$rv = "'$classname' is not the name of an existing widget class.";
	}
	unless (exists $wlw->{$classname}) {
				$rv .= "\n\nWidget class definition '$classname' doesn't yet exist."
	}
	unless (exists $wlw->{$sw}) {
				$rv .= "\n\nWidget class definition '$sw' doesn't yet exist."
	}
	return $rv;
}

=head3 validate

	This method validates the given options-HASH

		- get rid of empty options,
		- quotate the values by means of quotatY,
		- eval the options to find sytax errors,
		- check some specaial cases like -text and -image,
		- return the discovered errors as a string or
		  UNDEF if none has been found.

	Arguments
		- widget ID
		- ref to option's HASH

	Returns
		- error message as string or UNDEF


=cut

sub validate {
	my $self = shift;
	my ($id,$values) = @_ ;
	my $rv;
	&main::trace("validate id = '$id'");

	my %val = %$values;
	foreach (keys %val) {
		if (defined $val{$_}) {
			delete $val{$_} if ( $val{$_}=~ /^\s*$/)
		} else {
			delete $val{$_}
		}
	}
	my (@opt) = (%val);
	my $type = ctkProject->descriptor->{$id}->type;
	my $o = $self->quotatY(\@opt);

	{
		no strict;
		eval "($o)";
	}
	if ($@) {
		$rv ="syntax error '$@'";
	} elsif (grep (/^-text/,@opt) && grep(/^-image/,@opt)) {
			$rv = "Option '-text' and '-image' are mutually exclusive";
	} elsif(grep(/^-text\s*$/,@opt) && grep(/^-textvariable/,@opt)) {
			$rv = "Option '-text' and '-textvariable' are mutually exclusive";
	} elsif(exists $val{'-scrolledclass'}) {
			my $w = $val{'-scrolledclass'};
			$rv = $self->validateScrolledclassname($w);
	} else {
		main::trace("validation OK.");
	}
	&main::trace("rv='$rv'") if defined $rv;
	return $rv
}

=head3 edit

	Edit the widget's options which are defined
	in the widget class defintion.

	Precondition

		widget must be selected

	Arguments

		ref to parent widget

	Return values

		1      on successful editing
		undef  if no editsing has been performed


=cut

sub edit {
	my $self = shift;
	my ($mw) = @_;
	return undef unless &main::getSelected;
	&main::trace("edit_widgetOptions");

	my $w_attr = main::getW_attr();

	my (%w_geom) = (
		'pack'  => [qw/-side -fill -expand -anchor -ipadx -ipady -padx -pady/],
		'grid'  => [qw/-row -column -rowspan -columnspan -sticky -ipadx -ipady -padx -pady/],
		'place' => [qw/-anchor -height -width -x -y -relheight -relwidth -relx -rely/],
		'form' => [ qw/-top -right -bottom -left -padx -pady -padtop -padbottom -padleft -padright -fill/]
		);

re_enter:
	&main::trace("re_enter");
	my $id=&main::getSelected;
	$id =~ s/.*\.//;

	return undef unless (defined(ctkProject->descriptor->{$id}));
	return undef if ($id eq &main::getMW());
	return undef if (ctkProject->descriptor->{$id}->type eq 'separator');

	my $pr = $w_attr->{ctkProject->descriptor->{$id}->type}->{attr};

	return undef unless (keys %$pr);

	map{&main::trace("pr{'$_'} = '$pr->{$_}'")} keys %$pr;

	my $d = ctkProject->descriptor->{$id};
	my @frm_pack = qw/-side left -fill both -expand 1 -padx 5 -pady 5/;
	my @pl = qw/-side left -padx 5 -pady 5/;

	my $db  = $mw->ctkDialogBox(-title=>"Widget options of '$id'",-buttons=>['Accept','Cancel','Widget doc','Geometry doc']);
	my $fbl = $db->LabFrame(-labelside=>'acrosstop',-label=>'Option\'s information')->pack(-side=>'bottom',-anchor=>'s',-expand => 1, -fill => 'x');
	my $bl  = $fbl->Label(-height=>2,-width=>80,-justify => 'left', -anchor => 'nw',-background => '#EEEEEE')->pack(-side => 'left',-padx => 0, -pady => 0, -expand => 1, -fill => 'x');

	my %val;
	my %lpack;

	if (keys %$pr) {
		my $db_lf = $db->LabFrame(-labelside=>'acrosstop',-label=>"Widget options (".$d->type.')')->pack(@frm_pack);
		my $db_lft = $db_lf->Scrolled('Tiler', -columns => 1, -scrollbars=>'oe')->pack;
		(%val) = &main::split_opt($d->opt);

		if (exists $pr->{'-scrolledclass'}) {
			$val{'-scrolledclass'} = $d->scrolledclass();
		}

		my @optPackRight=(qw/-side right -padx 7/);

		foreach my $k (sort keys %$pr) {
			my $f = $db_lf->Frame();
			$db_lft->Manage( $f );
			my $lab = $f->Label(-text => $k)->pack(-padx=>7,-pady=>5,-side=>'left');
			&main::cnf_dlg_ballon($bl,$lab,$k);
			if ($pr->{$k} eq 'color'){
				$val{$k} = '' unless (exists $val{$k});
				&main::color_Picker($f,'Color',\$val{$k},1);
			} elsif($pr->{$k} eq 'float') {
				$val{$k} = 0 unless (exists $val{$k});
				$f->Button(-text=>'+',-command=>sub{($val{$k})++})->pack(@optPackRight);
				$f->Entry(-textvariable=>\$val{$k},-width=>4)->pack(-side=>'right');
				$f->Button(-text=>'-',-command=>sub{($val{$k})--;})->pack(@optPackRight);
			} elsif($pr->{$k} eq 'int+'){
				$val{$k} = 0 unless (exists $val{$k});
				&ctkNumEntry::numEntry($f,-textvariable=>\$val{$k},-width=>4,-minvalue=>0)->pack(@optPackRight);
			} elsif($pr->{$k} eq 'text') {
				$val{$k} = '' unless (exists $val{$k});
				$val{$k} = $id if (!$val{$k} && $k =~ /^text$/);
				$f->Entry(-textvariable=>\$val{$k})->pack(@optPackRight);
			} elsif($pr->{$k} eq 'text-') {
				$val{$k} = '' unless (exists $val{$k});
				my $wE = $f->Entry(-textvariable=>\$val{$k})->pack(@optPackRight);
			} elsif($pr->{$k} eq 'text+') {
				$val{$k} = '' unless (exists $val{$k});
				my $wE = $f->Entry(-textvariable=>\$val{$k})->pack(@optPackRight);
			} elsif($pr->{$k} eq 'list') {
				my $editList = sub{
					my $hwnd = shift;
					my ($wE,$val,$k) = @_;
					main::log("editList $k");
					my $options = $val->{$k};
					my $w = $hwnd->ctkDlgOptionsList(-title, "$k",
							-buttons, ['OK','Cancel'],
							# -options , $options
							);
					$w->editOptions($options);
					my $answer = $w->Show();
					if ($answer =~/ok/i) {
						$w->onOK($wE);
					} else {}
					$w->destroy();
					};
				$val{$k} = '' unless (exists $val{$k});
				my $wB = $f->Button(-text=>'Edit')->pack(@optPackRight);
				my $wE = $f->Entry(-textvariable=>\$val{$k})->pack(@optPackRight);
				$wB->configure(-command , [$editList,$f,$wE,\%val,$k]);
			} elsif($pr->{$k} eq 'array') {
				use ctkDlgArrayList;
				my $editList = sub{
					my $hwnd = shift;
					my ($wE,$val,$k) = @_;
					main::log("arrayList $k");
					my $options = $val->{$k};
					my $w = $hwnd->ctkDlgArrayList(-title, "$k",
							-buttons, ['OK','Cancel'],
							## -options , $options
							);
					$w->editArray($options);
					my $answer = $w->Show();
					if ($answer =~/ok/i) {
						$w->onOK($wE);
					} else {}
					$w->destroy();
					};
				$val{$k} = '' unless (exists $val{$k});
				my $wB = $f->Button(-text=>'Edit')->pack(@optPackRight);
				my $wE = $f->Entry(-textvariable=>\$val{$k})->pack(@optPackRight);
				$wB->configure(-command , [$editList,$f,$wE,\%val,$k]);
			} elsif($pr->{$k} eq 'file' ) {
				$val{$k} = '' unless (exists $val{$k});
				my $wE = $f->Entry(-textvariable  => \$val{$k},-bg => 'white', -width => 48); ## u MO03604
				my $wV = $val{$k};
				my $wB = $f->Button(-text=>'Browse',
							-command => [sub{
								my $file = shift;
								my $w = &main::imageFileSelect($f,$file);
								if(defined($w)) {
									$wE->delete(0,'end');
									$wE->insert('end',$w);
									$wE->update()
								} ## else {}
								},$wV]
							);
				$wB->pack(@optPackRight);
				$wE->pack(@optPackRight);
				$wE->xview('end');
			} elsif($pr->{$k} eq 'font') {
				$val{$k} = '' unless (exists $val{$k});
				my $wE = $f->Entry(-textvariable  => \$val{$k},-bg => 'white', -width => 32);	## u MO03604
				my $wV = $val{$k};
				my $wB = $f->Button(-text=>'Browse',
							-command => [sub{
								my $self = shift;
								my ($target) = @_;
								my $w = $self->ctkFontDialog(-title => "$ctkTitle - Font options", -gen => 'options',-target => $target);
								},$db,$wE]
								);
				$wB->pack(@optPackRight);
				$wE->pack(@optPackRight);
				$wE->xview('end');
			} elsif($pr->{$k} eq 'photo'){	## n MO03701
				my $widgets = &main::getWidgets;
				my @wIdent;
				map {
					push @wIdent,$_ if (ref($widgets->{$_}) =~/photo/i)
				} sort keys %$widgets;
				@wIdent = map { &main::path_to_id($_)} @wIdent;
				@wIdent = map {"\$$_"} @wIdent;
				$f->BrowseEntry(-variable=>\$val{$k},-width=>14,-choices=>\@wIdent)->pack(@optPackRight);
			} elsif($pr->{$k} eq 'callback'){
				my @allSubs = ctkCallback->allCallbackNames;
				map {s/^(\w+)$/\\&$1/} @allSubs;
				$f->BrowseEntry(-textvariable=>\$val{$k},-width=>14,
						-choices=>\@allSubs
						)->pack(@optPackRight);
			} elsif($pr->{$k} eq 'variable'){
				my @aVars = sort (@ctkProject::user_auto_vars,@ctkProject::user_local_vars);
				my $wR = eval "\\\$val{$k}";
				$f->BrowseEntry(-variable=>$wR,-width=>14,-choices=>\@aVars)->pack(@optPackRight); ;
			} elsif($pr->{$k} eq 'scrollableclassname'){
				my @c = sort grep /^Scrolled/, keys %{$main::workWidget->widgets()};
				map (s/^Scrolled//,@c);shift @c unless ($c[0]);
				$f->BrowseEntry(-textvariable=>\$val{$k},-width=>14,
						-choices=>\@c
						)->pack(@optPackRight);
			} elsif($pr->{$k} eq 'widget'){
				my @wIdent = sort keys %ctkProject::descriptor;
				map {$_ = '$'.$_} @wIdent;
				$f->BrowseEntry(-variable=>\$val{$k},-width=>14,-choices=>\@wIdent)->pack(@optPackRight);
			} elsif($pr->{$k} eq 'justify') {
				$val{$k}='left' unless $val{$k};
				my $mnb = $f->Menubutton(-underline=>0,-relief=>'raised',-textvariable=>\$val{$k}, -direction =>'below')->pack(@optPackRight);
				my $mnu = $mnb->menu(qw/-tearoff 0/); $mnb->configure(-menu => $mnu);
				foreach my $r(qw/left center right/) {
					$mnu->command(-label=>$r,-image=>$pic->{"justify_$r"},-command=>sub{$val{$k}=$r;});
					}
			} elsif($pr->{$k} eq 'relief') {
				my $mnub = &main::optMenuWidget($f,$k,[qw/raised sunken flat ridge solid groove/],\$val{$k});
				$mnub->pack(@optPackRight);
			} elsif($pr->{$k} eq 'anchor') {
				$val{$k} = '' unless (exists $val{$k});
				&main::AnchorMenu($f,\$val{$k},'')->pack(@optPackRight);
			} elsif($pr->{$k} eq 'side') {
				$val{$k} = '' unless (exists $val{$k});
				&main::SideMenu($f,\$val{$k},'')->pack(@optPackRight);
			} elsif($pr->{$k} =~ /^menu\(/) {
				my $menu=$pr->{$k};
				my @w;
				$menu=~s/.*\(//;$menu=~s/\)//;
				@w = split('\|',$menu);
				if(scalar(@w) > 2) {
					$f->Optionmenu(-options=>[@w],-textvariable=>\$val{$k})->pack(@optPackRight);
				} else {
					my ($on,$off)=@w;
					$val{$k}=$on unless $val{$k};
					$f->Button(-textvariable=>\$val{$k},-relief=>'raised',-command=>sub{$val{$k}=($val{$k} eq $on)?$off:$on;})->pack(@optPackRight);
				}
			} elsif($pr->{$k} eq 'lpack') {
				$val{$k} =~ s/[\[\]']//g if (exists($val{$k}));
				(%lpack)=&main::split_opt($val{$k});
				$f->Optionmenu(-options=>[qw/n ne e se s sw w nw/],-textvariable=>\$lpack{'-anchor'})->pack(@optPackRight);
				$f->Optionmenu(-options=>[qw/left top right bottom/],-textvariable=>\$lpack{'-side'})->pack(@optPackRight);
			} else {
				$f->Entry(-textvariable=>\$val{$k})->pack(@optPackRight);
				## &std::ShowErrorDialog("Unexpected attribute type '$pr->{$k}' , discarded.");
			}
		}
	}

	my ($geom_type,$geom_opt,$n,$wn);
	my %g_val;
	my @brothers;
	# geometry part
	if ($d->geom) {
		my $db_rf=$db->LabFrame(-labelside=>'acrosstop',-label=>'Geometry manager')->pack(@frm_pack); # define right frame
		($geom_type,$geom_opt) = split('[)(]',$d->geom); # get type and options
		$geom_type =~ s/ //g;
		(%g_val)=&main::split_opt($geom_opt); # get geometry option values
		$n = $db_rf->NoteBook( -ipadx => 6, -ipady => 6 )->pack(qw/-expand yes -fill both -padx 5 -pady 5 -side top/);
		$wn = [];
		foreach  (@$main::geomMgr) {
			push @$wn,$n->add($_, -label => $_, -underline => 0);
		}
		my ($g_pack,$g_grid,$g_place,$g_form) = @$wn;

		# pack options:
		{
			&main::cnf_dlg_ballon($bl,$g_pack->Label(-text=>'-side',-justify=>'left')->grid(-row=>0,-column=>0,-sticky=>'w',-padx=>8),'-side');
			&main::SideMenu($g_pack,\$g_val{'-side'},$bl)->grid(-row=>0,-column=>1,-pady=>4);
		}
		{
			&main::cnf_dlg_ballon($bl,$g_pack->Label(-text=>'-anchor',-justify=>'left')->grid(-row=>1,-column=>0,-sticky=>'w',-padx=>8),'-anchor');
			&main::AnchorMenu($g_pack,\$g_val{'-anchor'},$bl)->grid(-row=>1,-column=>1,-pady=>4);
		}
		{
			&main::cnf_dlg_ballon($bl,$g_pack->Label(-text=>'-fill',-justify=>'left')->grid(-row=>2,-column=>0,-sticky=>'w',-padx=>8),'-fill');
			&main::FillMenu($g_pack,\$g_val{'-fill'},$bl)->grid(-row=>2,-column=>1,-pady=>4);
		}
		{
			&main::cnf_dlg_ballon($bl,$g_pack->Label(-text=>'-expand',-justify=>'left')->grid(-row=>3,-column=>0,-sticky=>'w',-padx=>8),'-expand');
			$g_val{'-expand'} = '0' unless exists $g_val{'-expand'};
			&main::cnf_dlg_ballon($bl,$g_pack->Button(-textvariable => \$g_val{'-expand'},-relief=>'raised', -command=>
								sub{$g_val{'-expand'}=1-$g_val{'-expand'}})->grid(-row=>3,-column=>1,-pady=>4),'-expand');

		}
		my $i=0;
		foreach my $k (qw/-ipadx -ipady -padx -pady/) {
			$i++;
			&main::cnf_dlg_ballon($bl,$g_pack->Label(-text=>$k,-justify=>'left')->grid(-row=>3+$i,-column=>0,-sticky=>'w',-padx=>8),$k);
			my $f=$g_pack->Frame()->grid(-row=>3+$i,-column=>1,-pady=>4);
			&main::cnf_dlg_ballon($bl,$f,$k);
			&ctkNumEntry::numEntry($f,-textvariable=>\$g_val{$k},-width=>4,-minvalue=>0)->pack(-side=>'right');
		}

		# geometry: grid
		{
			&main::cnf_dlg_ballon($bl,$g_grid->Label(-text=>'-sticky',-justify=>'left')->
					grid(-row=>0,-column=>0,-sticky=>'w',-padx=>8),'-sticky');
			my $f=$g_grid->Frame()->grid(-row=>0,-column=>1,-pady=>4);
			&main::cnf_dlg_ballon($bl,$f,'-sticky');
			my %st;
			foreach my $s (qw/n s e w/) {
				$st{$s}=' ';
				$st{$s}= 1 if (exists $g_val{'-sticky'} && $g_val{'-sticky'} =~ /$s/);
				$f->Checkbutton(-text=>$s,-variable=>\$st{$s},
					-command => sub{
						$g_val{'-sticky'} =~ s/$s//g;
						$g_val{'-sticky'}.= $s if($st{$s}) ;
						}
					)->pack(-side=>'left');
				}
		}
		$i=1;
		foreach my $k (qw/-column -row -columnspan -rowspan -ipadx -ipady -padx -pady/) {
			&main::cnf_dlg_ballon($bl,$g_grid->Label(-text=>$k,-justify=>'left')->grid(-row=>$i,-column=>0,-sticky=>'w',-padx=>8),$k);
			my $f = $g_grid->Frame()->grid(-row=>$i,-column=>1,-pady=>4);
			&main::cnf_dlg_ballon($bl,$f,$k);
			&ctkNumEntry::numEntry($f,-textvariable=>\$g_val{$k},-width=>4,-minvalue=>($k=~/(-column|-row)$/)?0:1)->pack(-side=>'right');
			$i++;
		}

	  # geometry: place
		$i=0;
		foreach my $k (qw/-height -width -x -y /) {
			&main::cnf_dlg_ballon($bl,$g_place->Label(-text=>$k,-justify=>'left')->grid(-row=>$i,-column=>0,-sticky=>'w',-padx=>8),$k);
			my $f=$g_place->Frame()->grid(-row=>$i,-column=>1,-pady=>4);
			&main::cnf_dlg_ballon($bl,$f,$k);
			&ctkNumEntry::numEntry($f,-textvariable=>\$g_val{$k},-width=>4,-minvalue=>0)->pack(-side=>'right');
			$i++;
		}
		foreach my $k (qw/-relheight -relwidth -relx -rely/) {
			&main::cnf_dlg_ballon($bl,$g_place->Label(-text=>$k,-justify=>'left')->grid(-row=>$i,-column=>0,-sticky=>'w',-padx=>8),$k);
			my $f=$g_place->Frame()->grid(-row=>$i,-column=>1,-pady=>4);
			&main::cnf_dlg_ballon($bl,$f,$k);
			&ctkNumEntry::numEntry01($f,-textvariable=>\$g_val{$k},-width=>4,-minvalue=>0)->pack(-side=>'right');
			$i++;
		}
	  # geometry: form
		{
		$i=0;
		foreach my $k (qw/-top -left -right -bottom/) {
			&main::cnf_dlg_ballon($bl,$g_form->Label(-text=>$k,-justify=>'left')->grid(-row=>$i,-column=>0,-sticky=>'w',-padx=>8),$k);
			my $f=$g_form->Frame()->grid(-row=>$i,-column=>1,-pady=>4);
			&main::cnf_dlg_ballon($bl,$f,$k);
			$f->Entry(-textvariable=>\$g_val{$k})->grid(-row=>$i,-column=>1,-pady=>4);
			$i++;
		}
		foreach my $k (qw/-padtop -padleft -padright -padbottom/) {
			&main::cnf_dlg_ballon($bl,$g_form->Label(-text=>$k,-justify=>'left')->grid(-row=>$i,-column=>0,-sticky=>'w',-padx=>8),$k);
			my $f=$g_form->Frame()->grid(-row=>$i,-column=>1,-pady=>4);
			&main::cnf_dlg_ballon($bl,$f,$k);
			&ctkNumEntry::numEntry($f,-textvariable=>\$g_val{$k},-width=>4,-minvalue=>0)->grid(-row=>$i,-column=>1,-pady=>4);
			$i++;
		}
			&main::cnf_dlg_ballon($bl,$g_form->Label(-text=>'-fill',-justify=>'left')->grid(-row=>$i,-column=>0,-sticky=>'w',-padx=>8),'-fill');
			my $f=$g_form->Frame()->grid(-row=>$i,-column=>1,-pady=>4);
			my $mnb = &main::FillMenu($f,\$g_val{'-fill'},0);
			$mnb->grid(-row=>$i,-column=>1,-pady=>4);
		}
	$n->raise($geom_type);
	}
	# bind balloon message + help on click
	$bl->bind('<Enter>', sub{$bl->configure(-text=>'')});
	$bl->bind('<Leave>', sub{$bl->configure(-text=>'')});

	$db->resizable(0,0);
	&main::recolor_dialog($db);

my $errMsg;
my $reply;
my $cleanup;
	$cleanup = sub {
		my $w = shift;
		return unless Tk::Exists($w); ## i 22.01.2013/mm
		main::trace("cleanup $w");
		map {
			&$cleanup($_);
		} $w->children;
		$w->destroy();
		$w = undef;
		};

	do {
		$errMsg = undef;
		$reply=$db->Show();
		if($reply eq 'Cancel') {
			&$cleanup($db);
			return undef;
		} elsif ($reply eq 'Widget doc'){
			$main::help->tkpod($id,undef,$mw);
			$errMsg = '';
		} elsif ($reply eq 'Geometry doc'){
			if ($n) {
				my $id = $n->raised();
				$main::help->tkpod($id,undef,$mw);
			} else {}
			$errMsg = '';
		} else {
			if ($errMsg = $self->validate($id,\%val)) {
				&std::ShowErrorDialog("$errMsg.\n\nPlease correct.",-buttons=>['Continue']);
			}
		}
	} until !defined($errMsg);

	if (keys %$pr) {
		$val{'-labelPack'} = "[-side=>'$lpack{'-side'}',-anchor=>'$lpack{'-anchor'}']"
		if %lpack;
	}
	my @wBrothers =();
	if ($d->geom) {
		$geom_type=$n->raised();
		# check for geometry conflicts here:
		# find all 'brothers' for current widget
		@wBrothers= &main::getBrotherToBeCheckedForGeom($id);
		@brothers = ();
		map {
			push @brothers,ctkProject->descriptor->{$_}->geom
		} @wBrothers;

		# if any of brothers does not match:
		# Ask user about conflict solution
		# 'Propagate' | 'Adopt' | 'Back' | 'Cancel'
		# go to start on 'Back'
		# return on 'Cancel'
		# otherwise - fix geometry respectively after 'undo_save'

		if (grep(!/^$geom_type/,@brothers)) {
			# we have conflict with one of the brothers
			my @w= ();
			map {
				push @w, $_ if (ctkProject->descriptor->{$_}->geom !~ /^$geom_type/);
			} @wBrothers;
			$reply = &main::askUserForGeom($id,$geom_type,join(',',@w));
			&$cleanup($db);
			return undef if ($reply eq 'Cancel');
			goto re_enter if ($reply eq 'Back');
		}
	}

	&main::undo_save(); 	# save current state for undo

	if (keys %$pr) {
		foreach my $k ( keys %val) {
			if($k =~/^-(showvalue|tearoff|indicatoron|underline)$/){
				delete $val{$k} if ($val{$k} =~ /^\s*$/);
			} else {
				delete $val{$k} unless ($val{$k});
			}
			if($pr->{$k} eq 'callback') {
				&main::pushCallback($val{$k});
			}
		}
		## $d->opt(&main::buildWidgetOptions(\%val,$d->type));
		if(ctkProject->descriptor->{$id}->type =~ /^Scrolled$/) {
				my($sc,$w) = &main::buildWidgetOptionsOnEditS(\%val);
				ctkProject->descriptor->{$id}->scrolledclass($sc);
				$d->opt($w);
		} elsif(ctkProject->descriptor->{$id}->type =~ /^Scrolled/) {
				my ($w) = ctkProject->descriptor->{$id}->type =~ /^Scrolled(.+)/ ;
				$w = "'$w' , ". &main::buildWidgetOptionsOnEdit(\%val);
				$d->opt($w)
		} else {
				$d->opt(&main::buildWidgetOptionsOnEdit(\%val));
		}
	}

	if ($d->geom) {
		foreach my $k (keys %g_val) {
			if($k =~/^(-row|-column)$/) {
				delete $g_val{$k} if (!defined($g_val{$k}) || $g_val{$k}=~/^\s*$/);
			} else {
				delete $g_val{$k} unless($g_val{$k});
			}
			delete $g_val{$k} unless grep($k eq $_,@{$w_geom{$geom_type}})
		}
		$geom_opt = join(', ',%g_val);
		$d->geom($geom_type."($geom_opt)");
		if ($reply eq 'Propagate') {
			main::Log();
			main::Log($id,"Propagating geom manager ".$d->geom. " to:");
			foreach (@wBrothers) {
				main::Log("$_");
				ctkProject->descriptor->{$_}->geom($d->geom)
			}
		} elsif ($reply eq 'Reset') {
			main::Log("Resetting geom manager ".ctkProject->descriptor->{$wBrothers[0]}->geom . " to: " . &main::getSelected);
			$d->geom(ctkProject->descriptor->{$wBrothers[0]}->geom)
		} elsif ($reply eq 'Adopt') {
			main::Log("Adopting geom manager ".ctkProject->descriptor->{$wBrothers[0]}->geom . " to: " . &main::getSelected);
			$d->geom(ctkProject->descriptor->{$wBrothers[0]}->geom)
		} else {
			## discard
		}
	}
	&main::unhide(&main::path_to_id()) if (main::isHidden(&main::path_to_id()));
	&$cleanup($db);
	&main::changes(1);
	&main::set_selected(&main::getSelected); ## i MO04901
	return 1;
}

## sub import {}

BEGIN { 1 }
END {1 }

1; ## -----------------------------------
