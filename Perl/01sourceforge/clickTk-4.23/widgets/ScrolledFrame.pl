$rDef = {
  'icon' => 'ScrolledFrame',
  'geom' => '1',
  'file' => 'ScrolledFrame',
  'balloon' => 1,
  'defaultgeometrymanager' => 'pack',
  'defaultgeometryoptions' => "-side => top, -fill => both, -expand => 1, -anchor => nw",
  'defaultwidgetoptions' => "-relief => solid, -borderwidth => 1",
  'attr' => {
    '-height' => 'int+',
    '-borderwidth' => 'int+',
    '-background' => 'color',
    '-label' => 'text',
    '-relief' => 'relief',
    '-width' => 'int+',
    '-scrollbars' => 'menu(s|os|e|oe|w|ow|n|on|se|ose|soe|osoe|sw|osw|sow|ne|one|noe|onoe|nw|onw|now|onow)'
  },
  'classname' => 'ScrolledFrame',
  'use' => 'Tk::Frame'
};
