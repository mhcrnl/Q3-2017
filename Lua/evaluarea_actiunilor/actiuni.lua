local actiuni = {}
--[[
Exista doua cai de estimare a rentabilitatii si riscului:
1. Trecutul este o "oglinda" a viitorului
2. Investitii nesimilare celor anterioare
========================================================================= 
Rentabilitatea unei actiuni este determinata de dividend si 
cresterea valorii de piata. R = ((D + P1-P0)/ P0) *100 
--]]

function actiuni.rata_rentabilitate(pret_actual, pret_cumparare, dividend)
    rent = ((dividend + pret_actual - pret_cumparare)/pret_cumparare)*100
    print(rent.."%")
    return rent
end
--[[
Rentabilitatea_actiunii = dividend + pretul_actual-pretul_cumparare 
--]]
function actiuni.rentabilitate(pret_actual, pret_cumparare, divident)
    rentabilitate = divident + pret_actual - pret_cumparare
    print(rentabilitate.."Ron")
    return rentabilitate
end
--[[

--]]
function actiuni.rata_anuala_de_rentabilitate()

end
return actiuni
