???
use FindBin qw/$Bin/;

$| = 1;
select STDERR;
$| = 1;
select STDOUT;

use constant GUIDOHOME => '###';

use lib GUIDOHOME . "/lib";
use lib "$Bin/../lib";
$ENV{GUIDOLIB} ||= GUIDOHOME . "/lib";
$ENV{GUIDOHOME} ||= GUIDOHOME;

use Guido::Application;

my $app = run Guido::Application(@ARGV);

