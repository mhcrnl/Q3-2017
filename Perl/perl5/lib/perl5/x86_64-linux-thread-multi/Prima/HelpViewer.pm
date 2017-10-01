#
#  Copyright (c) 1997-2002 The Protein Laboratory, University of Copenhagen
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
#  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#  SUCH DAMAGE.
#
#  Created by:
#     Dmitry Karasik <dk@plab.ku.dk> 
#
#  $Id$

use strict;
use Prima;
use Prima::PodView;
use Prima::Buttons;
use Prima::InputLine;
use Prima::StdDlg;
use Prima::IniFile;
use Prima::Utils;

package Prima::HelpViewer;
use vars qw(@helpWindows $windowClass);

$windowClass = 'Prima::PodViewWindow';

sub open
{
	shift;
	my $topic = $_[0];
	
	$windowClass-> create unless scalar @helpWindows;
	$helpWindows[0]-> bring_to_front;
	$helpWindows[0]-> {text}-> update_view;
	$helpWindows[0]-> {text}-> load_link( $topic); 
	$helpWindows[0]-> {text}-> select;

	if (
		( 
			$::application-> get_modal_window( mt::Exclusive) ||
			$::application-> get_modal_window( mt::Shared)
		) && 
		!$helpWindows[0]-> get_modal
	) {
		$helpWindows[0]-> execute;
		$helpWindows[0]-> close if $helpWindows[0];
	}
}

sub close
{
	shift;
	my @w = @helpWindows;
	for my $k ( @w) {
		$k-> close;
	}
}

package Prima::CustomPodView;
use vars qw(@ISA);
@ISA = qw(Prima::PodView);

sub load_file
{
	my ( $self, $manpage) = @_;
	my $ret;
	my $o = $self-> owner;
	$o-> text( $o-> {stext});
	$o-> status( "Loading $manpage ... ");
	if (( $ret = $self-> SUPER::load_file( $manpage)) > 0) {
		$o-> text( $o-> {stext} . ' - ' . $manpage);
	}
	$o-> status('');
	$o-> update;
	$o-> update_menu($ret);

	return $ret;
}

sub link_click
{
	my ( $self, $s, $btn, $mod, $x, $y) = @_;
	$self-> SUPER::link_click( $s, $btn, $mod, $x, $y);
	return if $btn != mb::Right;

	my $new = ref($self-> owner)-> create;
	if ( $s =~ /^\//) {
		$s = "$self->{pageName}$s";
	} elsif ( $s =~ /^"(.*)"$/) {
		$s = "$self->{pageName}/$1";
	} elsif ( $s =~ /^topic:\/\//) {
		$new-> {text}-> load_link( $self-> {pageName});
	}
	$new-> {text}-> update_view;
	$new-> {text}-> load_link( $s);
	$new-> select;
}

sub load_link
{
	my ( $self, $link) = @_;
	
	if ( $link =~ /^(http|ftp):\//) {
		$self-> owner-> status("Starting browser for $link...");
		if ( Prima::Application-> get_system_info-> {apc} == apc::Win32) {
			open UNIQUE_FILE_HANDLE_NEVER_TO_BE_CLOSED, "|start $link";
			close UNIQUE_FILE_HANDLE_NEVER_TO_BE_CLOSED if 0;
		} else {
			my $pg;
			CMD: for my $cmd ( qw(sensible-browser xdg-open x-www-browser www-browser firefox mozilla netscape)) {
				for ( split /:/, $ENV{PATH} ) {
					$pg = "$_/$cmd", last CMD if -x "$_/$cmd";
				}
			}
			$self-> owner-> status("Cannot start browser"), return 
				unless defined $pg && ! system( "$pg $link &");
		}   
		return;
	}

	my $ret = $self-> SUPER::load_link( $link);
	$self-> owner-> update;
	return $ret;
}

sub on_bookmark
{
	my ( $self, $mark) = @_;
	my $o = $self-> owner;
	push @{$o-> {history}}, $mark;
	$o-> {forwardLinks} = [];
	$o-> menu-> goforw-> disable;
	$o-> Forward-> enabled(0);
	$o-> menu-> goback-> enable;
	$o-> Back-> enabled(1);
	$o-> update;
}

sub on_newpage
{
	my ( $self, $mark) = @_;
	my $o = $self-> owner;
	undef $o-> {find_offset};
	$o-> fastfind_close;
}

sub on_keydown
{
	my ( $self, $code, $key, $mod, $r) = @_;
	my $c = chr $code;
	if ( $c =~ /[\/\?Nn]/) {
		if ( $c eq '/') {
			$self-> owner-> fastfind(1);
		} elsif ( $c eq '?') {
			$self-> owner-> fastfind(0);
		} elsif ( $c eq 'N') {
			$self-> owner-> fastfind_repeat(0);
		} elsif ( $c eq 'n') {
			$self-> owner-> fastfind_repeat(1);
		}
		$self-> clear_event;
		return;
	}

	if ( $key == kb::Esc && $self-> owner-> {printing}) {
		$self-> owner-> {printing} = -1;
		$self-> clear_event;
		return;
	}
	
	$self-> SUPER::on_keydown( $code, $key, $mod, $r);
}

