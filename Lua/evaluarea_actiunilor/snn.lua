#!/usr/bin/lua

snn = require("actiuni")

max1an = 7.7900
min1an = 4.7950
dividend = 0

snn.rentabilitate(max1an, min1an, dividend)
snn.rata_rentabilitate(max1an, min1an, dividend)

max6luni = 7.7900
min6luni = 6.4000

snn.rentabilitate(max6luni, min6luni, dividend)
snn.rata_rentabilitate(max6luni, min6luni, dividend)

max1luna = 7.5000
min1luna = 7.0000

snn.rentabilitate(max1luna, min1luna, dividend)
snn.rata_rentabilitate(max1luna, min1luna, dividend)

