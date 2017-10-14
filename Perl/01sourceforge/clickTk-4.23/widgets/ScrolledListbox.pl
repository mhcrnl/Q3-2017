$rDef = {
  'icon' => 'ScrolledListbox',
  'geom' => '1',
  'file' => 'ScrolledListbox',
  'attr' => {
    '-background' => 'color',
    '-foreground' => 'color',
    '-width' => 'int+',
    '-setgrid' => 'menu(0|1)',
    '-borderwidth' => 'int+',
    '-height' => 'int+',
    '-selectmode' => 'menu(single|browse|multiple|extended)',
    '-relief' => 'relief',
    '-scrollbars' => 'menu(s|os|e|oe|w|ow|n|on|se|ose|soe|osoe|sw|osw|sow|ne|one|noe|onoe|nw|onw|now|onow)'
  },
  'classname' => 'ScrolledListbox',
  'use' => 'Tk::Listbox',
  'defaultgeometrymanager' => 'pack',
  'balloon' => '1',
  'defaultgeometryoptions' => undef,
  'defaultwidgetoptions' => undef
};
