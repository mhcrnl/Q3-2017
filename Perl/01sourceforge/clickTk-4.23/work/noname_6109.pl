$rDescriptor = {
  'mw' => bless( {
    'type' => 'Frame',
    'geom' => undef,
    'parent' => undef,
    'order' => undef,
    'id' => 'mw',
    'opt' => undef
  }, 'ctkDescriptor' )
};
$rTree = [
  'mw'
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
  'autoExtract2Local' => '1',
  'code' => 1,
  'treewalk' => 'D',
  'subroutineArgsName' => '%args',
  'title' => '',
  'baseClass' => '',
  'Toplevel' => '1',
  'subWidgetList' => [],
  'strict' => '0',
  'buttons' => ' ',
  'subroutineArgs' => '-title , \'???\'',
  'modal' => '0',
  'description' => '',
  'modalDialogClassName' => 'DialogBox',
  'subroutineName' => 'thisDialog',
  'onDeleteWindow' => 'sub{1}',
  'autoExtractVariables' => '1'
};
$rProjectName = \'noname.pl';
$ropt_isolate_geom = \'0';
$rHiddenWidgets = [];
$rLibraries = [];
$rApplName = \'';
$rApplFolder = \'';
$opt_TestCode = \'1';
$rBaseClass = [];
$rwork_save_temp = \1;
