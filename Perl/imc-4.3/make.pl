# Make utility script for imc

# Copyright (C) 1998, 1999 by Peter Verthez

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

# Written by Peter Verthez, <Peter.Verthez@advalvas.be>.

$config_file=$ARGV[0];

open (IN, "$config_file");
@lines = <IN>;
close IN;

for $line (@lines) {
  chop $line;
  @splitted = split /=/, $line;
  $config{$splitted[0]} = $splitted[1];
}

$progname=$config{PROG};

open (IN, "$config{srcdir}/$progname.dist");
open (OUT, ">$progname");

$line=<IN>;
print OUT "#! $config{PERL}\n";
while (<IN>) {
  if (/@(\S+)@/) {
    $config_val=$config{$1};
    s/@(\S+)@/$config_val/;
  }
  print OUT;
}

close OUT;
close IN;

