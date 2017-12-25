#!/usr/bin/ruby -w

puts "SALUT! Din main RUBY";

print <<EOF
    Aceasta este o portiune de documentatie
    in stilul ruby.
EOF

print <<"EOF"
    Acesta este un document tot in stilul
    ruby.
EOF

print <<`EOC` #executa comenzi
    echo unde esti?.
    echo AICI
EOC

print <<"foo", <<"bar" # stiva de comenzi
    Acesta este foo
foo
    Acesta este bar
bar

BEGIN {
    puts "Acesta este rulat la inceputul programului";
}

END {
    puts "Acest cod ruleaza la finalul programului";
}

# acesta este un comentariu

=begin
Acesta este un comentariu
pe mai multe linii
=end
