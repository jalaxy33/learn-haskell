# Data.List 模块

`Data.List` 是关于 List 操作的模块，它提供了一组非常有用的 List 处理函数。有几个函数已经在 `Prelude` 模块里了，开箱可用（比如 `map` 和 `filter`）。

## 常用函数

### intersperse

`intersperse` 取一个元素与 List 作参数，并将该元素置于 List 中每对元素的中间。

```hs
ghci> intersperse '.' "MONKEY"
"M.O.N.K.E.Y"
ghci> intersperse 0 [1,2,3,4,5,6]
[1,0,2,0,3,0,4,0,5,0,6]
```

### intercalate

`intercalate` 取两个 List 作参数。它会将第一个 List 交叉插入第二个 List 中间，并返回一个 List.

```hs
ghci> intercalate " " ["hey","there","guys"]
"hey there guys"
ghci> intercalate [0,0,0] [[1,2,3],[4,5,6],[7,8,9]]
[1,2,3,0,0,0,4,5,6,0,0,0,7,8,9]
```

### transpose

`transpose` 函数可以反转一组 List 的 List。你若把一组 List 的 List 看作是个 2D 的矩阵，那 `transpose` 的操作就是将其列为行。

```hs
ghci> transpose [[1,2,3],[4,5,6],[7,8,9]]
[[1,4,7],[2,5,8],[3,6,9]]
ghci> transpose ["hey","there","guys"]
["htg","ehu","yey","rs","e"]
```

假如有两个多项式 $3x^{2} + 5x + 9$，$10x^{3} + 9$ 和 $8x^{3} + 5x^{2} + x - 1$，将其相加，我们可以列三个 List: `[0,3,5,9]`，`[10,0,0,9]` 和 `[8,5,1,-1]` 来表示。再用如下的方法取得结果.

```hs
ghci> map sum $ transpose [[0,3,5,9],[10,0,0,9],[8,5,1,-1]]
[18,8,6,17]
```

### foldl' 和 foldl1'

`foldl'` 和 `foldl1'` 是它们各自惰性实现的严格版本。在用 fold 处理较大的 List 时，经常会遇到堆栈溢出的问题，而这罪魁祸首就是 fold 的惰性。

> 在执行 `fold` 时，累加器的值并不会被立即更新，而是做一个"在必要时会取得所需的结果"的承诺。每过一遍累加器，这一行为就重复一次。而所有的这堆"承诺"最终就会塞满你的堆栈。

严格的 `fold` 就不会有这一问题，它们不会作"承诺"，而是直接计算中间值的结果并继续执行下去。如果用惰性 `fold` 时经常遇到溢出错误，就应换用它们的严格版。

### concat

`concat` 把一组 List 连接为一个 List。

```hs
ghci> concat ["foo","bar","car"]
"foobarcar"
ghci> concat [[3,4,5],[2,3,4],[2,1,1]]
[3,4,5,2,3,4,2,1,1]
```

它相当于移除一级嵌套。若要彻底地连接其中的元素，你得 `concat` 它两次才行.

### concatMap

`concatMap` 函数与 `map` 一个 List 之后再 `concat` 它等价.

```hs
ghci> concatMap (replicate 4) [1..3]
[1,1,1,1,2,2,2,2,3,3,3,3]
```

<details><summary>代码解释</summary>

先拆解各个函数：

- `replicate 4`：接受一个数字 n 和一个元素 x，返回一个包含 n 个 x 的列表。如 `replicate 4 1` 得到 `[1,1,1,1]`
- `[1..3]` 得到 `[1,2,3]`
- `concatMap`：等价于 `concat . map`。首先对列表中的每个元素应用函数（该函数必须返回列表），后将所有结果列表连接成一个单一列表。

计算过程：

- 输入 `[1,2,3]`
- 映射阶段：
  - `replicate 4 1` → `[1,1,1,1]`
  - `replicate 4 2` → `[2,2,2,2]`
  - `replicate 4 3` → `[3,3,3,3]`
- 连接阶段：`[1,1,1,1] ++ [2,2,2,2] ++ [3,3,3,3]`
- 最终结果：`[1,1,1,1,2,2,2,2,3,3,3,3]`

