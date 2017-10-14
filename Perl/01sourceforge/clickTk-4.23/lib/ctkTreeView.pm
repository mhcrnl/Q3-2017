##
package ctkTreeView ;

=pod

=head1 ctkTreeView - View Perl-structures using Perl/Tk widgets

=head2 Syntax


	my $view = ctkTreeView->new(<arguments>);

	$view->addButtons(<buttons arguments>);

	$view->setSeparator(<separator char>);

	$view->tree->configure(<option>);

	$view->showDataTree(<ref to data structure>, <title>, <name of root>);


=head2 Applying ctkTreeView

=head3 Why ctkTreeView?

	- use ctkTreeView as data explorer
	- investigate data structures using callbacks
	- use ctkTreeView as base class for application specific viewer

=head3 Data representation

	- nodes:
		HASH element : <key value>
		ARRAY element :
			scalar : [<index value>] ='<value>'
			hash : HASH [<index value>]
			array : ARRAY [index value>]
		ref to SCALAR : '<dereferenced value>'
	- leafs:
		scalar value : '<value>'
		empty value : ''
		undef : UNDEF
		unsupported objects : ref(<object>) UNKNOWN

=head3 Node's identification

	Hash element : key
	array element : index value

	Example : $t= {x => [qw/E0 E2/]}
			/
			/x
			/x/0/E0
			/x/1/E2

=head2 Customizing ctkTreeView

=head3 Some basics

	constructor : allocate widgets and data members

		method new
		method _init
			add default buttons

	showDataTree

		pack all components into toplevel
		add itemstyples
		call lastInit callback
		send autosetmode to the Tree widget

	onOK or onCancel callbacks

		terminate the widget
		callbacks return true to instruct the instance to terminate and
			false to continue

	userdata

		Store user's data into data member.
		Class code do never modify the content of this data member.

	Pls remember: The toplevel works as a non-modal widget. Therefore many
	instances of ctkTreeView may coexists at the same time!

=head3 Customization parameters

	ctkTreeView allows a wide palette of customization parameter:

		- set separator values
		- define buttons for actions (navigation)
		- modify itemStyles
		- set widget options using callback lastInit

	Thereby the provided accessor should be used.

	Basically ctkTreeView may be adapted at any time like a usual
	widget.
	Though there are a few contraints:

		- non modal mode
		- structure of the toplevel
		- buttons
		- limited set of itemStyles
		- itemtypes (text/imageText)
		- handling of special cases (undef)
		- no data editing
		- no public data element
		- no support for class instances which do not base on HASH



=head2 Writing derived classes

	It is reasonnable to write a derived class only when the
	customization don't allow to fulfill the requirements.

	- constructor

		- call SUPER::new

	- overload _init method (new widgets)

		- first call SUPER::_init()
		- do the specialized ini process

	- overload showDataTree (pack new widgets)

		- call SUPER::showDataTree to pack standard widgets
		- do the specialized process

	- write new navigation methods (i.e. goto specific node)

		- use the standard methods to perform stadard function
		- add application dependent functionalities

	- add new data members

	- overload method findItem

	- do not overload properties or accessors

	- do not overload xadd method

	- do not use class variables to control process flow, use
	  property userdata instead.

=head3 save data using property userdata


	Example: user saved the selection. At OK - time this
		selection should still be active.

	my $view = ctkTreeView->new(...);

	$view->tree->configure(-command => sub {

		## do some useable stuff

		$view->userdata($self->info('selection')); ## save selection
		} );

	$view->showDataTree(...);

	sub onK {
		my $self = shift;
		my $s = $self->userdata;
		return 0 if ($s ne $self->tree->info('selection')); 	## cannot terminate
		return 1; 	## terminate widget
	}

=head2 Programming Notes

	This class is not a composite widget.

	While debug mode is on it print trace-entries into STDERR.

	ctkTreeView supports object classes of type ARRAY, HASH, SCALAR, CODE.

	Instances of other kind are supported when they can be accessed as HASH
	and their names match /[A-Za-z0-9_\-]+/ .

=head2 Maintenance

	Author : Marco
	Date   : 09.06.2005
	History

	09.06.2005 First draft
	28.02.2006 MO02501
	06.09.2006 version 1.03

=cut

use Tk::HList;
use Tk::Tree;
use Tk::ItemStyle;
use Tk::Font;

our $VERSION = 1.05;

=head2 new

	Constructor

=over

