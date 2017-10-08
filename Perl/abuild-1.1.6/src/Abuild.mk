# Ordinarily, the abuild-autoconf build item would create an interface
# file that would be loaded automatically by virtue of our dependency
# on that build item.  However, to make this work for both
# bootstrapping and building with abuild, we generate a makefile
# fragment and included it instead.

../autoconf/abuild-$(ABUILD_PLATFORM)/autoconf-bootstrap.mk:
	($(MAKE) -C ../autoconf -f Makefile.bootstrap)

include ../autoconf/abuild-$(ABUILD_PLATFORM)/autoconf-bootstrap.mk

# MSVC doesn't require explicitly naming of boost libraries
ifneq ($(CCXX_TOOLCHAIN), msvc)
LIBS += $(foreach L,thread regex system filesystem date_time,boost_$(L)$(BOOST_LIB_SUFFIX))
endif

ifdef ABUILD_STATIC
# Support static linking for the bootstrap build
XLINKFLAGS += -static
endif

ifndef ABUILD_SKIP_WERROR
 ifeq ($(CCXX_TOOLCHAIN), gcc)
 WFLAGS += -Werror
 endif
endif

ifeq ($(CCXX_TOOLCHAIN), msvc)
# Disable a warning in InterfaceParser about using "this" in a constructor
WFLAGS_InterfaceParser.cc = -wd4355
WFLAGS_test_option_parser.cc = -wd4355
endif

WFLAGS_interface.tab.cc :=
WFLAGS_interface.fl.cc :=

TEST_PROGS := \
	test_util \
	test_keyval \
	test_canonicalize_path \
	test_get_program_fullpath \
	test_run_program \
	test_option_parser \
	test_logger \
	test_thread_safe_queue \
	test_worker_pool \
	test_dependency_graph \
	test_dependency_evaluator \
	test_dependency_runner \
	test_interface \
	test_interface_parser \
	test_threaded_fork

TARGETS_bin := abuild $(TEST_PROGS)
TARGETS_lib := abuild

$(foreach P,$(TEST_PROGS),$(eval SRCS_bin_$(P) := $(P).cc))

# Sources that are not specific to abuild
ifeq ($(ABUILD_PLATFORM_OS), windows)
  PROCESS_HANDLER_OS := windows
else
  PROCESS_HANDLER_OS := unix
endif
GENERAL_SRCS := \
	QTC.cc \
	QEXC.cc \
	Util.cc \
	ProcessHandler.cc \
	ProcessHandler_$(PROCESS_HANDLER_OS).cc \
	Logger.cc \
	Error.cc \
	KeyVal.cc \
	FileLocation.cc \
	OptionParser.cc \
	DependencyEvaluator.cc \
	DependencyGraph.cc \
	DependencyRunner.cc

# Automatically generated scanners and parsers
AUTO_SRCS := \
	interface.tab.cc \
	interface.fl.cc

ifndef ABUILD_SKIP_PARSER_CACHE
 FLEX_CACHE := parser-cache
 BISON_CACHE := parser-cache
endif

# All sources including abuild-specific sources

# The "abuild library" isn't released -- it's just a convenient way of
# getting all the object files together for use by the various test
# programs.  We put files that are not used by any test suites (other
# than abuild's own) in with the executable instead of the library
# simply to avoid having to relink all the test programs whenever
# they change.
SRCS_lib_abuild := \
	$(GENERAL_SRCS) \
	$(AUTO_SRCS) \
	InterfaceParser.cc \
	FlagData.cc \
	Parser.cc \
	Token.cc \
	TokenFactory.cc \
	NonTerminal.cc \
	nt_Word.cc \
	nt_Words.cc \
	nt_AfterBuild.cc \
	nt_TargetType.cc \
	nt_TypeSpec.cc \
	nt_Declaration.cc \
	nt_Function.cc \
	nt_Argument.cc \
	nt_Arguments.cc \
	nt_Conditional.cc \
	nt_Assignment.cc \
	nt_Reset.cc \
	nt_Blocks.cc \
	nt_Block.cc \
	nt_IfClause.cc \
	nt_IfClauses.cc \
	nt_IfBlock.cc \
	Interface.cc \
	TargetType.cc

SRCS_bin_abuild := \
	PlatformData.cc \
	TraitData.cc \
	PlatformSelector.cc \
	ItemConfig.cc \
	BackingConfig.cc \
	BuildForest.cc \
	BuildTree.cc \
	BuildItem.cc \
	JavaBuilder.cc \
	UpgradeData.cc \
	Abuild-misc.cc \
	Abuild-init.cc \
	Abuild-help.cc \
	Abuild-dump.cc \
	Abuild-traverse.cc \
	Abuild-buildset.cc \
	Abuild-build.cc \
	Abuild-upgrade.cc \
	abuild_main.cc

# If not defined or empty, coverage cases will not be invoked in the
# make code.
export QTC_MK_DIR := $(shell qtest-driver --print-path)/QTC/make

export TC_SRCS := \
	$(wildcard $(SRCDIR)/*.cc) \
	$(wildcard $(SRCDIR)/../rules/*/*.mk) \
	$(wildcard $(SRCDIR)/../make/*.mk) \
	$(wildcard $(SRCDIR)/../make/*/*.mk) \
	$(wildcard $(SRCDIR)/../make/*/*/*.mk) \
	$(wildcard $(SRCDIR)/../groovy/*.groovy) \
	$(wildcard $(SRCDIR)/java-support/src/java/org/abuild/*.java) \
	$(wildcard $(SRCDIR)/java-support/src/java/org/abuild/*/*.java) \
	$(wildcard $(SRCDIR)/java-support/src/groovy/org/abuild/*/*.groovy)

RULES := ccxx
LOCAL_RULES := local-rules.mk
