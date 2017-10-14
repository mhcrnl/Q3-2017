=pod

=head1 TkAnalysis

	This class provides methods to analyze TK widgets as well
	as dialogs to shows and even edit their results.

=head2 Syntax

=head3 Control

	new
	destroy

=head3 General

	_bindDump
	_prepareOptions
	_stringify
	getOptions
	isEditable
	stringifyOption
	widgetDump

	a2h
	compareWidget
	subwidgetList


=head3 Dialogs

	listBindings
	showOptions
	updateAllOptions
	viewCurrentOptions
	viewDefaultOptions

	showClassDiagram
	addClass
	addClassNames


=head2 Notes

	None.

=cut

package TkAnalysis;

$debug = 0;

use constant OPT_ROVIEW => 0;
use constant OPT_UPDATEVIEW => 1;

use Tk::Text;
use Tk::ROText;
use Tk::TextUndo;

use vars qw/$VERSION/;

$VERSION = 1.12;

sub new {
	my ($class) = shift;
	my (%args) = @_;
	$class = ref($class) || $class;
	my $self = {};
	$self = bless $self , $class;
	$self->{hwnd} = $args{hwnd} if (exists $args{hwnd});
	$debug = $args{debug} if (exists $args{debug});
	return $self;
}

sub destroy {
	my $self = shift;
	$self ={};
}

sub hwnd { shift->{hwnd} }
sub debug { $debug }

sub isEditable {
	my $self = shift;
	my ($obj) = @_;
	my $rv;
	my $ref = ref $obj;
	if ($ref =~ /^\s*$/) {
		$rv = 1
	} elsif ($ref =~ /^(HASH|ARRAY|SCALAR)$/) {
		$rv = 2
	} else {
		$rv = 0
	}
	&main::trace("isEditable returned '$rv' for '$obj'");
	return $rv
}

sub _stringify {
	my $self = shift;
	my ($obj,$default) = @_;
	my $rv ;
	my $ref = ref $obj;
	if ($ref eq 'SCALAR') {
		$rv = $$obj;
	} elsif ($ref eq 'ARRAY') {
		$rv .='( ';
		map {$rv .= "'$_' " } @$obj; ## TODO : recursion
		$rv .=')'
	} elsif ($ref eq 'HASH') {
		$rv .='{';
		map {$rv .= "$_ => '".$obj->{$_}."'"} keys %$obj;	## TODO : recursion
		$rv .='}';
	} elsif ($ref eq 'CODE') {
		$rv = 'sub{...code...}'
	} elsif ($ref =~ /^\s*$/) {
		$rv = $obj
	} elsif ($ref =~ /^Tk::\w+$/) {
		$rv = "$obj"
	} else {
		$rv = $default
	}
	&main::trace("_stringify returned '$rv'");
	return $rv
}

sub widgetDump {
	my $self = shift;
	my ($widget) = @_;
	use Data::Dumper ;
	my $rv = Data::Dumper->Dump($widget);
	return $rv;
}

sub stringifyOption {
	my $self = shift;
	my ($opt) = @_;
	my $rv = [];
	map {
		 push @$rv , $self->_stringify($_)
	} @$opt;
	return $rv
}

sub getOptions {
	my $self = shift;
	my ($widget,$stringify) = @_;
	my @rv;

	return undef unless(defined($widget));

	@rv = $widget->configure();
	map {
		$_ =  $self->stringifyOption($_);
	} @rv if ($stringify) ;
	return wantarray ? @rv : \@rv;
}

sub _prepareOptions {
	my $self = shift;
	my ($widget,$option,$stringify) = @_;
	my $rv = [];
	map {push @$rv, $_} @$option;
	$rv->[3] = 'N/A' unless (defined($option->[3]));
	$rv->[4] = $widget->cget($option->[0]) if (defined($option->[4]) && $option->[4] =~ /\W/);
	$rv->[4] = $option->[3] unless(defined($option->[4]));
	$rv->[4] = 'N/A' unless (defined($option->[4]));
	$rv->[4] = $rv->[3] if ($option->[0] =~/offset/i && $option->[4] =~/^\s*\d+\s*$/);
	$rv = $self->stringifyOption($rv) if ($stringify);
	return $rv;
}

