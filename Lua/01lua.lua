#!/usr/bin/lua
-- Acesta este un comentariu in lua 

print ("SALUT!")

print ("Introduceti numele filei:")
file_name = io.read()

file = io.open(file_name, "w")

file:write("#!/usr/bin/lua \n")
file:write("-- Linia de mai sus permite rularea filei: ./" ..file_name.."\n")
file:write("-- Date: "..os.date("%c", os.time()))

file:close()

