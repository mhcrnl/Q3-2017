#!/usr/bin/perl

#Acesta este un comentariu

print "Salut!\n";
$a = 10;
$text = <<"EOF";
Aceasta est sintaxa pentru afisarea acestui text
care va continua pe mai multe linii pana la intalnirea
sfarsitului EOF pe linie noua. Valoarea variabilei a=$a
va fi afisata .
EOF
print "$text\n";

$text = <<'EOF';
Acesta este un text marcat cu o singura virgula, valoarea variabilei
a = $a nu va mai fi afisata.
EOF
print "$text\n"; 