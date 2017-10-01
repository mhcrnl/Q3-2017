# This file was automatically generated.
package Prima::Config;
use vars qw(%Config);

# Determine lib based on the location of this module
use File::Basename qw(dirname);
use File::Spec;
my $lib = File::Spec->catfile(dirname(__FILE__), '..');

%Config = (
	ifs                   => '\/',
	quote                 => '\'',
	platform              => 'unix',
	incpaths              => [ "$lib/Prima/CORE","$lib/Prima/CORE/generic","/usr/local/include","/usr/include/freetype2","/usr/include/gtk-2.0","/usr/lib64/gtk-2.0/include","/usr/include/pango-1.0","/usr/include/atk-1.0","/usr/include/cairo","/usr/include/pixman-1","/usr/include/libdrm","/usr/include/gdk-pixbuf-2.0","/usr/include/libpng16","/usr/include/pango-1.0","/usr/include/harfbuzz","/usr/include/pango-1.0","/usr/include/glib-2.0","/usr/lib64/glib-2.0/include","/usr/include/libpng16","/usr/include/libpng16" ],
	gencls                => "gencls",
	tmlink                => "tmlink",
	scriptext             => '',
	genclsoptions         => '--tml --h --inc',
	cobjflag              => '-o ',
	coutexecflag          => '-o ',
	clinkprefix           => '',
	clibpathflag          => '-L',
	cdefs                 => [],
	libext                => '.a',
	libprefix             => '',
	libname               => "$lib/auto/Prima/Prima.a",
	dlname                => "$lib/auto/Prima/Prima.so",
	ldoutflag             => '-o ',
	ldlibflag             => '-l',
	ldlibpathflag         => '-L',
	ldpaths               => [],
	ldlibs                => ['png16','X11','Xext','freetype','fontconfig','Xrender','Xft','gtk-x11-2.0','gdk-x11-2.0','pangocairo-1.0','atk-1.0','cairo','gdk_pixbuf-2.0','gio-2.0','pangoft2-1.0','pango-1.0','gobject-2.0','glib-2.0','Xrandr'],
	ldlibext              => '',
	inline                => 'inline',
	dl_load_flags         => 1,

	inc                   => "-I$lib/Prima/CORE -I$lib/Prima/CORE/generic -I/usr/local/include -I/usr/include/freetype2 -I/usr/include/gtk-2.0 -I/usr/lib64/gtk-2.0/include -I/usr/include/pango-1.0 -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/pixman-1 -I/usr/include/libdrm -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/libpng16 -I/usr/include/pango-1.0 -I/usr/include/harfbuzz -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/libpng16 -I/usr/include/libpng16",
	define                => '',
	libs                  => "",
);

1;
