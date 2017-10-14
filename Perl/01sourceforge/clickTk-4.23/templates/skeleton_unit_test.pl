$rDescriptor = {
  '' => bless( {}, 'ctkDescriptor' ),
  'w_Menu_008' => bless( {
    'parent' => 'w_Menubutton_007',
    'geom' => '',
    'id' => 'w_Menu_008',
    'type' => 'Menu',
    'opt' => '-background=>#ffffff, -tearoff=>0, -foreground=>#000000, -relief=>raised'
  }, 'ctkDescriptor' ),
  'w_command_015' => bless( {
    'parent' => 'w_Menu_013',
    'geom' => '',
    'id' => 'w_command_015',
    'type' => 'command',
    'opt' => '-label=>\'Test 2\', -command=>\\&do_test2'
  }, 'ctkDescriptor' ),
  'w_command_020' => bless( {
    'parent' => 'w_Menu_017',
    'geom' => '',
    'opt' => '-label, \'debug mode\', -foreground, #ffffff, -command, sub{1}, -state, normal, -variable, \\$debug, -onvalue, 1',
    'type' => 'checkbutton',
    'id' => 'w_command_020'
  }, 'ctkDescriptor' ),
  'w_Menubutton_016' => bless( {
    'parent' => 'w_Frame_001',
    'geom' => 'pack(-anchor=>nw, -side=>left)',
    'id' => 'w_Menubutton_016',
    'type' => 'Menubutton',
    'opt' => '-background=>#ffffff, -state=>normal, -justify=>left, -relief=>raised, -text=>Options'
  }, 'ctkDescriptor' ),
  'w_Frame_003' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-fill, both, -expand, 1, -anchor, nw, -side, top)',
    'id' => 'w_Frame_003',
    'type' => 'Frame',
    'opt' => '-background, #f3f3f3, -relief, flat'
  }, 'ctkDescriptor' ),
  'w_Menu_017' => bless( {
    'parent' => 'w_Menubutton_016',
    'geom' => '',
    'id' => 'w_Menu_017',
    'type' => 'Menu',
    'opt' => ''
  }, 'ctkDescriptor' ),
  'w_Frame_001' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-anchor=>nw, -fill=>x, -side=>top, -expand=>1)',
    'id' => 'w_Frame_001',
    'type' => 'Frame',
    'opt' => '-background=>#fbfbfb, -relief=>raised'
  }, 'ctkDescriptor' ),
  'mw' => bless( {}, 'ctkDescriptor' ),
  'w_command_009' => bless( {
    'parent' => 'w_Menu_008',
    'geom' => '',
    'id' => 'w_command_009',
    'type' => 'command',
    'opt' => '-label=>help, -command=>\\&do_help'
  }, 'ctkDescriptor' ),
  'w_ScrolledROText_018' => bless( {
    'parent' => 'w_Frame_003',
    'geom' => 'pack()',
    'id' => 'w_ScrolledROText_018',
    'type' => 'ScrolledROText',
    'opt' => ' -scrollbars, se, -relief, sunken'
  }, 'ctkDescriptor' ),
  'w_Frame_002' => bless( {
    'parent' => 'mw',
    'geom' => 'pack(-anchor=>sw, -fill=>x, -side=>bottom, -expand=>1)',
    'id' => 'w_Frame_002',
    'type' => 'Frame',
    'opt' => '-background=>#f7f7f7, -relief=>ridge'
  }, 'ctkDescriptor' ),
  'w_Menu_005' => bless( {
    'parent' => 'w_Menubutton_004',
    'geom' => '',
    'id' => 'w_Menu_005',
    'type' => 'Menu',
    'opt' => '-background=>#ffffff, -foreground=>#000000, -tearoff=>0, -relief=>raised'
  }, 'ctkDescriptor' ),
  'w_Menubutton_007' => bless( {
    'parent' => 'w_Frame_001',
    'geom' => 'pack(-anchor=>ne, -side=>right)',
    'id' => 'w_Menubutton_007',
    'type' => 'Menubutton',
    'opt' => '-background=>#ffffff, -foreground=>#000000, -state=>normal, -justify=>left, -relief=>raised, -text=>Help'
  }, 'ctkDescriptor' ),
  'w_Menubutton_004' => bless( {
    'parent' => 'w_Frame_001',
    'geom' => 'pack(-anchor=>nw, -side=>left)',
    'id' => 'w_Menubutton_004',
    'type' => 'Menubutton',
    'opt' => '-background=>#ffffff, -foreground=>#000000, -state=>normal, -justify=>left, -text=>File, -relief=>raised'
  }, 'ctkDescriptor' ),
  'w_command_006' => bless( {
    'parent' => 'w_Menu_005',
    'geom' => '',
    'id' => 'w_command_006',
    'type' => 'command',
    'opt' => '-label=>Exit, -command=>\\&do_exit'
  }, 'ctkDescriptor' ),
  'w_Menubutton_012' => bless( {
    'parent' => 'w_Frame_001',
    'geom' => 'pack(-anchor=>nw, -side=>left)',
    'id' => 'w_Menubutton_012',
    'type' => 'Menubutton',
    'opt' => '-background=>#ffffff, -state=>normal, -justify=>left, -text=>Test, -relief=>raised'
  }, 'ctkDescriptor' ),
  'w_Label_010' => bless( {
    'parent' => 'w_Frame_002',
    'geom' => 'pack(-fill, x, -expand, 1, -anchor, nw, -side, left)',
    'id' => 'w_Label_010',
    'type' => 'Label',
    'opt' => '-background, #f8f8f8, -justify, left, -text, Statusbar, -relief, ridge'
  }, 'ctkDescriptor' ),
  'w_command_014' => bless( {
    'parent' => 'w_Menu_013',
    'geom' => '',
    'id' => 'w_command_014',
    'type' => 'command',
    'opt' => '-background=>#ffffff, -label=>\'Test 1\', -command=>\\&do_test1'
  }, 'ctkDescriptor' ),
  'w_Menu_013' => bless( {
    'parent' => 'w_Menubutton_012',
    'geom' => '',
    'id' => 'w_Menu_013',
    'type' => 'Menu',
    'opt' => ''
  }, 'ctkDescriptor' )
};
$rTree = [
  'mw',
  'mw.w_Frame_001',
  'mw.w_Frame_001.w_Menubutton_004',
  'mw.w_Frame_001.w_Menubutton_012',
  'mw.w_Frame_001.w_Menubutton_016',
  'mw.w_Frame_001.w_Menubutton_016.w_Menu_017',
  'mw.w_Frame_001.w_Menubutton_016.w_Menu_017.w_command_020',
  'mw.w_Frame_001.w_Menubutton_012.w_Menu_013',
  'mw.w_Frame_001.w_Menubutton_012.w_Menu_013.w_command_014',
  'mw.w_Frame_001.w_Menubutton_012.w_Menu_013.w_command_015',
  'mw.w_Frame_001.w_Menubutton_007',
  'mw.w_Frame_001.w_Menubutton_007.w_Menu_008',
  'mw.w_Frame_001.w_Menubutton_007.w_Menu_008.w_command_009',
  'mw.w_Frame_001.w_Menubutton_004.w_Menu_005',
  'mw.w_Frame_001.w_Menubutton_004.w_Menu_005.w_command_006',
  'mw.w_Frame_003',
  'mw.w_Frame_003.w_ScrolledROText_018',
  'mw.w_Frame_002',
  'mw.w_Frame_002.w_Label_010'
];
$rUser_subroutines = [
  'sub setStatusbar {',
  '	my $msg = shift;',
  '	$w_Label_010->configure(-text => $msg);',
  '}',
  '',
  'sub do_exit {',
  '	exit',
  '}',
  'sub do_help {',
  '}',
  'sub do_test1 {',
  '	&main::setStatusbar(\'Doing test 1 \');',
  '	&main::log("Start test 1 ...");',
  '	## code to be tested goes here ...',
  '}',
  'sub do_test2 {',
  '	&main::setStatusbar(\'Doing test 2 \');',
  '	&main::log("Start test 2...")',
  '	## code to be tested goes here ...',
  '}',
  'sub log {&main::Log(@_)}',
  'sub Log {',
  '	map {',
  '		print "\\n$_";',
  '		$w_ScrolledROText_018->insert(\'end\',"\\n$_");',
  '	} @_;',
  '}',
  'sub trace {&main::Trace(@_)}',
  'sub Trace {',
  '	&Log(@_) if ($debug);',
  '}',
  '',
  'sub init { 1 }'
];
$rUser_methods_code = [];
$rUser_gcode = [
  'my $debug = 0; 	## 1 ¦ 0 : debug mode ON or OFF
  '
  ];
$rOther_code = [];
$rUser_pod = [
'
=head2 Description

	Skeleton for unit test .

=head2 Syntax

	....

=head2 Notes

	None.

=head2 Maintenance

	Version: 1.01
	Author:  marco
	History: 22.05.2005 first draft

=cut

'
];
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
  'code' => '1',
  'onDeleteWindow' => 'sub{exit}',
  'treewalk' => 'D',
  'baseClass' => ''
};
$rProjectName = \undef;
$ropt_isolate_geom = \undef;
$rHiddenWidgets = [];
$rLibraries = [];
$rApplName = \'';
$rApplFolder = \'';
$opt_TestCode = \1;
