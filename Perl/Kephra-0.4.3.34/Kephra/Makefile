# This Makefile is for the Kephra extension to perl.
#
# It was generated automatically by MakeMaker version
# 7.24 (Revision: 72400) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#

#   MakeMaker Parameters:

#     ABSTRACT => q[crossplatform GUI-Texteditor along Perl alike Paradigms ]
#     AUTHOR => [q[Herbert Breunung]]
#     BUILD_REQUIRES => { ExtUtils::MakeMaker=>q[6.42], Test::Exception=>q[0], Test::More=>q[0.47], Test::NoWarnings=>q[0], Test::Script=>q[0.01] }
#     CONFIGURE_REQUIRES => {  }
#     DISTNAME => q[Kephra]
#     EXE_FILES => [q[bin/kephra]]
#     LICENSE => q[gpl_2]
#     MIN_PERL_VERSION => q[5.006]
#     NAME => q[Kephra]
#     NO_META => q[1]
#     PREREQ_PM => { Config::General=>q[2.4], Cwd=>q[0], Encode::Guess=>q[0], ExtUtils::MakeMaker=>q[6.42], File::UserConfig=>q[0], POSIX=>q[0], Test::Exception=>q[0], Test::More=>q[0.47], Test::NoWarnings=>q[0], Test::Script=>q[0.01], Text::Wrap=>q[0], Wx=>q[0.94], Wx::Perl::ProcessStream=>q[0.25], YAML::Tiny=>q[0.31] }
#     TEST_REQUIRES => {  }
#     VERSION => q[0.4.3.34]
#     VERSION_FROM => q[lib/Kephra.pm]
#     dist => {  }
#     realclean => { FILES=>q[MYMETA.yml] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /usr/lib64/perl5/Config.pm).
# They may have been overridden via Makefile.PL or on the command line.
AR = ar
CC = gcc
CCCDLFLAGS = -fPIC
CCDLFLAGS = -Wl,--enable-new-dtags -Wl,-z,relro 
DLEXT = so
DLSRC = dl_dlopen.xs
EXE_EXT = 
FULL_AR = /usr/bin/ar
LD = gcc
LDDLFLAGS = -shared -Wl,-z,relro  -L/usr/local/lib -fstack-protector-strong
LDFLAGS = -Wl,-z,relro  -fstack-protector-strong -L/usr/local/lib
LIBC = libc-2.24.so
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = linux
OSVERS = 4.11.5-200.fc25.x86_64
RANLIB = :
SITELIBEXP = /usr/local/share/perl5
SITEARCHEXP = /usr/local/lib64/perl5
SO = so
VENDORARCHEXP = /usr/lib64/perl5/vendor_perl
VENDORLIBEXP = /usr/share/perl5/vendor_perl


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
DFSEP = $(DIRFILESEP)
NAME = Kephra
NAME_SYM = Kephra
VERSION = 0.4.3.34
VERSION_MACRO = VERSION
VERSION_SYM = 0_4_3_34
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.4.3.34
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1
MAN3EXT = 3pm
INSTALLDIRS = site
INSTALL_BASE = /home/mhcrnl/perl5
DESTDIR = 
PREFIX = $(INSTALL_BASE)
INSTALLPRIVLIB = $(INSTALL_BASE)/lib/perl5
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = $(INSTALL_BASE)/lib/perl5
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = $(INSTALL_BASE)/lib/perl5
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = $(INSTALL_BASE)/lib/perl5/x86_64-linux-thread-multi
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = $(INSTALL_BASE)/lib/perl5/x86_64-linux-thread-multi
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = $(INSTALL_BASE)/lib/perl5/x86_64-linux-thread-multi
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = $(INSTALL_BASE)/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = $(INSTALL_BASE)/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = $(INSTALL_BASE)/bin
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = $(INSTALL_BASE)/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLSITESCRIPT = $(INSTALL_BASE)/bin
DESTINSTALLSITESCRIPT = $(DESTDIR)$(INSTALLSITESCRIPT)
INSTALLVENDORSCRIPT = $(INSTALL_BASE)/bin
DESTINSTALLVENDORSCRIPT = $(DESTDIR)$(INSTALLVENDORSCRIPT)
INSTALLMAN1DIR = $(INSTALL_BASE)/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = $(INSTALL_BASE)/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = $(INSTALL_BASE)/man/man1
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = $(INSTALL_BASE)/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = $(INSTALL_BASE)/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = $(INSTALL_BASE)/man/man3
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB =
PERL_ARCHLIB = /usr/lib64/perl5
PERL_ARCHLIBDEP = /usr/lib64/perl5
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = Makefile.old
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /usr/lib64/perl5/CORE
PERL_INCDEP = /usr/lib64/perl5/CORE
PERL = "/usr/bin/perl" "-Iinc"
FULLPERL = "/usr/bin/perl" "-Iinc"
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_DIR = 755
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /usr/share/perl5/vendor_perl/ExtUtils/MakeMaker.pm
MM_VERSION  = 7.24
MM_REVISION = 72400

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
MAKE = make
FULLEXT = Kephra
BASEEXT = Kephra
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = lib/Kephra.pm
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic
BOOTDEP = 

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = bin/kephra
MAN3PODS = lib/Kephra.pm \
	lib/Kephra/API.pm \
	lib/Kephra/App/EditPanel/Fold.pm \
	lib/Kephra/App/EditPanel/Margin.pm \
	lib/Kephra/App/Panel/Output.pm \
	lib/Kephra/App/Window.pm \
	lib/Kephra/CommandList.pm \
	lib/Kephra/Config.pm \
	lib/Kephra/Config/File.pm \
	lib/Kephra/Config/Global.pm \
	lib/Kephra/Config/Tree.pm \
	lib/Kephra/Document.pm \
	lib/Kephra/Document/Data.pm \
	lib/Kephra/Document/Property.pm \
	lib/Kephra/Document/SyntaxMode.pm \
	lib/Kephra/Edit.pm \
	lib/Kephra/Edit/Comment.pm \
	lib/Kephra/Edit/Convert.pm \
	lib/Kephra/Edit/Format.pm \
	lib/Kephra/Edit/Goto.pm \
	lib/Kephra/Edit/History.pm \
	lib/Kephra/Edit/Marker.pm \
	lib/Kephra/Edit/Search.pm \
	lib/Kephra/Edit/Select.pm \
	lib/Kephra/EventTable.pm \
	lib/Kephra/File.pm

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIBDEP)$(DFSEP)Config.pm $(PERL_INCDEP)$(DFSEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVEDEP    = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = dev.pl \
	lib/Kephra.pm \
	lib/Kephra/API.pm \
	lib/Kephra/App.pm \
	lib/Kephra/App/ContextMenu.pm \
	lib/Kephra/App/EditPanel.pm \
	lib/Kephra/App/EditPanel/Fold.pm \
	lib/Kephra/App/EditPanel/Indicator.pm \
	lib/Kephra/App/EditPanel/Margin.pm \
	lib/Kephra/App/MainToolBar.pm \
	lib/Kephra/App/MenuBar.pm \
	lib/Kephra/App/Panel.pm \
	lib/Kephra/App/Panel/CommandLine.pm \
	lib/Kephra/App/Panel/Notepad.pm \
	lib/Kephra/App/Panel/Output.pm \
	lib/Kephra/App/Panel/TreeTool.pm \
	lib/Kephra/App/SearchBar.pm \
	lib/Kephra/App/StatusBar.pm \
	lib/Kephra/App/TabBar.pm \
	lib/Kephra/App/Window.pm \
	lib/Kephra/CommandList.pm \
	lib/Kephra/Config.pm \
	lib/Kephra/Config/Default.pm \
	lib/Kephra/Config/Default/CommandList.pm \
	lib/Kephra/Config/Default/ContextMenus.pm \
	lib/Kephra/Config/Default/GlobalSettings.pm \
	lib/Kephra/Config/Default/Localisation.pm \
	lib/Kephra/Config/Default/MainMenu.pm \
	lib/Kephra/Config/Default/ToolBars.pm \
	lib/Kephra/Config/File.pm \
	lib/Kephra/Config/Global.pm \
	lib/Kephra/Config/Interface.pm \
	lib/Kephra/Config/Localisation.pm \
	lib/Kephra/Config/Tree.pm \
	lib/Kephra/Dialog.pm \
	lib/Kephra/Dialog/Color.pm \
	lib/Kephra/Dialog/Config.pm \
	lib/Kephra/Dialog/Exit.pm \
	lib/Kephra/Dialog/Info.pm \
	lib/Kephra/Dialog/Keymap.pm \
	lib/Kephra/Dialog/Notify.pm \
	lib/Kephra/Dialog/Search.pm \
	lib/Kephra/Document.pm \
	lib/Kephra/Document/Change.pm \
	lib/Kephra/Document/Data.pm \
	lib/Kephra/Document/Property.pm \
	lib/Kephra/Document/SyntaxMode.pm \
	lib/Kephra/Edit.pm \
	lib/Kephra/Edit/Comment.pm \
	lib/Kephra/Edit/Convert.pm \
	lib/Kephra/Edit/Format.pm \
	lib/Kephra/Edit/Goto.pm \
	lib/Kephra/Edit/History.pm \
	lib/Kephra/Edit/Marker.pm \
	lib/Kephra/Edit/Search.pm \
	lib/Kephra/Edit/Search/InputTarget.pm \
	lib/Kephra/Edit/Select.pm \
	lib/Kephra/Edit/Special.pm \
	lib/Kephra/EventTable.pm \
	lib/Kephra/File.pm \
	lib/Kephra/File/History.pm \
	lib/Kephra/File/IO.pm \
	lib/Kephra/File/Session.pm \
	lib/Kephra/Help.pm \
	lib/Kephra/Log.pm \
	lib/Kephra/Macro.pm \
	lib/Kephra/Menu.pm \
	lib/Kephra/Plugin.pm \
	lib/Kephra/Plugin/Demo.pm \
	lib/Kephra/ToolBar.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 7.24
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(ABSPERLRUN)  -e 'use AutoSplit;  autosplit($$$$ARGV[0], $$$$ARGV[1], 0, 1, 1)' --



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(TRUE)
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(ABSPERLRUN) -MExtUtils::Command -e 'mkpath' --
EQUALIZE_TIMESTAMP = $(ABSPERLRUN) -MExtUtils::Command -e 'eqtime' --
FALSE = false
TRUE = true
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(ABSPERLRUN) -MExtUtils::Install -e 'install([ from_to => {@ARGV}, verbose => '\''$(VERBINST)'\'', uninstall_shadows => '\''$(UNINST)'\'', dir_mode => '\''$(PERM_DIR)'\'' ]);' --
DOC_INSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'perllocal_install' --
UNINSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'uninstall' --
WARN_IF_OLD_PACKLIST = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'warn_if_old_packlist' --
MACROSTART = 
MACROEND = 
USEMAKEFILE = -f
FIXIN = $(ABSPERLRUN) -MExtUtils::MY -e 'MY->fixin(shift)' --
CP_NONEMPTY = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'cp_nonempty' --


