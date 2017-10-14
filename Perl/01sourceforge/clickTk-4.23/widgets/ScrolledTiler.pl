$rDef = {
  'icon' => 'default',
  'geom' => '1',
  'file' => 'ScrolledTiler',
  'attr' => {
    '-fg' => 'color',
    '-yscrollcommand' => 'callback',
    '-height' => 'int+',
    '-borderwidth' => 'int+',
    '-relief' => 'relief',
    '-rows' => 'int+',
    '-bg' => 'color',
    '-width' => 'int+',
    '-columns' => 'int+',
    '-scrollbars' => 'menu(s|os|e|oe|w|ow|n|on|se|ose|soe|osoe|sw|osw|sow|ne|one|noe|onoe|nw|onw|now|onow)'
    },
  'classname' => 'ScrolledTiler',
  'pathName' => undef,
  'use' => 'Tk::Tiler',
  'nonVisual' => undef,
  'defaultgeometrymanager' => 'pack',
  'balloon' => '0',
  'defaultwidgetoptions' => '-columns,1,-rows,1',
  'defaultgeometryoptions' => undef
};