=item Arguments

	hwnd     parent widget (mandatory)
	debug    debug mode on/off 1 or 0
	buttons  ref to array of hashes containing buttons definitions.
	onOK     callback for 'OK' - button
	onCancel callback for 'Cancel' - button
	autosetmode call autosetmode (0/1)

=item Returns

	Always true.

=item Notes

	It clears the class variables,
	calls _init to initiate widgets.

=back

=cut

sub new {
	my $class = shift;
	my (%args) = @_;
	$class = ref($class) unless(ref($class) =~ /^\s*$/);
	my $self = {};
	$self->{hwnd} = delete $args{hwnd} if (exists $args{hwnd});
	$self->{debug} = delete $args{debug} if (exists $args{debug});
	$self->{autosetmode} = delete $args{autosetmode} if (exists $args{autosetmode});
	$self->{tree} = undef;
	$self->{path} = undef;
	$self->{itemStyle} ={};
	$self->{buttons} = [];
	$self->{toplevel} = $self->{frame1} = $self->{frame2} = $self->{label} = undef;

	$self->{onOK} = $self->{onCancel} = undef;

	$self->{userdata} = undef;

	$self = bless $self,$class;

	$self->set_treePath(undef);
	$self->set_treeLevel(undef);
	$self->set_levelAtOpenTime(undef);

	$self->_init(%args);

	return $self;

}

=head2 destroy

	Destructor

=over

=item Arguments

	None.

=item Returns

	Always true.

=item Notes

	It clears the class variables!!!

=back

=cut

sub destroy {
	my $self = shift;
	if (Tk::Exists ($self->tree)) {
		$self->closeAll();
		## $self->tree->DESTROY() ;
	}
	if(ref($self->toplevel) =~ /toplevel/i) {
			$self->toplevel->DESTROY()
	} else {
			map {
				$self->cleanupAllWidgets($_)
			} $self->toplevel->children;
	}
	undef $self;
	return 1
}

sub cleanupAllWidgets {
	my $self = shift;
	my ($widget) = @_;

	return unless(defined($widget));

	map {
		$self->cleanupAllWidgets($_) if(Tk::Exists($_))
	} $widget->children;

	$widget->destroy();
	return 1;
}

=head2 _init

	Initialize widgets( allocates toplevel, frames, default buttons).

=over

=item Arguments

	Arguments passed by constructor

	buttons  ref to array of button's argument list

=item Returns

	Always true.

=item Notes

	Widgets are not packed into toplevel.

=back

=cut

sub _init {
	my $self = shift;
	my (%args) = @_;

	my $hwnd = $self->hwnd;

	$self->set_levelAtOpenTime(2);

	my $w = $hwnd->Toplevel(-title => __PACKAGE__) unless (exists $args{toplevel} && $args{toplevel});
	$w = $args{toplevel} unless defined $w;

	$self->set_toplevel($w);

	$self->{frame1} = $w->Frame();
	$self->{frame2} = $w->Frame();


	$self->{label} =  $self->frame2->Label(-text => ' ', -width => 50, -bg => 'lightblue');

	if (exists $args{separator}) {
		$self->{separator} = delete $args{separator}
	} else {
		$self->{separator} = '/'
	}

	$self->_addDefaultButtons();

	if(exists $args{buttons}) {
		map {$self->addButton(%$_)} @{$args{buttons}};
		delete $args{buttons};
	}

	if(exists $args{onOK}) {
		$self->set_onOK($args{onOK});
		delete $args{onOK};
	}
	if(exists $args{onCancel}) {
		$self->set_onCancel($args{onCancel});
		delete $args{onCancel};
	}

	my $tree = $self->frame1->Scrolled('Tree',-scrollbars => "osoe",
			-drawbranch => 1,
			-header => 1,
			-indicator => 1,
			-itemtype   => 'text',
			-separator  => $self->separator,
			-selectmode => 'single',
			-browsecmd  => [sub {},undef],
			-selectbackground => 'blue',
			-selectforeground => 'white',
			-command => [sub {},undef],
			## -opencmd => sub{1},
			## -closecmd => sub{1},
			-ignoreinvoke => 0,
			-bg => 'lightgray',
			-width => 60,
			-height => 20,
			-font => $self->toplevel->Font(-family => 'Courier', -size => 10, -weight => 'normal')
			);

	$self->set_tree($tree);

	$tree->configure(-browsecmd  => [sub {
					my $self = shift;
					$self->trace("Tree browsecmd");
					$self->label->configure(-bg=> => 'lightgray', -fg => 'black');
					map {$self->trace("$_")} @_ ;
					},$self,@_]);

	$tree->configure(-command => [sub {
					my $self = shift;
					my $path = $self->tree->info('selection');
					$self->trace("Tree command");
					my $sep = $self->tree->cget(-separator);
					$self->label->configure(-text=>" $path ", -bg => 'blue', -fg => 'white');
					my @w = split /$sep/, $path;
					map {$self->trace("$_")} @_ ;
					},$self,@_]);

	return 1
}