package Prima::PodViewWindow;
use vars qw(@ISA $finddlg $prndlg $setupdlg $inifile
$defaultVariableFont $defaultFixedFont);
@ISA = qw(Prima::Window);

$inifile = Prima::IniFile-> create(
	file => Prima::Utils::path('HelpWindow'),
	default => { View => {
		FullText => 1,
		FixedFont => 'monospace',
	}},
);

sub profile_default
{
	my $def = $_[ 0]-> SUPER::profile_default;
	my %prf = (
	menuItems => 
		[[ '~File' => [
			['~Open' => 'Ctrl+O' => '^O' => 'load_dialog' ],
			['~Go to...' => 'G' => 'G' => 'goto' ],
			['~New window' => 'Ctrl+N' => '^N' => 'new_window'],
			['~Run' => [
				['p-class' => 'filter_p_class'],
			]],
			[],
			['~Print ...' => 'Ctrl+P' => '^P' => 'print'],
			[],
			['~Close window' => 'Ctrl-W' => '^W' => sub { $_[0]-> close }],
			['E~xit' => 'Ctrl+Q' => '^Q' => sub { Prima::HelpViewer-> close }],
		]], [ '~View' => [
			[ '~Increase font' => 'Ctrl +' => '^+' => sub {
					return if $_[0]-> {text}-> {defaultFontSize} > 100;
					$_[0]-> {text}-> {defaultFontSize} += 2;
					$_[0]-> {text}-> format(1);
					$inifile-> section('View')-> {FontSize} = $_[0]-> {text}-> {defaultFontSize};
			}],
			[ '~Decrease font' => 'Ctrl -' => '^-' => sub {
					return if $_[0]-> {text}-> {defaultFontSize} < 4;
					$_[0]-> {text}-> {defaultFontSize} -= 2;
					$_[0]-> {text}-> format(1);
					$inifile-> section('View')-> {FontSize} = $_[0]-> {text}-> {defaultFontSize};
			}],
			[],
			[ 'fullView' => 'Full text ~view' => 'Ctrl+V' => '^V' => sub {
				$_[0]-> {text}-> topicView( ! $_[0]-> menu-> toggle( $_[1]));
				$_[0]-> update;
				$inifile-> section('View')-> {FullText} = $_[0]-> {text}-> topicView ? 0 : 1;
			}],
			['-src' => 'View so~urce' => 'Ctrl+U' => '^U' => 'view_source'],
			[],
			['~Find...' => 'Ctrl+F' => '^F' => 'find'],
			['Find ~again' => 'Ctrl+L' => '^L' => 'find2'],
			['Fa~st find' => [
				['fff' => '~Forward' => '/' => kb::NoKey, sub { $_[0]-> fastfind(1) }],
				['ffb' => '~Backward' => '?' => kb::NoKey, sub { $_[0]-> fastfind(0) }],
				['-frf' => '~Repeat forward' => 'n' => kb::NoKey, sub { $_[0]-> fastfind_repeat(1) }],
				['-frb' => 'Repeat backward' => 'N' => kb::NoKey, sub { $_[0]-> fastfind_repeat(0) }],
			]],
			[],
			['Set~up' => 'setup_dialog'],
			['Set font ~encoding' => [
				map { [ "ENC$_", $_, 'set_encoding' ] } sort @{$::application-> font_encodings()},
			]],
		]], [ '~Go' => [
				[ '-goback' => '~Back' => 'Alt + LeftArrow' => km::Alt | kb::Left, 'back' ],
				[ '-goforw' => '~Forward' => 'Alt + RightArrow' => km::Alt | kb::Right, 'forward' ],
				[],
				[ '-goup'   => '~Up' => 'Alt + UpArrow' => km::Alt | kb::Up, 'up' ],
				[ '-goprev'   => '~Previous' => 'prev' ],
				[ '-gonext'   => '~Next' => 'next' ],
			]
		], ['-doc', '~Topics', ''],
		[],
		[ '~Help' => [
			[ '~About' => sub {
				$::application-> open_help('Prima::HelpViewer/NAME');
			}],
			[ '~Help' => 'F1' => 'F1' => sub {
				$::application-> open_help('Prima::HelpViewer/Help');
			}],
		]
		]],
		text => 'POD viewer',
		history => [],
		icon    => Prima::StdBitmap::icon(0),
		ownerIcon => 0,
	);
	@$def{keys %prf} = values %prf;
	return $def;
}