sub updateAllOptions_old {
	my $self = shift;
	my ($widget,$title) = @_;
	my $rv;
	$widget = $self unless(defined($widget));
	my $hwnd = $widget ; ## unless (defined($hwnd));
	$title = ref($widget) unless(defined($title));
	my $options = $self->getOptions($widget);
	my $db = $hwnd->Dialog(-title=> $title, -buttons => [qw/OK cancel/]);
	my $tw = $db->add('Scrolled', 'TextUndo', -scrollbars => 'se',-wrap => 'none')->pack(-expand => 1, -fill => 'both');
	my $line;
	foreach (@$options) {
		$line ='';
		my $o = $self->_prepareOptions($widget,$_,1);

		$line = $o->[0]." \t=> \t\'".$o->[4] ."'  \t\t(default => '".$o->[3]."');";
		$tw->insert('end',"$line\n");
		}
	my $r = $db->Show();
	if ($r =~ /OK/) {
		&main::trace("reconfiguring ".$widget->class());
		$rv = [];
		map {
			my ($n,$v,$d) = /^\s*(-\w+)\s*=>\s*\'([^\']*)\'\s*\(default => \'([^\']*)\'/;
			if (defined($n) && $n =~/^-/ && defined($v)) {
				&main::trace("$n => '$v' ($d)");
				if ($v  ne $d) {
					unless($v =~/^N[\/\.\-\_\s]A/i) {
						$widget->configure($n => $v) ;
						push @$rv, [$n,$v];
						&main::trace("$n reconfigured to '$v'");
					}
				}
			}
		} split /\n/ , $tw->get('0.1','end');
	} else {
		$rv = undef
	}
	return $rv
}

sub updateAllOptions {
	my $self = shift;
	my ($widget,$title) = @_;
	my $rv;
	return wantarray ? () : 0  unless(defined($widget));
	my $hwnd = $widget ; ## unless (defined($hwnd));
	$title = ref($widget) unless(defined($title));

	my $options = $self->getOptions($widget);

	my $e = [];
	map {push @$e,$self->isEditable($_->[4])} @$options;

	my $db = $hwnd->Dialog(-title=> $title, -buttons => [qw/OK cancel/]);

	my $db_lf = $db->add('Frame')->pack(-expand => 1, -fill => 'both');

	my $db_lft = $db_lf->Scrolled('Tiler', -columns => 1, -scrollbars=>'oe')->pack;

	my @optPackRight=(qw/-side right -padx 7/);
	my @optPackLeft=(qw/-padx 7 -pady 10 -side  left /);

	my $i = 0;
	my $wE = [];
	foreach  (@$options) {
		my $f = $db_lf->Frame();
		$db_lft->Manage( $f );
		my $o = $self->_prepareOptions($widget,$_,1);

		$f->Label(-text => $o->[0], -width => 16)->pack(@optPackLeft);
		my $state = 'normal';
		my $bg = 'white';
		$state = 'disabled' if($e->[$i] != 1);
		$state = 'disabled' if($o->[4] eq 'N/A');
		$bg = 'lightgray' if($e->[$i] != 1);
		$bg = 'lightgray' if($o->[4] eq 'N/A');
		push @$wE,$f->Entry(-textvariable=>\$o->[4], -state => $state, -background => $bg)->pack(@optPackLeft);
		$f->Label(-text => $o->[3])->pack(@optPackRight);
		$i++
	}

	my $r = $db->Show();

	if ($r =~ /^OK/i) {
		&main::trace("reconfiguring ".$widget->class());
		$rv = [];
		$i = 0;
		map {
			my ($n,$v) = ($_->[0],$_->[4]);
			unless(!defined($v) || $v =~ /^N[\/\.\-\_\s]A/i) {
				if ($e->[$i] == 1) {
					my $V = $wE->[$i]->get();
					if (defined ($v) && $V !~ /^N[\/\.\-\_\s]A/i  ) {
						if ($V ne $v && $V !~ /^\s*$/) {
							$widget->configure($n => $V);
							push @$rv, [$n,$V];
							&main::trace("$n reconfigured to '$V'");
						}	## else {}
					}	## else {}
				}	## else {}
			}	## else {}
			$i++;
		} @$options;
	} else {
		$rv = []
	}
	return wantarray ? @$rv : scalar(@$rv)
}