=head2 _addDefaultButtons

	Stack default button definition into data member stack buttons.

=over

=item Arguments

	None.

=item Returns

	Always true.

=item Notes

	At least OK button must be defined.

=back

=cut

sub _addDefaultButtons {
	my $self = shift;

	$self->addButton(-text => 'OK',-command => [sub{ shift->do_onOK() },$self], -bg => 'white');
	$self->addButton(-text => 'Cancel', -command => [sub{shift->do_onCancel()},$self],-bg => 'white');

	return 1
}

sub addItemStyles {
	my $self = shift;
	my $t = $self->tree->cget(-itemtype);
	$font1 = $self->toplevel->Font(-family => 'Courier', -size => 10, -weight => 'normal');
	$font2 = $self->toplevel->Font(-family => 'Courier', -size => 10, -weight => 'bold');
	$self->set_itemStyle('red',  $self->hwnd->ItemStyle($t, -foreground=>'#FF0000', -font => $font1,-selectbackground => 'blue',-selectforeground => 'white'));
	$self->set_itemStyle('green',$self->hwnd->ItemStyle($t, -foreground=>'#00FF00', -font => $font1,-selectbackground => 'blue',-selectforeground => 'white'));
	$self->set_itemStyle('blue', $self->hwnd->ItemStyle($t, -foreground=>'#0000FF', -font => $font1,-selectbackground => 'blue',-selectforeground => 'white'));
	$self->set_itemStyle('black',$self->hwnd->ItemStyle($t, -foreground=>'black',   -font => $font1,-selectbackground => 'blue',-selectforeground => 'white'));
}

=head2 Properties

	hwnd        parent widget
	debug       0/1 debug mode on / off
	tree        ref to widget of class Tree
	path        path of current node (selection)
	toplevel    ref to topLevel widget
	frame1      frame for tree widget
	frame2      frame for buttons
	label       Label widget
	itemStyle   HASH of all defined node styles (instances of class itemStyle)
	buttons     stack of defined buttons (ref to widget)
	separator   level separator

=cut

sub hwnd {shift->{hwnd}}
sub debug {shift->{debug}}
sub tree {shift->{tree}}
sub path {shift->{path}}
sub toplevel {shift->{toplevel}}
sub itemStyle {shift->{itemStyle}}
sub buttons {shift->{buttons}}
sub frame1 {shift->{frame1}}
sub frame2 {shift->{frame2}}
sub label {shift->{label}}
sub treePath {shift->{treePath}}
sub treeLevel{shift->{treeLevel}}
sub levelAtOpenTime {shift->{levelAtOpenTime}}
sub onOK {shift->{onOK}}
sub onCancel{shift->{onCancel}}
sub separator{shift->{separator}}

sub userdata {
	my $self = shift;
	my $rv = $self->{userdata};
	return $rv unless (scalar(@_) >0);
	$self->{userdata} = shift if (@_ == 1);
	$self->Log("Unallowed arguments for userdata discarded.") if (@_);
	return $rv
}

sub set_onOK {
	my $self = shift;
	my $rv = $self->onOK;
	$self->{onOK} = shift if(@_);
	return $rv
}
sub set_onCancel {
	my $self = shift;
	my $rv = $self->onCancel;
	$self->{onCancel} = shift if(@_);
	return $rv
}
sub set_levelAtOpenTime {
	my $self = shift;
	my $rv = $self->levelAtOpenTime;
	$self->{levelAtOpenTime} = shift if(@_);
	return $rv
}
sub set_treeLevel {
	my $self = shift;
	my $rv = $self->treeLevel;
	$self->{treeLevel} = shift if(@_);
	return $rv
}
sub set_treePath {
	my $self = shift;
	my $rv = $self->treePath;
	$self->{treePath} = shift if(@_);
	return $rv
}