sub init
{
	my $self = shift;
	my %profile = $self-> SUPER::init(@_);
	my $t = $self-> font-> height + 2;
	$self-> {text} = $self-> insert( 'Prima::CustomPodView' => 
		origin => [ 0, $t],
		size   => [ $self-> width, $self-> height - $t * 2 - 4],
		growMode => gm::Client,
		current  => 1,
	);

	unless ( defined $defaultVariableFont) {
		$defaultVariableFont = $self-> {text}-> {fontPalette}-> [0]-> {name};
		$defaultFixedFont    = $self-> {text}-> {fontPalette}-> [1]-> {name};
	}
	
	my $enc = ((Prima::Application-> get_system_info-> {apc} == apc::Win32) ?
		'Western' : 
		'iso8859-1'
	); # set a fall-back latin-1 encoding

	$enc = $::application-> font_encodings-> [0] unless 
		grep { $_ eq $enc } @{$::application-> font_encodings};
	if ( defined $enc) {
		$self-> {text}-> {fontPalette}-> [$_]-> {encoding} = $enc for 0, 1;
		$self-> menu-> check( "ENC$enc") if $self-> menu-> has_item( "ENC$enc");
	}

	my ( $x, $y) = ( 0, $self-> height - $t - 4);
	for ( qw(Back Forward Up Prev Next)) {
		my $lc = lc;
		my $text = $_;
		$text = '<<' if $text eq 'Prev';
		$text = '>>' if $text eq 'Next';
		my $b = $self-> insert( Button =>
			text => $text,
			name => $_,
			origin => [ $x, $y],
			height => $t + 4,
			selectable => 0,
			enabled => 0,
			growMode => gm::GrowLoY,
			onClick => sub { $self-> $lc(); }
			
		);
		$x += $b-> width;
	}

	$self-> {status} = $self-> insert( Widget =>
		origin      => [0,0],
		size        => [ $self-> width, $t],
		selectable  => 0,
		growMode    => gm::Floor,
		text        => '',
		onPaint     => sub {
			my ( $self, $canvas) = @_;
			$canvas-> clear;
			$canvas-> text_out_bidi( $self-> text, 1, 1);
		}
	);

	$self-> {fastfinder} = $self-> insert( InputLine =>
		origin      => [0,0],
		size        => [ $self-> width, $t],
		growMode    => gm::Floor,
		text        => '',
		name        => 'FastFinder',
		delegations => ['Change', 'KeyDown'],
		visible     => 0,
	);

	$self-> {stext} = $self-> text;
	$self-> {statusTimer} = $self-> insert( Timer =>
		timeout => 4000,
		onTick => sub {
			$self-> status('');
			$_[0]-> stop;
		},
	);
	
	$self-> {forwardLinks} = [];
	$self-> $_($profile{$_}) for qw(history);


	my $sec = $inifile-> section('View');
	if ( exists $sec-> {FontSize} ) {
		my $fs = $sec-> {FontSize};
		if ( $fs =~ /^\d+$/ && $fs > 4 && $fs < 100) {
			$self-> {text}-> {defaultFontSize} = $fs;
		}
	}
	
	if ( exists $sec-> {FontEncoding} ) {
		my $fe = $sec-> {FontEncoding};
		if ( $self-> menu-> has_item( "ENC$fe")) {
			my $enc = $self-> {text}-> {fontPalette}-> [0]-> {encoding};
			$self-> menu-> uncheck( "ENC$enc") if $self-> menu-> has_item( "ENC$enc");
			$self-> menu-> check( "ENC$fe");
			$self-> {text}-> {fontPalette}-> [$_]-> {encoding} = $fe for 0,1;
		}
	}

	if ( $sec-> {FullText}) {
		$self-> menu-> fullView-> check; 
		$self-> {text}-> topicView(0);
	} else {
		$self-> {text}-> topicView(1);
    }

	$self-> {text}-> {fontPalette}-> [0]-> {name} = $sec-> {VariableFont}
		if $sec-> {VariableFont};
	$self-> {text}-> {fontPalette}-> [1]-> {name} = $sec-> {FixedFont}
		if $sec-> {FixedFont};
	$self-> {text}-> {colorMap}-> [ Prima::PodView::COLOR_CODE_FOREGROUND & ~tb::COLOR_INDEX] = $sec-> {ColorCode}
		if $sec-> {ColorCode};
	$self-> {text}-> {colorMap}-> [ Prima::PodView::COLOR_LINK_FOREGROUND & ~tb::COLOR_INDEX] = $sec-> {ColorLink}
		if $sec-> {ColorLink};

	push @Prima::HelpViewer::helpWindows, $self;

	return %profile;
}

sub on_close
{
	my $self = $_[0];
	my $sec = $inifile-> section('View');

	$sec-> {FontSize}     = $self-> {text}-> {defaultFontSize};
	$sec-> {FontEncoding} = $self-> {text}-> {fontPalette}-> [0]-> {encoding};
	$sec-> {FullText}     = $self-> {text}-> topicView ? 0 : 1;
}

