## Process this file with automake to produce Makefile.in
EXTRA_IMAGES = next.png next.jpg next.gif
TEST_SCRIPT = test_script
EXTRA_DIST = @INPUT_FILES@ $(EXTRA_IMAGES) $(TEST_SCRIPT) imcmp.pl rgb.txt

CLEANFILES = @OUTPUT_FILES@
SUBDIRS = ref

TESTS_ENVIRONMENT=export PERL=$(PERL); $(srcdir)/$(TEST_SCRIPT)
TESTS := @INPUT_FILES@
