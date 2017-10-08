use strict;
use warnings;
use utf8;
use Prima qw(Label InputLine Buttons Application PodView Edit);
use Prima::Bidi qw(:require :rtl);

$::application-> wantUnicodeInput(1);

my $w;
my $pod;
my $arabic;
my $editor;
my $pod_text;

$w = Prima::MainWindow-> create(
	size => [ 430, 200],
	text => "Bidirectional texts",
	menuItems => [
		[ "~Options" => [
			[ "~Toggle direction" => sub {
				$arabic-> alignment( $arabic-> alignment == ta::Left ? ta::Right : ta::Left );
				my $td = !$w-> Hebrew-> textDirection;
				$w-> Hebrew-> textDirection($td);
				$pod->textDirection($td);
				$pod->format(1);
			} ],
		]],
	],
);

$w->insert( InputLine =>
	name => 'Hebrew',
	origin => [ 10, 10],
	width  => 200,
	text => "אפס123 - תרttttאה מה אני יכול!",
	growMode => gm::Floor,
);

$w-> insert( Button => 
	name => 'Farsi',
	text => 'ترک',
	origin => [ 320, 10 ],
	growMode => gm::GrowLoX,
	onClick => sub { $::application-> close },
);

my $panel = $w->insert( Widget =>
	origin => [ 10, 50 ],
	size   => [ 410, 140 ],
	growMode  => gm::Client,
);

my $arabic_text = "الفالح حلمه كبير.
طول ساق النبتة وصارت
شجرة في أرض الفالح
وعلى الشجرة غصون و أوراق
بفيتها إ حتمى الفالح
الفالح حلمه كبير";

$editor = $panel-> insert( Edit => 
	packInfo => { fill => 'both', expand => 1, pad => 10 , side => 'left'},
	geometry => gt::Pack,
	name => 'Editor',
	text     => $arabic_text,
);

$arabic = $panel->insert( Label =>
	packInfo => { fill => 'both', expand => 1, pad => 10, side => 'left' },
	geometry => gt::Pack,
	name  => 'Arabic',
	backColor => cl::Yellow,
	text     => $arabic_text,
	wordWrap => 1,
	showPartial => 0,
);

$pod = $panel-> insert( PodView => 
	packInfo => { fill => 'both', expand => 1, pad => 10 , side => 'left'},
	geometry => gt::Pack,
	name => 'Pod',
);

$arabic_text =~ s/(.*?)\n//;
$pod_text = "=head1 $1\n\n" . join("\n\n", split "\n", $arabic_text) . "\n\n";
$pod-> open_read( createIndex => 0 );
$pod-> read($pod_text);
$pod-> close_read;

run Prima;
