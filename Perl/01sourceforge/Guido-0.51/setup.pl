package main;

#########################################################
# For installing from a remote location, use this format#
#########################################################
#my $inst_location = 'http://mysite.com/myprogram.osd';

############################################
# For a local installation, use this format#
############################################
my $inst_location = './guido.osd';
PI::install($inst_location, 1);

################################################
# The code below this comment shouldn't require#
#  editing                                     #
################################################

package PI;

use strict;
use vars qw/@ISA @EXPORT $VERSION/;
use File::Copy;
use File::Path;
use File::Spec::Functions 'splitpath';
use Data::Dumper;

$| = 1;

use Config;
require Exporter;

@ISA = qw(Exporter);

@EXPORT = qw(
		 install
);

$VERSION = '0.25';

#Constants
use constant DEF_INSTALL_DIR => '/';
use constant DEF_LINUX_INSTALL_DIR => '/usr/local/';
use constant DEF_WIN32_INSTALL_DIR => 'c:\\program files\\';
use constant MAX_DISP_LINES => 25;

#Private globals
my $install_dir;
my $package_name;
my $package;
my $real_package_file;
my $tar;
my $osd;

# Preloaded methods go here.
sub new{
  my($class, %attribs) = @_;
  my $self = {
    no_extract => $attribs{no_extract},
    osd_href => $attribs{osd},
    pi_file  => $attribs{pi_file},
    loaded   => {},
    needed   => {
	'XML::Parser' => [
	    {type=>'ppm', package=>'XML-Parser'},
	    {type=>'cpan', package=>'XML::Parser'},
	  ],
	'XML::DOM' => [
	    {type=>'ppm', package=>'XML-DOM'},
	    {type=>'cpan', package=>'XML::DOM'},
	  ],
	'Archive::Tar' => [
	    {type=>'ppm', package=>'Archive-Tar'},
	    {type=>'cpan', package=>'Archive::Tar'},
	  ],
	'LWP::Simple' => [
	    {type=>'ppm', package=>'LWP-Simple'},
	    {type=>'cpan', package=>'LWP::Simple'},
	  ],
	'URI' => [
	    {type=>'ppm', package=>'URI'},
	    {type=>'cpan', package=>'URI'},
	  ]
    }
  };
  return bless $self => $class;
}

sub install{
  my($file, $no_extract) = @_;
  my $pi;
  if ($file =~ /.pi$/) {
    $pi = new PI(pi_file => $file, no_extract=>$no_extract);
  }
  else {
    $pi = new PI(osd => $file, no_extract=>$no_extract);
  }

  $pi->install_package();

}

sub install_package{
  my($self) = @_;

  $self->eval_deps();
  if (keys(%{$self->{needed}})) {
      $self->install_dependencies();
  }
  $self->init();
  $self->verify_dependencies();
  if (keys(%{$self->{needed}})) {
    $self->install_dependencies();
  }
  $self->verify_package();
  $self->load_archive();
  $self->prelude();
  $self->get_install_dir();
  $self->install_package_files();
  $self->post_config();
  print "Installation successful\n";
  return 1;
}

# Figure out initial information need to get going
#  we either use the osd or pi file provided
sub init{
  my($self) = @_;
  $self->{tmp_dir} = File::Spec::Functions::tmpdir();
  if ($self->{pi_file}) {
    $self->load_pi_file();
  }
  else{
    $self->parse_osd();
  }


}