</details>

### and 和 or

`and` 取一组布尔值 List 作参数。只有其中的值全为 True 的情况下才会返回 True。

```hs
ghci> and $ map (>4) [5,6,7,8]
True
ghci> and $ map (==4) [4,4,4,3,4]
False
```

`or` 与 `and` 相似，一组布尔值 List 中若存在一个 True 它就返回 True.

```hs
ghci> or $ map (==4) [2,3,4,5,6,1]
True
ghci> or $ map (>4) [1,2,3]
False
```

### any 和 all

`any` 和 `all` 取一个限制条件和一组布尔值 List 作参数，检查是否该 List 的某个元素或每个元素都符合该条件。

通常较 `map` 一个 List 到 `and` 或 `or` 而言，使用 `any` 或 `all` 会更多些。

```hs
ghci> any (==4) [2,3,5,6,1,4]
True
ghci> all (>4) [6,9,10]
True
ghci> all (`elem` ['A'..'Z']) "HEYGUYSwhatsup"
False
ghci> any (`elem` ['A'..'Z']) "HEYGUYSwhatsup"
True
```

### iterate

`iterate` 取一个函数和一个值作参数。它会用该值去调用该函数并用所得的结果再次调用该函数，产生一个无限的 List.

```hs
ghci> take 10 $ iterate (*2) 1
[1,2,4,8,16,32,64,128,256,512]
ghci> take 3 $ iterate (++ "haha") "haha"
["haha","hahahaha","hahahahahaha"]
```

> 提示：之前说过，无限 List 通常会结合 `take` 函数截断

### splitAt

`splitAt` 取一个 List 和数值作参数，将该 List 在特定的位置断开。返回一个包含两个 List 的二元组.

```hs
ghci> splitAt 3 "heyman"
("hey","man")
ghci> splitAt 100 "heyman"
("heyman","")
ghci> splitAt (-3) "heyman"
("","heyman")
ghci> let (a,b) = splitAt 3 "foobar" in b ++ a
"barfoo"
```

### takeWhile

`takeWhile` 这一函数十分的实用。它从一个 List 中取元素，一旦遇到不符合条件的某元素就停止.

```hs
ghci> takeWhile (>3) [6,5,4,3,2,1,2,3,4,5,4,3,2,1]
[6,5,4]
ghci> takeWhile (/=' ') "This is a sentence"
"This"
```

如果要求所有三次方小于 10000 的数的和，用 `filter` 来过滤 map (^3) [1..] 所得结果中所有小于 10000 的数是不行的。因为**对无限 List 执行的 filter 永远都不会停止**。你已经知道了这个 List 是单增的，但 Haskell 不知道。所以应该这样：

```hs
ghci> sum $ takeWhile (<10000) $ map (^3) [1..]
53361
```

用 `(^3)` 处理一个无限 List，而一旦出现了大于等于 10000 的元素这个 List 就被切断了，sum 到一起也就轻而易举.

### dropWhile

`dropWhile` 与 `takeWhile` 相似，不过它是扔掉符合条件的元素。一旦限制条件返回 False，它就返回 List 的余下部分。方便实用!

```hs
ghci> dropWhile (/=' ') "This is a sentence"
" is a sentence"
ghci> dropWhile (<3) [1,2,2,2,3,4,5,4,3,2,1]
[3,4,5,4,3,2,1]
```

给一 Tuple 组成的 List，这 Tuple 的首项表示股票价格，第二三四项分别表示年,月,日。我们想知道它是在哪天首次突破 $1000 的!

```hs
ghci> let stock = [(994.4,2008,9,1),(995.2,2008,9,2),(999.2,2008,9,3),(1001.4,2008,9,4),(998.3,2008,9,5)]
ghci> head (dropWhile (\(val,y,m,d) -> val < 1000) stock)
(1001.4,2008,9,4)
```

### span 和 break

`span` 与 `takeWhile` 有点像，只是它返回两个 List。第一个 List 与同参数调用 `takeWhile` 所得的结果相同，第二个 List 就是原 List 中余下的部分。

