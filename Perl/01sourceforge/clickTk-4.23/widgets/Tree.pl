$rDef = {
  'icon' => 'Tree',
  'geom' => '1',
  'file' => 'Tree',
  'attr' => {
    '-selectbackground' => 'color',
    '-font' => 'text',
    '-drawbranch' => 'menu(0|1)',
    '-bg' => 'color',
    '-width' => 'int+',
    '-selectmode' => 'menu(single|browse|extended',
    '-browsecmd' => 'callback',
    '-borderwidth' => 'int+',
    '-height' => 'int+',
    '-command' => 'callback',
    '-selectforeground' => 'color',
    '-separator' => 'text',
    '-header' => 'menu(0|1)',
    '-indicator' => 'menu(0|1)'
  },
  'classname' => 'Tree',
  'use' => 'Tk::Tree',
  'defaultgeometrymanager' => 'pack',
  'balloon' => '1',
  'defaultgeometryoptions' => undef,
  'defaultwidgetoptions' => ''
};
