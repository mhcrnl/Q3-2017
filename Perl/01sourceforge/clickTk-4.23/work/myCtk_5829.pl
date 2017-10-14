$rDescriptor = {
  'mw' => bless( {
    'order' => undef,
    'id' => 'mw',
    'parent' => undef,
    'geom' => undef,
    'opt' => undef,
    'type' => 'Frame'
  }, 'ctkDescriptor' ),
  'wr_001' => bless( {
    'id' => 'wr_001',
    'order' => '',
    'type' => 'Button',
    'parent' => 'mw',
    'opt' => '-font , \'wr_001\' , -underline , 0 , -text , \'wr_001\' , -state , \'normal\' ',
    'geom' => 'pack()'
  }, 'ctkDescriptor' )
};
$rTree = [
  'mw',
  'mw.wr_001'
];
$rUser_subroutines = [
  'sub init { 1 }
'
];
$rUser_methods_code = [
  'sub arglist {
',
  'my $self=shift;
',
  'my $args = shift;
',
  'return $args
',
  '}
'
];
$rUser_gcode = [];
$rOther_code = [];
$rUser_pod = [];
$rUser_auto_vars = [];
$rUser_local_vars = [];
$rFile_opt = {
  'subroutineArgsName' => '%args',
  'modalDialogClassName' => 'DialogBox',
  'subroutineArgs' => '-title , \'???\'',
  'Toplevel' => '1',
  'strict' => 0,
  'title' => '',
  'subWidgetList' => [],
  'autoExtract2Local' => 1,
  'onDeleteWindow' => 'sub{1}',
  'buttons' => ' ',
  'baseClass' => '',
  'code' => 0,
  'description' => '',
  'autoExtractVariables' => 1,
  'modal' => 0,
  'subroutineName' => 'thisDialog',
  'treewalk' => 'D'
};
$rProjectName = \'myCtk.pl';
$ropt_isolate_geom = \'0';
$rHiddenWidgets = [];
$rLibraries = [];
$rApplName = \'';
$rApplFolder = \'';
$opt_TestCode = \'1';
$rBaseClass = [];
$rwork_save_temp = \1;