# --- MakeMaker makemakerdflt section:
makemakerdflt : all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(NOECHO) $(NOOP)
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = Kephra
DISTVNAME = Kephra-0.4.3.34


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"\
	INSTALL_BASE="$(INSTALL_BASE)"\
	PASTHRU_DEFINE='$(DEFINE) $(PASTHRU_DEFINE)'\
	PASTHRU_INC='$(INC) $(PASTHRU_INC)'


# --- MakeMaker special_targets section:
.SUFFIXES : .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir pure_all subdirs clean_subdirs makemakerdflt manifypods realclean_subdirs subdirs_dynamic subdirs_pure_nolink subdirs_static subdirs-test_dynamic subdirs-test_static test_dynamic test_static



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)

pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) blibdirs
	$(NOECHO) $(NOOP)

help :
	perldoc ExtUtils::MakeMaker


# --- MakeMaker blibdirs section:
blibdirs : $(INST_LIBDIR)$(DFSEP).exists $(INST_ARCHLIB)$(DFSEP).exists $(INST_AUTODIR)$(DFSEP).exists $(INST_ARCHAUTODIR)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists $(INST_SCRIPT)$(DFSEP).exists $(INST_MAN1DIR)$(DFSEP).exists $(INST_MAN3DIR)$(DFSEP).exists
	$(NOECHO) $(NOOP)

