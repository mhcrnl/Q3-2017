package Guido::Plugin::Toolbox::Editor;

use Tk;
use Guido::PropertyPageDialog;
use Data::Dumper;
use base qw(Tk::Frame);
use Tk::widgets qw(LabEntry);

Construct Tk::Widget 'Guido::Plugin::Toolbox::Editor';

sub Populate {
    my ($cw, $args) = @_;
    
    $cw->{_config_} = delete $args->{-config};
    $tb_config = $cw->{_config_}->{plugindata}->{Toolbox};
    $tb_config->{icon_search_path} = "" if ref($tb_config->{icon_search_path});
    
    $cw->LabEntry(
	-label=>'Icon search path',
	-textvariable=>\$cw->{_config_}->{plugindata}->{Toolbox}->{icon_search_path},
       )->pack();	
}

1;

