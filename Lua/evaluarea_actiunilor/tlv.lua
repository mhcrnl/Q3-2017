#!/usr/bin/lua

tlv = require("actiuni")
print("Rentabilitate actiuni TLV")

max1an = 3.000
min1an = 2.030
dividend = 0

tlv.rentabilitate(max1an, min1an, dividend)
tlv.rata_rentabilitate(max1an, min1an, dividend)

max6luni = 2.550
min6luni = 2.100

tlv.rentabilitate(max6luni, min6luni, dividend)
tlv.rata_rentabilitate(max6luni, min6luni, dividend)

max1luna = 2.2000
min1luna = 2.0900

tlv.rentabilitate(max1luna,min1luna, dividend)
tlv.rata_rentabilitate(max1luna,min1luna, dividend)
