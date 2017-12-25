#!/usr/bin/lua 
-- Linia de mai sus permite rularea filei: ./03lua.lua
-- Date: Sun Dec 24 21:25:00 2017

print("Salut! Din programul de stocare a datelor economice")
print("Fila in care se salveaza datele este economia.txt")

local file_name = "economia.txt"

local data      = os.date("%c", os.time()) 
print("Introduceti cursul Euro/Ron: ")
local euro = io.read()
print("Introduceti cursul Dolar/Ron: ")
local dolar = io.read()

file = io.open(file_name, "a")
file:write(data..", ")
file:write(euro..", ")
file:write(dolar)
file:write("\n")

file_read = io.open(file_name, "r")
io.input(file_read)
--Citeste doar prima linie din ecomonia.txt
--print(io.read())
--Citeste toata fila economia.txt
print(file_read:read("*a"))

file:close()
file_read:close()
--=======================================================
--read_file( file_name )
function read_file( file_name )
    local file_read = io.open(file_name, "r")
    io.input(file_read)
    print( file_read:read("a"))
    file_read:close() 
end
