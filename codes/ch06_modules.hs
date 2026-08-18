import Data.Char
import Data.List
import Data.Map qualified as Map

numUniques :: (Eq a) => [a] -> Int
numUniques = length . nub

-- Caesar ciphar
encode :: Int -> String -> String
encode shift msg = map (chr . (+ shift) . ord) msg

decode :: Int -> String -> String
decode shift msg = encode (negate shift) msg

-- findKey from scratch

findKey1 :: (Eq k) => k -> [(k, v)] -> v
findKey1 key xs = snd . head . filter (\(k, v) -> key == k) $ xs

findKey2 :: (Eq k) => k -> [(k, v)] -> Maybe v
findKey2 key [] = Nothing
findKey2 key ((k, v) : xs) =
  if key == k
    then
      Just v
    else
      findKey2 key xs

findKey3 :: (Eq k) => k -> [(k, v)] -> Maybe v
findKey3 key = foldr (\(k, v) acc -> if key == k then Just v else acc) Nothing

-- Map.fromList from scratch
fromList' :: (Ord k) => [(k, v)] -> Map.Map k v
fromList' = foldr (\(k, v) acc -> Map.insert k v acc) Map.empty