sub rel2abs{
  my($rel, $abs) = @_;
  if ($rel =~ m|://|) {return $rel}
  my $tmp_href = $abs;
  $tmp_href =~ s|[^/]+$||;
  $tmp_href .= $rel;
  return $tmp_href;
}

sub parse_osd{
  my($self) = @_;

  #Normalize the osd path to a URI
  if(is_uri($self->{osd_href})) {
    $self->{osd_href} = URI->new($self->{osd_href})->as_string();
  }
  else {
    $self->{osd_href} = URI::file->new_abs($self->{osd_href})->as_string();
  }

  # get osd content
#  my $osd_content = LWP::Simple::get($self->{osd_href});
#  if (!$osd_content) {
#    die "Couldn't access OSD file at " . $self->{osd_href} . ": $!";
#  }

  print "Parsing OSD file at " . $self->{osd_href} . "...";

  my $osd_content;
  my $dom = XML::DOM::Parser->new();
  my $osd_doc = $dom->parse(LWP::Simple::get($self->{osd_href}));

  if (!$osd_doc) {
    die "failed to load: $!";
  }

  #parse it and load the data structure
  my $pkg_node = $osd_doc->getElementsByTagName("SOFTPKG")->[0];
  my $package_id = $pkg_node->getAttribute("NAME");
  my $version = $pkg_node->getAttribute("VERSION");
  my $lic_node = $pkg_node->getElementsByTagName("LICENSE")->[0];
  my $license_href = $lic_node->getAttribute("HREF");

  #Just for now we assume that the codebase is platform independent!
  my $cb_node = $pkg_node->getElementsByTagName("CODEBASE")->[0];
  my $package_href = $cb_node->getAttribute("HREF");
  my $post_install_script = $pkg_node->getElementsByTagName("INSTALL")->[0]->getFirstChild->getNodeValue();

  my $author = $pkg_node->getElementsByTagName("AUTHOR")->[0]->getFirstChild->getNodeValue();
  my $abstract = $pkg_node->getElementsByTagName("ABSTRACT")->[0]->getFirstChild->getNodeValue();
  $self->{osd_content} = $osd_doc->toString();
  $self->{osd_data} = {
    package_id   => $package_id,
    version      => $version,
    author       => $author,
    license_href => rel2abs($license_href, $self->{osd_href}),
    abstract     => $abstract,
    package_href => rel2abs($package_href, $self->{osd_href}),
    post_install_script => $post_install_script,
  };

  #figure out dependencies
  my @deps = $pkg_node->getElementsByTagName("DEPENDENCY");
  foreach my $dep (@deps) {
    my $dep_array = [];
    $self->{osd_data}->{deps}->{$dep->getAttribute("NAME")} = $dep_array;
    foreach my $codebase ($dep->getElementsByTagName("CODEBASE")) {
      push(@$dep_array, {
        type => $codebase->getAttribute("TYPE"),
        package => $codebase->getAttribute("PACKAGE"),
        location => $codebase->getAttribute("LOCATION"),
      });
    }
  }
#  print Dumper($self->{osd_data}) . "\n";
#  exit;

  print "ok.\n";

  return 1;
}

sub is_uri{$_[0] =~ m|^http://|;}

sub verify_package{
  my($self) = @_;

  return 1 if $self->{no_extract};

  my $package_href = $self->{osd_data}->{package_href};
  
  my $real_package_file = $self->{tmp_dir} . "/" . $self->{osd_data}->{package_id};
  print "Downloading package file $package_href to $real_package_file...";
  my $response = LWP::Simple::getstore($package_href, $real_package_file);
  if(LWP::Simple::is_success($response)) {
    print "successful.\n";
    $self->{real_package_file} = $real_package_file;
    return 1;
  }
  else {
    die "failed (error code $response)";
    return 0;
  }
}

sub verify_dependencies{
  my($self) = @_;
  my %deps = %{$self->{osd_data}->{deps}};
  while(my($dep_name, $dep_srcs) = each %deps) {
    print "Checking for package dependency $dep_name...";
    if ($self->{loaded}->{$dep_name}) {
      print "found.\n";
    }
    else {
      print "\n\t";
      $self->load_module($dep_name, 0);
    }
    if (!$self->{loaded}->{$dep_name}) {
      $self->{needed}->{$dep_name} = $dep_srcs;
    }
  }
  #print Dumper $self;

#  exit;
  return 1;
}

sub install_dependencies{
  my($self) = @_;
  print "Some dependencies were not found.  Would you like to install them now?(y/n):";
  while(my $response = <STDIN>) {
    if ($response =~ /^y/i) {
      print "OK\n";
      while(my($needed, $srcs) = each %{$self->{needed}}) {
	print "Attempting to install $needed...\n";
	#my $multi_srcs;
	my $i;
	my %transports;
	my $codebase_url;
	if (scalar(@$srcs) > 1) {
	  $i = 1;
	  print "The following installation mechanisms are available:\n";
	  foreach my $codebase (@$srcs) {
	    my $transport = $codebase->{type};
	    my $package = $codebase->{package};
            my $location = $codebase->{location};
	    $transports{"$i"} = $codebase;
	    print $i . ") " . uc($transport) . "\n";
	    ++$i;
	  }
	  $i = $i-1;
	  my $choice = 0;
	  while(!grep(/$choice/,(1..$i))) {
	    print "Please enter your choice (1-$i): ";
	    chomp($choice = <STDIN>);
	  }
	  $codebase_url = $transports{$choice};
	}
	else {
	  $codebase_url = $srcs->[0];
	}
	
	my $transport = $codebase_url->{type};
	my $package = $codebase_url->{package};
	if ($transport eq "cpan") {
	  if($self->install_cpan_package($package)) {
	    delete $self->{needed}->{$needed};
	    print "Installation of $package succeeded.\n";
	  }
	  else {
	    print "Installation of $package failed.\n";
	  }
	}
	elsif($transport eq "ppm") {
	  my $location = $codebase_url->{location};
	  if($self->install_ppm_package($package, $location)) {
	    delete $self->{needed}->{$needed};
	    print "Installation of $package succeeded.\n";
	  }
	  else {
	    print "Installation of $package failed: " . $PPM::PPMERR . ".\n";
	  }
	}
      }
      last;
    }
    elsif($response =~ /^n/i) {
      print "Cannot continue without dependencies\n";
      last;
    }
    print "Some dependencies were not found.  Would you like to install them now?(y/n):";
  }
}

sub install_ppm_package{
  my($self, $package, $location) = @_;
  my $location_desc = '';
  $location_desc = "( Repository: $location )" if $location;
  print "Installing ppm package $package $location_desc...\n";

  my %package_info = (
    package => $package,
#    location => $location,
  );

  $package_info{'location'} = $location if $location;

  PPM::InstallPackage(%package_info);
  my %hash = PPM::InstalledPackageProperties();
  if($hash{$package}) {
    return 1;
  }
  else {
    return 0;
  }
}

sub install_cpan_package{
  my($self, $package) = @_;
  print "Installing cpan package $package...\n";
  CPAN::Shell->install($package);
  my $mod = CPAN::Shell->expand("Module", $package);
  if ($mod && $mod->inst_file) {
    return 1;
  }
  else {
    return 0;
  }
}

sub load_archive{
  my($self) = @_;
  my $script = $self->{osd_data}->{post_install_script};
  if ($self->{no_extract}) {
    my ($package) = $self->{osd_data}->{package_href} =~ m|/([^/]+)\.tar\.gz|;
    $script =~ s/^$package\///;
    $self->{post_config_code} = join('', _read_file($script));
  }
  else {
    my $package = $self->{osd_data}->{package_id};
    my $real_package_file = $self->{real_package_file};
    my $package = $self->{osd_data}->{package_id};

    print "Loading package file $package ($real_package_file)\n";

    $self->{tar_archive} = Archive::Tar->new($real_package_file, 1);
    $self->{post_config_code} = $self->{tar_archive}->get_content($script);
#  print $self->{post_config_code} . "\n";
#  exit;
    return 1;
  }
}

sub eval_deps {
  my($self) = @_;
  $self->load_module("Archive::Tar", 1);
  $self->load_module("LWP::Simple", 1);
  $self->load_module("XML::Parser", 1);
  $self->load_module("XML::DOM", 1);
  $self->load_module("File::Path", 1);
  $self->load_module("File::Spec::Functions", 1);
  $self->load_module("URI", 1);
  $self->load_module("URI::file", 1);
  $self->load_module("PPM", 0);
  $self->load_module("CPAN", 0);
}

sub load_module {
  my($self, $module, $required) = @_;
  print "Loading external module $module...";
  eval "require $module;";
  if ($@) {
    print "not found.\n"; 
  }
  else {
    print "found.\n";
    delete $self->{needed}->{$module};
    $self->{loaded}->{$module} = 1;
  }
  return 1;
}

sub prelude{
  my($self) = @_;
  my $readme_text;
  my ($package_name) = $self->{osd_data}->{package_href} =~ m|/([^/]+)\.tar\.gz|;

  if(!$self->{no_extract} && grep(m|^$package_name/README$|i, $self->{tar_archive}->list_files())) {
	$readme_text = $self->{tar_archive}->get_content("$package_name/README");
  }
  elsif (-e 'README') {
      open(README, "README") or die "Couldn't open README file: $!\n";
      my @readme_text = <README>;
      $readme_text = join("\n", @readme_text);
  }

  print "Would you like to read the README file? (y/n):";
  while(my $response = <STDIN>) {
      if ($response =~ /^y/i) {
	  print "OK\n";
	  _display($readme_text);
	  last;
      }
      elsif($response =~ /^n/i) {
	  print "Skipping README\n";
	  last;
      }
      print "Would you like to read the README file? (y/n):";
  }
  print "\n\nI am ready to install the program.  You can enter your preferred installation directory (or you can take the default by hitting \"enter\".)\n\n";
}

sub get_install_dir{
  my($self) = @_;
  my $package_name = $self->{osd_data}->{package_id};
  if($Config{osname} eq 'linux') {
    $install_dir = DEF_LINUX_INSTALL_DIR . $package_name;
  }
  elsif ($Config{osname} eq 'MSWin32') {
    $install_dir = DEF_WIN32_INSTALL_DIR . $package_name;
  }
  else {
    print "Unable to recognize operating system, using fallback installation directory...\n";
    $install_dir = DEF_INSTALL_DIR . $package_name;
  }
  print "Please choose install directory [default: $install_dir]:";
  my $custom_install_dir = <STDIN>;
  chomp($install_dir = $custom_install_dir) if $custom_install_dir ne "\n";
  print "Install dir will be $install_dir\n";
  $self->{install_dir} = $install_dir;
  return 1;
}

sub post_config{
  my($self) = @_;
  chdir($self->{install_dir}) or die "Couldn't change directory to $self->{install_dir}: $!";
  my $script = $self->{osd_data}->{post_install_script};
  print "Running post install script " . $script . "\n";
  my $post_config_code = $self->{post_config_code};
  $@ = 0;
eval <<EVAL_CODE;
$post_config_code
EVAL_CODE

  if ($@) {
    print "There was an error executing the post installation script: $@\n";
    print "The file content was: \n$post_config_code\n";
    return 0;
  }
  return 1;
}

sub show_docs{
}

sub ensure_directory{
  my($dir) = @_;
  File::Path::mkpath($dir, 0, 0755);
  if (!-d $dir) {die "Couldn't create directory $dir"}
}

sub install_package_files {
  my($self) = @_;
  my $package_name = $self->{osd_data}->{package_id};
  my $install_dir = $self->{install_dir};
  my $tar = $self->{tar_archive};
  my $inst_err;

  print "Initiating installation of $package_name\n";

  ensure_directory($install_dir);
  if (!$self->{no_extract}) {chdir($self->{tmp_dir});}
  my ($package_name) = $self->{osd_data}->{package_href} =~ m|/([^/]+)\.tar\.gz|;
  if (!$package_name) {
      $inst_err = 1; 
      $! = "Couldn't resolve package name from " . 
	$self->{osd_data}->{package_href};
      return 0;
  }
  unless($self->{no_extract}) {
      foreach my $file ($tar->list_files()) {
	  print "Extracting $file\n";
	  $tar->extract($file);
	  if ($Archive::Tar::Error) {
	      print "Error during installation: " . $Archive::Tar::Error . "\n";
	      $inst_err = 1;
	      return 0;
	  }
      }
  }
  if (!$inst_err) {
      if (!$self->{no_extract}) {
	  chdir($package_name) or die "Couldn't enter extracted files directory, $package_name: $!";
      }
      open(MANIFEST, "MANIFEST") or die "Couldn't extract MANIFEST information";
      while(chomp(my $file = <MANIFEST>)) {
	  my $base_file = $file;
	  $base_file =~ s/$package_name//;
	  my($null, $dest_dir, $null2) = splitpath($file);
	  mkpath("$install_dir/$dest_dir", 1, 0755);
	  print "Copying $file to $install_dir/$base_file\n";
	  copy("./$file", "$install_dir/$base_file") or ($inst_err = 1 && last);
      }
  }
  if ($inst_err) {
    return 0;
  }
  else {
    print "Files installed successfully\n";
    return 1;
  }
}

sub _read_file{
  my($file) = @_;
  open(F, $file) or warn "Failed to open file $file: $!\n";
  my @file = <F>;
  return @file;
}

sub _display{
  my($to_display) = @_;
  my @to_display = split("\n", $to_display);
  while(@to_display) {
    for(my $i=0;$i<MAX_DISP_LINES;$i++) {
      print shift @to_display;
      print "\n";
      last if !@to_display;
    }
    last if !@to_display;
    print "<MORE - hit enter>";
    my $null = <STDIN>;
  }
  print "<END - hit enter>";
  my $null = <STDIN>;
}

1;
__END__

=head1 NAME

PI - Perl extension for installing a Perl program

=head1 SYNOPSIS

  use PI;
  install('myprogram.osd');

=head1 DESCRIPTION

PI is developed for installing the perl program Guido.  Hopefully, it can be used to install other Perl programs without much modification, but it's certainly in need of improvement.  Please improve it and send patches to the author.

PI uses the Open Software Description format for figuring out information about the package to install.  For information on OSD, go to the W3C web site (www.w3c.org), or see the sample file available at the Guido web site (guido.sourceforge.net).

=head2 EXPORT

None.

=head1 AUTHOR

James Tillman <jtillman@bigfoot.com>

=head1 SEE ALSO

perl(1).

=cut
