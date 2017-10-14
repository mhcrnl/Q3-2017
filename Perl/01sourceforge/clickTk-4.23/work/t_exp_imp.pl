$rDescriptor = {
  'wr_017' => bless( {
    'parent' => 'wr_016',
    'geom' => undef,
    'order' => undef,
    'id' => 'wr_017',
    'type' => 'Menu',
    'opt' => ''
  }, 'ctkDescriptor' ),
  'wr_018' => bless( {
    'parent' => 'wr_017',
    'geom' => undef,
    'order' => undef,
    'id' => 'wr_018',
    'type' => 'command',
    'opt' => '-background , \'#ffffff\' , -label , \'Exit\' , -command , sub{exit} '
  }, 'ctkDescriptor' ),
  'mw' => bless( {
    'parent' => undef,
    'geom' => undef,
    'order' => undef,
    'id' => 'mw',
    'type' => 'Frame',
    'opt' => undef
  }, 'ctkDescriptor' ),
  'wr_001' => bless( {
    'parent' => 'mw',
    'geom' => 'pack (-anchor=>nw, -side=>left, -fill=>both, -expand=>1)',
    'order' => undef,
    'id' => 'wr_001',
    'type' => 'Frame',
    'opt' => '-relief , solid , -borderwidth , 2'
  }, 'ctkDescriptor' ),
  'wr_008' => bless( {
    'parent' => 'wr_001',
    'geom' => 'pack(-side=>bottom, -anchor=>sw, -pady=>5, -fill=>x, -expand=>1, -padx=>5)',
    'order' => undef,
    'id' => 'wr_008',
    'type' => 'Label',
    'opt' => '-anchor , nw , -background , #80ffff , -justify , left , -text , Selection , -relief , flat'
  }, 'ctkDescriptor' ),
  'wr_002' => bless( {
    'parent' => 'mw',
    'geom' => 'pack (-anchor=>nw, -side=>left, -fill=>both, -expand=>1)',
    'order' => undef,
    'id' => 'wr_002',
    'type' => 'Frame',
    'opt' => '-relief , solid , -borderwidth , 2'
  }, 'ctkDescriptor' ),
  'wr_005' => bless( {
    'parent' => 'wr_002',
    'geom' => 'pack(-side=>top, -anchor=>nw, -pady=>5, -fill=>both, -expand=>1, -padx=>5)',
    'order' => '$wr_005->SetGUICallbacks([]);',
    'id' => 'wr_005',
    'type' => 'TextEdit',
    'opt' => '-wrap , none , -bg , #ffffff , -state , normal'
  }, 'ctkDescriptor' ),
  'wr_011' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-anchor, nw, -side, top)',
    'order' => undef,
    'id' => 'wr_011',
    'type' => 'Pane',
    'opt' => '-gridded , \'xy\' , -sticky , \'n\' '
  }, 'ctkDescriptor' ),
  'wr_004' => bless( {
    'parent' => 'wr_001',
    'geom' => 'pack(-side=>top, -anchor=>nw, -pady=>5, -fill=>both, -expand=>1, -padx=>5)',
    'order' => undef,
    'id' => 'wr_004',
    'type' => 'Listbox',
    'opt' => '-background , #ffffff , -selectmode , single , -relief , sunken'
  }, 'ctkDescriptor' ),
  'wr_009' => bless( {
    'parent' => 'wr_001',
    'geom' => 'pack(-side=>top, -anchor=>nw, -pady=>5, -fill=>both, -expand=>1, -padx=>5)',
    'order' => undef,
    'id' => 'wr_009',
    'type' => 'LabEntry',
    'opt' => '-background , #ffffff , -justify , left , -label , \'Options list\' , -relief , sunken , -labelPack , [-side , left , -anchor , n ] , -textvariable , \\$test , -state , normal'
  }, 'ctkDescriptor' ),
  'wr_016' => bless( {
    'parent' => 'wr_011',
    'geom' => 'pack(-anchor, nw, -side, top)',
    'order' => undef,
    'id' => 'wr_016',
    'type' => 'Menubutton',
    'opt' => '-anchor , \'nw\' , -background , \'#ffffff\' , -state , \'normal\' , -justify , \'left\' , -relief , \'raised\' , -text , \'File\' '
  }, 'ctkDescriptor' ),
  'wr_006' => bless( {
    'parent' => 'wr_002',
    'geom' => 'pack(-side=>bottom, -anchor=>sw, -fill=>x, -expand=>1)',
    'order' => undef,
    'id' => 'wr_006',
    'type' => 'Label',
    'opt' => '-anchor , nw , -background , #0080ff , -justify , left , -text , \'Object name\' , -relief , flat'
  }, 'ctkDescriptor' )
};
$rTree = [
  'mw',
  'mw.wr_011',
  'mw.wr_001',
  'mw.wr_002',
  'mw.wr_001.wr_004',
  'mw.wr_001.wr_009',
  'mw.wr_001.wr_008',
  'mw.wr_002.wr_005',
  'mw.wr_002.wr_006',
  'mw.wr_011.wr_016',
  'mw.wr_011.wr_016.wr_017',
  'mw.wr_011.wr_016.wr_017.wr_018'
];
$rUser_subroutines = [
  'sub init { 1 }'
];
$rUser_methods_code = [];
$rUser_gcode = [];
$rOther_code = [];
$rUser_pod = [];
$rUser_auto_vars = [];
$rUser_local_vars = [
  '$test'
];
$rFile_opt = {
  'modal' => '0',
  'subWidgetList' => [],
  'autoExtractVariables' => '1',
  'subroutineName' => 'thisDialog',
  'description' => '',
  'autoExtract2Local' => '1',
  'baseClass' => '',
  'strict' => '1',
  'subroutineArgs' => '-title , \'???\'                 ',
  'Toplevel' => '1',
  'title' => '',
  'code' => 0,
  'onDeleteWindow' => 'sub{1}'
};
$rLastfile = \'.\\project\\t_exp_imp.pl';
$ropt_isolate_geom = \'0';
$rHiddenWidgets = [];
$rLibraries = [
  'c:/Dokumente und Einstellungen/marco/Projekte/ClickTk/test'
];
$rApplName = \'test_import_export';
$rApplFolder = \'c:/Dokumente und Einstellungen/marco/Projekte/ClickTk/test';
$opt_TestCode = \'1';