sub on_destroy
{
	my $self = $_[0];
	@Prima::HelpViewer::helpWindows = grep { $_ != $self } @Prima::HelpViewer::helpWindows;
	$inifile-> write;
	$self-> {source_mate}-> close if $self-> {source_mate};
}

sub load_dialog
{
	my $self = $_[0];
	my $file = Prima::open_file(
	filter    => [
		['Documentation' => '*.pod;*.pm;*.pl'],
		['All files' => '*']],
		text     => 'Open manpage',
	);
	return unless defined $file;
	my $mark = $self-> {text}-> make_bookmark;
	$self-> {text}-> load_file( $file);
	$self-> {text}-> notify(q(Bookmark), $mark) if $mark;
}

sub goto
{
	eval "use Prima::MsgBox"; die "$@\n" if $@;
	my $self = $_[0];
	my $ret = Prima::MsgBox::input_box('Go to location', 'Enter manpage:', ''); 
	$self-> {text}-> load_link( $ret) if defined $ret;
}

sub new_window
{
	my $self = $_[0];
	my $new = ref($self)-> create;
	$new-> {text}-> update_view;
	$new-> {text}-> load_bookmark( $self-> {text}-> make_bookmark);
	$new-> select;
}

sub filter_p_class
{
	eval "use Prima::MsgBox"; die "$@\n" if $@;
	my $self = $_[0];
	my $ret = Prima::MsgBox::input_box(
		'Run p-class', 
		'Enter Prima class, or leave empty to see the options list:', 
		''
	);
	return unless defined $ret;
	my $content = `p-class $ret`;
	unless ( length $content) {
		Prima::message("'p-class $ret' returned no data");
		return;
	}
	$content = "=pod\n\n$content\n\n=cut" if $content !~ /=pod/m;
	$self-> {text}-> load_content( $content) if defined $ret;
	$self-> update_menu(1);
	$self-> text( $self-> {stext} . ' - ' . $ret);
}

sub history
{
	return $_[0]-> {history} unless $#_;
	$_[0]-> {history} = $_[1];
}

sub back
{
	my $self = $_[0];
	my $t = $self-> {text};
	my $h = $self-> {history};
	return unless scalar @$h;

	my $mark = $t-> make_bookmark;
	if ( $t-> load_bookmark( pop @$h) == 1) {
		push @{$self-> {forwardLinks}}, $mark;
		$self-> menu-> goforw-> enable;
		$self-> Forward-> enabled(1);
	}
	$self-> menu-> goback-> enabled( scalar @$h );
	$self-> Back-> enabled( scalar @$h );
	$self-> update;
}

sub forward
{
	my $self = $_[0];
	return unless scalar @{$self-> {forwardLinks}};
	my $t = $self-> {text};
	my $h = $self-> {history};

	my $mark = $t-> make_bookmark;
	if ( $t-> load_bookmark( pop @{$self-> {forwardLinks}} ) == 1) {
		push @$h, $mark;
		$self-> menu-> goback-> enable;
		$self-> Back-> enabled(1);
	}
	$self-> menu-> goforw-> enabled( scalar @{$self-> {forwardLinks}} );
	$self-> Forward-> enabled( scalar @{$self-> {forwardLinks}} );
	$self-> update;
}

sub navigate
{
	my ( $self, $mark) = @_;
	return unless $mark;
	my $t = $self-> {text};
	my $h = $self-> {history};

	my $old = $t-> make_bookmark;
	if ( $t-> load_bookmark( $mark ) > 0) {
		push @$h, $old;
		$self-> menu-> goback-> enable;
		$self-> Back-> enabled(1);
	}
	$self-> menu-> goforw-> enabled( 0);
	$self-> {forwardLinks} = [];
	$self-> Forward-> enabled( 0);
	$self-> update;
}

sub up   { $_[0]-> navigate( $_[0]-> {text}-> make_bookmark( 'up')); }
sub prev { $_[0]-> navigate( $_[0]-> {text}-> make_bookmark( 'prev')); }
sub next { $_[0]-> navigate( $_[0]-> {text}-> make_bookmark( 'next')); }

sub update
{
	my $self = $_[0];
	my $t = $self-> {text};
	for my $m ( qw(Up Prev Next)) {
		my $l = lc $m;
		my $mark = $t-> make_bookmark( lc $m);
		$self-> menu-> enabled( "go$l", defined $mark);
		$self-> bring($m)-> enabled( defined $mark);
	}
}

sub doc_goto
{
	my ( $self, $item) = @_;
	my $topic = $self-> menu-> data( $item);
	$self-> {text}-> load_link("topic://$topic");
}
	
