use Config;

if (!$self) {
  die "Couldn't get access to the installation environment.  Aborting post-installation configuration.\nThis script is meant to be run by the installer and should not be run directly.";
}
my $install_dir = $self->{install_dir};
my $response = 'n';

if (-e "$install_dir/bin/guido_config.cfg" or 
      -e "$install_dir/bin/guido_rt.cfg") {
    my $prompt = "You currently have configuration files in\nthe main Guido installation directory.\nWould you like to keep them? [y/n]:";
    print $prompt;
    while(chomp($response = <STDIN>)) {
	last if $response =~ /^(y|n)$/i;
	print $prompt;
    }
}
if ($response eq 'y') {
    print "Keeping old configuration files\n";
}
else {
    chmod(0644, "$install_dir/bin/guido_config.cfg");
    chmod(0644, "$install_dir/bin/guido_rt.cfg");
    open(CFG_IN, "$install_dir/bin/guido_config.cfg.ex") or 
      die "Couldn't open $install_dir/bin/guido_config.cfg.ex for reading: $!";
    open(RT_IN, "$install_dir/bin/guido_rt.cfg.ex") or 
      die "Couldn't open $install_dir/bin/guido_rt.cfg.ex for reading: $!";
    open(CFG_OUT, ">$install_dir/bin/guido_config.cfg") or 
      die "Couldn't open $install_dir/bin/guido_config.cfg for writing: $!";
    open(RT_OUT, ">$install_dir/bin/guido_rt.cfg") or 
      die "Couldn't open $install_dir/bin/guido_rt.cfg for writing: $!";
}

open(SCR_IN, "$install_dir/bin/guido.pl.ex") or 
  die "Couldn't open $install_dir/bin/guido.pl.ex for reading: $!";
open(SCR_OUT, ">$install_dir/bin/guido.pl") or 
  die "Couldn't open $install_dir/bin/guido.pl for writing: $!";


print "Writing out configuration files and startup script\n";

while(<CFG_IN>) {print CFG_OUT}
while(<RT_IN>)  {print RT_OUT}
while(<SCR_IN>)  {
    s/\?\?\?/$Config{'startperl'} -w/;
    s/###/$install_dir/e;
    print SCR_OUT;
}

close(CFG_IN);
close(RT_IN);
close(CFG_OUT);
close(RT_OUT);
chmod(0755, "$install_dir/bin/guido.pl");
print "Post installation configuration complete.\n";