```hs
ghci> let (fw, rest) = span (/=' ') "This is a sentence" in "First word:" ++ fw ++ ", the rest:" ++ rest
"First word: This, the rest: is a sentence"
```

`span` 是在条件首次为 False 时断开 List，而 `break` 则是在条件首次为 True 时断开 List，`break` 返回的第二个 List 就会以第一个符合条件的元素开头。

> `break p` 与 `span (not . p)` 是等价的.

```hs
ghci> break (==4) [1,2,3,4,5,6,7]
([1,2,3],[4,5,6,7])
ghci> span (/=4) [1,2,3,4,5,6,7]
([1,2,3],[4,5,6,7])
```

### sort

`sort` 可以排序一个 List，因为只有能够作比较的元素才可以被排序，所以这一 List 的元素必须是 `Ord` 型别类的实例型别。

```hs
ghci> sort [8,5,3,2,1,6,4,2]
[1,2,2,3,4,5,6,8]
ghci> sort "This will be sorted soon"
" Tbdeehiillnooorssstw"
```

### group

`group` 取一个 List 作参数，并将其中**相邻并相等**的元素各自归类，组成一个个子 List.

```hs
ghci> group [1,1,1,1,2,2,2,2,3,3,2,2,2,5,6,7]
[[1,1,1,1],[2,2,2,2],[3,3],[2,2,2],[5],[6],[7]]
```

若在 `group` 一个 List 之前给它排序就可以得到每个元素在该 List 中的出现次数。

```hs
ghci> map (\l@(x:xs) -> (x,length l)) . group . sort $ [1,1,1,1,2,2,2,2,3,3,2,2,2,5,6,7]
[(1,4),(2,7),(3,2),(5,1),(6,1),(7,1)]
```

<details><summary>代码解释</summary>

这里解释 `(\l@(x:xs) -> (x, length l))`：

- `l@(x:xs)` 是一个 as-pattern（别名模式）：
  - `l` 绑定整个子列表（例如 `[1,1,1,1]`）
  - `x` 绑定该子列表的第一个元素（即该组代表的元素值）
  - `xs` 绑定剩余部分（本例未使用）
- 返回元组 `(x, length l)`，其中 `length l` 是该组长度，即该元素出现的总次数。

</details>

### inits 和 tails

`inits` 和 `tails` 与 init 和 tail 相似，只是它们会**递归地调用自身**直到什么都不剩

```hs
ghci> inits "w00t"
["","w","w0","w00","w00t"]
ghci> tails "w00t"
["w00t","00t","0t","t",""]
ghci> let w = "w00t" in zip (inits w) (tails w)
[("","w00t"),("w","00t"),("w0","0t"),("w00","t"),("w00t","")]
```

结合 `fold` 实现一个搜索子 List 的函数:

```hs
search :: (Eq a) => [a] -> [a] -> Bool
search needle haystack =
  let nlen = length needle
  in foldl (\acc x -> if take nlen x == needle then True else acc) False (tails haystack)
```

首先，对搜索的 List 调用 tails，然后遍历每个 List 来检查它是不是我们想要的。由此我们便实现了一个类似 `isInfixOf` 的函数（见下文）

### isInfixOf, isPrefixOf 和 isSuffixOf

`isInfixOf` 从一个 List 中搜索一个子 List，若该 List 包含子 List，则返回 True.

```hs
ghci> "cat" `isInfixOf` "im a cat burglar"
True
ghci> "Cat" `isInfixOf` "im a cat burglar"
False
ghci> "cats" `isInfixOf` "im a cat burglar"
False
```

`isPrefixOf` 与 `isSuffixOf` 分别检查一个 List 是否以某子 List 开头或者结尾.

```hs
ghci> "hey" `isPrefixOf` "hey there!"
True
ghci> "hey" `isPrefixOf` "oh hey there!"
False
ghci> "there!" `isSuffixOf` "oh hey there!"
True
ghci> "there!" `isSuffixOf` "oh hey there"
False
```

### elem 和 notElem

`elem` 与 `notElem` 检查一个 List 是否包含某元素.

### partition

`partition` 取一个限制条件和 List 作参数，返回两个 List，第一个 List 中包含所有符合条件的元素，而第二个 List 中包含余下的.

