$rDescriptor = {
  'wr_001' => bless( {
    'parent' => 'mw',
    'geom' => 'pack()',
    'order' => undef,
    'id' => 'wr_001',
    'type' => 'Label',
    'opt' => '-anchor , nw , -justify , left , -relief , flat , -text , $args{-labeltext} , -font , $args{-font}'
  }, 'ctkDescriptor' ),
  'mw' => bless( {
    'parent' => undef,
    'geom' => undef,
    'order' => undef,
    'id' => 'mw',
    'type' => 'Frame',
    'opt' => undef
  }, 'ctkDescriptor' )
};
$rTree = [
  'mw',
  'mw.wr_001'
];
$rUser_subroutines = [
  'sub init { ',
  '%args = (-title , \'Demo global argList\',',
  ' -labeltext => \'demo ArgList\',',
  ' -font => [-family,\'Bradley Hand ITC\',-size,16,-weight,\'bold\',-slant,\'roman\',-underline,0 ,-overstrike,0])',
  ' }'
];
$rUser_methods_code = [];
$rUser_gcode = [];
$rOther_code = [];
$rUser_pod = [];
$rUser_auto_vars = [
  '%args'
];
$rUser_local_vars = [];
$rFile_opt = {
  'modal' => '1',
  'subWidgetlist' => [],
  'autoExtractVariables' => '1',
  'subroutineName' => 'useglobalArgList',
  'description' => 'Demo global Args',
  'autoExtract2Local' => '0',
  'baseClass' => '',
  'Toplevel' => '1',
  'subroutineArgs' => '',
  'strict' => '0',
  'title' => 'Demo subroutine arg list',
  'code' => '0',
  'onDeleteWindow' => 'sub{1}'
};
$rLastfile = \'t_demoGlobalArgList.pl';
$ropt_isolate_geom = \'0';
$rHiddenWidgets = [];
$rLibraries = [];
$rApplName = \'';
$rApplFolder = \'';
$opt_TestCode = \'1';
