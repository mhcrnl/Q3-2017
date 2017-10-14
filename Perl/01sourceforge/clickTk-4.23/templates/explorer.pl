$rDescriptor = {
  'w_command_012' => bless( {
    'parent' => 'w_Menu_011',
    'geom' => undef,
    'order' => undef,
    'id' => 'w_command_012',
    'type' => 'command',
    'opt' => '-label , w_command_012'
  }, 'ctkDescriptor' ),
  'w_command_015' => bless( {
    'parent' => 'w_Menu_014',
    'geom' => undef,
    'order' => undef,
    'id' => 'w_command_015',
    'type' => 'command',
    'opt' => '-label , w_command_015'
  }, 'ctkDescriptor' ),
  'w_Menubutton_010' => bless( {
    'parent' => 'w_Frame_001',
    'geom' => 'pack(-side=>left, -anchor=>nw)',
    'order' => undef,
    'id' => 'w_Menubutton_010',
    'type' => 'Menubutton',
    'opt' => '-relief , flat , -text , w_Menubutton_010 , -justify , left , -state , normal'
  }, 'ctkDescriptor' ),
  'w_Frame_007' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-side=>bottom, -anchor=>sw, -fill=>x, -expand=>1)',
    'order' => undef,
    'id' => 'w_Frame_007',
    'type' => 'Frame',
    'opt' => '-relief , raised , -label , w_Frame_007'
  }, 'ctkDescriptor' ),
  'w_Menu_011' => bless( {
    'parent' => 'w_Menubutton_010',
    'geom' => undef,
    'order' => undef,
    'id' => 'w_Menu_011',
    'type' => 'Menu',
    'opt' => ''
  }, 'ctkDescriptor' ),
  'wr_017' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-side=>top, -anchor=>nw, -fill=>x, -expand=>1)',
    'order' => undef,
    'id' => 'wr_017',
    'type' => 'Frame',
    'opt' => '-borderwidth , 2 , -relief , solid'
  }, 'ctkDescriptor' ),
  'w_Frame_001' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-anchor=>nw, -side=>top, -fill=>x, -expand=>1)',
    'order' => undef,
    'id' => 'w_Frame_001',
    'type' => 'Frame',
    'opt' => '-relief , flat , -background , #ffffff , -label , w_Frame_001'
  }, 'ctkDescriptor' ),
  'w_Menubutton_013' => bless( {
    'parent' => 'w_Frame_001',
    'geom' => 'pack(-side=>right, -anchor=>ne)',
    'order' => undef,
    'id' => 'w_Menubutton_013',
    'type' => 'Menubutton',
    'opt' => '-relief , flat , -text , w_Menubutton_013 , -justify , left , -state , normal'
  }, 'ctkDescriptor' ),
  'mw' => bless( {
    'parent' => undef,
    'geom' => undef,
    'order' => undef,
    'id' => 'mw',
    'type' => 'Frame',
    'opt' => undef
  }, 'ctkDescriptor' ),
  'wr_015' => bless( {
    'parent' => 'wr_017',
    'geom' => 'pack(-side=>left, -anchor=>nw, -fill=>both, -expand=>1)',
    'order' => undef,
    'id' => 'wr_015',
    'type' => 'ScrolledROText',
    'opt' => 'ROText , -state , normal , -relief , sunken , -scrollbars , se , -wrap , none'
  }, 'ctkDescriptor' ),
  'w_Label_016' => bless( {
    'parent' => 'w_Frame_007',
    'geom' => 'pack(-side=>left, -anchor=>nw, -fill=>x, -expand=>1)',
    'order' => undef,
    'id' => 'w_Label_016',
    'type' => 'Label',
    'opt' => '-relief , ridge , -background , #ffffff , -text , \'Statusbar 1\' , -justify , left'
  }, 'ctkDescriptor' ),
  'w_Menu_014' => bless( {
    'parent' => 'w_Menubutton_013',
    'geom' => undef,
    'order' => undef,
    'id' => 'w_Menu_014',
    'type' => 'Menu',
    'opt' => ''
  }, 'ctkDescriptor' ),
  'wr_024' => bless( {
    'parent' => 'wr_017',
    'geom' => 'pack(-fill, both, -expand, 1, -anchor, nw, -side, left)',
    'order' => '$wr_024 -> configure(); $wr_016 = $wr_024 -> packAdjust ( -side , \'left\'  );',
    'id' => 'wr_024',
    'type' => 'ScrolledListbox',
    'opt' => '\'Listbox\' , -background , \'#ffffff\' , -selectmode , \'single\' , -relief , \'flat\' , -scrollbars , \'se\' '
  }, 'ctkDescriptor' ),
  'w_Label_017' => bless( {
    'parent' => 'w_Frame_007',
    'geom' => 'pack(-side=>right, -anchor=>se, -fill=>x, -expand=>1)',
    'order' => undef,
    'id' => 'w_Label_017',
    'type' => 'Label',
    'opt' => '-relief , ridge , -text , \'Statusbar 2\' , -justify , left'
  }, 'ctkDescriptor' )
};
$rTree = [
  'mw',
  'mw.w_Frame_001',
  'mw.wr_017',
  'mw.w_Frame_007',
  'mw.w_Frame_001.w_Menubutton_010',
  'mw.w_Frame_001.w_Menubutton_013',
  'mw.w_Frame_007.w_Label_016',
  'mw.w_Frame_007.w_Label_017',
  'mw.wr_017.wr_024',
  'mw.wr_017.wr_015',
  'mw.w_Frame_001.w_Menubutton_013.w_Menu_014',
  'mw.w_Frame_001.w_Menubutton_010.w_Menu_011',
  'mw.w_Frame_001.w_Menubutton_013.w_Menu_014.w_command_015',
  'mw.w_Frame_001.w_Menubutton_010.w_Menu_011.w_command_012'
];
$rUser_subroutines = [
  'sub init { 1 }'
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
  'title' => 'File Explorer',
  'subWidgetList' => [],
  'modalDialogClassName' => 'DialogBox',
  'description' => 'Set up a dialog to explore structures.',
  'autoExtract2Local' => '1',
  'code' => '0',
  'onDeleteWindow' => 'sub{exit}',
  'treewalk' => 'D',

  'baseClass' => ''
};
$rProjectName = \'.\\project\\explorer.pl';
$ropt_isolate_geom = \'0';
$rHiddenWidgets = [];
$rLibraries = [];
$rApplName = \'';
$rApplFolder = \'';
$opt_TestCode = \'1';
$rBaseClass = [];
