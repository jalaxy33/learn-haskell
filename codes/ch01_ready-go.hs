-- load with `:l <this-module>` in ghci

--- Function ---

doubleMe x = x + x

doubleUs x y = doubleMe x + doubleMe y

doubleSmallNumber' x = (if x > 100 then x else x * 2) + 1 -- ' is accepted in func name

conanO'Brien = "It's a-me, Conan O'Brien!"

--- List Comprehesion ---

boomBangs xs = [if x < 10 then "BOOM!" else "BANG!" | x <- xs, odd x]

length' xs = sum [1 | _ <- xs] -- define my own length

removeNonUppercase st = [c | c <- st, c `elem` ['A' .. 'Z']]
