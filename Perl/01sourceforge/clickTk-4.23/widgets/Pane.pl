$rDef = {
  'icon' => 'Pane',
  'geom' => '1',
  'file' => 'Pane',
  'attr' => {
    '-fg' => 'color',
    '-yscrollcommand' => 'callback',
    '-height' => 'int+',
    '-sticky' => 'menu(n|s|e|w|nsew|ns|ew|)',
    '-label' => 'text',
    '-bg' => 'color',
    '-width' => 'int+',
    '-xscrollcommand' => 'callback',
    '-gridded' => 'menu(x|y|xy)'
  },
  'classname' => 'Pane',
  'use' => 'Tk::Pane',
  'nonVisual' => undef,
  'defaultgeometrymanager' => 'pack',
  'balloon' => '0',
  'defaultgeometryoptions' => undef,
  'defaultwidgetoptions' => undef
};
