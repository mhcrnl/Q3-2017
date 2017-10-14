$rDef = {
  'use' => 'Tk::Scrollbar',
  'geom' => '1',
  'defaultgeometrymanager' => 'pack',
  'file' => 'Scrollbar',
  'attr' => {
    '-bg' => 'color',
    '-orient' => 'menu(horizontal|vertical)',
    '-command' => 'text',
  },
  'balloon' => '0',
  'defaultwidgetoptions' => '-orient => vertical',
  'defaultgeometryoptions' => undef,
  'classname' => 'Scrollbar'
};