```hs
ghci> partition (`elem` ['A'..'Z']) "BOBsidneyMORGANeddy"
("BOBMORGAN","sidneyeddy")
ghci> partition (>3) [1,3,5,6,3,2,1,0,3,7]
([5,6,7],[1,3,3,2,1,0,3])
```

了解这个与 `span` 和 `break` 的差异是很重要的——`span` 和 `break` 会在遇到第一个符合或不符合条件的元素处断开，而 `partition` 则会遍历整个 List。

```hs
ghci> span (`elem` ['A'..'Z']) "BOBsidneyMORGANeddy"
("BOB","sidneyMORGANeddy")
```

### find

`find` 取一个 List 和限制条件作参数，并返回首个符合该条件的元素，而这个元素是个 `Maybe` 值。

在这里你只需了解 `Maybe` 值是 `Just something` 或 `Nothing` 就够了。

- 与一个 List 可以为空也可以包含多个元素相似，一个 Maybe 可以为空，也可以是单一元素。
- 同样与 List 类似，一个 Int 型的 List 可以写作 `[Int]`，Maybe有个 Int 型可以写作 `Maybe Int`。

```hs
ghci> find (>4) [1,2,3,4,5,6]
Just 5
ghci> find (>9) [1,2,3,4,5,6]
Nothing
ghci> :t find
find :: (a -> Bool) -> [a] -> Maybe a
```

注意一下 `find` 的型别，它的返回结果为 `Maybe a`，这与 `[a]` 的写法有点像，只是 Maybe 型的值只能为空或者单一元素，而 List 可以为空,一个元素，也可以是多个元素.

想想之前用 `dropWhile` 实现的那段找股票的代码，`head (dropWhile (\(val,y,m,d) -> val < 1000) stock)`，其中 `head` 不安全。

> 如果我们的股票没涨过 $1000 会怎样? `dropWhile` 会返回一个空 List，而对空 List 取 `head` 就会引发一个错误。

把它改成下面的形式就安全多了：

```hs
...
ghci> find (\(val,y,m,d) -> val > 1000) stock
...
```

若存在合适的结果就得到它, 像 `Just (1001.4,2008,9,4)`，若不存在合适的元素(即我们的股票没有涨到过 $1000)，就会得到一个 `Nothing`.

### elemIndex 和 elemIndices

`elemIndex` 与 `elem` 相似，只是它返回的不是布尔值，它只是'**可能**' （Maybe）返回我们找的**元素的索引**，若这一元素不存在，就返回 `Nothing`。

```hs
ghci> :t elemIndex
elemIndex :: (Eq a) => a -> [a] -> Maybe Int
ghci> 4 `elemIndex` [1,2,3,4,5,6]
Just 3
ghci> 10 `elemIndex` [1,2,3,4,5,6]
Nothing
```

`elemIndices` 与 `elemIndex` 相似，只不过它返回的是 List，就不需要 Maybe 了。因为不存在用空 List 就可以表示，这就与 Nothing 相似了.

```hs
ghci> ' ' `elemIndices` "Where are the spaces?"
[5,9,13]
```

### findIndex 和 findIndices

`findIndex` 与 `find` 相似，但它返回的是可能存在的首个符合该条件元素的索引。`findIndices` 会返回所有符合条件的索引.

```hs
ghci> findIndex (==4) [5,3,2,1,6,4]
Just 5
ghci> findIndex (==7) [5,3,2,1,6,4]
Nothing
ghci> findIndices (`elem` ['A'..'Z']) "Where Are The Caps?"
[0,6,10,14]
```

### zipN 和 zipWithN

在前面，我们讲过了 `zip` 和 `zipWith`，它们只能将两个 List 组到一个二元组数或二参函数中，但若要组三个 List 该怎么办？好说~ 有 `zip3`,`zip4`...,和 `zipWith3`, `zipWith4`...直到 7。

> 连着组 8 个 List 的情况很少遇到。还有个聪明办法可以组起无限多个 List，但限于我们目前的水平，就先不谈了.