# Backwards compat with 6.18 through 6.25
blibdirs.ts : blibdirs
	$(NOECHO) $(NOOP)

$(INST_LIBDIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_LIBDIR)
	$(NOECHO) $(TOUCH) $(INST_LIBDIR)$(DFSEP).exists

$(INST_ARCHLIB)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHLIB)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHLIB)
	$(NOECHO) $(TOUCH) $(INST_ARCHLIB)$(DFSEP).exists

$(INST_AUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_AUTODIR)
	$(NOECHO) $(TOUCH) $(INST_AUTODIR)$(DFSEP).exists

$(INST_ARCHAUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHAUTODIR)
	$(NOECHO) $(TOUCH) $(INST_ARCHAUTODIR)$(DFSEP).exists

$(INST_BIN)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_BIN)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_BIN)
	$(NOECHO) $(TOUCH) $(INST_BIN)$(DFSEP).exists

$(INST_SCRIPT)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_SCRIPT)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_SCRIPT)
	$(NOECHO) $(TOUCH) $(INST_SCRIPT)$(DFSEP).exists

$(INST_MAN1DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN1DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN1DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN1DIR)$(DFSEP).exists

$(INST_MAN3DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN3DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN3DIR)$(DFSEP).exists



# --- MakeMaker linkext section:

linkext :: dynamic
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) config $(INST_BOOT) $(INST_DYNAMIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all config  \
	bin/kephra \
	lib/Kephra.pm \
	lib/Kephra/API.pm \
	lib/Kephra/App/EditPanel/Fold.pm \
	lib/Kephra/App/EditPanel/Margin.pm \
	lib/Kephra/App/Panel/Output.pm \
	lib/Kephra/App/Window.pm \
	lib/Kephra/CommandList.pm \
	lib/Kephra/Config.pm \
	lib/Kephra/Config/File.pm \
	lib/Kephra/Config/Global.pm \
	lib/Kephra/Config/Tree.pm \
	lib/Kephra/Document.pm \
	lib/Kephra/Document/Data.pm \
	lib/Kephra/Document/Property.pm \
	lib/Kephra/Document/SyntaxMode.pm \
	lib/Kephra/Edit.pm \
	lib/Kephra/Edit/Comment.pm \
	lib/Kephra/Edit/Convert.pm \
	lib/Kephra/Edit/Format.pm \
	lib/Kephra/Edit/Goto.pm \
	lib/Kephra/Edit/History.pm \
	lib/Kephra/Edit/Marker.pm \
	lib/Kephra/Edit/Search.pm \
	lib/Kephra/Edit/Select.pm \
	lib/Kephra/EventTable.pm \
	lib/Kephra/File.pm
	$(NOECHO) $(POD2MAN) --section=1 --perm_rw=$(PERM_RW) -u \
	  bin/kephra $(INST_MAN1DIR)/kephra.$(MAN1EXT) 
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) -u \
	  lib/Kephra.pm $(INST_MAN3DIR)/Kephra.$(MAN3EXT) \
	  lib/Kephra/API.pm $(INST_MAN3DIR)/Kephra::API.$(MAN3EXT) \
	  lib/Kephra/App/EditPanel/Fold.pm $(INST_MAN3DIR)/Kephra::App::EditPanel::Fold.$(MAN3EXT) \
	  lib/Kephra/App/EditPanel/Margin.pm $(INST_MAN3DIR)/Kephra::App::EditPanel::Margin.$(MAN3EXT) \
	  lib/Kephra/App/Panel/Output.pm $(INST_MAN3DIR)/Kephra::App::Panel::Output.$(MAN3EXT) \
	  lib/Kephra/App/Window.pm $(INST_MAN3DIR)/Kephra::App::Window.$(MAN3EXT) \
	  lib/Kephra/CommandList.pm $(INST_MAN3DIR)/Kephra::CommandList.$(MAN3EXT) \
	  lib/Kephra/Config.pm $(INST_MAN3DIR)/Kephra::Config.$(MAN3EXT) \
	  lib/Kephra/Config/File.pm $(INST_MAN3DIR)/Kephra::Config::File.$(MAN3EXT) \
	  lib/Kephra/Config/Global.pm $(INST_MAN3DIR)/Kephra::Config::Global.$(MAN3EXT) \
	  lib/Kephra/Config/Tree.pm $(INST_MAN3DIR)/Kephra::Config::Tree.$(MAN3EXT) \
	  lib/Kephra/Document.pm $(INST_MAN3DIR)/Kephra::Document.$(MAN3EXT) \
	  lib/Kephra/Document/Data.pm $(INST_MAN3DIR)/Kephra::Document::Data.$(MAN3EXT) \
	  lib/Kephra/Document/Property.pm $(INST_MAN3DIR)/Kephra::Document::Property.$(MAN3EXT) \
	  lib/Kephra/Document/SyntaxMode.pm $(INST_MAN3DIR)/Kephra::Document::SyntaxMode.$(MAN3EXT) \
	  lib/Kephra/Edit.pm $(INST_MAN3DIR)/Kephra::Edit.$(MAN3EXT) \
	  lib/Kephra/Edit/Comment.pm $(INST_MAN3DIR)/Kephra::Edit::Comment.$(MAN3EXT) \
	  lib/Kephra/Edit/Convert.pm $(INST_MAN3DIR)/Kephra::Edit::Convert.$(MAN3EXT) \
	  lib/Kephra/Edit/Format.pm $(INST_MAN3DIR)/Kephra::Edit::Format.$(MAN3EXT) \
	  lib/Kephra/Edit/Goto.pm $(INST_MAN3DIR)/Kephra::Edit::Goto.$(MAN3EXT) \
	  lib/Kephra/Edit/History.pm $(INST_MAN3DIR)/Kephra::Edit::History.$(MAN3EXT) \
	  lib/Kephra/Edit/Marker.pm $(INST_MAN3DIR)/Kephra::Edit::Marker.$(MAN3EXT) \
	  lib/Kephra/Edit/Search.pm $(INST_MAN3DIR)/Kephra::Edit::Search.$(MAN3EXT) \
	  lib/Kephra/Edit/Select.pm $(INST_MAN3DIR)/Kephra::Edit::Select.$(MAN3EXT) \
	  lib/Kephra/EventTable.pm $(INST_MAN3DIR)/Kephra::EventTable.$(MAN3EXT) \
	  lib/Kephra/File.pm $(INST_MAN3DIR)/Kephra::File.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:

