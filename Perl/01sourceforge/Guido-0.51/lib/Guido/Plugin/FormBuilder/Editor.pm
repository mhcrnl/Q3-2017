package Guido::Plugin::FormBuilder::Editor;

use Tk;
use Guido::PropertyPageDialog;
use Data::Dumper;
use base qw(Tk::Frame);
use Tk::widgets qw(LabEntry);

Construct Tk::Widget 'Guido::Plugin::FormBuilder::Editor';

sub Populate {
	my ($cw, $args) = @_;

	$cw->{_config_} = delete $args->{-config};

	if (!defined($cw->{_config_}->{plugindata}->{FormBuilder}->{default_widget_type})) {
	  $cw->{_config_}->{plugindata}->{FormBuilder}->{default_widget_type} = 'TkWidget';
	}

	$cw->LabEntry(
		-label=>'Default Widget Type',
		-textvariable=>\$cw->{_config_}->{plugindata}->{FormBuilder}->{default_widget_type},
	)->pack();	
}


1;
