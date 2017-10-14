$rDescriptor = {
  'wr_001' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-anchor , nw , -side , top , -pady , 5 , -fill , x , -expand , 1 , -padx , 5)',
    'order' => undef,
    'id' => 'wr_001',
    'type' => 'Listbox',
    'opt' => '-background , #ffffff , -selectmode , single , -relief , sunken'
  }, 'ctkDescriptor' ),
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
    'geom' => 'pack(-fill, x, -expand, 1, -anchor, nw, -pady, 5, -side, top, -padx, 5)',
    'order' => undef,
    'id' => 'wr_002',
    'type' => 'Button',
    'opt' => '-background , \'#ffffff\' , -command , sub{1} , -state , \'normal\' , -text , \'Test\' '
  }, 'ctkDescriptor' )
};
$rTree = [
  'mw',
  'mw.wr_001',
  'mw.wr_002'
];
$rUser_subroutines = [
  'sub init { 1 }',
  'sub test_01 {',
  '	shift->_show()',
  '}'
];
$rUser_methods_code = [
  'sub arglist {',
  '	my $self = shift;',
  '	my ($args) = @_;',
  '	## no arguments',
  '	return $args',
  '}',
  'sub _show {',
  '	my $rv = shift->Show();',
  '	return $rv',
  '}'
];
$rUser_gcode = [];
$rOther_code = [];
$rUser_pod = [];
$rUser_auto_vars = [
  '$xyz'
];
$rUser_local_vars = [];
$rFile_opt = {
  'modal' => '0',
  'autoExtractVariables' => '1',
  'subroutineName' => 'thisDialog',
  'Toplevel' => 0,
  'code' => 3,
  'treewalk' => 'D',
  'subWidgetList' => [
    {
      'public' => '1',
      'name' => 'List',
      'ident' => 'wr_001'
    },
    {
      'public' => '1',
      'name' => 'Test',
      'ident' => 'wr_002'
    }
  ],
  'description' => 'Test composite based on DialogBox',
  'autoExtract2Local' => '1',
  'baseClass' => 'Tk::DialogBox',
  'strict' => '1',
  'subroutineArgs' => '',
  'subroutineArgsName' => '%args',
  'title' => 'Extended DialogBox',
  'modalDialogClassName' => 'DialogBox',
  'buttons' => ' ',
  'onDeleteWindow' => 'sub{exit(0)}'
};
$rProjectName = \'.\\project\\DialogBoxX.pl';
$ropt_isolate_geom = \'0';
$rHiddenWidgets = [];
$rLibraries = [];
$rApplName = \'';
$rApplFolder = \'';
$opt_TestCode = \'1';
$rBaseClass = [
  'Tk::DialogBox'
];
