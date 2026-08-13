--- Curried function ---
------------------------

multThree :: (Num a) => a -> a -> a -> a
multThree x y z = x * y * z

-- 不全调用
compareWithHundred :: (Num a, Ord a) => a -> Ordering
compareWithHundred x = compare 100 x

compareWithHundred' :: (Num a, Ord a) => a -> Ordering
compareWithHundred' = compare 100

-- 中缀函数的补全调用
divideByTen :: (Floating a) => a -> a
divideByTen = (/ 10)

isUpperAlphanum :: Char -> Bool
isUpperAlphanum = (`elem` ['A' .. 'Z'])

-- `-`号放数字前表示 "负n"，这时用 `subtract`
subtractFour :: (Num a) => a -> a
subtractFour = (subtract 4)

--- 使用高阶函数 ---
--------------------

applyTwice :: (a -> a) -> a -> a
applyTwice f x = f (f x)

zipWith' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith' _ [] _ = []
zipWith' _ _ [] = []
zipWith' f (x : xs) (y : ys) = f x y : zipWith' f xs ys

flip' :: (a -> b -> c) -> b -> a -> c
flip' f y x = f x y

--- map & filter ---
--------------------

map' :: (a -> b) -> [a] -> [b]
map' _ [] = []
map' f (x : xs) = f x : map' f xs

filter' :: (a -> Bool) -> [a] -> [a]
filter' _ [] = []
filter' p (x : xs)
  | p x = x : filter' p xs
  | otherwise = filter' p xs

quicksort :: (Ord a) => [a] -> [a]
quicksort [] = []
quicksort (x : xs) =
  let smallerSorted = quicksort (filter (<= x) xs)
      biggerSorted = quicksort (filter (> x) xs)
   in smallerSorted ++ [x] ++ biggerSorted

--- lambda ---
--------------

addN :: (Num a) => a -> (a -> a)
addN n = \x -> x + n

-- 由于有柯里化，下面两种写法等价
addThree :: (Num a) => a -> a -> a -> a
addThree x y z = x + y + z

addThree' :: (Num a) => a -> a -> a -> a
addThree' = \x -> \y -> \z -> x + y + z

flip2 :: (a -> b -> c) -> b -> a -> c
flip2 f = \x y -> f y x

--- fold ---
------------

-- [foldl]

sum' :: (Num a) => [a] -> a
sum' xs = foldl (\acc x -> acc + x) 0 xs

-- 如果用柯里化，可以写出更简单的实现
sum2 :: (Num a) => [a] -> a
sum2 = foldl (+) 0

elem' :: (Eq a) => a -> [a] -> Bool
elem' y ys = foldl (\acc x -> if x == y then True else acc) False ys

-- [foldr]

map2 :: (a -> b) -> [a] -> [b]
map2 f xs = foldr (\x acc -> f x : acc) [] xs

-- [foldl1 & foldr1]

-- sum也可以这么实现：
sum3 :: (Num a) => [a] -> a
sum3 = foldl1 (+)

-- [用 fold 实现库函数]

maximum' :: (Ord a) => [a] -> a
maximum' = foldr1 (\x acc -> if x > acc then x else acc)

reverse' :: [a] -> [a]
reverse' = foldl (\acc x -> x : acc) [] -- 也可以改成 `foldl (flip (:)) []`

product' :: (Num a) => [a] -> a
product' = foldr1 (*)

filter2 :: (a -> Bool) -> [a] -> [a]
filter2 p = foldr (\x acc -> if p x then x : acc else acc) []

head' :: [a] -> a
head' = foldr1 (\x _ -> x)

last' :: [a] -> a
last' = foldl1 (\_ x -> x)

--- function composition ---
----------------------------

-- 对于以下函数
oddSquareSum :: Integer
oddSquareSum = sum (takeWhile (< 10000) (filter odd (map (^ 2) [1 ..])))

-- 只用函数组合会比较长
oddSquareSum_ :: Integer
oddSquareSum_ = sum . takeWhile (< 10000) . filter odd . map (^ 2) $ [1 ..]

-- 结合 `let` 语句更易读
oddSquareSum__ :: Integer
oddSquareSum__ =
  let oddSquares = filter odd $ map (^ 2) [1 ..]
      belowLimit = takeWhile (< 10000) oddSquares
   in sum belowLimit
