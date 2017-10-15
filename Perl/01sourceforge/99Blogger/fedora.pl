#! /usr/bin/perl

use v5.010;
use Mojo::UserAgent;
use Mojo::DOM;
use Data::Dump;
# Fine grained response handling (dies on connection errors)
my $ua  = Mojo::UserAgent->new;
# ------------------------------------------------ Extract date from FEDORA site
my $site = "https://start.fedoraproject.org/";
my $file = "Bloger.txt";
# -----------------------------------------------------------------------ARTICOLE
# my $title = $ua->get($site)->result->dom->at('title')->text;
# my $title1 = $ua->get($site)->result->dom->at('h4')->text;
# my $tag_p = $ua->get($site)->result->dom->find('div > p')->map('text')->join("\n");
# my $text = $ua->get($site) ->result->dom->find('h3')->map('text')->join("\n");
#my $href =$ua->get($site) ->result->dom->find('href')->map('text')->join("\n");
# say "ARTICOLE DIN: $title";
# say $title1;
# say $tag_p;
# say $text;

say $ua->get($site)->result->dom->at('#site-content')->text;
say $ua->get($site)->result->dom->find('[id]')->map(attr => 'class')->join("\n");

# my $href =$ua->get($site) ->result->dom->find('href')->map('text')->join("\n");
# my $title = $ua->get($site)->result->dom->at('title')->text;

# # say $title
# say $href;
# say $text;
mojoDom();
fedoraV01($site, $file);

sub mojoDom {
	print "FUNCTIA MOJODOM\n";
	my $dom = Mojo::DOM->new('<div><p id="a">TEST</p><p id ="b">123</p></div>');
	#FIND
	say $dom->at('#b')->text;
	say $dom->find('p')->map('text')->join("\n");
	say $dom->find('[id]')->map(attr => 'id') ->join("\n");
	#iterate
	$dom->find('p[id]')->reverse->each(sub {say $_->{id} });
	#loop
	for my $e ($dom->find('p[id]')->each) {
		say $e->{id}, ':', $e->text;
	}
	say $dom->all_text;
}
=pod
 <div class="col-xs-12 col-sm-11 white">
        	<div class="row">
        		<div class="col-xs-1 col-sm-1 hidden-xs">
        		<img src="https://fedoramagazine.org/wp-content/uploads/2017/09/du-simple-300x127.jpg">
        		</div>
        		<div class="col-xs-11 col-sm-10">
					  <a class="title" href="https://fedoramagazine.org/check-disk-usage-command-line-du/"><h3>Check disk usage at the command line with du</h3></a>
				</div>
        		<div class="hidden-xs col-sm-1 comments pull-right">
					<i class="fa fa-fw fa-comment comment-icon"></i>1
				</div>
        	</div>
        	<div class="row">
        		<div class="col-xs-12 col-sm-11 col-sm-offset-1">
        		<p>End users and system administrators sometimes struggle to get exact disk usage numbers by folder (directory) or file. The du command can help. It stands for disk usage, and is one of the most useful commands to report disk usage.... <a class="more-link" href="https://fedoramagazine.org/check-disk-usage-command-line-du/">Continue Reading →</a>...</p>
				<a href="https://fedoramagazine.org/check-disk-usage-command-line-du/" class="pull-right readme">Read more ...</a>
        		</div>
        	</div>
		</div>
=cut
sub fedora {
	# args of function
	my ( $site ) = @_;
	print "FUNCTION FEDORA\n";
	say $ua->get($site)->result->dom->at('title')->text;
	say $ua->get($site)->result->dom->at('h4')->text;
	# say $ua->get($site)->result->dom->find('div > p')->map('text')->join("\n");
	say $ua->get($site) ->result->dom->find('h3')->map('text')->join("\n");
	say $ua->get($site)->result->dom->find('[class]')->map(attr => 'class') ->join("\n");
	say $ua->get($site)->result->dom->attr({class => 'href'});
	say "SCSS";
	say $ua->get($site)->result->dom->children->shuffle->first->tag; # css->select('*');
	say $ua->get($site)->result->dom->children('div ~ p');
	say $ua->get($site)->result->dom->children->shuffle->first->tag;
	say $ua->get($site)->result->dom->content('<p>End users and system administrators</p>');
	say $ua->get($site)->result->dom->find('h3,  p')->map('text')->join("\n");
	say $ua->get($site)->result->dom->following('a ~ href');
}

sub fedoraV00 {
	my ( $site, $file) = @_;
	print "Funtion: fedoraV00($site, $file)\n";
	open(my $fh, '>',$file) or die "Could not open file '$filename' $!";
	my $title = $ua->get($site)->result->dom->at('title')->text;
	print $fh "ARTICOLE:\n";
	say $fh "##$title";
	say $ua->get($site) ->result->dom->find('h3, p')->map('text')->join("\n");
	say $fh $ua->get($site) ->result->dom->find('h3, p')->map('text')->join("\n");
	close $fh;
}
sub fedoraV01{
	my ( $site, $file) = @_;
	print "Funtion: fedoraV01($site, $file)\n";
	open(my $fh, '>',$file) or die "Could not open file '$filename' $!";
	my $dom = $ua->get($site)->result->dom;
	say $dom->at('title')->text;
	#say $dom->find('h3')->map('text')->join("\n");
	#say $fh $dom->find('h3')->join("\n");
=pod
	<h3><a alt="Fedora Docs" href="https://docs.fedoraproject.org/"><i class="fa fa-fw fa-book header-icon"></i>Fedora Documentation</a></h3>
	<h3><a alt="Ask Fedora" href="https://ask.fedoraproject.org/"><i class="fa fa-fw fa-question-circle header-icon"></i>Help for Fedora Users</a></h3>
	<h3><a alt="Get Fedora" href="https://getfedora.org"><i class="fa fa-fw fa-download header-icon"></i>Get Fedora</a></h3>
	<h3>Check disk usage at the command line with du</h3>
	<h3>Getting Started with Flatpak</h3>
	<h3>Using Octave on Fedora 26</h3>
	<h3>4 cool new projects to try in COPR for October</h3>
	<h3>Where is the beta for Fedora Server 27?</h3>
=cut
	#say $fh $dom->find('a h3')->join("\n");
=pod
	<h3>Check disk usage at the command line with du</h3>
	<h3>Getting Started with Flatpak</h3>
	<h3>Using Octave on Fedora 26</h3>
	<h3>4 cool new projects to try in COPR for October</h3>
	<h3>Where is the beta for Fedora Server 27?</h3>
=cut
	say $fh $dom->find('div div div div p a')->map(attr=>'href')->join("\n");



}