EXE_FILES = bin/kephra

pure_all :: $(INST_SCRIPT)/kephra
	$(NOECHO) $(NOOP)

realclean ::
	$(RM_F) \
	  $(INST_SCRIPT)/kephra 

$(INST_SCRIPT)/kephra : bin/kephra $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/kephra
	$(CP) bin/kephra $(INST_SCRIPT)/kephra
	$(FIXIN) $(INST_SCRIPT)/kephra
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/kephra



# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	- $(RM_F) \
	  $(BASEEXT).bso $(BASEEXT).def \
	  $(BASEEXT).exp $(BASEEXT).x \
	  $(BOOTSTRAP) $(INST_ARCHAUTODIR)/extralibs.all \
	  $(INST_ARCHAUTODIR)/extralibs.ld $(MAKE_APERL_FILE) \
	  *$(LIB_EXT) *$(OBJ_EXT) \
	  *perl.core MYMETA.json \
	  MYMETA.yml blibdirs.ts \
	  core core.*perl.*.? \
	  core.[0-9] core.[0-9][0-9] \
	  core.[0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9] \
	  core.[0-9][0-9][0-9][0-9][0-9] lib$(BASEEXT).def \
	  mon.out perl \
	  perl$(EXE_EXT) perl.exe \
	  perlmain.c pm_to_blib \
	  pm_to_blib.ts so_locations \
	  tmon.out 
	- $(RM_RF) \
	  blib 
	  $(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	- $(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
# so clean is forced to complete before realclean_subdirs runs
realclean_subdirs : clean
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:
# Delete temporary files (via clean) and also delete dist files
realclean purge :: realclean_subdirs
	- $(RM_F) \
	  $(FIRST_MAKEFILE) $(MAKEFILE_OLD) 
	- $(RM_RF) \
	  $(DISTVNAME) MYMETA.yml 


# --- MakeMaker metafile section:
metafile :
	$(NOECHO) $(NOOP)


# --- MakeMaker signature section:
signature :
	cpansign -s


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ */*~ *.orig */*.orig *.bak */*.bak *.old */*.old



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(ABSPERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	  -e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';' --

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)_uu'

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)'
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).zip'
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).shar'
	$(POSTOP)


# --- MakeMaker distdir section:
create_distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"

distdir : create_distdir  
	$(NOECHO) $(NOOP)



# --- MakeMaker dist_test section:
disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL 
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)



# --- MakeMaker dist_ci section:
ci :
	$(ABSPERLRUN) -MExtUtils::Manifest=maniread -e '@all = sort keys %{ maniread() };' \
	  -e 'print(qq{Executing $(CI) @all\n});' \
	  -e 'system(qq{$(CI) @all}) == 0 or die $$!;' \
	  -e 'print(qq{Executing $(RCS_LABEL) ...\n});' \
	  -e 'system(qq{$(RCS_LABEL) @all}) == 0 or die $$!;' --


# --- MakeMaker distmeta section:
distmeta : create_distdir metafile
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -e q{META.yml};' \
	  -e 'eval { maniadd({q{META.yml} => q{Module YAML meta-data (added by MakeMaker)}}) }' \
	  -e '    or die "Could not add META.yml to MANIFEST: $${'\''@'\''}"' --
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -f q{META.json};' \
	  -e 'eval { maniadd({q{META.json} => q{Module JSON meta-data (added by MakeMaker)}}) }' \
	  -e '    or die "Could not add META.json to MANIFEST: $${'\''@'\''}"' --



# --- MakeMaker distsignature section:
distsignature : distmeta
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{SIGNATURE} => q{Public-key signature (added by MakeMaker)}}) }' \
	  -e '    or die "Could not add SIGNATURE to MANIFEST: $${'\''@'\''}"' --
	$(NOECHO) cd $(DISTVNAME) && $(TOUCH) SIGNATURE
	cd $(DISTVNAME) && cpansign -s



# --- MakeMaker install section:

install :: pure_install doc_install
	$(NOECHO) $(NOOP)

install_perl :: pure_perl_install doc_perl_install
	$(NOECHO) $(NOOP)

install_site :: pure_site_install doc_site_install
	$(NOECHO) $(NOOP)

install_vendor :: pure_vendor_install doc_vendor_install
	$(NOECHO) $(NOOP)

pure_install :: pure_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

doc_install :: doc_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read "$(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist" \
		"$(INST_LIB)" "$(DESTINSTALLPRIVLIB)" \
		"$(INST_ARCHLIB)" "$(DESTINSTALLARCHLIB)" \
		"$(INST_BIN)" "$(DESTINSTALLBIN)" \
		"$(INST_SCRIPT)" "$(DESTINSTALLSCRIPT)" \
		"$(INST_MAN1DIR)" "$(DESTINSTALLMAN1DIR)" \
		"$(INST_MAN3DIR)" "$(DESTINSTALLMAN3DIR)"
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		"$(SITEARCHEXP)/auto/$(FULLEXT)"


pure_site_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read "$(SITEARCHEXP)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist" \
		"$(INST_LIB)" "$(DESTINSTALLSITELIB)" \
		"$(INST_ARCHLIB)" "$(DESTINSTALLSITEARCH)" \
		"$(INST_BIN)" "$(DESTINSTALLSITEBIN)" \
		"$(INST_SCRIPT)" "$(DESTINSTALLSITESCRIPT)" \
		"$(INST_MAN1DIR)" "$(DESTINSTALLSITEMAN1DIR)" \
		"$(INST_MAN3DIR)" "$(DESTINSTALLSITEMAN3DIR)"
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		"$(PERL_ARCHLIB)/auto/$(FULLEXT)"

pure_vendor_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read "$(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist" \
		"$(INST_LIB)" "$(DESTINSTALLVENDORLIB)" \
		"$(INST_ARCHLIB)" "$(DESTINSTALLVENDORARCH)" \
		"$(INST_BIN)" "$(DESTINSTALLVENDORBIN)" \
		"$(INST_SCRIPT)" "$(DESTINSTALLVENDORSCRIPT)" \
		"$(INST_MAN1DIR)" "$(DESTINSTALLVENDORMAN1DIR)" \
		"$(INST_MAN3DIR)" "$(DESTINSTALLVENDORMAN3DIR)"