sub set_tree {
	my $self = shift;
	my $rv = $self->tree;
	$self->{tree} = shift if(@_);
	return $rv
}
sub set_toplevel {
	my $self = shift;
	my $rv = $self->toplevel;
	$self->{toplevel} = shift if(@_);
	return $rv
}
sub set_label {
	my $self = shift;
	my $rv = $self->label;
	$self->{label} = shift if(@_);
	return $rv
}

sub set_itemStyle {
	my $self = shift;
	my ($id,$instance) = @_;
	&Tk::error("Missing itemStyle ident") unless(defined($id));
	&Tk::error("Missing itemStyle instance") unless(defined($instance));
	my $rv = $self->itemStyle->{$id};
	$self->itemStyle->{$id} = $instance;
	return $rv
}

sub addButton {
	my $self = shift;
	my (%args) = @_;
	my $b = $self->frame2->Button(%args);
		push @{$self->buttons} , $b;
}

sub setSeparator {
	my $self = shift;
	$self->tree->configure(-separator => $_[0]) if (@_);
}

sub getSeparator {
	my $self = shift;
	my $rv;
	$rv = $self->tree->cget('-separator') if(defined($self->tree));
	return $rv
}

sub do_onOK {
	my $self = shift;
	my $x = $self->onOK;
	my $a = 1;
	$a = &$x($self) if (defined($x));
	$self->destroy() if($a);
}

sub do_onCancel {
	my $self = shift;
	my $x = $self->onCancel;
	my $a = 1;
	$a = &$x($self) if (defined($x));
	$self->destroy() if($a);
}

sub autosetmode {
	my $self = shift;
	my ($value) = @_;
	$self->{autosetmode} = $value if (defined($value));
	$self->tree->autosetmode() if ($self->{autosetmode});
}

=head2 showDataTree

=over

=item descrition

=item Arguments

=item Returns

=item Notes

=back

=cut

sub showDataTree {
	my $self = shift;
	my ($dataTree,$title,$treeRootText,$lastInit) = @_;
	my $tree = $self->tree;

	$self->addItemStyles();

	$self->toplevel->configure(-title => __PACKAGE__." - $title") if(defined($title) && ref($self->toplevel) =~ /toplevel/i);

	$self->xadd($dataTree,$treeRootText);

	$self->frame1->pack(-side => 'top', -anchor => 'nw',-expand => 1 , -fill => 'both');
	$self->frame2->pack(-side => 'bottom', -anchor => 'sw',-expand => 1 , -fill => 'both');

	$self->label->pack(-anchor => 'nw',-expand => 1 , -fill => 'x');
	$tree->pack(-anchor => 'nw', -expand => 1 , -fill => 'both');

	map {
			$_->pack(-side => 'left', -anchor => 'sw',-expand => 1, -fill => 'x')
	} @{$self->buttons};

	&$lastInit($self) if(defined($lastInit));

	$tree->autosetmode(); 	## dont move it away from here !!!

}

=head2 xadd

=over

=item Add an element to the tree

=item Arguments

=item Returns

=item Notes

=back

=cut

