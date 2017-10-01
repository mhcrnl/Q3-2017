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
#  Created by Dmitry Karasik <dk@plab.ku.dk>
#  $Id$
#
#  Setup dialog management

use strict;
use warnings;
use Prima::PS::Printer;
package Prima::PS::Printer;


sub sdlg_export
{
	my ( $self, $p) = @_;
	my $d = $self-> {setupDlg}-> TabbedNotebook1-> Notebook;
	my $i  = $d-> VList-> items;
	my $a = 0;
	my %hk = map { $$_[0] => $a++ } @$i;
	$p-> {color}      = $d-> Color-> index ? 1 : 0;
	$p-> {portrait}   = $d-> Orientation-> index ? 0 : 1;
	$p-> {scaling}    = $d-> Scaling-> value / 100;
	$p-> {resolution} = $d-> Resolution-> value;
	$p-> {copies}     = $d-> CopyCount-> text;
	$p-> {page}       = $d-> PaperSize-> text;
	$p-> {devParms}   = { map { my $j = $i-> [ $hk{ $_}]; @$j[0,3] } keys %{$self-> {data}-> {devParms}}};
	$p-> {useDeviceFontsOnly} = $i-> [ $hk{UseDeviceFontsOnly}]-> [3];
	$p-> {useDeviceFonts} = $i-> [ $hk{UseDeviceFonts}]-> [3];
	$p-> {useDeviceFonts} = 1 if $p-> {useDeviceFontsOnly};
	$p-> {isEPS} = $i-> [ $hk{IsEPS}]-> [3];
	$p-> {spoolerType} = $d-> Spool-> index;
	$p-> {spoolerData} = $d-> Spool-> bring(( $p-> {spoolerType} == lpr) ? 'LParams' : 'CmdLine')-> text;
}

sub sdlg_import
{
	my ( $self, $p) = @_;
	my $d = $self-> {setupDlg}-> TabbedNotebook1-> Notebook;
	
	$d-> Color->       index( $p-> {color} ? 1 : 0);
	$d-> Orientation-> index( $p-> {portrait} ? 0 : 1);
	$d-> Scaling->     value( int( $p-> {scaling} * 100));
	$d-> Resolution->  value( int( $p-> {resolution}));
	$d-> CopyCount->   value( int( $p-> {copies}));
	$d-> PaperSize->   text( $p-> {page});

	my $i  = $d-> VList-> items;
	my $a = 0;
	my %hk = map { $$_[0] => $a++ } @$i;
	for ( keys %{$p-> {devParms}}) {
		my $j = $i-> [ $hk{$_}];
		$j-> [3] = $p-> {devParms}-> {$_};
	}

	$i-> [ $hk{UseDeviceFontsOnly}]-> [3] = $p-> {useDeviceFontsOnly};
	$i-> [ $hk{UseDeviceFonts}]-> [3] = $p-> {useDeviceFonts};
	$i-> [ $hk{UseDeviceFonts}]-> [3] = 1 if $p-> {useDeviceFontsOnly}; 
	$i-> [ $hk{IsEPS}]-> [3] = $p-> {isEPS};

	for ( @$i) {
		if ( $$_[2] == 0) {
			$$_[1] = $$_[3];
		} elsif ( $$_[2] == 1) {
			$$_[1] = $$_[3] ? 'Yes' : 'No';
		} elsif ( $$_[2] == 2) {
			my $i = $d-> ValueBox-> ValueBook-> VCombo-> items;
			$$_[1] = $i-> [ $$_[3] ];
		}
	}

	$p-> {spoolerType} = file if $p-> {spoolerType} == lpr && !$unix;
	my $sp = $d-> Spool;
	$sp-> index( $p-> {spoolerType});
	$sp-> CmdLine-> text( '');
	$sp-> LParams-> text( '');
	$sp-> bring( ($p-> {spoolerType} == lpr) ? 'LParams' : 'CmdLine')-> text( $p-> {spoolerData});
}