doc_perl_install :: all
	$(NOECHO) $(ECHO) Appending installation info to "$(DESTINSTALLARCHLIB)/perllocal.pod"
	-$(NOECHO) $(MKPATH) "$(DESTINSTALLARCHLIB)"
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> "$(DESTINSTALLARCHLIB)/perllocal.pod"

doc_site_install :: all
	$(NOECHO) $(ECHO) Appending installation info to "$(DESTINSTALLARCHLIB)/perllocal.pod"
	-$(NOECHO) $(MKPATH) "$(DESTINSTALLARCHLIB)"
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> "$(DESTINSTALLARCHLIB)/perllocal.pod"

doc_vendor_install :: all
	$(NOECHO) $(ECHO) Appending installation info to "$(DESTINSTALLARCHLIB)/perllocal.pod"
	-$(NOECHO) $(MKPATH) "$(DESTINSTALLARCHLIB)"
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLVENDORLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> "$(DESTINSTALLARCHLIB)/perllocal.pod"


uninstall :: uninstall_from_$(INSTALLDIRS)dirs
	$(NOECHO) $(NOOP)

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) "$(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist"

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) "$(SITEARCHEXP)/auto/$(FULLEXT)/.packlist"

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) "$(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist"


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE :
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:
# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	-$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	-$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	- $(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) clean $(DEV_NULL)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the $(MAKE) command.  <=="
	$(FALSE)



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = "/usr/bin/perl"
MAP_PERLINC   = "-Iblib/arch" "-Iblib/lib" "-I/usr/lib64/perl5" "-I/usr/share/perl5"

