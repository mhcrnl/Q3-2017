$rDescriptor = {
  'mw' => bless( {
    'parent' => undef,
    'geom' => undef,
    'order' => undef,
    'id' => 'mw',
    'type' => 'Frame',
    'opt' => undef
  }, 'ctkDescriptor' ),
  'wr_actions' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-anchor=>nw, -side=>top, -pady=>10, -fill=>x, -expand=>1, -padx=>10)',
    'order' => '$mw->Subwidget(\'B_OK\')->configure(-command,\\&do_OK);
$mw->Subwidget(\'B_Cancel\')->configure(-command,\\&do_Cancel);',
    'id' => 'wr_actions',
    'type' => 'Frame',
    'opt' => '-borderwidth , 1 , -relief , sunken'
  }, 'ctkDescriptor' ),
  'wr_data' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-anchor=>nw, -side=>top, -pady=>10, -fill=>both, -expand=>1, -padx=>10)',
    'order' => undef,
    'id' => 'wr_data',
    'type' => 'Frame',
    'opt' => '-borderwidth , 1 , -relief , sunken'
  }, 'ctkDescriptor' )
};
$rTree = [
  'mw',
  'mw.wr_data',
  'mw.wr_actions'
];
$rUser_subroutines = [
  'sub init { 1 }',
  '',
  'sub do_OK {',
  '	exit(0)',
  '}',
  '',
  'sub do_Cancel {',
  '	exit(0)',
  '}'
];
$rUser_methods_code = [];
$rUser_gcode = [];
$rOther_code = [];
$rUser_pod = [];
$rUser_auto_vars = [];
$rUser_local_vars = [];
$rFile_opt = {
  'modal' => '1',
  'autoExtractVariables' => '1',
  'treewalk' => 'B',
  'subroutineName' => 'thisDialog',
  'subWidgetList' => [],
  'description' => 'Template',
  'autoExtract2Local' => '1',
  'baseClass' => '',
  'strict' => '0',
  'subroutineArgs' => '-title , \'???\'',
  'Toplevel' => '1',
  'subroutineArgsName' => '%args',
  'title' => 'Modal dialog',
  'modalDialogClassName' => 'DialogBox',
  'code' => '0',
  'buttons' => ' OK Cancel',
  'onDeleteWindow' => 'sub{1}'
};
$rProjectName = \'noname.pl';
$ropt_isolate_geom = \'0';
$rHiddenWidgets = [];
$rLibraries = [];
$rApplName = \'';
$rApplFolder = \'';
$opt_TestCode = \'1';
$rBaseClass = [];
