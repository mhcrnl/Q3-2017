#!/usr/bin/lua

snn = require("actiuni")

max1an = 0.3380
min1an = 0.2590
dividend = 0

snn.rentabilitate(max1an, min1an, dividend)
snn.rata_rentabilitate(max1an, min1an, dividend)

max6luni = 0.3250
min6luni = 0.2800

snn.rentabilitate(max6luni, min6luni, dividend)
snn.rata_rentabilitate(max6luni, min6luni, dividend)

max1luna = 0.2890
min1luna = 0.2800

snn.rentabilitate(max1luna, min1luna, dividend)
snn.rata_rentabilitate(max1luna, min1luna, dividend)

