## ctk: description Enhance TextEdit with search functionality
## ctk: title Search in Text
## ctk: application ' ' ' '
## ctk: strict  0
## ctk: code  2
## ctk: testCode  0
## ctk: subroutineName thisDialog
## ctk: autoExtractVariables  1
## ctk: autoExtract2Local  1
## ctk: modal 0
## ctk: buttons
## ctk: baseClass  Tk::TextEdit
## ctk: isolGeom 0
## ctk: version 4.21
## ctk: onDeleteWindow  sub{Tk::exit}
## ctk: Toplevel  1
## ctk: argList
## ctk: treewalk D
## ctk: 2012 04 30 - 16:44:04

use Tk;

package SearchTextEdit;
use vars qw($VERSION);
$VERSION = '1.02';
use Tk::TextEdit;
use Tk::Derived;
@SearchTextEdit::ISA = qw(Tk::Derived Tk::TextEdit);
Construct Tk::Widget 'SearchTextEdit';
## ctk: Globalvars
## ctk: Globalvars end
sub ClassInit {
	my $self = shift;
##
## 	init class
##
	$self->SUPER::ClassInit(@_);

}

sub InitObject
{
 my $self = shift;
 $self->SUPER::InitObject(@_);
 Tk::TextEdit::InitObject($self,@_);
}

sub Populate {
	my ($self,$args) = @_;
##
## ctk: Localvars
## ctk: Localvars end
## 	move args to local variables
##
	$self->SUPER::Populate($self->arglist($args));
##
## 	 set up ConfigSpecs 	(optional)
##
	my $mw = $self;
## ctk: code generated by ctk_w version '4.21'
## ctk: instantiate and display widgets

## ctk: widgets generated using treewalk D
## ctk: end of gened Tk-code

##
	return $self;
}
## ctk: methods
sub arglist {
	my $self=shift;
	my $args = shift;
	return $args
}

sub _destroy {
	my $self = shift;
	$self->{'find_window'}->destroy();
	delete $self->{'find_window'} ;
	delete $self->{'search_tag'} ;
	delete $self->{'search_text'};
	$self->{'search_start'} = "" ;
	$self->{'searchExact'} = 0 ;
}
sub destroy {
	my $self = shift;
	if (exists $self->{'find_window'} && Tk::Exists($self->{'find_window'})) {
		$self->_destroy();
	} else {}
	$self->SUPER::destroy();
}

=head3 saveInputIntoHistory

	Save the current item for later use in the
	drop down list.

=cut

sub saveInputIntoHistory {
	my $self = shift;
	my ($entry,$item) = @_;
	return 0 unless($entry->can('Subwidget'));
	my @history = $entry->Subwidget('slistbox')->get('0','end');
	$item = $entry->Subwidget('entry')->get() unless defined ($item);
	$entry->Subwidget('slistbox')->insert ('end',$item) unless grep ($item eq $_,@history);
	return 1
}

=head3 search

	Set up or raise the input dialog

=cut

sub _getMainwindow {
	return (Tk::MainWindow::Existing())[0]
}

=head3 search

	Set up or raise the input dialog.

	Special version for base class TextEdit:
	TextEdit sends search-messages to locate the
	pairs of parenthesis. Doing that it specifies
	an arglist. This fact may be used to route the message
	to the SUPER class.

=cut

sub search {
	my $self = shift;
	return $self->SUPER::search(@_) if (@_);
	if( $self->{'find_window'} ) {
		$self->{'find_window'}->raise() ;
		$self->{'find_text'}->focus() ;
		return ;
	}
	$self->SUPER::tagConfigure('search_tag', "-background" => "green") ;
	$self->{'search_start'} = $self->SUPER::index('insert') if( $self->{'search_start'} eq "" ) ;
	my $dismissSub = sub {
		my $self = shift;
		$self->tagRemove('search_tag', @{$self->{'search_tag'}}) if exists $self->{'search_tag'} ;
		$self->_destroy();
		} ;

	my ($top,$chk,$case,$frm,$rad1,$rad2,$okayBtn);

	$top = $self->Toplevel(-title => "Search Text") ;
	$self->{'find_text'} = $top->BrowseEntry(-label, 'Text', -bg,'#ffffff', -labelPack , [-side=>'left',-anchor=>'n'])->pack(-side => 'top', -fill => 'both', -expand => 1,-padx, 20, -pady , 20) ;
	$frm = $top->Frame()->pack(-side => 'top', -fill => 'both', -expand => 1) ;
	$self->{'fwdOrBack'} = 1 ;
	$rad1 = $frm->Radiobutton(-text => "Forward", -value => 1, -variable => \$self->{'fwdOrBack'}) ;
	$rad1->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$rad2 = $frm->Radiobutton(-text => "Backward", -value => 0, -variable => \$self->{'fwdOrBack'}) ;
	$rad2->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$self->{'searchRegexp'} = 0 ;
	$self->{'searchExact'} = 0 ;
	$case = $frm->Checkbutton(-text => "Exact", -variable => \$self->{'searchExact'}) ;
	$case->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$chk = $frm->Checkbutton(-text => "RegExp", -variable => \$self->{'searchRegexp'}) ;
	$chk->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$okayBtn = $top->Button( -text => "OK",
		-command => sub { $self->showResults($self->{'find_text'}, $okayBtn, $self->{'searchRegexp'}) ; },
		)->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$self->{'find_text'}->bind('<Return>', sub { $self->showResults($self->{'find_text'}, $okayBtn, $self->{'searchRegexp'}) ; }) ;
	$top->Button( -text => "Cancel",
		-command => [$dismissSub,$self],
		)->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$self->{'find_window'} = $top ;
	$top->protocol('WM_DELETE_WINDOW', [$dismissSub,$self]) ;
	$self->{'find_text'}->focus() ;
}

