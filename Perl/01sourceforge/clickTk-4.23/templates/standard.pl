$rDescriptor = {
  '' => bless( {}, 'ctkDescriptor' ),
  'w_Menu_005' => bless( {
    'parent' => 'w_Menubutton_004',
    'geom' => '',
    'id' => 'w_Menu_005',
    'type' => 'Menu',
    'opt' => '-background, #ffffff, -foreground, #000000, -tearoff, 0, -relief, raised'
  }, 'ctkDescriptor' ),
  'w_Menu_008' => bless( {
    'parent' => 'w_Menubutton_007',
    'geom' => '',
    'id' => 'w_Menu_008',
    'type' => 'Menu',
    'opt' => '-background, #ffffff, -tearoff, 0, -relief, raised, -foreground, #000000'
  }, 'ctkDescriptor' ),
  'w_Menubutton_004' => bless( {
    'parent' => 'w_Frame_001',
    'geom' => 'pack(-anchor,nw,-side,left)',
    'id' => 'w_Menubutton_004',
    'type' => 'Menubutton',
    'opt' => '-background, #ffffff, -foreground, #000000, -state, normal, -justify, left, -relief, raised, -text, File'
  }, 'ctkDescriptor' ),
  'w_Menubutton_007' => bless( {
    'parent' => 'w_Frame_001',
    'geom' => 'pack(-anchor,ne,-side,right)',
    'id' => 'w_Menubutton_007',
    'type' => 'Menubutton',
    'opt' => '-background, #ffffff, -foreground, #000000, -state, normal, -justify, left, -relief, raised, -text, Help'
  }, 'ctkDescriptor' ),
  'w_Frame_003' => bless( {
    'parent' => 'mw',
    'geom' => 'pack()',
    'id' => 'w_Frame_003',
    'type' => 'Frame',
    'opt' => '-background, #f3f3f3, -relief, flat'
  }, 'ctkDescriptor' ),
  'w_command_006' => bless( {
    'parent' => 'w_Menu_005',
    'geom' => '',
    'id' => 'w_command_006',
    'type' => 'command',
    'opt' => '-label, Exit, -command, \\&do_exit'
  }, 'ctkDescriptor' ),
  'w_Frame_001' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-fill,x,-expand,1,-anchor,nw,-side,top)',
    'id' => 'w_Frame_001',
    'type' => 'Frame',
    'opt' => '-background, #fbfbfb, -relief, raised'
  }, 'ctkDescriptor' ),
  'w_Label_010' => bless( {
    'parent' => 'w_Frame_002',
    'geom' => 'pack(-fill,x,-expand,1,-anchor,nw,-side,left)',
    'id' => 'w_Label_010',
    'type' => 'Label',
    'opt' => '-background, #f8f8f8, -justify, left, -relief, flat, -text, Statusbar'
  }, 'ctkDescriptor' ),
  'w_command_009' => bless( {
    'parent' => 'w_Menu_008',
    'geom' => '',
    'id' => 'w_command_009',
    'type' => 'command',
    'opt' => '-label, help, -command, \\&do_help'
  }, 'ctkDescriptor' ),
  'mw' => bless( {
    'parent' => undef,
    'geom' => undef,
    'order' => undef,
    'opt' => undef,
    'type' => 'Frame',
    'id' => 'mw'
  }, 'ctkDescriptor' ),
  'w_Frame_002' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-fill,x,-expand,1,-anchor,sw,-side,bottom)',
    'id' => 'w_Frame_002',
    'type' => 'Frame',
    'opt' => '-background, #f7f7f7, -relief, ridge'
  }, 'ctkDescriptor' )
};
$rTree = [
  'mw',
  'mw.w_Frame_001',
  'mw.w_Frame_001.w_Menubutton_004',
  'mw.w_Frame_001.w_Menubutton_007',
  'mw.w_Frame_001.w_Menubutton_007.w_Menu_008',
  'mw.w_Frame_001.w_Menubutton_007.w_Menu_008.w_command_009',
  'mw.w_Frame_001.w_Menubutton_004.w_Menu_005',
  'mw.w_Frame_001.w_Menubutton_004.w_Menu_005.w_command_006',
  'mw.w_Frame_003',
  'mw.w_Frame_002',
  'mw.w_Frame_002.w_Label_010'
];
$rUser_subroutines = [
  'sub do_exit {',
  '	exit',
  '}',
  '',
  'sub do_help {',
  '',
  '}'
];
$rUser_methods_code = [];
$rUser_gcode = [];
$rOther_code = [];
$rUser_pod = [];
$rUser_auto_vars = [];
$rUser_local_vars = [];
$rFile_opt = {
  'Toplevel' => '1',
  'subroutineArgs' => '',
  'strict' => '0',
  'modal' => '0',
  'subroutineArgsName' => '%args',
  'autoExtractVariables' => '1',
  'subroutineName' => 'thisDialog',
  'title' => 'Main dialog',
  'subWidgetList' => [],
  'modalDialogClassName' => 'DialogBox',
  'description' => 'Set up application\'s main dialog.',
  'autoExtract2Local' => '1',
  'code' => '0',
  'onDeleteWindow' => 'sub{exit}',
  'treewalk' => 'D',
  'baseClass' => '',
  'title' => 'Tk application',
  'description' => 'template 001',
  'code' => '1'
};
$rProjectName = \undef;
$ropt_isolate_geom = \undef;
$rHiddenWidgets = [];
$rLibraries = [];
$rApplName = \'';
$rApplFolder = \'';
$opt_TestCode = \'1';