sub viewCurrentOptions {
	my $self = shift;
	my ($hwnd,$widget) = @_;
	$hwnd = $self->{hwnd} unless (defined($hwnd));
	$widget = $hwnd unless (defined($widget));
	return undef unless(defined($widget));
	my $widgetClass = $widget->Class() if($widget->can('Class'));
	$widgetClass = $widget->class() if($widget->can('class'));
	return undef unless (defined($widgetClass));
	my $options = $self->getOptions($widget);
	$self->showOptions($hwnd,$options,"Current options of widget '$widgetClass'",OPT_ROVIEW);
	return 1
}

sub viewDefaultOptions {
	my $self = shift;
	my ($hwnd,$widgetClass) = @_;
	$hwnd = $self->{hwnd} unless (defined($hwnd));
	return undef unless($widgetClass =~ /\S+/);
	my $widget = $hwnd->$widgetClass();
	my $options = $self->getOptions($widget);
	$self->showOptions($hwnd,$options,"Default options of widget '$widgetClass'",OPT_ROVIEW);
	return 1
}

sub showOptions {
	my $self = shift;
	my ($hwnd,$options,$title,$RO) = @_;

	$hwnd = $self->{hwnd} unless (defined($hwnd));

	my $tl = $hwnd->Toplevel(-title=> std::_title($title));
	my $hlist = $tl->Scrolled(HList,-scrollbars => 'oe',
				-columns=>6,
				-width => 100,
				-selectforeground => 'white',
				-selectbackground => 'blue',
				-header => 1,
				-height => 40,
				-sizecmd => sub {1}
				)->pack(-side => 'left',-fill => 'y',-expand => 1,-anchor => 'nw');

	my $blue = $hlist->ItemStyle('text', -foreground=>'blue',-background => '#E1FCFF', -anchor=>'w',-selectforeground => 'white',-selectbackground => 'blue');
	my $blue1 = $hlist->ItemStyle('text', -foreground=>'blue',-background => '#FFFFFF', -anchor=>'w',-selectforeground => 'white',-selectbackground => 'blue');
	my $blue2 = $hlist->ItemStyle('text', -foreground=>'blue',-background => '#EAFFFF', -anchor=>'w',-selectforeground => 'white',-selectbackground => 'blue');
	my $green1 = $hlist->ItemStyle('text', -foreground=>'black',-background => 'green', -anchor=>'w',-selectforeground => 'white',-selectbackground => 'blue');
	my $pink = $hlist->ItemStyle('text', -foreground=>'black',-background => 'pink', -anchor=>'w',-selectforeground => 'white',-selectbackground => 'blue');

	my $e;
	$hlist->header('create', 0,-itemtype => 'text', -text => 'Name', -style => $green1);
	$hlist->header('create', 1,-itemtype => 'text', -text => '.Xdefault', -style => $green1);
	$hlist->header('create', 2,-itemtype => 'text', -text => 'Class', -style => $green1);
	$hlist->header('create', 3,-itemtype => 'text', -text => 'Default', -style => $green1);
	$hlist->header('create', 4,-itemtype => 'text', -text => 'Current', -style => $green1);
	$hlist->header('create', 5,-itemtype => 'text', -text => '       ', -style => $green1);

	map {
		my $row = $_;
		my $style;
		if (defined$row->[3] && defined$row->[4]) {
			if ( ref($row->[4]) =~ /^\s*$/ && ref($row->[3]) =~/^\s*$/ ) {
				$style = ($row->[4] eq $row->[3]) ? $blue :  $pink;
			} else {
				$style = $blue1;
			}
		} else {
				$style = $blue2;
		}
		$e = $hlist->addchild("");
		map {
			$hlist->itemCreate($e, $_, -itemtype=>'text',
				-text=> $self->_stringify($row->[$_]), -style=>$style );
		} (0..5) ;
	} @$options;

}

sub addClass {
	my ($self,$widget,$rv) = @_;
	my $w = [];
	my $v = [];
	map {
		$self->addClass($_,$w);
	} $widget->children();
	if (@$w) {
		if (scalar(@$w) > 1) {
			push @$rv, {"$widget" => $w};
		} else {
			push @$rv, {"$widget" => $w->[0]};
		}
	} else {
		push @$rv, "$widget";
	}
	return $rv;
}

