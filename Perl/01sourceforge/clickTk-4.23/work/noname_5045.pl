$rDescriptor = {
  'w_Frame_005' => bless( {
    'type' => 'Frame',
    'order' => undef,
    'parent' => 'w_NoteBookFrame_003',
    'geom' => 'pack(-side , top , -anchor , nw , -pady , 5 , -padx , 5)',
    'id' => 'w_Frame_005',
    'opt' => '-relief , flat'
  }, 'ctkDescriptor' ),
  'w_Frame_009' => bless( {
    'order' => undef,
    'type' => 'Frame',
    'parent' => 'w_NoteBookFrame_003',
    'opt' => '-relief , flat',
    'id' => 'w_Frame_009',
    'geom' => 'pack(-side , top , -anchor , nw , -pady , 5 , -padx , 5)'
  }, 'ctkDescriptor' ),
  'w_Frame_015' => bless( {
    'id' => 'w_Frame_015',
    'opt' => '',
    'geom' => 'pack(-anchor , nw , -side , top , -fill , both , -expand , 1)',
    'type' => 'Frame',
    'order' => undef,
    'parent' => 'w_Frame_001'
  }, 'ctkDescriptor' ),
  'wr_018' => bless( {
    'opt' => '-borderwidth , 2 , -relief , flat',
    'id' => 'wr_018',
    'geom' => 'pack(-side , top , -anchor , nw , -fill , both , -expand , 1)',
    'parent' => 'wr_NoteBookFrame_005',
    'type' => 'Frame',
    'order' => undef
  }, 'ctkDescriptor' ),
  'w_NoteBookFrame_004' => bless( {
    'parent' => 'w_NoteBook_002',
    'order' => undef,
    'type' => 'NoteBookFrame',
    'geom' => undef,
    'opt' => '-raisecmd , \'sub{print"\\nraisecmd2 @_"}\' , -justify , left , -label , \'Browse view\' , -createcmd , \'sub{print"\\ncreatecmd2 @_"}\' , -state , normal',
    'id' => 'w_NoteBookFrame_004'
  }, 'ctkDescriptor' ),
  'w_ScrolledListbox_014' => bless( {
    'opt' => 'Listbox , -background , #ffffff , -borderwidth , 1 , -selectmode , single , -relief , sunken , -scrollbars , se',
    'id' => 'w_ScrolledListbox_014',
    'geom' => 'pack(-anchor , nw , -side , top , -fill , both , -expand , 1 , -padx , 5)',
    'parent' => 'w_NoteBookFrame_004',
    'type' => 'ScrolledListbox',
    'order' => undef
  }, 'ctkDescriptor' ),
  'wr_019' => bless( {
    'type' => 'Checkbutton',
    'order' => undef,
    'parent' => 'wr_018',
    'geom' => 'grid(-row , 0 , -sticky , nw , -column , 0)',
    'id' => 'wr_019',
    'opt' => '-relief , flat , -variable , \\$option1 , -state , normal , -justify , left , -text , Option___1 , -onvalue , 1'
  }, 'ctkDescriptor' ),
  'w_NoteBook_002' => bless( {
    'type' => 'NoteBook',
    'order' => undef,
    'parent' => 'w_Frame_001',
    'id' => 'w_NoteBook_002',
    'opt' => '-background , #80ffff , -foreground , #ffffff , -focuscolor , #8080ff , -backpagecolor , #0080ff , -inactivebackground , #0080c0',
    'geom' => 'pack(-anchor , nw , -side , top , -pady , 5 , -fill , both , -expand , 1 , -padx , 5)'
  }, 'ctkDescriptor' ),
  'w_Frame_017' => bless( {
    'geom' => 'pack(-anchor , sw , -side , bottom , -fill , x , -expand , 1)',
    'opt' => '',
    'id' => 'w_Frame_017',
    'order' => undef,
    'type' => 'Frame',
    'parent' => 'w_Frame_001'
  }, 'ctkDescriptor' ),
  'wr_016' => bless( {
    'parent' => 'mw',
    'order' => '',
    'type' => 'LabFrame',
    'geom' => 'pack(-side , top , -anchor , nw , -fill , both , -expand , 1)',
    'opt' => '-label, wr_016, -relief, ridge, -labelside, acrosstop',
    'id' => 'wr_016'
  }, 'ctkDescriptor' ),
  'w_Frame_001' => bless( {
    'opt' => '-relief , flat',
    'id' => 'w_Frame_001',
    'geom' => 'pack(-side , top , -anchor , nw , -fill , both , -expand , 1)',
    'type' => 'Frame',
    'order' => undef,
    'parent' => 'mw'
  }, 'ctkDescriptor' ),
  'w_Button_018' => bless( {
    'type' => 'Button',
    'order' => undef,
    'parent' => 'w_Frame_015',
    'geom' => 'pack(-anchor, nw, -pady, 2, -fill, x, -side, left, -expand, 1)',
    'opt' => '-relief , \'raised\' , -command , sub{ &do_exit_1 } , -background , \'#ffffff\' , -text , \'OK\' , -state , \'normal\' , -underline , 0 ',
    'id' => 'w_Button_018'
  }, 'ctkDescriptor' ),
  'w_Label_020' => bless( {
    'id' => 'w_Label_020',
    'opt' => '-background , #c0c0c0 , -justify , left , -relief , flat , -text , \'Status and messages.\'',
    'geom' => 'pack(-anchor , nw , -side , left , -fill , x , -expand , 1)',
    'parent' => 'w_Frame_017',
    'order' => undef,
    'type' => 'Label'
  }, 'ctkDescriptor' ),
  'wr_NoteBookFrame_005' => bless( {
    'order' => undef,
    'type' => 'NoteBookFrame',
    'parent' => 'w_NoteBook_002',
    'geom' => undef,
    'opt' => '-raisecmd , \'sub{print"\\nraisecmd3 @_"}\' , -justify , left , -label , Options , -createcmd , \'sub{ print "\\ncreatecmd3 @_"  }\' , -state , normal',
    'id' => 'wr_NoteBookFrame_005'
  }, 'ctkDescriptor' ),
  'w_Button_019' => bless( {
    'opt' => '-background , #ffffff , -command , \\&do_exit_0 , -state , normal , -text , Cancel',
    'id' => 'w_Button_019',
    'geom' => 'pack(-anchor , nw , -side , left , -pady , 2 , -fill , x , -expand , 1)',
    'type' => 'Button',
    'order' => undef,
    'parent' => 'w_Frame_015'
  }, 'ctkDescriptor' ),
  'mw' => bless( {
    'id' => 'mw',
    'opt' => undef,
    'geom' => undef,
    'parent' => undef,
    'type' => 'Frame',
    'order' => undef
  }, 'ctkDescriptor' ),
  'w_NoteBookFrame_003' => bless( {
    'geom' => undef,
    'id' => 'w_NoteBookFrame_003',
    'opt' => '-anchor , nw , -label , \'Record view\' , -justify , left , -createcmd , \'sub{print"\\ncreatecmd1 @_" }\' , -state , normal',
    'order' => undef,
    'type' => 'NoteBookFrame',
    'parent' => 'w_NoteBook_002'
  }, 'ctkDescriptor' )
};
$rTree = [
  'mw',
  'mw.w_Frame_001',
  'mw.w_Frame_001.w_NoteBook_002',
  'mw.w_Frame_001.w_Frame_015',
  'mw.w_Frame_001.w_Frame_017',
  'mw.w_Frame_001.w_NoteBook_002.w_NoteBookFrame_003',
  'mw.w_Frame_001.w_NoteBook_002.w_NoteBookFrame_004',
  'mw.w_Frame_001.w_NoteBook_002.wr_NoteBookFrame_005',
  'mw.w_Frame_001.w_Frame_015.w_Button_018',
  'mw.w_Frame_001.w_Frame_015.w_Button_019',
  'mw.w_Frame_001.w_Frame_017.w_Label_020',
  'mw.w_Frame_001.w_NoteBook_002.wr_NoteBookFrame_005.wr_018',
  'mw.w_Frame_001.w_NoteBook_002.w_NoteBookFrame_003.w_Frame_005',
  'mw.w_Frame_001.w_NoteBook_002.w_NoteBookFrame_003.w_Frame_009',
  'mw.w_Frame_001.w_NoteBook_002.w_NoteBookFrame_004.w_ScrolledListbox_014',
  'mw.w_Frame_001.w_NoteBook_002.wr_NoteBookFrame_005.wr_018.wr_019',
  'mw.wr_016'
];
$rUser_subroutines = [];
$rUser_methods_code = [];
$rUser_gcode = [];
$rOther_code = [];
$rUser_pod = [];
$rUser_auto_vars = [
  '$option1',
  '$option2',
  '$option3',
  '$option4',
  '$option5',
  '$option6',
  '$sub',
  '$subclasse',
  '@records'
];
$rUser_local_vars = [];
$rFile_opt = {
  'autoExtractVariables' => '1',
  'modal' => '0',
  'subroutineName' => 'dlgNotebook',
  'onDeleteWindow' => 'sub{1}
  'subWidgetList' => [],
  'description' => '',
  'modalDialogClassName' => 'DialogBox',
  'buttons' => ' ',
  'baseClass' => '',
  'code' => '0',
  'title' => '',
  'subroutineArgsName' => '%args',
  'subroutineArgs' => '-title , \'Test Notebook\'
  'strict' => '0',
  'autoExtract2Local' => '1',
  'Toplevel' => '1
  'treewalk' => 'D'
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