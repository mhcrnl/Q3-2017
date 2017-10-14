$rDef = {
  'icon' => 'ScrolledPane',
  'geom' => '1',
  'file' => 'ScrolledPane',
  'attr' => {
    '-fg' => 'color',
    '-yscrollcommand' => 'callback',
    '-height' => 'int+',
    '-sticky' => 'menu(n|s|e|w|nsew|ns|ew|)',
    '-label' => 'text',
    '-bg' => 'color',
    '-borderwidth' => 'int+',
    '-relief' => 'relief',
    '-width' => 'int+',
    '-xscrollcommand' => 'callback',
    '-gridded' => 'menu(x|y|xy)',
    '-scrollbars' => 'menu(s|os|e|oe|w|ow|n|on|se|ose|soe|osoe|sw|osw|sow|ne|one|noe|onoe|nw|onw|now|onow)'
  },
  'classname' => 'ScrolledPane',
  'use' => 'Tk::Pane',
  'nonVisual' => 0,
  'defaultgeometrymanager' => 'pack',
  'balloon' => '0',
  'defaultgeometryoptions' => undef,
  'defaultwidgetoptions' => undef
};