sub addClassNames {
	my ($self,$widget,$rv) = @_;
	my $w = [];
	map {
		$self->addClassNames($_,$w);
	} $widget->children();
	my $x = sprintf('%04d',scalar(@$rv));
	if (@$w) {
		my $n = "$widget";
		$n = $1 if $n =~ /^([^=]+)=/;
		$n =~ s/\s//g;
		if (scalar(@$w) > 1) {
			push @$rv, {"$x $n" => $w};
		} else {
			push @$rv, {"$x $n" => $w->[0]};
		}
	} else {
		my $n = "$widget";
		$n = $1 if $n =~ /^([^=]+)=/;
		$n =~ s/\s//g;
		push @$rv, "$x $n";
	}
	return $rv;
}

sub showClassDiagram {
	my ($self,$hwnd, $widget) = @_;
	my $sw = [];
	$sw = $self->addClass($widget,$sw);

	$hwnd = $mw unless(defined($hwnd));

	use ctkTreeView 1.04;

	my $view = ctkTreeView->new(
			hwnd => $hwnd,
			onOK => sub{return 1},
			debug => $debug);

	$view->userdata('0');

	$view->showDataTree($sw,"Structure of widget $widget","widget");
	return undef;
}

sub a2h {
	my $self = shift;
	my $a = shift;
	my $rv = {};
	if (ref $a eq 'HASH') {
		map {
			$rv->{$_} = $self->a2h($a->{$_})
		} keys %$a
	} elsif (ref $a eq 'ARRAY') {
		map {
			my $r = ref($_);
			if ($r =~ /^\s*$/) {
				$rv->{$_} = undef
			} elsif ($r eq 'HASH') {
				my $h = $_;
				map {
					$rv->{$_} = $self->a2h($h->{$_})
				} keys %$h
			} elsif ($r eq 'ARRAY') {
				$rv->{$_} = $self->a2h($_) ## ???
			} elsif ($r =~ /\S+/) {
				$rv->{$_} = undef
			} else {
				die "unexpected ref ".ref($_)
			}
		} @$a;
	}
	return $rv;
}

sub compareWidgetTree {
	my $self = shift;
	my ($widget1, $widget2) = @_;
	use ctkBtree 1.01;
	my $w1 = $self->addClassNames($widget1);
	my $w2 = $self->addClassNames($widget2);
	$w1 = $self->a2h($w1);
	$w2 = $self->a2h($w2);
	my $bt = ctkBtree->new();
	my @rv = ();
	$bt->traverse_DF2x_pre($w1,$w2,
			sub {
				my $self = shift;
				my @p = @{$self->getStack};
				# map {s/^\d+\s+//} @p;
				my $s = join ' / ',@p;
				push @rv,"$s in w1"
				},
			sub {
				my $self = shift;
				my @p = @{$self->getStack};
				# map {s/^\d+\s+//} @p;
				my $s = join ' / ',@p;
				push @rv,"$s  in w2"
				} ,
			sub{1});
	return wantarray ? @rv : scalar(@rv);
}

sub subwidgetList {
	my $sel = shift;
	my ($widget) = @_ ;
	my @rv = () ;
	@rv = sort keys %{$widget->{SubWidget}} if (exists $widget->{SubWidget});
	return wantarray ? @rv : scalar(@rv);
	}

=head2 _bindDump

	Dump binding information.

	print "Binding information for $w\n";
	foreach my $tag ($w->bindtags) {
		print "\n Binding tag '$tag' has these bindings:\n";
		foreach my $binding ($w->bind($tag)) {
			my $callback = $w->bind($tag,$binding)
			print "  $callback\n";
		}
	}

	Arguments

		- list of widgets to be processed

	Returns

		- dump as an array (or ref to array)
		  of text lines, ready to be shown.

	Note: see original code in package Tk::bindDump

=cut

sub _stringifyCallback {
	my $rv='';
	my $indent = $Data::Dumper::Indent;
	$Data::Dumper::Indent = 1;
	$rv = Data::Dumper->Dump([$_[0]],['callback']);
	$Data::Dumper::Indent = $indent;
	return $rv
}

sub _bindDump {
	my $self = shift;
	my @wList = @_;
	my @rv;

	map {
		my $w = $_;
		my @bindtags = $w->bindtags();
		my $n = 0;

		push @rv , sprintf("Binding information for '%s'\n", $w->PathName);

		foreach my $tag (@bindtags) {
			my @bindings = $w->bind($tag);
			$n++;
			if (scalar(@bindings)) {
				push @rv , sprintf("\n%3d. Binding tag '$tag':\n", $n);
				foreach my $binding ( @bindings ) {
					my $callback = $w->bind($tag, $binding);
					next if(ref($callback) =~ /^\s*$/ && $callback =~ /^\s*$/);
					push @rv , sprintf("Sequence %s :\n", $binding);
					my $s = &_stringifyCallback($callback);
					$s =~ s/\n//g; 
					push @rv,"\t$s\n";	
				}
			} else {
				push @rv , sprintf("\n%3d. Binding tag '$tag' : no bindings.\n", $n);

			}
			push @rv,"\n"
		}
		push @rv , sprintf("---------------------------------------------------------\n");
	} @wList;

	return wantarray ? @rv : \@rv;
} # end bindDump

