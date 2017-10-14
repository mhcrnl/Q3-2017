$rDescriptor = {
  'wr_012' => bless( {
    'parent' => 'wr_011',
    'geom' => 'pack(-anchor=>nw, -side=>left, -fill=>x, -expand=>1)',
    'order' => undef,
    'opt' => '-anchor , nw , -background , #c0c0c0 , -borderwidth , 1 , -justify , left , -text , Status , -relief , flat',
    'type' => 'Label',
    'id' => 'wr_012'
  }, 'ctkDescriptor' ),
  'wr_017' => bless( {
    'parent' => 'wr_010',
    'geom' => 'pack(-anchor=>nw, -side=>left, -fill=>x, -expand=>1, -padx=>2)',
    'order' => undef,
    'opt' => '-background , #ffffff , -state , normal , -text , Ok , -relief , raised',
    'type' => 'Button',
    'id' => 'wr_017'
  }, 'ctkDescriptor' ),
  'wr_019' => bless( {
    'parent' => 'wr_015',
    'geom' => 'pack(-side=>left, -anchor=>nw, -fill=>both, -expand=>1)',
    'order' => undef,
    'opt' => '-state , normal , -relief , sunken , -wrap , none',
    'type' => 'ROText',
    'id' => 'wr_019'
  }, 'ctkDescriptor' ),
  'wr_018' => bless( {
    'parent' => 'wr_010',
    'geom' => 'pack(-anchor=>nw, -side=>left, -fill=>x, -expand=>1, -padx=>2)',
    'order' => undef,
    'opt' => '-background , #ffffff , -state , normal , -text , Cancel , -relief , raised',
    'type' => 'Button',
    'id' => 'wr_018'
  }, 'ctkDescriptor' ),
  'mw' => bless( {
    'parent' => undef,
    'geom' => undef,
    'order' => undef,
    'opt' => undef,
    'type' => 'Frame',
    'id' => 'mw'
  }, 'ctkDescriptor' ),
  'wr_008' => bless( {
    'parent' => 'wr_006',
    'geom' => 'pack(-anchor=>nw, -side=>top, -fill=>both, -expand=>1)',
    'order' => undef,
    'opt' => '-relief , solid',
    'type' => 'Frame',
    'id' => 'wr_008'
  }, 'ctkDescriptor' ),
  'wr_015' => bless( {
    'parent' => 'wr_009',
    'geom' => 'pack(-anchor=>nw, -side=>left, -fill=>both, -expand=>1)',
    'order' => undef,
    'opt' => '-label , Data , -labelside , acrosstop',
    'type' => 'LabFrame',
    'id' => 'wr_015'
  }, 'ctkDescriptor' ),
  'wr_014' => bless( {
    'parent' => 'wr_008',
    'geom' => 'pack(-anchor=>nw, -side=>left, -fill=>x, -expand=>1)',
    'order' => undef,
    'opt' => '-anchor , nw , -background , #c0c0c0 , -justify , left , -text , Title , -relief , flat',
    'type' => 'Label',
    'id' => 'wr_014'
  }, 'ctkDescriptor' ),
  'wr_009' => bless( {
    'parent' => 'wr_006',
    'geom' => 'pack(-anchor=>nw, -side=>top, -fill=>both, -expand=>1)',
    'order' => undef,
    'opt' => '-relief , solid',
    'type' => 'Frame',
    'id' => 'wr_009'
  }, 'ctkDescriptor' ),
  'wr_010' => bless( {
    'parent' => 'wr_007',
    'geom' => 'pack(-anchor=>sw, -side=>top, -fill=>x, -expand=>1)',
    'order' => undef,
    'opt' => '-relief , solid',
    'type' => 'Frame',
    'id' => 'wr_010'
  }, 'ctkDescriptor' ),
  'wr_011' => bless( {
    'parent' => 'wr_007',
    'geom' => 'pack(-ipady=>2, -ipadx=>2, -anchor=>sw, -side=>bottom, -fill=>x, -expand=>1)',
    'order' => undef,
    'opt' => '-relief , flat',
    'type' => 'Frame',
    'id' => 'wr_011'
  }, 'ctkDescriptor' ),
  'wr_020' => bless( {
    'parent' => 'wr_015',
    'geom' => 'pack(-side=>left, -anchor=>nw, -fill=>both, -expand=>1)',
    'order' => undef,
    'opt' => '-selectmode , single , -relief , sunken',
    'type' => 'Listbox',
    'id' => 'wr_020'
  }, 'ctkDescriptor' ),
  'wr_007' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-anchor=>nw, -side=>top, -fill=>x, -expand=>1)',
    'order' => undef,
    'opt' => '-label , Actions , -labelside , acrosstop',
    'type' => 'LabFrame',
    'id' => 'wr_007'
  }, 'ctkDescriptor' ),
  'wr_016' => bless( {
    'parent' => 'wr_020',
    'geom' => undef,
    'order' => undef,
    'opt' => '-side , left',
    'type' => 'packAdjust',
    'id' => 'wr_016'
  }, 'ctkDescriptor' ),
  'wr_006' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-anchor=>nw, -side=>top, -fill=>x, -expand=>1)',
    'order' => undef,
    'opt' => '-relief , solid',
    'type' => 'Frame',
    'id' => 'wr_006'
  }, 'ctkDescriptor' )
};
$rTree = [
  'mw',
  'mw.wr_006',
  'mw.wr_007',
  'mw.wr_006.wr_008',
  'mw.wr_006.wr_009',
  'mw.wr_007.wr_010',
  'mw.wr_007.wr_011',
  'mw.wr_006.wr_008.wr_014',
  'mw.wr_006.wr_009.wr_015',
  'mw.wr_007.wr_010.wr_017',
  'mw.wr_007.wr_010.wr_018',
  'mw.wr_007.wr_011.wr_012',
  'mw.wr_006.wr_009.wr_015.wr_020',
  'mw.wr_006.wr_009.wr_015.wr_019',
  'mw.wr_006.wr_009.wr_015.wr_020.wr_016'
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
  'strict' => '0',
  'subroutineArgs' => '-title , \'???\'  ',
  'Toplevel' => '1',
  'modal' => '0',
  'subroutineArgsName' => '%args',
  'autoExtractVariables' => '1',
  'subroutineName' => 'dlgFraming',
  'title' => 'Framing',
  'subWidgetList' => [],
  'modalDialogClassName' => 'DialogBox',
  'description' => 'test framing',
  'autoExtract2Local' => '1',
  'code' => '0',
  'onDeleteWindow' => 'sub{exit(0)}',
  'baseClass' => ''
};
$rProjectName = \'.\\project\\framing_1.pl';
$ropt_isolate_geom = \'0';
$rHiddenWidgets = [];
$rLibraries = [];
$rApplName = \'';
$rApplFolder = \'';
$opt_TestCode = \'1';
$rBaseClass = [];