sub update_menu
{
	my ( $self, $loaded_ok) = @_;
	# update document menu layout
	my $m = $self-> menu;
	$m-> remove( $$_[0]) for @{$m-> get_items('doc')};
	my $t = $self-> {text};

	if ( $loaded_ok == 1 && scalar @{$t-> {topics}}) {
		my @array;
		my $current = \@array;
		my $level = 0;
		my @stack;
		my $id = -1;
		for ( @{$t-> {topics}}) {
			$id++;
			my ( $start, $end, $text, $style, $depth, $offset) = @$_;
			$depth = $style - Prima::PodView::STYLE_HEAD_1 + $depth;
			$text =~ s/([A-Z]<|>)//g;
		AGAIN: 
			if ( $level == $depth) {
			} elsif ( $level < $depth) {
				my $last = $$current[-1];
				$depth = $level, goto AGAIN unless $last;
				push @stack, [ $level, $current];
				$level = $depth;
				@$last = (@$last[0,1], $current = [[@$last],[]]);
			} elsif ( scalar @stack) {
				($level, $current) = @{pop @stack} 
					while $level > $depth && @stack;
			} else {
				$level = 0;
				$current = \@array;
			}
			push @$current, [ undef, $text, '', kb::NoKey, \&doc_goto, $id];
		}
		$m-> insert( \@array, 'doc', 0);
		$m-> doc-> enabled(1);
		$m-> src-> enabled(1);
	} else {
		$m-> doc-> enabled(0);
		$m-> src-> enabled($loaded_ok > 0);
	}
}

sub status
{ 
	my ( $self, $text) = @_;
	$self-> {status}-> text( $text);
	$self-> {status}-> repaint;
	$self-> {status}-> update_view;
	$self-> {statusTimer}-> stop;
	$self-> {statusTimer}-> start;
}

sub find_dialog
{
	my $self = $_[0];
	my %prf;
	%{$self-> {findData}} = (
		replaceText  => '',
		findText     => '',
		replaceItems => [],
		findItems    => [],
		options      => 0,
		scope        => fds::Cursor,
	) unless defined $self-> {findData};
	my $fd = $self-> {findData};
	my @props = qw(findText options scope);
	if ( $fd) { for( @props) { $prf{$_} = $fd-> {$_}}}
	$finddlg = Prima::FindDialog-> create( text => 'Find text') unless $finddlg;
	$finddlg-> set( %prf);
	$finddlg-> Find-> items($fd-> {findItems});
	my $ret = 0;
	my $rf  = $finddlg-> execute;
	if ( $rf != mb::Cancel) {
		{ for( @props) { $self-> {findData}-> {$_} = $finddlg-> $_()}}
		$self-> {findData}-> {result} = $rf;
		@{$self-> {findData}-> {findItems}} = @{$finddlg-> Find-> items};
		$ret = 1;
	}
	return $ret;
}