$(MAP_TARGET) :: $(MAKE_APERL_FILE)
	$(MAKE) $(USEMAKEFILE) $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : static $(FIRST_MAKEFILE) pm_to_blib
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR="" \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:
TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/*.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)
	$(NOECHO) $(NOOP)

test :: $(TEST_TYPE)
	$(NOECHO) $(NOOP)

# Occasionally we may face this degenerate target:
test_ : test_dynamic
	$(NOECHO) $(NOOP)

subdirs-test_dynamic :: dynamic pure_all

test_dynamic :: subdirs-test_dynamic
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness($(TEST_VERBOSE), 'inc', '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: dynamic pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-Iinc" "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

subdirs-test_static :: static pure_all

test_static :: subdirs-test_static
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness($(TEST_VERBOSE), '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_static :: static pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-Iinc" "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)



# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd :
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="Kephra" VERSION="0.4.3.34">' > Kephra.ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>crossplatform GUI-Texteditor along Perl alike Paradigms </ABSTRACT>' >> Kephra.ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>Herbert Breunung</AUTHOR>' >> Kephra.ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> Kephra.ppd
	$(NOECHO) $(ECHO) '        <PERLCORE VERSION="5,006,0,0" />' >> Kephra.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Config::General" VERSION="2.4" />' >> Kephra.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Cwd::" />' >> Kephra.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Encode::Guess" />' >> Kephra.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="File::UserConfig" />' >> Kephra.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="POSIX::" />' >> Kephra.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Text::Wrap" />' >> Kephra.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Wx::" VERSION="0.94" />' >> Kephra.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Wx::Perl::ProcessStream" VERSION="0.25" />' >> Kephra.ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="YAML::Tiny" VERSION="0.31" />' >> Kephra.ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="x86_64-linux-thread-multi-5.24" />' >> Kephra.ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> Kephra.ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> Kephra.ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> Kephra.ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib : $(FIRST_MAKEFILE) $(TO_INST_PM)
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  'dev.pl' '$(INST_LIB)/dev.pl' \
	  'lib/Kephra.pm' 'blib/lib/Kephra.pm' \
	  'lib/Kephra/API.pm' 'blib/lib/Kephra/API.pm' \
	  'lib/Kephra/App.pm' 'blib/lib/Kephra/App.pm' \
	  'lib/Kephra/App/ContextMenu.pm' 'blib/lib/Kephra/App/ContextMenu.pm' \
	  'lib/Kephra/App/EditPanel.pm' 'blib/lib/Kephra/App/EditPanel.pm' \
	  'lib/Kephra/App/EditPanel/Fold.pm' 'blib/lib/Kephra/App/EditPanel/Fold.pm' \
	  'lib/Kephra/App/EditPanel/Indicator.pm' 'blib/lib/Kephra/App/EditPanel/Indicator.pm' \
	  'lib/Kephra/App/EditPanel/Margin.pm' 'blib/lib/Kephra/App/EditPanel/Margin.pm' \
	  'lib/Kephra/App/MainToolBar.pm' 'blib/lib/Kephra/App/MainToolBar.pm' \
	  'lib/Kephra/App/MenuBar.pm' 'blib/lib/Kephra/App/MenuBar.pm' \
	  'lib/Kephra/App/Panel.pm' 'blib/lib/Kephra/App/Panel.pm' \
	  'lib/Kephra/App/Panel/CommandLine.pm' 'blib/lib/Kephra/App/Panel/CommandLine.pm' \
	  'lib/Kephra/App/Panel/Notepad.pm' 'blib/lib/Kephra/App/Panel/Notepad.pm' \
	  'lib/Kephra/App/Panel/Output.pm' 'blib/lib/Kephra/App/Panel/Output.pm' \
	  'lib/Kephra/App/Panel/TreeTool.pm' 'blib/lib/Kephra/App/Panel/TreeTool.pm' \
	  'lib/Kephra/App/SearchBar.pm' 'blib/lib/Kephra/App/SearchBar.pm' \
	  'lib/Kephra/App/StatusBar.pm' 'blib/lib/Kephra/App/StatusBar.pm' \
	  'lib/Kephra/App/TabBar.pm' 'blib/lib/Kephra/App/TabBar.pm' \
	  'lib/Kephra/App/Window.pm' 'blib/lib/Kephra/App/Window.pm' \
	  'lib/Kephra/CommandList.pm' 'blib/lib/Kephra/CommandList.pm' \
	  'lib/Kephra/Config.pm' 'blib/lib/Kephra/Config.pm' \
	  'lib/Kephra/Config/Default.pm' 'blib/lib/Kephra/Config/Default.pm' \
	  'lib/Kephra/Config/Default/CommandList.pm' 'blib/lib/Kephra/Config/Default/CommandList.pm' \
	  'lib/Kephra/Config/Default/ContextMenus.pm' 'blib/lib/Kephra/Config/Default/ContextMenus.pm' \
	  'lib/Kephra/Config/Default/GlobalSettings.pm' 'blib/lib/Kephra/Config/Default/GlobalSettings.pm' \
	  'lib/Kephra/Config/Default/Localisation.pm' 'blib/lib/Kephra/Config/Default/Localisation.pm' \
	  'lib/Kephra/Config/Default/MainMenu.pm' 'blib/lib/Kephra/Config/Default/MainMenu.pm' \
	  'lib/Kephra/Config/Default/ToolBars.pm' 'blib/lib/Kephra/Config/Default/ToolBars.pm' \
	  'lib/Kephra/Config/File.pm' 'blib/lib/Kephra/Config/File.pm' \
	  'lib/Kephra/Config/Global.pm' 'blib/lib/Kephra/Config/Global.pm' \
	  'lib/Kephra/Config/Interface.pm' 'blib/lib/Kephra/Config/Interface.pm' \
	  'lib/Kephra/Config/Localisation.pm' 'blib/lib/Kephra/Config/Localisation.pm' \
	  'lib/Kephra/Config/Tree.pm' 'blib/lib/Kephra/Config/Tree.pm' \
	  'lib/Kephra/Dialog.pm' 'blib/lib/Kephra/Dialog.pm' \
	  'lib/Kephra/Dialog/Color.pm' 'blib/lib/Kephra/Dialog/Color.pm' \
	  'lib/Kephra/Dialog/Config.pm' 'blib/lib/Kephra/Dialog/Config.pm' \
	  'lib/Kephra/Dialog/Exit.pm' 'blib/lib/Kephra/Dialog/Exit.pm' 
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  'lib/Kephra/Dialog/Info.pm' 'blib/lib/Kephra/Dialog/Info.pm' \
	  'lib/Kephra/Dialog/Keymap.pm' 'blib/lib/Kephra/Dialog/Keymap.pm' \
	  'lib/Kephra/Dialog/Notify.pm' 'blib/lib/Kephra/Dialog/Notify.pm' \
	  'lib/Kephra/Dialog/Search.pm' 'blib/lib/Kephra/Dialog/Search.pm' \
	  'lib/Kephra/Document.pm' 'blib/lib/Kephra/Document.pm' \
	  'lib/Kephra/Document/Change.pm' 'blib/lib/Kephra/Document/Change.pm' \
	  'lib/Kephra/Document/Data.pm' 'blib/lib/Kephra/Document/Data.pm' \
	  'lib/Kephra/Document/Property.pm' 'blib/lib/Kephra/Document/Property.pm' \
	  'lib/Kephra/Document/SyntaxMode.pm' 'blib/lib/Kephra/Document/SyntaxMode.pm' \
	  'lib/Kephra/Edit.pm' 'blib/lib/Kephra/Edit.pm' \
	  'lib/Kephra/Edit/Comment.pm' 'blib/lib/Kephra/Edit/Comment.pm' \
	  'lib/Kephra/Edit/Convert.pm' 'blib/lib/Kephra/Edit/Convert.pm' \
	  'lib/Kephra/Edit/Format.pm' 'blib/lib/Kephra/Edit/Format.pm' \
	  'lib/Kephra/Edit/Goto.pm' 'blib/lib/Kephra/Edit/Goto.pm' \
	  'lib/Kephra/Edit/History.pm' 'blib/lib/Kephra/Edit/History.pm' \
	  'lib/Kephra/Edit/Marker.pm' 'blib/lib/Kephra/Edit/Marker.pm' \
	  'lib/Kephra/Edit/Search.pm' 'blib/lib/Kephra/Edit/Search.pm' \
	  'lib/Kephra/Edit/Search/InputTarget.pm' 'blib/lib/Kephra/Edit/Search/InputTarget.pm' \
	  'lib/Kephra/Edit/Select.pm' 'blib/lib/Kephra/Edit/Select.pm' \
	  'lib/Kephra/Edit/Special.pm' 'blib/lib/Kephra/Edit/Special.pm' \
	  'lib/Kephra/EventTable.pm' 'blib/lib/Kephra/EventTable.pm' \
	  'lib/Kephra/File.pm' 'blib/lib/Kephra/File.pm' \
	  'lib/Kephra/File/History.pm' 'blib/lib/Kephra/File/History.pm' \
	  'lib/Kephra/File/IO.pm' 'blib/lib/Kephra/File/IO.pm' \
	  'lib/Kephra/File/Session.pm' 'blib/lib/Kephra/File/Session.pm' \
	  'lib/Kephra/Help.pm' 'blib/lib/Kephra/Help.pm' \
	  'lib/Kephra/Log.pm' 'blib/lib/Kephra/Log.pm' \
	  'lib/Kephra/Macro.pm' 'blib/lib/Kephra/Macro.pm' \
	  'lib/Kephra/Menu.pm' 'blib/lib/Kephra/Menu.pm' \
	  'lib/Kephra/Plugin.pm' 'blib/lib/Kephra/Plugin.pm' \
	  'lib/Kephra/Plugin/Demo.pm' 'blib/lib/Kephra/Plugin/Demo.pm' \
	  'lib/Kephra/ToolBar.pm' 'blib/lib/Kephra/ToolBar.pm' 
	$(NOECHO) $(TOUCH) pm_to_blib


# --- MakeMaker selfdocument section:

# here so even if top_targets is overridden, these will still be defined
# gmake will silently still work if any are .PHONY-ed but nmake won't

static ::
	$(NOECHO) $(NOOP)

dynamic ::
	$(NOECHO) $(NOOP)

config ::
	$(NOECHO) $(NOOP)


# --- MakeMaker postamble section:


# End.
# Postamble by Module::Install 1.01
config ::
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/."
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/."
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/cesky"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/cesky"
	$(NOECHO) $(CP) "share/help/cesky/tahle_verse.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/cesky/tahle_verse.txt"
	$(NOECHO) $(CP) "share/help/cesky/navigace.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/cesky/navigace.txt"
	$(NOECHO) $(CP) "share/help/cesky/vitejte.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/cesky/vitejte.txt"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english"
	$(NOECHO) $(CP) "share/help/english/all_feature.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/all_feature.txt"
	$(NOECHO) $(CP) "share/help/english/keymap.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/keymap.txt"
	$(NOECHO) $(CP) "share/help/english/special_feature.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/special_feature.txt"
	$(NOECHO) $(CP) "share/help/english/navigation.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/navigation.txt"
	$(NOECHO) $(CP) "share/help/english/this_version.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/this_version.txt"
	$(NOECHO) $(CP) "share/help/english/welcome.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/welcome.txt"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/license"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/license"
	$(NOECHO) $(CP) "share/help/english/license/scintilla.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/license/scintilla.txt"
	$(NOECHO) $(CP) "share/help/english/license/credits.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/license/credits.txt"
	$(NOECHO) $(CP) "share/help/english/license/wx.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/license/wx.txt"
	$(NOECHO) $(CP) "share/help/english/license/lgpl.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/license/lgpl.txt"
	$(NOECHO) $(CP) "share/help/english/license/artistic.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/license/artistic.txt"
	$(NOECHO) $(CP) "share/help/english/license/gpl.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/english/license/gpl.txt"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/romana"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/romana"
	$(NOECHO) $(CP) "share/help/romana/functiuni.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/romana/functiuni.txt"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/deutsch"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/deutsch"
	$(NOECHO) $(CP) "share/help/deutsch/alle_funktionen.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/deutsch/alle_funktionen.txt"
	$(NOECHO) $(CP) "share/help/deutsch/besondere_funktionen.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/deutsch/besondere_funktionen.txt"
	$(NOECHO) $(CP) "share/help/deutsch/diese_version.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/deutsch/diese_version.txt"
	$(NOECHO) $(CP) "share/help/deutsch/tastaturbelegung.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/deutsch/tastaturbelegung.txt"
	$(NOECHO) $(CP) "share/help/deutsch/navigation.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/deutsch/navigation.txt"
	$(NOECHO) $(CP) "share/help/deutsch/willkommen.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/deutsch/willkommen.txt"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/deutsch/lizenz"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/deutsch/lizenz"
	$(NOECHO) $(CP) "share/help/deutsch/lizenz/anerkennung.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/deutsch/lizenz/anerkennung.txt"
	$(NOECHO) $(CP) "share/help/deutsch/lizenz/gpl.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/help/deutsch/lizenz/gpl.txt"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/plugin"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/plugin"
	$(NOECHO) $(CP) "share/config/plugin/installed.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/plugin/installed.conf"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/session"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/session"
	$(NOECHO) $(CP) "share/config/session/history.yml" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/session/history.yml"
	$(NOECHO) $(CP) "share/config/session/current.yaml" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/session/current.yaml"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global"
	$(NOECHO) $(CP) "share/config/global/autosaved.conf~" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/autosaved.conf~"
	$(NOECHO) $(CP) "share/config/global/autosaved.conf.old" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/autosaved.conf.old"
	$(NOECHO) $(CP) "share/config/global/autosaved.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/autosaved.conf"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/data"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/data"
	$(NOECHO) $(CP) "share/config/global/data/search.yml" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/data/search.yml"
	$(NOECHO) $(CP) "share/config/global/data/notepad_content.txt" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/data/notepad_content.txt"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/sub"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/sub"
	$(NOECHO) $(CP) "share/config/global/sub/pbs.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/sub/pbs.conf"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/sub/documentation"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/sub/documentation"
	$(NOECHO) $(CP) "share/config/global/sub/documentation/english.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/sub/documentation/english.conf"
	$(NOECHO) $(CP) "share/config/global/sub/documentation/cesky.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/sub/documentation/cesky.conf"
	$(NOECHO) $(CP) "share/config/global/sub/documentation/deutsch.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/global/sub/documentation/deutsch.conf"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/template"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/template"
	$(NOECHO) $(CP) "share/config/template/perl.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/template/perl.conf"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/pascal.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/pascal.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/context.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/context.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/nsis.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/nsis.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/sh.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/sh.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/baan.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/baan.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/lua.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/lua.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/scheme.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/scheme.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/tex.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/tex.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/conf.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/conf.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/js.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/js.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/lisp.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/lisp.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/vbs.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/vbs.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/asm.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/asm.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/fortran.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/fortran.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/forth.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/forth.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/python.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/python.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/yaml.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/yaml.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/perl.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/perl.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/tcl.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/tcl.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/idl.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/idl.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/batch.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/batch.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/diff.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/diff.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/eiffel.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/eiffel.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/xml.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/xml.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/cpp.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/cpp.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/css.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/css.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/ada.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/ada.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/matlab.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/matlab.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/java.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/java.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/err.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/err.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/php.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/php.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/html.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/html.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/latex.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/latex.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/property.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/property.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/as.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/as.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/sql.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/sql.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/ps.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/ps.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/make.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/make.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/ruby.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/ruby.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/cs2.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/cs2.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/vb.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/vb.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/ave.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/ave.pm"
	$(NOECHO) $(CP) "share/config/syntaxhighlighter/cs.pm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxhighlighter/cs.pm"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxmode"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxmode"
	$(NOECHO) $(CP) "share/config/syntaxmode/perl.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/syntaxmode/perl.conf"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface"
	$(NOECHO) $(CP) "share/config/interface/contextmenus.yml" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/contextmenus.yml"
	$(NOECHO) $(CP) "share/config/interface/appbars.yml" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/appbars.yml"
	$(NOECHO) $(CP) "share/config/interface/commands.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/commands.conf"
	$(NOECHO) $(CP) "share/config/interface/mainmenu.yml" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/mainmenu.yml"
	$(NOECHO) $(CP) "share/config/interface/iconset_jenne.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/iconset_jenne.conf"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/app"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/app"
	$(NOECHO) $(CP) "share/config/interface/icon/app/wxwin.ico" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/app/wxwin.ico"
	$(NOECHO) $(CP) "share/config/interface/icon/app/proton.ico" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/app/proton.ico"
	$(NOECHO) $(CP) "share/config/interface/icon/app/wxpl.ico" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/app/wxpl.ico"
	$(NOECHO) $(CP) "share/config/interface/icon/app/mdi.ico" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/app/mdi.ico"
	$(NOECHO) $(CP) "share/config/interface/icon/app/proton2.ico" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/app/proton2.ico"
	$(NOECHO) $(CP) "share/config/interface/icon/app/proton.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/app/proton.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/app/snippet.ico" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/app/snippet.ico"
	$(NOECHO) $(CP) "share/config/interface/icon/app/note.ico" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/app/note.ico"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/help-home.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/help-home.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/file-save.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/file-save.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/edit-bookmark.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/edit-bookmark.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/app-exit.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/app-exit.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/goto-line.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/goto-line.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/empty.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/empty.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/reload.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/reload.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/go-fast-backward.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/go-fast-backward.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/line-wrap.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/line-wrap.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/file-print.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/file-print.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/preview.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/preview.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/find-start.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/find-start.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/edit-replace.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/edit-replace.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/file-open.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/file-open.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/find-previous.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/find-previous.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/find-next.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/find-next.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/edit-delete.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/edit-delete.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/file-manager.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/file-manager.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/go-first.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/go-first.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/go-previous.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/go-previous.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/file-new.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/file-new.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/go-next.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/go-next.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/favourite.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/favourite.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/edit-cut.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/edit-cut.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/replace-next.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/replace-next.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/help-info.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/help-info.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/edit-redo.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/edit-redo.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/clean-up.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/clean-up.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/config-preferences.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/config-preferences.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/config-mode-perl.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/config-mode-perl.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/replace-start.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/replace-start.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/config-mode-html.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/config-mode-html.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/console.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/console.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/go-fast-forward.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/go-fast-forward.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/stay-on-top.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/stay-on-top.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/edit-paste.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/edit-paste.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/help-mail.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/help-mail.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/edit-undo.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/edit-undo.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/file-save-all.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/file-save-all.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/note.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/note.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/file-close.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/file-close.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/go-last.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/go-last.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/help-tip.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/help-tip.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/replace-previous.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/replace-previous.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/image.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/image.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/help-documentation.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/help-documentation.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/config-mode-full.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/config-mode-full.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/goto-last-edit.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/goto-last-edit.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/file-save-as.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/file-save-as.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/edit-copy.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/edit-copy.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/tango/help-keyboard.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/tango/help-keyboard.xpm"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/help-home.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/help-home.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/file-save.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/file-save.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/edit-bookmark.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/edit-bookmark.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/app-exit.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/app-exit.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/goto-line.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/goto-line.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/bookmark8.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/bookmark8.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/bookmark2.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/bookmark2.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/empty.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/empty.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/reload.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/reload.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/go-fast-backward.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/go-fast-backward.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/line-wrap.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/line-wrap.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/bookmark7.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/bookmark7.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/file-print.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/file-print.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/preview.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/preview.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/find-start.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/find-start.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/edit-replace.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/edit-replace.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/file-open.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/file-open.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/bookmark1.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/bookmark1.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/find-previous.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/find-previous.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/edit-edit.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/edit-edit.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/find-next.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/find-next.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/marker-next.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/marker-next.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/panel-close.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/panel-close.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/edit-delete.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/edit-delete.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/editor-fullscreen.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/editor-fullscreen.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/go-first.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/go-first.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/go-previous.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/go-previous.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/file-new.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/file-new.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/colorpicker.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/colorpicker.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/go-next.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/go-next.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/favourite.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/favourite.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/edit-cut.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/edit-cut.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/bookmark6.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/bookmark6.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/output-panel.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/output-panel.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/replace-next.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/replace-next.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/marker-previous.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/marker-previous.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/help-info.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/help-info.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/edit-redo.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/edit-redo.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/run-skript.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/run-skript.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/clean-up.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/clean-up.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/config-preferences.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/config-preferences.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/config-mode-perl.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/config-mode-perl.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/replace-start.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/replace-start.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/config-mode-html.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/config-mode-html.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/go-fast-forward.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/go-fast-forward.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/marker.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/marker.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/stay-on-top.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/stay-on-top.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/bookmark5.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/bookmark5.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/edit-paste.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/edit-paste.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/help-mail.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/help-mail.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/edit-undo.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/edit-undo.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/file-save-all.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/file-save-all.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/note.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/note.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/file-close.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/file-close.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/go-last.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/go-last.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/help-tip.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/help-tip.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/replace-previous.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/replace-previous.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/image.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/image.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/bookmark0.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/bookmark0.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/help-documentation.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/help-documentation.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/config-mode-full.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/config-mode-full.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/bookmark4.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/bookmark4.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/goto-last-edit.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/goto-last-edit.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/file-save-as.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/file-save-as.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/edit-copy.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/edit-copy.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/help-keyboard.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/help-keyboard.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/bookmark9.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/bookmark9.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/set/jenne/bookmark3.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/set/jenne/bookmark3.xpm"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/splash"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/splash"
	$(NOECHO) $(CP) "share/config/interface/icon/splash/start_kephra.xpm" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/splash/start_kephra.xpm"
	$(NOECHO) $(CP) "share/config/interface/icon/splash/start_kephra.jpg" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/icon/splash/start_kephra.jpg"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/cache"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/cache"
	$(NOECHO) $(CP) "share/config/interface/cache/index_l18n.yml" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/interface/cache/index_l18n.yml"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/localisation"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/localisation"
	$(NOECHO) $(CP) "share/config/localisation/norsk.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/localisation/norsk.conf"
	$(NOECHO) $(CP) "share/config/localisation/english.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/localisation/english.conf"
	$(NOECHO) $(CP) "share/config/localisation/cesky.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/localisation/cesky.conf"
	$(NOECHO) $(CP) "share/config/localisation/espanol.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/localisation/espanol.conf"
	$(NOECHO) $(CP) "share/config/localisation/romana.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/localisation/romana.conf"
	$(NOECHO) $(CP) "share/config/localisation/deutsch.conf" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/localisation/deutsch.conf"
	$(NOECHO) $(MKPATH) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/macro"
	$(NOECHO) $(CHMOD) $(PERM_DIR) "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/macro"
	$(NOECHO) $(CP) "share/config/macro/test.macro" "$(INST_LIB)/auto/share/dist/$(DISTNAME)/config/macro/test.macro"


