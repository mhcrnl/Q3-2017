package ctkDlgEnterWidgetOptions;
use vars qw($VERSION);
$VERSION = '1.01';
require Tk::DialogBox;
require Tk::Derived;
@ctkDlgEnterWidgetOptions::ISA = qw(Tk::Derived Tk::DialogBox);

my ($name,$type,$value);

my $aType;

Construct Tk::Widget 'ctkDlgEnterWidgetOptions';
sub ClassInit {
	my $self = shift;
	$self->SUPER::ClassInit(@_);
	$name=$type=$value='';
	$aType =[(ctkWidgetLib->optionsTyp())];
}
sub Populate {
	my ($self,$args) = @_;

	$name = $value = $type = '';
	$name = delete $args->{-name} if exists $args->{-name};
	$value = delete $args->{-value} if exists $args->{-value};
	$type = delete $args->{-type} if exists $args->{-type};

	$self->SUPER::Populate($args);

	my $wr_data = $self -> Frame ( -borderwidth , 1 , -relief , 'sunken'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>10, -fill=>'both', -expand=>1, -padx=>10);
	my $wr_actions = $self -> Frame ( -borderwidth , 1 , -relief , 'sunken'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>10, -fill=>'x', -expand=>1, -padx=>10);
	my $wr_004 = $wr_data -> Label ( -anchor , 'nw' , -justify , 'left' , -relief , 'flat' , -text , 'Name'  ) -> grid(-row=>0, -column=>0, -sticky=>'nw');
	my $wr_005 = $wr_data -> Entry ( -background , '#ffffff' , -width , 32 , -state , 'normal' , -justify , 'left' , -relief , 'sunken' , -textvariable , \$name  ) -> grid(-row=>0, -sticky=>'nw', -column=>1);
	my $wr_006 = $wr_data -> Label ( -anchor , 'nw' , -justify , 'left' , -text , 'Value' , -relief , 'flat'  ) -> grid(-row=>1, -column=>0, -sticky=>'nw');
	my $wr_008 = $wr_data -> Entry ( -background , '#ffffff' , -width , 32 , -state , 'normal' , -justify , 'left' , -relief , 'sunken' , -textvariable , \$value  ) -> grid(-row=>1, -column=>1,-sticky=>'nw');
	my $wr_010 = $wr_data -> Label ( -anchor , 'nw' , -justify , 'left' , -text , 'Type' , -relief , 'flat'  ) -> grid(-row=>2, -column=>0, -sticky=>'nw');
	my $wr_012 = $wr_data -> BrowseEntry ( -background , '#ffffff' , -width , 32 , -state , 'normal' , -justify , 'left' , -variable , \$type , -choices , $aType  ) -> grid(-row=>2, -sticky=>'nw', -column=>1);

	## 	ctkTargetComposite->ConfigSpecs();
	## 	$self->Delegates(); 	(optional)
	return $self;
}

sub name { return $name }
sub value { return $value }
sub type { return $type }

sub do_OK {
	my $self = shift;
}
sub do_Cancel {
	my $self = shift;
}
1; ## eom