sub xadd {
	my $self = shift;
	my ($data,$treeRootText) = @_;
	my $tree = $self->tree;
	my $treePath = $self->treePath;
	my $treeLevel = $self->treeLevel;
	my $sep = $tree->cget('-separator');
##	my $folder= '/opt/cltd/perl58/lib/site_perl/5.8.3/aix/Tk/folder.xbm'; 	## colors (yellow)
##	my $img = $hlist->Photo(-file => $folder );

	my $red   = $self->itemStyle->{red};
	my $green = $self->itemStyle->{green};
	my $blue  = $self->itemStyle->{blue};
	my $black = $self->itemStyle->{black};

	my $w;
	my $ref = 0;

	$self->trace("xadd ".ref($data));
	unless (defined($treePath)) {
			 $tree->add($sep,-text => $treeRootText);
			 $treePath = $sep;
	}
	$treeLevel++;
	$self->set_treeLevel($treeLevel);
	$w = $treePath;
	$self->trace("path = $treePath ;data = $data");
	if (ref($data) eq 'HASH') {
		map {
			my $item = $_ ;
			if (ref($data->{$_}) =~ /^\s*$/) {
				$item =~ s/$sep/_/g;
				my $w = $treePath;
				$treePath .= ($treePath =~ /$sep$/) ? "$item" : "$sep$item";
				$self->trace("path = $treePath ;item = $item");
				my $d = defined($data->{$_}) ? "$item = '$data->{$_}'" : "$item = UNDEF";
				$tree->add($treePath, -text => $d, -style=>$black );
				$treePath = $w;
			} else {
				$treePath .= ($treePath =~ /$sep$/) ? "$item" : "$sep$item";
				$self->set_treePath($treePath);
				$self->trace("path = $treePath ;item = $item");
				$tree->add($treePath, -text => $item , -style=>$blue );
				if ($self->treeLevel > $self->levelAtOpenTime) {
					$tree->hide('entry',$treePath);
				}
				$self->xadd($data->{$item});
				$treePath = $w;
				$self->set_treePath($treePath);
			}
		} sort keys %$data;
	} elsif (ref($data) eq 'ARRAY') {
		my $i=0;
		map {
			my $w = $treePath;
			if (ref($_) =~/^\s*$/) {
				my $item = "$i";
				$item =~ s/$sep/_/g;
				$self->trace($item);
				$treePath .= ($treePath =~ /$sep$/) ? "$item" : "$sep$item";
				$self->set_treePath($treePath);
				my $d = defined($_) ? "[$item] = '$_'" : "[$item] = UNDEF";
				$tree->add($treePath, -text => $d, -style=>$black );
			} else {
				my $w = $treePath;
				my $item = ref($_)." [$i]";
				## my $item = "[$i]";
				$item =~ s/$sep/_/g;
				$self->trace($item);
				$treePath .= ($treePath =~ /$sep$/) ? "$item" : "$sep$item";
				$self->set_treePath($treePath);
				$tree->add($treePath, -text => $item , -style=>$blue );
				$self->xadd($_);
			}
			$treePath = $w;
			$self->set_treePath($treePath);
			$i++;
		} @$data;
	} elsif(ref($data) eq 'CODE') {
		$ref++;
		my $item = "CODE$ref" ;
		$self->trace("leaf path=$treePath ;data=SUB{...}");
		$treePath .= "$sep$item";
		$self->set_treePath($treePath);
		$tree->add($treePath, -text => 'CODE', -style=>$blue);
	} elsif(ref($data) eq 'SCALAR') {
		$ref ++;
		my $item = "SCALAR_$ref" ;
		$self->trace("leaf path=$treePath ;item = $item");
		$treePath .= "$sep$item";
		$self->set_treePath($treePath);
		my $d = $$data;
		$d = "$item = ".defined($d) ? "'$d'" : 'UNDEF';
		$tree->add($treePath, -text => $d, -style=>$blue);
	} elsif (ref($data) =~ /^[a-zA-Z0-9_\-]+$/) {
		my $item = ref($data);
		$treePath .= ($treePath =~ /$sep$/) ? "$item" : "$sep$item";
		$self->set_treePath($treePath);
		$tree->add($treePath, -text => $item , -style=>$red );
		my $w = $treePath;
		map {
			my $item = $_ ;
			if (ref($data->{$_}) =~ /^\s*$/) {
				$item =~ s/$sep/_/g;
				my $w = $treePath;
				$treePath .= ($treePath =~ /$sep$/) ? "$item" : "$sep$item";
				$self->set_treePath($treePath);
				$self->trace("path = $treePath ;item = $item");
				my $d = defined($data->{$_}) ? "$item = '$data->{$_}'" : "$item = UNDEF";
				$tree->add($treePath, -text => $d, -style=>$black );
				$treePath = $w;
				$self->set_treePath($treePath);
			} else {
				$treePath .= ($treePath =~ /$sep$/) ? "$item" : "$sep$item";
				$self->set_treePath($treePath);
				$self->trace("path = $treePath ;item = $item");
				$tree->add($treePath, -text => $item , -style=>$blue );
				if ($self->treeLevel > $self->levelAtOpenTime) {
					$tree->hide('entry',$treePath);
				}
				$self->xadd($data->{$_});
				$treePath = $w;
				$self->set_treePath($treePath);
			}
		} sort keys %$data;
	} elsif(ref($data) =~ /^\s*$/) {
		my $item = $data ;
		$item= 'UNDEF' unless(defined($item));
		$item =~ s/$sep/_/g;
		$self->trace("leaf path=$treePath ;data=$data");
		$treePath .= "$sep$item";
		$self->set_treePath($treePath);
		my $d = (defined($data)) ? "'$data'" : 'UNDEF' ;
		$tree->add($treePath, -text => $d, -style=>$blue);
	} else {
		$ref ++;
		my $item = ref ($data) ;
		$item =~ s/$sep/_/g;
		$self->trace("leaf path=$treePath ;data=$item");
		$treePath .= "$sep$item\_$ref";
		$self->set_treePath($treePath);
		my $d = "$item UNKNOWN";
		$tree->add($treePath, -text => $d, -style=>$red);
		$self->log("Cannot handle item of type '".ref($data)."'");
		## Tk::Error("Data of type 'ref($data)' not supported., discarded");
	}
	if ($treeLevel > $self->levelAtOpenTime) {
				$tree->hide('entry',$treePath);
	}
	$treePath = $w;
	$self->set_treePath($treePath);
	$treeLevel--;
	$self->set_treeLevel($treeLevel);
	return 1
}