sub find_text
{
	my ( $self, $line, $offset, $options) = @_;
	$self = $self-> {text};
	return unless scalar @{$self-> {blocks}};
	$line = '('.quotemeta( $line).')' unless $options & fdo::RegularExpression;

	my @range = $self-> text_range;
	return if $range[0] >= $range[1];
	$offset = $range[0] if $offset < $range[0];
	$offset = $range[1] if $offset > $range[1];
	return if $offset < $range[0];
	
	my ( $re, $re2, $esub);
	$re  = '/';
	$re .= '\\b' if $options & fdo::WordsOnly;
	$re .= "$line";
	$re .= '\\b' if $options & fdo::WordsOnly;
	$re .= '/';
	$re2 = '';
	$re2.= 'i' unless $options & fdo::MatchCase;

	my $dir = ( $options & fdo::BackwardSearch) ? 0 : 1;
	my @opt = $dir ? ( $offset, $range[1] - $offset + 1) : 
					( $range[0], $offset - $range[0]);
	my @text = split('(\n)', substr( ${$self-> {text}}, $opt[0], $opt[1]));
	@text = reverse @text unless $dir;

	
	local $SIG{__WARN__}=sub{};
	$esub = eval(<<FINDER);
sub {
	for ( \@text) {
		\$offset -= length unless $dir;
		if ( $re$re2) {
			\$offset += length(\$`);
			return \$offset, \$offset + length(\$&);
		}
		\$offset += length if $dir;
	}
	return;
}
FINDER
	return unless $esub;
	return $esub-> ();
}

sub do_find
{
	my ( $self, $search_flags) = @_;
	my $t = $self-> {text};
	my $p = $self-> {findData};
	my $flags = ( defined $search_flags) ? $search_flags : $$p{options};
	
	my ( $offset, $offset2);
	if ( defined $self-> {find_offset}) {
	$offset = $self-> {find_offset};
	} else {
		if ( $$p{scope} != fds::Cursor) {
			my @scope = ($$p{scope} == fds::Top) ? (0,0) : (-1,-1);
			$offset = $t-> info2text_offset( @scope);
		} else {
			$offset = $t-> info2text_offset( $t-> xy2info( $t-> offset, $t-> topLine));
		}
	}

	( $offset, $offset2) = $self-> find_text( $$p{findText}, $offset, $flags);
	if ( !defined $offset) {
		$self-> {find_offset} = $t-> info2text_offset(
			( $flags & fdo::BackwardSearch) ?
				(-1,-1):(0,0));
		$self-> status("No text found - new search will continue from " . 
		(( $flags & fdo::BackwardSearch) ? 'bottom' : 'top'));
		return;
	}
	$self-> {find_offset} = ( $flags & fdo::BackwardSearch) ?
		$offset : $offset2;
	$self-> select_findout( $offset, $offset2);
}

sub find
{
	my $self = $_[0];
	return unless $self-> find_dialog;
	undef $self-> {find_offset};
	$self-> do_find;
}

sub find2
{
	my $self = $_[0];
	return unless $self-> {findData};
	$self-> do_find;
}

sub fastfind_close
{
	my $self = $_[0];
	return unless $self-> {fastfinder}-> visible;
	$self-> {fastfinder}-> hide;
	$self-> {text}-> select;
	$self-> menu-> enable($_) for qw( fff ffb frf frb);
	$self-> {text}-> selection(-1,-1,-1,-1);
}

sub fastfind 
{
	my ( $self, $dir) = @_;
	return if $self-> {fastfinder}-> visible;
	my $t = $self-> {text};
	$self-> {fasttrack} = [
		$t-> offset, $t-> topLine,
		$dir ? 0 : fdo::BackwardSearch
	];
	$self-> {find_offset} = $t-> info2text_offset( $t-> xy2info( $t-> offset, $t-> topLine));
	$self-> {fastfinder}-> text('');
	$self-> {fastfinder}-> show;
	$self-> {fastfinder}-> select;
	$self-> menu-> disable($_) for qw( fff ffb frf frb);
}

sub fastfind_repeat
{
	my ( $self, $dir) = @_;
	return unless length $self-> {fastfinder}-> text;
	%{$self-> {findData}} = (
		replaceText  => '',
		findText     => '',
		replaceItems => [],
		findItems    => [],
		options      => 0,
		scope        => fds::Cursor,
	) unless defined $self-> {findData};

	$self-> {findData}-> {findText} = $self-> {fastfinder}-> text;
	$dir = $self-> {fasttrack}-> [2] ? 
		( $dir ? fdo::BackwardSearch : 0) :
		( $dir ? 0 : fdo::BackwardSearch);
	$self-> do_find( $dir | fdo::RegularExpression);
}

sub select_findout
{
	my ( $self, $offset, $offset2) = @_;
	my $t = $self-> {text};
	my ( @sel) = (
		$t-> text_offset2info( $offset),
		$t-> text_offset2info( $offset2),
	);

	if ( 4 == scalar @sel) {
		$t-> selection( @sel);
		my @s = ( $t-> info2xy( @sel[0,1]), $t-> info2xy( @sel[2,3]));
		$sel[0] += $t-> text2xoffset( @sel[0,1]);
		$sel[2] += $t-> text2xoffset( @sel[2,3]);
		my $x = $t-> offset;
		my @sz = $t-> get_active_area( 2, $t-> size);
		$t-> offset( $sel[0]) if $x > $sel[0] || $x + $sz[0] < $sel[2];
		$t-> topLine( $s[1]);
	}
}

sub FastFinder_Change
{
	my ( $self, $ff) = @_;
	my $tx = $ff-> text;
	my $t = $self-> {text};
	$t-> selection(-1,-1,-1,-1);
	if ( length $tx) {
		my ( $o1, $o2) = $self-> find_text( $tx, $self-> {find_offset}, 
			$self-> {fasttrack}-> [2] | fdo::RegularExpression);
		return unless defined $o1;
		$self-> select_findout( $o1, $o2);
	} else {
		$t-> offset( $self-> {fasttrack}-> [0]); 
		$t-> topLine( $self-> {fasttrack}-> [1]);      
	}
}

sub FastFinder_KeyDown
{
	my ( $self, $ff, $code, $key, $mod, $r) = @_;
	if ( $key == kb::Enter) {
		$ff-> clear_event;
		$self-> fastfind_close;
		$self-> fastfind_repeat( 1);
	} elsif ( $key == kb::Esc) {
		$ff-> clear_event;
		$self-> fastfind_close;
		$self-> {text}-> offset( $self-> {fasttrack}-> [0]); 
		$self-> {text}-> topLine( $self-> {fasttrack}-> [1]);      
	}
}

sub print
{
	my $self = $_[0];

	$self-> fastfind_close;

	$prndlg = Prima::PrintSetupDialog-> create unless $prndlg;
	return unless $prndlg-> execute;
	
	my $p = $::application-> get_printer;
	return unless $p-> begin_doc( $self-> {text}-> pageName);

	my $pc = 1;
	$self-> {printing} = 1;

	my @font;
	my $sec = $inifile-> section('View');
	my $printer_font = $p-> get_font;
	unless ( length $sec-> {VariableFont}) {
		$font[0] = $self-> {text}-> {fontPalette}-> [0]-> {name};
		$self-> {text}-> {fontPalette}-> [0]-> {name} = $printer_font-> {name};
	}
	unless ( length $sec-> {FixedFont}) {
		$font[1] = $self-> {text}-> {fontPalette}-> [1]-> {name};
		$self-> {text}-> {fontPalette}-> [1]-> {name} = $printer_font-> {name};
	}

	# change resolution
	my @old_res = $self-> {text}-> resolution;
	$self-> {text}-> resolution( $p-> resolution);

	my $ok = $self-> {text}-> print( $p, sub {
		$self-> status("Printing page $pc. Press ESC to cancel");
		$pc++;
		$::application-> yield;
		return 0 if $self-> {printing} < 0;
		1;
	});
	
	$self-> {text}-> resolution( @old_res);
	
	if ( $ok) {
		$p-> end_doc;
		$self-> status("Printing done");
	} else {
		$self-> status("Printing aborted");
		$p-> abort_doc;
	}

	for ( 0, 1) {
		$self-> {text}-> {fontPalette}-> [$_]-> {name} = $font[$_] if defined $font[$_];
	}
	
	$self-> {printing} = undef;
}

sub setup_dialog
{
	eval "use Prima::VB::VBLoader"; die "$@\n" if $@;
	my $self = $_[0];
	my $t = $self-> {text};
	unless ( defined $setupdlg) {
		Prima::message("$@"), return 
			unless $setupdlg = Prima::VBLoad( 'Prima::HelpViewer.fm');
	}

	my $sec = $inifile-> section('View');
	my ( $of1, $of2) = map { $t-> {fontPalette}-> [$_]-> {name}} (0,1);

	my $ntext = $self-> text;
	$self-> text('Enumerating fonts...');

	my $fe = $t-> {fontPalette}-> [0]-> {encoding};
	my $fonts = $::application-> fonts;
	$setupdlg-> FixFont-> items( ['Default', sort map { 
		$_-> {name}} grep { 
			my $x;
			$x = grep { $fe eq $_ } @{$_-> {encodings}} if $_-> {pitch} == fp::Fixed;
			$x;
		} @$fonts ]);
	$setupdlg-> VarFont-> items( [ 'Default', sort map { 
		$_-> {name}} grep { 
			my $x = grep { $fe eq $_ } @{$_-> {encodings}};
			$x;
		} @$fonts ]);
	$self-> text( $ntext);

	$setupdlg-> VarFont-> text( $sec-> {VariableFont} ? $sec-> {VariableFont} : 'Default');
	$setupdlg-> FixFont-> text( $sec-> {FixedFont} ? $sec-> {FixedFont} : 'Default');
	$setupdlg-> LinkColor-> value( defined($sec-> {ColorLink}) ? $sec-> {ColorLink} :
		$t-> {colorMap}-> [ Prima::PodView::COLOR_LINK_FOREGROUND & ~tb::COLOR_INDEX ]);
	$setupdlg-> CodeColor-> value( defined($sec-> {ColorCode}) ? $sec-> {ColorCode} :
		$t-> {colorMap}-> [ Prima::PodView::COLOR_CODE_FOREGROUND & ~tb::COLOR_INDEX ]);
	
	return if $setupdlg-> execute != mb::OK;

	$t-> {colorMap}-> [ Prima::PodView::COLOR_LINK_FOREGROUND & ~tb::COLOR_INDEX ] = $setupdlg-> LinkColor-> value;
	$t-> {colorMap}-> [ Prima::PodView::COLOR_CODE_FOREGROUND & ~tb::COLOR_INDEX ] = $setupdlg-> CodeColor-> value;

	my $f1 = $setupdlg-> VarFont-> text;
	my $f2 = $setupdlg-> FixFont-> text;

	$sec-> {VariableFont} = ( $f1 eq 'Default' ) ? '' : $f1;
	$sec-> {FixedFont}    = ( $f2 eq 'Default' ) ? '' : $f2;
	$sec-> {ColorLink}    = $setupdlg-> LinkColor-> value;
	$sec-> {ColorCode}    = $setupdlg-> CodeColor-> value;

	$f1 = $defaultVariableFont if $f1 eq 'Default';
	$f2 = $defaultFixedFont if $f2 eq 'Default';
	
	if ( $f1 ne $of1 || $f2 ne $of2) {
		$t-> {fontPalette}-> [0]-> {name} = $f1;
		$t-> {fontPalette}-> [1]-> {name} = $f2;
		$t-> format(1);
	} else {
		$t-> repaint;
	}
}

sub set_encoding
{
	my ( $self, $fe) = @_;

	my $t = $self-> {text};
	my $m = $self-> menu;
	
	$fe =~ s/^ENC//;
	return unless $m-> has_item( "ENC$fe");

	my $enc = $self-> {text}-> {fontPalette}-> [0]-> {encoding};
	$m-> uncheck( "ENC$enc") if $m-> has_item( "ENC$enc");
	$m-> check( "ENC$fe");
	$t-> {fontPalette}-> [$_]-> {encoding} = $fe for 0,1;
	$inifile-> section('View')-> {FontEncoding} = $self-> {text}-> {fontPalette}-> [0]-> {encoding};
	$t-> format(1);
}

sub view_source
{
	my $self = $_[0];
	if ( $self-> {source_mate}) {
		$self-> {source_mate}-> bring_to_front;
		return;
	}
	eval "use Prima::Edit";
	if ( $@) {
		Prima::message($@);
		return;
	}
	my $ff = $self-> {text}-> {source_file};
	return unless defined $ff;
	unless ( open F, $ff) {
		Prima::message("Cannot read $ff:$!");
		return;
	}
	local $/;
	my $src = <F>;
	close F;
	my $w = Prima::Window-> create(
		packPropagate => 0,
		text          => $ff,
		onDestroy     => sub { $self-> {source_mate} = undef },
	);
	my %font = (
		%{$self-> {text}-> {fontPalette}-> [1]},
		size => $self-> {text}-> {defaultFontSize},
	);
	$w-> insert( 'Prima::Edit',
		pack         => { expand => 1, fill => 'both'},
		textRef      => \$src,
		font         => \%font,
		readOnly     => 1,
		syntaxHilite => 1,
	);
	$self-> {source_mate} = $w;
	$self-> {source_mate}-> bring_to_front;
}

1;

__END__

=pod

=head1 NAME

Prima::HelpViewer - the built-in pod file browser

=head1 USAGE

The module presents two packages, C<Prima::HelpViewer>
and C<Prima::PodViewWindow>. Their sole purpose is to serve as a mediator
between C<Prima::PodView> package, the toolkit help interface and the user.
C<Prima::PodViewWindow> includes all the user functionality, including ( but
not limited to :) text search, color and font setup, printing etc.
C<Prima::HelpViewer> provides two methods - C<open> and C<close>, used by
C<Prima::Application> for help viewer invocation.

=head1 Help

The browser can be used to view and print POD
( plain old documentation ) files. See the command overview below for more
detailed description:

=over

=item File

=over

=item Open

Presents a file selection dialog, when the user can select
a file to browse in the viewer. The file must contain POD content,
otherwise a warning is displayed.

=item Goto

Asks for a manpage, that is searched in PATH and the installation
directories. 

=item New window

Opens the new viewer window with the same context.

=item Run

Commands in this group call external processes

=over

=item p-class

p-class is Prima utility for displaying the widget class hierachies.
The command asks for Prima class to display the hierachy information 
for.

=back

=item Print

Provides a dialog, when the user can select the appropriate 
printer device and its options.

Prints the current topic to the selected printer. 

If L<Full text view> menu item is checked, prints the whole manpage.

=item Close window

Closes the window. 

=item Close all windows

Closes all help viewer windows.

=back 

=item View

=over

=item Increase font

Increases the currently selected font by 2 points.

=item Decrease font

Decreases the currently selected font by 2 points.

=item Full text view

If checked, the whole manpage is displayed. Otherwise,
its content is presented as a set of topic, and only one
topic is displayed.

=item Find

Presents a find dialog, where the user can
select the text to search and the search options -
the search direction, scope, and others.

=item Find again

Starts search for the text, entered in the last find dialog,
with the same search options.

=item Fast find

The following commands provide a simple vi-style text search functionality -
character keys ?,/,n,N bound to the commands below:

=over

=item Forward

Presents an input line where a text can be entered; the text search is 
performed parallel to the input.

=item Backward

Same as L<Forward> option, except that the serach direction is backwards.

=item Repeat forward

Repeat the search in the same direction as the initial search was being invoked.

=item Repeat backward

Repeat the search in the reverse direction as the initial search was being invoked.

=back

=item Setup

Presents a setup dialog, where the user can select appropriate fonts and colors.

=back

=item Go

=over

=item Back

Displays the previously visited manpage ( or topic )

=item Forward

Displays the previously visited manpage ( or topic ),
that was left via L<Back> command.

=item Up

Displays the upper level topic within a manpage.

=item Previous

Moves to the previous topic within a manpage.

=item Next

Moves to the next topic within a manpage.

=back

=item Help

=over

=item About

Displays the information about the help viewer.

=item Help

Displays the information about the usage of the help viewer

=back

=back

=head1 AUTHOR

Dmitry Karasik, E<lt>dmitry@karasik.eu.orgE<gt>.

=head1 COPYRIGHT

This program is distributed under the BSD License.


=cut