```hs
ghci> zipWith3 (\x y z -> x + y + z) [1,2,3] [4,5,2,2] [2,2,3]
[7,9,8]
ghci> zip4 [2,3,3] [2,2,2] [5,5,3] [2,2,2]
[(2,2,5,2),(3,2,5,2),(3,2,3,2)]
```

与普通的 zip 操作相似，以返回的 List 中长度最短的那个为准.

### lines 和 unlines

在处理来自文件或其它地方的输入时，`lines` 会非常有用。它取一个字串作参数。并返回由其中的每一行组成的 List.

```hs
ghci> lines "first line\nsecond line\nthird line"
["first line","second line","third line"]
```

> `'\n'` 表示unix下的换行符，在 Haskell 的字符中，反斜杠表示特殊字符.

`unlines` 是 `lines` 的反函数，它取一组字串的 List，并将其通过 `'\n'` 合并到一块.

```hs
ghci> unlines ["first line", "second line", "third line"]
"first line\nsecond line\nthird line\n"
```

### words 和 unwords

`words` 和 `unwords` 可以把一个字串分为一组单词或执行相反的操作，很有用.

```hs
ghci> words "hey these are the words in this sentence"
["hey","these","are","the","words","in","this","sentence"]
ghci> words "hey these are the words in this\nsentence"
["hey","these","are","the","words","in","this","sentence"]
ghci> unwords ["hey","there","mate"]
"hey there mate"
```

### nub

`nub` 可以将一个 List 中的重复元素全部筛掉，使该 List 的每个元素都如雪花般独一无二

> `nub` 的含义就是'一小块'或'一部分'，用在这里觉得很古怪

```hs
ghci> nub [1,2,3,4,3,2,1,2,3,4,3,2,1]
[1,2,3,4]
ghci> nub "Lots of words and stuff"
"Lots fwrdanu"
```

### delete

`delete` 取一个元素和 List 作参数，会删掉该 List 中首次出现的这一元素.

```hs
ghci> delete 'h' "hey there ghang!"
"ey there ghang!"
ghci> delete 'h' . delete 'h' $ "hey there ghang!"
"ey tere ghang!"
ghci> delete 'h' . delete 'h' . delete 'h' $ "hey there ghang!"
"ey tere gang!"
```

### \\, union 和 intersect