=head2 listBindings

	Show the resut of _bindDump for the given widget

	Arguments
		- ref to widget to be bindDumped

	Returns

		- None

=cut

sub listBindings_modal {
	my $self = shift;
	my ($hwnd, $widget) = @_;

	my $mw = $hwnd->DialogBox(-title=> std::_title('List actual bindings '.$widget->PathName),-buttons => ['OK']);
	$mw->protocol('WM_DELETE_WINDOW',sub{1});

	# my $wr_001 = $mw -> Scrolled ( 'Listbox' , -selectmode , 'single' , -scrollbars , 'osoe' , -background , '#FFFFFF' ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'both', -expand=>1, -padx=>5);
	my $wr_001 = $mw -> Scrolled ( 'ROText', -scrollbars , 'osoe' , -background , '#FFFFFF' ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'both', -expand=>1, -padx=>5);


	my @b = $widget->bindtags() if (Tk::Exists ($widget));

	$wr_001->delete('1.0','end');
	map {
		$wr_001->insert('end',$_)
	} @b;
	$wr_001->insert('end',"\n");
	@b = $self->_bindDump($widget);
	map {
		s/\n$//;
		$wr_001->insert('end',$_)
	} @b;

	$rv =  $mw->Show();
}

sub listBindings {
	my $self = shift;
	my ($hwnd, $widget) = @_;

	return unless(Tk::Exists ($widget));

	my @b0 = $widget->bindtags() if (Tk::Exists ($widget));
	my @b = $self->_bindDump($widget);

	my $mw = $hwnd->Toplevel(-title , 'List actual bindings '.$widget->PathName);
	$mw->protocol('WM_DELETE_WINDOW',sub{$mw->destroy()});

	my $wr_001 = $mw -> Scrolled ( 'ROText', -scrollbars , 'osoe' , -background , '#FFFFFF' ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'both', -expand=>1, -padx=>5);
	my $wr_002 = $mw->Button(-text, 'Close', -relief, 'raised', -command , sub{$mw->destroy()}, -background , '#FFFFFF' )->pack(-side=>'top', -anchor=>'center', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);


	$wr_001->delete('1.0','end');
	map {
		$wr_001->insert('end',$_)
	} @b0;
	$wr_001->insert('end',"\n");
	map {
		## s/\n$//;
		$wr_001->insert('end',$_)
	} @b;
	
}

sub showTkVariables {
	my $self = shift;
	my (%args) = @_;
	my $t = (exists $args{-title}) ? $args{-title} : 'Tk variables';
	my $db = $self->hwnd->ctkDialogBox(-title => $t);
	$db->add('Message',-text =>	"\nTK VERSION    :'$Tk::VERSION'".
								"\nTK version    :'$Tk::version'".
								"\nTK strictMotif:'$Tk::strictMotif'".
								"\nTK patchLevel :'$Tk::patchLevel'".
								"\nTK library    :'$Tk::library'".
								"\nTK platform   :'$Tk::platform'".
								"\nTk tearoff    :'$Tk::tearoff'".
								"\nfileevent     :"."*fileevent".
								"\nTk widget     :"."$Tk::widget".
								"\nTk event      :"."$Tk::event".
								"\ntime so far   :".Tk::Time_So_Far
								,
				-aspect => 300,
				-justify => 'left',
				-relief => 'ridge',
				-font => 'C_normal',
				-bg => '#FFFFFF',
	-padx => 5, -pady => 5)->pack(-fill => 'x', -expand => 1);

	&main::trace("TK VERSION     : '$Tk::VERSION'",
				"TK version     : '$Tk::version'",
				"TK strictMotif : '$Tk::strictMotif'",
				"TK patchLevel  : '$Tk::patchLevel'",
				"TK library     : '$Tk::library'");
	return $db
}

1; ## make perl happy ...!