sub sdlg_exec
{
	my $self = $_[0];
	
	unless ( defined $self-> {setupDlg}) {
		eval "use Prima::VB::VBLoader"; die "$@\n" if $@;
		eval "use Prima::MsgBox"; die "$@\n" if $@;
		$self-> {setupDlg} = Prima::VBLoad( 'Prima::PS::setup.fm', 
		'Form1'     => { visible => 0, centered => 1, designScale => [ 7, 16 ]},
		'PaperSize' => { items => [ sort keys %pageSizes ], },
		'OK'        => {
			onClick => sub { 
				my $t = $_[0]-> owner-> TabbedNotebook1-> Notebook;
				my $x = $t-> Profiles;
				my $i = $x-> get_items( $x-> focusedItem);
				$self-> sdlg_export( $self-> {vprinters}-> { $i});
				if ( $i ne $self-> {current}) {
					return if Prima::MsgBox::message_box( 
						$self-> {setupDlg}-> text, 
						"Current settings do not belong to printer \'$self->{current}\'. Procced anyway?",
						mb::Warning|mb::OKCancel) != mb::OK;
				}
				unless ( exists $self-> {vprinters}-> {$self-> {current}}) {
					Prima::MsgBox::message_box(  $self-> {setupDlg}-> text,
					"Printer profile \'$self->{current}\' is not present. Please create one",
					mb::Error|mb::OK);
					return;
				}
			RETRY_SAVE:   
				if ( $self-> {bigChange}) {
					my $res = Prima::MsgBox::message_box( $self-> {setupDlg}-> text,
						"The printer profile configurations have been changed significantly. Would you like to save them?",
						mb::Warning|mb::YesNoCancel);
					if ( $res == mb::Yes) {    
						$t-> SaveBtn-> notify(q(Click));
						goto RETRY_SAVE;
					} elsif ( $res != mb::No) {
						return;
					}
				}           
				$_[0]-> owner-> ok;
			}
		},
		'Profiles' => { onSelectItem => sub {
				my ( $me, $index, $state) = @_;
				$index = $$index[0];
				if ( defined $self-> {lastFocItem}) {
					$self-> sdlg_export( 
						$self-> {vprinters}-> { 
							$me-> get_items( $self-> {lastFocItem})
						}
					);
				}   
				$self-> sdlg_import( 
					$self-> {vprinters}-> { $me-> get_items( $index)}
				);
				$me-> owner-> VList-> notify(q(SelectItem), 
					[ $me-> owner-> VList-> focusedItem], 1
				);
				$self-> {lastFocItem} = $index;
		}},
		'AddBtn' => { onClick => sub {
			my $x = $_[0]-> owner-> Profiles;
			my $n = 1;
			my $vp = $self-> {vprinters};
			while ( 1) {           
				last unless exists $vp-> {"New <$n>"};
				$n++;
			}
			$n = "New <$n>";
			$vp-> {$n} = deepcopy( $self-> {defaultData});
			$x-> add_items( $n);
			$self-> {bigChange} = 1;
		}},
		'DelBtn' => { onClick  => sub {
			my $x = $_[0]-> owner-> Profiles;
			my $f = $x-> focusedItem;
			my $i = $x-> get_items( $f);
			return if ( $i eq $self-> {current}) && ( Prima::MsgBox::message_box(
				$self-> {setupDlg}-> text, 
				"This profile is for currently selected printer, and should not be deleted. Proceed anyway?",
				mb::Warning|mb::OKCancel) != mb::OK);
			if ( $x-> count == 1) {
				Prima::message("At least one printer profile should be always present.");
				return;
			}
			$x-> delete_items( $f);
			delete $self-> {vprinters}-> {$i};
			$self-> {bigChange} = 1;
			$self-> {lastFocItem} = undef;
			$x-> focusedItem( $f ? $f - 1 : 0);
		}},
		'RenameBtn' => { onClick => sub {
			my $x = $_[0]-> owner-> Profiles;
			my $i = $x-> get_items( $x-> focusedItem);
		AGAIN:   
			my $n = Prima::MsgBox::input_box( 
				'Rename printer profile', 
				'Enter new name:', $i
			);
			return unless defined $n;
			if (( $n ne $i) && exists ( $self-> {vprinters}-> {$n})) {
				Prima::message( "Profile \'$n\' already exists");
				goto AGAIN;
			}
			$self-> {vprinters}-> {$n} = $self-> {vprinters}-> {$i};
			delete $self-> {vprinters}-> {$i};
			my @i = @{$x-> items};
			$i[$x-> focusedItem] = $n;
			$x-> items( \@i);
			$self-> {bigChange} = 1;
		}},
		'SaveBtn' => { onClick => sub {
			my $n = $self-> {resFile};
			my $x = $_[0]-> owner-> Profiles;
			$self-> sdlg_export( 
				$self-> {vprinters}-> { $x-> get_items( $x-> focusedItem)}
			);
			unless ( -f $n) {
				my $x = $n;
				$x =~ s/[\\\/]?[^\\\/]+$//;
				unless ( -d $x) {
					eval "use File::Path"; die "$@\n" if $@;
					File::Path::mkpath( $x);
				}
			}
		SAVE:   
			unless ( open F, "> $n") {
				goto SAVE if Prima::MsgBox::message_box( $self-> {setupDlg}-> text,
				"Error writing to '$n':$!", mb::Retry|mb::Cancel) == mb::Retry;
				return;
			}
			print F "# Prima toolkit postscript printer configuration file\n{\n";
			for ( keys %{$self-> {vprinters}}) {
				my $z = $_;
				$z =~ s/(\\|\')/\\$1/g;
				print F "'$z' => {\n";
				my $p = $self-> {vprinters}-> {$_};
				for ( keys %$p) {
					next if $_ eq 'devParms';
					$z = $$p{$_};
					$z =~ s/(\\|\')/\\$1/g;
					print F "$_ => '$z',\n";
				}
				print F "devParms => {\n";
				$p = $p-> {devParms};
				for ( keys %$p) {
					$z = $$p{$_};
					$z =~ s/(\\|\')/\\$1/g;
					print F "\t$_ => '$z',\n";
				}
				print F "}},\n";
			}
			print F "}\n";
			close F;
			$self-> {printers} = { map { $_ => deepcopy($self-> {vprinters}-> {$_}) } 
				keys %{$self-> {vprinters}}};
			$self-> {bigChange} = 0;
		}},
		'ImportBtn' => { onClick => sub {
			my $c = Prima::MsgBox::input_box( "Import printer resources", 
				"Enter file name:", "/etc/printcap");
			return unless defined $c;
			my @imported = $self-> import_printers( 'vprinters', $c);
			if ( @imported) {
				if ( defined $imported[0]) {
					$_[0]-> owner-> Profiles-> add_items( @imported);
					$self-> {bigChange} = 1;
				} else {
					Prima::message( "Error opening '$c':$!");
				}
			} else {
				Prima::message("No importable resources found");
			}
		}},
		);
		Prima::message("$@"), return unless $self-> {setupDlg};
		unless ( $self-> {setupDlg}) { Prima::message( $@ ); return }
		$self-> {setupDlg}-> TabbedNotebook1-> Notebook-> VList-> focusedItem( 0);
	}
	
	my $d = $self-> {setupDlg}-> TabbedNotebook1-> Notebook;
	my $p = $self-> {data};
	
	$self-> {bigChange} = 0;
	
	$d-> Profiles-> focusedItem( -1);
	$d-> Profiles-> items( [ keys %{$self-> {printers}}]);
	$self-> {vprinters} = { map { $_ => deepcopy($self-> {printers}-> {$_}) } 
		keys %{$self-> {printers}}};
	my $index = 0;   
	for ( keys %{$self-> {printers}}) {
		last if $_ eq $self-> {current};
		$index++;
	}
	$self-> {lastFocItem} = undef;
	$d-> Profiles-> focusedItem( $index);
	
	$self-> sdlg_import( $p);
	return if $self-> {setupDlg}-> execute != mb::OK;
	$p = {};
	$self-> sdlg_export( $p);
	$self-> data( $p);
}

1;
