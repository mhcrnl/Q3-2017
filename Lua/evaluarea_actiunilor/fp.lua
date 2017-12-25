#!/usr/bin/lua 

fp = require("actiuni")

print("Analiza actiuni FP(Fondul Proprietatea)")

pret_actual     = 0.9250
pret_cumparare  = 0.7900
dividend        = 0

fp.rentabilitate(pret_actual, pret_cumparare, dividend)
fp.rata_rentabilitate(pret_actual, pret_cumparare, dividend)

max6luni = 0.8750
min6luni = 0.8260

fp.rentabilitate(max6luni, min6luni, dividend)
fp.rata_rentabilitate(max6luni, min6luni, dividend)

max1luna = 0.8700
min1luna = 0.8300
fp.rentabilitate(max1luna, min1luna, dividend)
fp.rata_rentabilitate(max1luna, min1luna, dividend)
