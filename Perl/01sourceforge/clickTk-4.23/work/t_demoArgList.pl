$rDescriptor = {
  'mw' => bless( {
    'parent' => undef,
    'geom' => undef,
    'order' => undef,
    'id' => 'mw',
    'type' => 'Frame',
    'opt' => undef
  }, 'ctkDescriptor' ),
  'wr_002' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-side=>top, -anchor=>nw, -fill=>x, -expand=>1)',
    'order' => undef,
    'id' => 'wr_002',
    'type' => 'Label',
    'opt' => '-background , #7df3ffffffff , -justify , left , -text , \'unit test linux\' , -relief , flat'
  }, 'ctkDescriptor' ),
  'wr_004' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-side=>top, -anchor=>nw, -fill=>x, -expand=>1)',
    'order' => undef,
    'id' => 'wr_004',
    'type' => 'Button',
    'opt' => '-background , #0000ffffffff , -command , \\&do_exit , -state , normal , -text , Exit'
  }, 'ctkDescriptor' ),
  'wr_003' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-anchor=>nw, -side=>top, -fill=>x, -expand=>1)',
    'order' => '$wr_003->configure(-bg => \'blue\');',
    'id' => 'wr_003',
    'type' => 'Button',
    'opt' => '-background , #ffff00000000 , -command , \\&colorRed , -state , normal , -text , \'Color arg label red\''
  }, 'ctkDescriptor' ),
  'wr_001' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-side=>top, -anchor=>nw, -fill=>x, -expand=>1)',
    'order' => undef,
    'id' => 'wr_001',
    'type' => 'Label',
    'opt' => '-anchor , nw , -justify , left , -relief , flat , -text , $args{-labeltext} , -font , $args{-font}'
  }, 'ctkDescriptor' )
};
$rTree = [
  'mw',
  'mw.wr_002',
  'mw.wr_001',
  'mw.wr_003',
  'mw.wr_004'
];
$rUser_subroutines = [
  'sub init { 1 }',
  'sub do_exit { ',
  'exit(0)',
  '}',
  'sub colorRed {',
  '	$wr_001->configure(-background => \'red\');',
  '}'
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
  'autoExtractVariables' => '1',
  'subroutineName' => 'useThisArgList',
  'subWidgetList' => [],
  'description' => 'Demo Args',
  'autoExtract2Local' => '0',
  'baseClass' => '',
  'strict' => '0',
  'subroutineArgs' => '-title , \'Demo argList\', -labeltext => \'demo ArgList\',-font => [-family,\'Bradley Hand ITC\',-size,16,-weight,\'bold\',-slant,\'roman\',-underline,0 ,-overstrike,0]      ',
  'Toplevel' => '1',
  'subroutineArgsName' => '%args',
  'title' => 'Demo subroutine arg list',
  'modalDialogClassName' => 'DialogBox',
  'code' => 0,
  'onDeleteWindow' => 'sub{1}'
};
$rProjectName = \'.\\project\\t_demoArgList.pl';
$ropt_isolate_geom = \'0';
$rHiddenWidgets = [];
$rLibraries = [];
$rApplName = \'';
$rApplFolder = \'';
$opt_TestCode = \'1';
$rBaseClass = [];