=head2 showAllChildren

=over

=item Open all children of selected (or given) node

	- get path if none was given by caller
	- show the node
	- set indicator to 'minus'
	- issue recursion to process children

=item Arguments

=item Returns

=item Notes

=back

=cut

sub showAllChildren {
	my $self = shift;
	my (@path) = @_;
	my @children = ();
	my $tree = $self->tree;

	@path = $tree->info('selection') unless(@path);

	map {
		@children = $self->tree->info('children',$_);
		map {
			$self->tree->show('entry',$_) if ($self->info('hidden',$_));
			$self->tree->indicator('create',$_,-itemtype => 'image', -image => $self->tree->Getimage('minus'));
		} @children;
		map {
			$self->openAllChildren(($_));
		} @children;
	} @path;
}

=head2 showNextLevel

=over

=item

=item Arguments

=item Returns

=item Notes

=back

=cut

sub showNextLevel {
	my $self = shift;
	my (@path) = @_;
	my @children = ();
	my $tree = $self->tree;
	@path = $tree->info('selection') unless(@path);

	map {
		@children = $tree->info('children',$_);
		map {
			if ($tree->info('hidden',$_)){
				$tree->show('entry',$_);
				$self->tree->indicator('create',$_,-itemtype => 'image', -image => $self->tree->Getimage('minus'));
			} else {}
		} @children;
	} @path;

}

=head2 openNextlevel

=over

=item descrition

=item Arguments

=item Returns

=item Notes

=back

=cut

sub openNextLevel {
	my $self = shift;
	my (@path) = @_;
	my $tree = $self->tree;
	my @children = ();
	@path = $tree->info('selection') unless(@path);

	map {
		 $tree->open($_) if ($tree->getmode($_) eq 'open');
	} @path;

}

=head2 closeAll

=over

=item Close all nodes starting at root

=item Arguments

	None.

=item Returns

	Always 1.
=item Notes

	None.

=back

=cut

sub closeAll {
	my $self = shift;
	my @children = ();
	my $tree = $self->tree;
	my $root = $tree->cget('-separator');
	@children = $tree->info('children',$root);
	$tree->close($root) unless ($tree->getmode($root) ne 'close');
	return 1
}

=head2 openAll

=over

=item Open all nodes starting at root.

=item Arguments

	None.

=item Returns

	Always 1.

=item Notes

	None.
=back

=cut

sub openAll {
	my $self = shift;
	my @children = ();
	my $tree = $self->tree;
	my $root = $tree->cget('-separator');
	@children = $tree->info('children',$root);
	$self->openAllChildren($root);
	return 1
}

=head2 openAllChildren

=over

=item Open all children of given (or selected) node

=item Arguments

	Path to node to be open (optional, default selected node).

=item Returns

=item Notes

	If no path is geiven and no node is selected then
	no action is done.

=back

=cut

sub openAllChildren {
	my $self = shift;
	my @path = @_;
	my $tree = $self->tree;
	@path = $tree->info('selection') unless(@path);
	map {
		$tree->open($_) unless ($tree->getmode($_) ne 'open');
		my @children = $tree->info('children',$_);
		map {
			$self->openAllChildren($_);
		}@children;
	} @path;
	return 1
}

=head2 closeAllChildren

=over

=item Close all children of given (or selected) node.

=item Arguments

	Path to node to be closed (default selected node).

=item Returns

	Always 1.
=item Notes

	If no path is given and no node is selected then
	no action is done.

=back

=cut

