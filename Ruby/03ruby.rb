#!/usr/bin/ruby -w
=begin
Programul cere inserarea unui nume de fila,
si creaza acea fila cu codul ruby de mai jos.
=end
data = Time.now

puts "Introduceti numele filei: "
$fila = gets.chomp #variabila globala
puts $fila

#fila_str = String.new($fila)
puts `ls`
continut = "# FILE: #$fila"

aFile = File.new($fila, "w") 
if aFile
    aFile.syswrite("#!/usr/bin/ruby -w \n")
    aFile.syswrite(continut)
    aFile.syswrite("\n# DATA: " + data.inspect)
else 
    puts "Fila nu a fost scrisa"
end

aFile.close