=head3 showResults

	do get text to be found from $entry
	set up switsches
	send message search
	remove tags 'search_tag'
	if found then do
		send message see
		send message markset
		compute new search_start
		save position into @$self->{'search_tag'}
		send addTag to tag the found text
		send selectionRange to $entry
		end

=cut

sub showResults {
	my $self = shift;
	my ($entry, $btn, $regExp) = @_ ;
	my (@switches, $result) ;
	my $txt = $entry->can('Subwidget') ?
		$entry->Subwidget('entry')->get() :
		$entry->get();
	return if $txt eq "" ;
	$self->saveInputIntoHistory($entry,$txt);
	$self->{'search_text'} = $txt;
	push @switches, "-forward" if $self->{'fwdOrBack'}  ;
	push @switches, "-backward" unless $self->{'fwdOrBack'} ;
	push @switches, $self->{'searchExact'} ? "-exact" : '-nocase' ;
	if( $regExp ) {
		push @switches, "-regexp" ;
	} else {
	}
	$result = $self->SUPER::search(@switches, $txt, $self->{'search_start'}) ;
	# untag the previously found text
	$self->SUPER::tagRemove('search_tag', @{$self->{'search_tag'}}) if defined $self->{'search_tag'} ;
	if( !$result || $result eq "" ) {
		# No Text was found
		$btn->flash() ;
		$btn->bell() ;
		delete $self->{'search_tag'} ;
		$self->{'search_start'} = "0.0" ;
	} else { # text found
		$self->SUPER::see($result) ;
		# set the insertion of the text as well
		$self->SUPER::markSet('insert' => $result) ;
		my $len = length $txt ; ## wrong , get len of result anyhow!
		if( $self->{'fwdOrBack'} ) {
			$self->{'search_start'}  = "$result +$len chars"  ;
			$self->{'search_tag'} = [ $result, $self->{'search_start'} ]  ;
		} else {
			# backwards search
			$self->{'search_start'}  = "$result -$len chars"  ;
			$self->{'search_tag'} = [ $result, "$result +$len chars"  ]  ;
		}
		# tag the newly found text
		$self->SUPER::tagAdd('search_tag', @{$self->{'search_tag'}}) ;
	} # end of text found
	$entry->selectionRange(0, 'end') if $entry->can('selectionRange') ;
}

sub showResultsNext {
	my $self = shift;
	# my ($entry, $btn, $regExp) = @_ ;
	my (@switches, $result) ;
	my $txt = $self->{'search_text'} if exists $self->{'search_text'};
	return unless (defined $txt && $txt ne "");
	push @switches, "-forward";
	if( $regExp ) {
		push @switches, "-regexp" ;
	} else {}
	push @switches, $self->{'searchExact'} ? "-exact" : '-nocase' ;
	$result = $self->SUPER::search(@switches, $txt, $self->{'search_start'}) ;
	# untag the previously found text
	$self->SUPER::tagRemove('search_tag', @{$self->{'search_tag'}}) if defined $self->{'search_tag'} ;
	if( !$result || $result eq "" ) {
		# No Text was found
		$btn->flash() ;
		$btn->bell() ;
		delete $self->{'search_tag'} ;
		$self->{'search_start'} = "0.0" ;
	} else { # text found
		$self->SUPER::see($result) ;
		# set the insertion of the text as well
		$self->SUPER::markSet('insert' => $result) ;
		my $len = length $txt ; ## wrong , get len of result anyhow!

		$self->{'search_start'}  = "$result +$len chars"  ;
		$self->{'search_tag'} = [ $result, $self->{'search_start'} ]  ;

		# tag the newly found text
		$self->SUPER::tagAdd('search_tag', @{$self->{'search_tag'}}) ;
	} # end of text found
}

sub showResultsPrevious {
	my $self = shift;
	# my ($entry, $btn, $regExp) = @_ ;
	my (@switches, $result) ;
	my $txt = $self->{'search_text'} if exists $self->{'search_text'};
	return unless (defined $txt && $txt ne "");
	push @switches, "-backward"  ;
	if( $regExp ) {
		push @switches, "-regexp" ;
	} else {}
	push @switches, $self->{'searchExact'} ? "-exact" : '-nocase' ;
	$result = $self->SUPER::search(@switches, $txt, $self->{'search_start'}) ;
	# untag the previously found text
	$self->SUPER::tagRemove('search_tag', @{$self->{'search_tag'}}) if defined $self->{'search_tag'} ;
	if( !$result || $result eq "" ) {
		# No Text was found
		$btn->flash() ;
		$btn->bell() ;
		delete $self->{'search_tag'} ;
		$self->{'search_start'} = "0.0" ;
	} else { # text found
		$self->SUPER::see($result) ;
		# set the insertion of the text as well
		$self->SUPER::markSet('insert' => $result) ;
		my $len = length $txt ; ## wrong , get len of result anyhow!

		$self->{'search_start'}  = "$result -$len chars"  ;
		$self->{'search_tag'} = [ $result, "$result +$len chars"  ]  ;

		# tag the newly found text
		$self->SUPER::tagAdd('search_tag', @{$self->{'search_tag'}}) ;
	} # end of text found
}

sub FindPopUp {
	my $self = shift;
	$self->search();
}
sub FindSelectionNext {
	my $self = shift;
	$self->showResultsNext();
}
sub FindSelectionPrevious {
	my $self = shift;
	$self->showResultsPrevious();
}

## ctk: methods end
## ctk: other code
## ctk: eof 2012 04 30 - 16:44:04
1;	## make perl compiler happy...