`\` 表示 List 的差集操作，这与集合的差集很相似，它会从左边 List 中的元素扣除存在于右边 List 中的元素一次.

```sh
ghci> [1..10] \\ [2,5,9]
[1,3,4,6,7,8,10]
ghci> "Im a big baby" \\ "big"
"Im a  baby"
```

`union` 与集合的并集也是很相似，它返回两个 List 的并集，即遍历第二个 List 若存在某元素**不属于第一个** List，则追加到第一个 List。看，第二个 List 中的重复元素就都没了!

```hs
ghci> "hey man" `union` "man what's up"
"hey manwt'sup"
ghci> [1..7] `union` [5..10]
[1,2,3,4,5,6,7,8,9,10]
```

`intersect` 相当于集合的交集。它返回两个 List 的相同部分.

```hs
ghci> [1..7] `intersect` [5..10]
[5,6,7]
```

### insert

`insert` 可以将一个元素插入一个可排序的 List，并将其置于**首个大于等于**它的元素之前，如果使用 `insert` 来给一个排过序的 List 插入元素，返回的结果依然是排序的.

```hs
ghci> insert 4 [1,2,3,5,6,7]
[1,2,3,4,5,6,7]
ghci> insert 'g' $ ['a'..'f'] ++ ['h'..'z']
"abcdefghijklmnopqrstuvwxyz"
ghci> insert 3 [1,2,4,3,2,1]
[1,2,3,4,3,2,1]
```

## 通用版本函数

### 以 `generic` 开头的函数

`length`，`take`，`drop`，`splitAt`，`!!` 和 `replicate` 之类的函数有个共同点。那就是它们的参数中都有个 Int 值（或者返回Int值），我觉得使用 Intergal 或 Num 型别类会更好。但出于历史原因，修改这些会破坏掉许多既有的代码。在 Data.List 中包含了更通用的替代版，如: `genericLength`，`genericTake`，`genericDrop`，`genericSplitAt`，`genericIndex` 和 `genericReplicate`。

举例：`length` 和 `genericLength`

- `length` 的型别声明为 `length :: [a] -> Int`，而我们若要像这样求它的平均值，`let xs = [1..6] in sum xs / length xs`，就会得到一个型别错误，因为 `/` 运算符不能对 Int 型使用!
- 而 `genericLength` 的型别声明则为 `genericLength :: (Num a) => [b] -> a`，Num 既可以是整数又可以是浮点数，`let xs = [1..6] in sum xs / genericLength xs` 这样再求平均数就不会有问题了.

### 以 `By` 结尾的函数

`nub`, `delete`, `union`, `intsect` 和 `group` 函数也有各自的通用替代版 `nubBy`，`deleteBy`，`unionBy`，`intersectBy` 和 `groupBy`，它们的区别就是前一组函数使用 `(==)` 来测试是否相等，而带 By 的那组则**取一个函数**作参数来判定相等性，`group` 就与 `groupBy (==)` 等价.

#### groupBy

假如有个记录某函数在每秒的值的 List，而我们要按照它小于零或者大于零的交界处将其分为一组子 List。如果用 `group`，它只能将相邻并相等的元素组到一起，而在这里我们的标准是它们是否互为相反数。`groupBy` 登场! 它取一个含两个参数的函数作为参数来判定相等性.

```hs
ghci> let values = [-4.3,-2.4,-1.2,0.4,2.3,5.9,10.5,29.1,5.3,-2.4,-14.5,2.9,2.3]
ghci> groupBy (\x y -> (x > 0) == (y > 0)) values
[[-4.3,-2.4,-1.2],[0.4,2.3,5.9,10.5,29.1,5.3],[-2.4,-14.5],[2.9,2.3]]
```

这样一来我们就可以很清楚地看出哪部分是正数，哪部分是负数，这个判断相等性的函数会**在两个元素同时大于零或同时小于零**时返回 True。

> 也可以写作 `\x y -> (x > 0) && (y > 0) || (x <= 0) && (y <= 0)`。但我觉得第一个写法的可读性更高。

#### 好用的 on 函数

Data.Function 中还有个 `on` 函数可以让上面这个例子的表达更清晰，其定义如下:

```hs
on :: (b -> b -> c) -> (a -> b) -> a -> a -> c
f `on` g = \x y -> f (g x) (g y)
```

执行 ``(==) `on` (> 0)`` 得到的函数就与 `\x y -> (x > 0) == (y > 0)` 基本等价。on 与带 By 的函数在一起会非常好用，你可以这样写:

```hs
ghci> groupBy ((==) `on` (> 0)) values
[[-4.3,-2.4,-1.2],[0.4,2.3,5.9,10.5,29.1,5.3],[-2.4,-14.5],[2.9,2.3]]
```

通常，与带 By 的函数打交道时，若要判断相等性，则 ``(==) `on` something``。若要判定大小，则 ``compare `on` something``.

#### 带比较的 By 函数

同样，`sort`，`insert`，`maximum` 和 `min` 都有各自的通用版本。如 groupBy 类似，`sortBy`，`insertBy`，`maximumBy` 和 `minimumBy` 都取一个函数来比较两个元素的大小。

例如 `sortBy` 的型别声明为: `sortBy :: (a -> a -> Ordering) -> [a] -> [a]`。前面提过，Ordering 型别可以有三个值，`LT`，`EQ` 和 `GT`。`compare` 取两个 Ord 型别类的元素作参数，所以 `sort` 与 `sortBy compare` 等价.

List 是可以比较大小的，且比较的依据就是其中元素的大小。如果按照其子 List 的长度为标准当如何? 可以用 `sortBy` 函数：

```hs
ghci> let xs = [[5,4,5,4,4],[1,2,3],[3,5,4,3],[],[2],[2,2]]
ghci> sortBy (compare `on` length) xs
[[],[2],[2,2],[1,2,3],[3,5,4,3],[5,4,5,4,4]]
```

> 如果你搞不清楚 `on` 在这里的原理，就可以认为它与 ``\x y -> length x `compare` length y`` 等价。