sub closeAllChildren {
	my $self = shift;
	my @path = @_;
	my $tree = $self->tree;
	@path = $tree->info('selection') unless(@path);
	map {
		my @children = $tree->info('children',$_);
		map {
			$self->closeAllChildren($_);
			$tree->close($_) unless ($tree->getmode($_) ne 'close');
		} @children;
	} @path;
	return 1
}

=head2 closeSelected

=over

=item The selected node is closed

=item Arguments

	None.

=item Returns

=item Notes

	If no path is given and no node is selected then
	no action is done.

=back

=cut

sub closeSelected {
	my $self = shift;
	my @path = @_;
	my $tree = $self->tree;
	@path = $tree->info('selection');
	map {
		my @children = $tree->info('children',$_);
		map {
			$self->closeAllChildren($_);
			$tree->close($_) unless ($tree->getmode($_) ne 'close');
		} @children;
		$tree->close($_) unless ($tree->getmode($_) ne 'close');
	} @path;
	return 1
}

=head2 hideAll

=over

=item Hide all children of the given (or selected) node.

=item Arguments

	Path to the node to be hidden.

=item Returns

	Always 1.

=item Notes

	Do not use this method!

=back

=cut

sub hideAll {
	my $self = shift;
	my @children = ();
	my $tree = $self->tree;
	my $root = $tree->cget('-separator');
	## TODO  010.06.2005/mm  didn't work (cannot open hidden items anymore)
	return 1;
	@children = $tree->info('children',$root);
	map {
		unless ($tree->info('hidden',$_)) {
			my @children1 = $tree->info('children',$_);
			map {
				$tree->hide('entry',$_) unless ($tree->info('hidden',$_));
			} @children1 ;
			$self->tree->indicator('create',$_,-itemtype => 'image', -image => $self->tree->Getimage('plus'));
		}
	} @children;
	return 1
}

=head2 findItem

=over

=item Search the tree for nodes having entered strig in its name.

	- Open a dialog to enter search string.
	- traverse 'in order' level 0 and 1 to search for the given substring
	- select found item if any has been found.

=item Arguments

	None.

=item Returns

	Always 1.

=item Notes

	Actually this method searches only level 0 and 1 for
	the entered substring.

=back

=cut

sub findItem {
	my $self = shift;
	my $tree = $self->tree;
	my $ans = 'Cancel';
	my ($db,$e1);
	my $string;

	$db = $self->toplevel->DialogBox(-title =>'Enter string to be searched',
        			         -buttons =>[ 'OK', 'Cancel']
				);
	$e1= $db->Entry( -width => 22,
					  -textvariable => \$string,
					  -borderwidth => 2,
					  -relief => 'sunken',
					  -bg => 'white');
	$db->Advertise('entry' => $e1);
	$e1->pack(-side => 'top', -anchor => 'nw');
	while (1) {
		$e1->focus;
		$ans = $db->Show();
		if( $ans =~/OK|Cancel/) {
			$string = $e1->get();
			last;
		} elsif ($ans eq 'Help') {
			## &informUser("Enter any string to be searched for in the tree.\nThe tree window will get changed in order to show the item containing the given string");
		} else {
			## &unrecovError("Unexpected answer '$ans' in sub findItem");
		}
	}
	if ($ans eq 'OK') {
		$string =~ s/\///g;
		$tree->selectionClear();

## TODO: apply recursive search through 'in order' traverser

		my $root = $self->getSeparator;
		my @children = $tree->info('children',$root);
		foreach (@children) {
			if (/$string/i) {
				$self->trace("String '$string' found in '$_'");
				$tree->open($_) if ($tree->getmode($_) eq 'open');
				$tree->see($_);
				$tree->selectionSet($_);
				last;
			} else {
				my $parent = $_;
				my @children1 = $tree->info('children',$parent);
				foreach (@children1) {
					if (/$string/i) {
						$self->trace("String '$string' found in '$_'");
						$tree->open($parent) if ($tree->getmode($_) eq 'open');
						$tree->see($_);
						$tree->selectionSet($_);
						last;
					} else {}
				}
			}
		}
	} else {
		## process dismissed
	}

}
sub Trace { shift->trace(@_)}
sub trace {
	my $self = shift;
	$self->log(@_) if $self->debug;
}
sub Log {shift->log(@_)}
sub log {
	my $self = shift;
	map {print STDERR "\n\t$_"} @_;
}
BEGIN {}
END {}

1 ; ## make perl compiler happy ...
