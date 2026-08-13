# 高阶函数

Haskell 中的函数可以接受函数作为参数也可以返回函数作为结果，这样的函数就被称作高阶函数。高阶函数可不只是某简单特性而已，它贯穿于 Haskell 的方方面面。

## Curried functions

本质上，Haskell 的所有函数都只有一个参数，所有多个参数的函数都是 Curried functions。

以 `max` 函数为例，以下两个调用是等价的：

```hs
ghci> max 4 5
5
ghci> (max 4) 5
5
```

> 它会首先回传一个取一个参数的函数，其回传值不是 4 就是该参数，取决于谁大。然后，以 5 为参数调用它，并取得最终结果。

把空格放到两个东西之间，称作`函数调用`。它有点像个运算符，并拥有最高的优先级。

> 看看 `max` 函数的型别: `max :: (Ord a) => a -> a -> a`。 也可以写作: `max :: (Ord a) => a -> (a -> a)`。可以读作 `max` 取一个参数 `a`，并回传一个函数(就是那个 `->`)，这个函数取一个 `a` 型别的参数，回传一个a。

### 不全调用

这样的好处又是如何? 简言之，我们若以不全的参数来调用某函数，就可以得到一个`不全调用`的函数。便于构造新函数，
将其传给另一个函数也是同样方便。看下面这个简单的例子：

```hs
multThree :: (Num a) => a -> a -> a -> a
multThree x y z = x * y * z

ghci> let multTwoWithNine = multThree 9
ghci> multTwoWithNine 2 3
54
ghci> let multWithEighteen = multTwoWithNine 2
ghci> multWithEighteen 10
180
```

下面两种写法是等价的：

```hs
compareWithHundred :: (Num a, Ord a) => a -> Ordering
compareWithHundred x = compare 100 x

compareWithHundred' :: (Num a, Ord a) => a -> Ordering
compareWithHundred' = compare 100
```

注意到后者定义没有参数，因为前者已经是柯里化的（即只有一个参数），所以可以这么等价。

> 型别声明依然相同，因为 `compare 100` 回传函数。`compare` 的型别为 `(Ord a) => a -> (a -> Ordering)`，用 100 调用它后回传的函数型别为 `(Num a, Ord a) => a -> Ordering`，同时由于 100 还是 Num 型别类的实例，所以还得另留一个类约束。

### 中缀函数的不全调用

中缀函数也可以不全调用，**用括号把它和一边的参数括在一起就行了**。 这回传一个取一参数并将其补到缺少的那一端的函数。 一个简单函数如下:

```hs
divideByTen :: (Floating a) => a -> a
divideByTen = (/10)
```

> 调用 `divideByTen 200` 就是 `(/10) 200`，和 `200 / 10` 等价。

另一个例子，一个检查字符是否为大写的函数:

```hs
isUpperAlphanum :: Char -> Bool
isUpperAlphanum = (`elem` ['A'..'Z'])
```

唯一的例外就是 `-` 运算符，放在数字前表示符号，如 `(-4)` 表示负 4，如果要表示减号就用 `subtract` 好了，像这样 `(subtract 4)`.

## 使用高阶函数

Haskell 中的函数可以取另一个函数做参数，也可以回传函数。

> **[NOTE]** 若在使用高阶函数的时候不清楚其型别为何，就先忽略掉它的型别声明，再到 ghci 下用 `:t` 命令来看下 Haskell 的型别推导.

例如，下面的函数接收一个函数并调用它两次：

```hs
applyTwice :: (a -> a) -> a -> a
applyTwice f x = f (f x)
```

> 注意型别声明，在此之前我们很少用到括号，在这里括号是必须的，它**标明了首个参数是个型别为 `(a->a)` 的函数**。

- 用法示例：
  ```
  ghci> applyTwice (+3) 10
  16
  ghci> applyTwice (++ " HAHA") "HEY"
  "HEY HAHA HAHA"
  ghci> applyTwice ("HAHA " ++) "HEY"
  "HAHA HAHA HEY"
  ghci> applyTwice (multThree 2 2) 9
  144
  ghci> applyTwice (3:) [1]
  [3,3,1]
  ```

现在用高阶函数实现个标准库中的 `zipWith` 函数。它取一个函数和两个 List 做参数，并把两个 List 交到一起(使相应的元素去调用该函数)。

```hs
zipWith' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith' _ [] _ = []
zipWith' _ _ [] = []
zipWith' f (x:xs) (y:ys) = f x y : zipWith' f xs ys
```

> 这函数的行为与普通的 `zip` 很相似，边界条件也是相同，只不过多了个参数，即处理元素交叉的函数。它关不着边界条件什么事儿，所以我们就只留一个 `_`。后一个模式的函数体与 `zip` 也很像，只不过这里是 `f x y` 而非 `(x,y)`。

- 用法示例
  ```
  ghci> zipWith' (+) [4,2,5,6] [2,6,2,3]
  [6,8,7,9]
  ghci> zipWith' max [6,3,2,1] [7,3,1,5]
  [7,3,2,5]
  ghci> zipWith' (++) ["foo ", "bar ", "baz "] ["fighters", "hoppers", "aldrin"]
  ["foo fighters","bar hoppers","baz aldrin"]
  ghci> zipWith' (*) (replicate 5 2) [1..]
  [2,4,6,8,10]
  ghci> zipWith' (zipWith' (*)) [[1,2,3],[3,5,6],[2,3,4]] [[3,2,2],[3,4,5],[5,4,3]]
  [[3,4,6],[9,20,30],[10,12,12]]
  ```

接下来实现标准库中的另一个函数 `flip`，flip简单地取一个函数作参数并回传一个相似的函数，只是它们的两个参数倒了个。

```hs
-- 完整写法
flip' :: (a -> b -> c) -> (b -> a -> c)
flip' f = g
    where g x y = f y x

-- 更简单的写法
flip' :: (a -> b -> c) -> b -> a -> c
flip' f y x = f x y
```

> 从这型别声明中可以看出，它取一个函数，其参数型别分别为 `a` 和 `b`，而它回传的函数的参数型别为 `b` 和 `a`。

- 用法示例：

  ```
  ghci> flip' zip [1,2,3,4,5] "hello"
  [('h',1),('e',2),('l',3),('l',4),('o',5)]
  ghci> zipWith (flip' div) [2,2..] [10,8,6,4,2]
  [5,4,3,2,1]
  ```

  <details><summary>后一个表达式的具体求值过程</summary>

  ```hs
  zipWith (flip' div) [2,2..] [10,8,6,4,2]
  => (flip' div) 2 10 : zipWith (flip' div) [2,2..] [8,6,4,2]
  => div 10 2 : zipWith (flip' div) [2,2..] [8,6,4,2]
  => 5 : zipWith (flip' div) [2,2..] [8,6,4,2]
  => 5 : (div 8 2 : zipWith (flip' div) [2,2..] [6,4,2])
  => 5 : 4 : zipWith (flip' div) [2,2..] [6,4,2]
  => 5 : 4 : 3 : zipWith (flip' div) [2,2..] [4,2]
  => 5 : 4 : 3 : 2 : zipWith (flip' div) [2,2..] [2]
  => 5 : 4 : 3 : 2 : 1 : zipWith (flip' div) [2,2..] []
  => 5 : 4 : 3 : 2 : 1 : []   -- 匹配到第二个列表为空，停止
  => [5,4,3,2,1]
  ```

  </details>

## 重要的 `map` 和 `filter`

`map` 和 `filter` 是函数式编程中最常用的高级函数。

> 能用 `map` 和 `filter` 的地方基本上都可以用 List Comprehension 等价实现，用什么完全取决于你。但是如果有多个限制条件，用 List Comprehension 会更方便。

### map

`map` 取一个函数和 List 做参数，遍历该 List 的每个元素来调用该函数产生一个新的 List。看下它的型别声明和实现:

```hs
map :: (a -> b) -> [a] -> [b]
map _ [] = []
map f (x:xs) = f x : map f xs
```

map 函数多才多艺，有一百万种用法。如下是其中一小部分:

```hs
ghci> map (+3) [1,5,3,1,6]
[4,8,6,4,9]
ghci> map (++ "!") ["BIFF", "BANG", "POW"]
["BIFF!","BANG!","POW!"]
ghci> map (replicate 3) [3..6]
[[3,3,3],[4,4,4],[5,5,5],[6,6,6]]
ghci> map (map (^2)) [[1,2],[3,4,5,6],[7,8]]
[[1,4],[9,16,25,36],[49,64]]
ghci> map fst [(1,2),(3,5),(6,3),(2,6),(2,5)]
[1,3,6,2,2]
```

> 你可能会发现，以上的所有代码都可以用 List Comprehension 来替代。`map (+3) [1,5,3,1,6]` 与 `[x+3 | x <- [1,5,3,1,6]` 完全等价。

### filter

`filter` 函数取一个限制条件和一个 List，回传该 List 中所有符合该条件的元素。它的型别声明及实现大致如下:

```hs
filter :: (a -> Bool) -> [a] -> [a]
filter _ [] = []
filter p (x:xs)
    | p x       = x : filter p xs
    | otherwise = filter p xs
```

很简单。只要 `p x` 所得的结果为真，就将这一元素加入新 List，否则就无视之。几个使用范例:

```
ghci> filter (>3) [1,5,3,2,1,6,4,3,2,1]
[5,6,4]
ghci> filter (==3) [1,2,3,4,5]
[3]
ghci> filter even [1..10]
[2,4,6,8,10]
ghci> let notNull x = not (null x) in filter notNull [[1,2,3],[],[3,4,5],[2,2],[],[],[]]
[[1,2,3],[3,4,5],[2,2]]
ghci> filter (`elem` ['a'..'z']) "u LaUgH aT mE BeCaUsE I aM diFfeRent"
"uagameasadifeent"
ghci> filter (`elem` ['A'..'Z']) "i lauGh At You BecAuse u r aLL the Same"
"GAYBALLS"
```

> 同样，以上都可以用 List Comprehension 的限制条件来实现。

### 几个示例

#### 用 `filter` 实现 quicksort

之前用 List Comprehension 来过滤元素，换成 filter 也可以实现：

```hs
quicksort :: (Ord a) => [a] -> [a]
quicksort [] = []
quicksort (x:xs) =
    let smallerSorted = quicksort (filter (<=x) xs)
        biggerSorted = quicksort (filter (>x) xs)
    in  smallerSorted ++ [x] ++ biggerSorted
```

#### 找出所有小于 10000 且为奇的平方的和

先提下 `takeWhile` 函数，它取一个限制条件和 List 作参数，然后从头开始遍历这一 List，并回传符合限制条件的元素。 而一旦遇到不符合条件的元素，它就停止了。

```hs
-- 用 map 和 filter
ghci> sum (takeWhile (<10000) (filter odd (map (^2) [1..])))
166650

-- 用 List Comprehension
ghci> sum (takeWhile (<10000) [m | m <- [n^2 | n <- [1..]], odd m])
166650
```

感谢 Haskell 的惰性特质，这一切才得以实现。我们之所以可以 `map` 或 `filter` 一个无限 List，是因为它的操作不会被立即执行，而是拖延一下。

> 只有我们要求 Haskell 交给我们 `sum` 的结果的时候，`sum` 函数才会跟 `takeWhile` 说，它要这些数。takeWhile 就再去要求 filter 和 map 行动起来，并在遇到大于等于 10000 时候停止.

#### 构造函数列表

用 `map`，我们可以写出类似 `map (*) [0..]` 之类的代码，例如：

```hs
ghci> let listOfFuns = map (*) [0..]
ghci> (listOfFuns !! 4) 5
20
```

取所得 List 的第五个元素可得一函数，与 `(*4)` 等价。 然后用 5 调用它，与 `(* 4) 5` 或 `4*5` 都是等价的.

<details><summary>解释</summary>

1. 在 Haskell 中，乘法运算符 `(*)` 是一个中缀函数，它的完整类型是：

   ```hs
   (*) :: Num a => a -> a -> a
   ```

   > 例如，`(*) 4` 会返回函数 `\x -> x * 4`（即“乘以4”）

2. 下面解释 `map (*) [0..]` 做了什么。`map` 将 `(*)` 依次部分应用到 `[0..]` 每个元素上，结果获得一个**无限长的函数列表**：

   ```hs
   [ (*0), (*1), (*2), (*3), (*4), (*5), ... ]
   ```

3. `!!` 是 Haskell 的列表索引运算符，下标从 0 开始。因此，`(listOfFuns !! 4)` 的结果就是函数 `(*4)`，即“乘以 4”。

4. 将上面取出的函数应用到参数 5 上：

   ```hs
   (*4) 5
   -- 等价于
   5 * 4
   ```

   结果为 20

</details>

## lambda匿名函数

lambda 就是匿名函数。有些时候我们需要传给高阶函数一个函数，而这函数我们只会用这一次，这就弄个特定功能的 lambda。

编写 lambda，就写个 `\`，后面是用空格分隔的参数，`->` 后面就是函数体。通常我们都是用括号将其括起，要不然它就会占据整个右边部分。

```hs
ghci> filter (\x -> x > 0) [-3, -1, 2, 5, -2]
[2, 5]
```

**lambda 是个表达式**，因此我们可以任意传递。表达式 `(\x -> x > 0)` 回传一个函数，它可以告诉我们当前数字是否非负。

> **注意**：不熟悉 Curried functions 与不全调用的人们往往会写出很多 lambda，而实际上大部分都是没必要的。例如，表达式 `map (+3) [1,6,3,2]` 与 `map (\x -> x+3) [1,6,3,2]` 等价，`(+3)` 和 `(\x -> x+3)` 都是给一个数加上 3。不用说，在这种情况下不用 lambda 要清爽的多。

和普通函数一样，lambda 也可以取多个参数。

```hs
ghci> zipWith (\a b -> (a * 30 + 3) / b) [5,4,3,2,1] [1,2,3,4,5]
[153.0,61.5,31.0,15.75,6.6]
```

同普通函数一样，你也可以在 lambda 中使用模式匹配，只是你无法为一个参数设置多个模式，如 `[]` 和 `(x:xs)`。lambda 的模式匹配若失败，就会引发一个运行时错误，**所以慎用！**

```
ghci> map (\(a,b) -> a + b) [(1,2),(3,5),(6,3),(2,6),(2,5)]
[3,8,9,8,7]
```

### lambda与柯里化

一般情况下，lambda 都是括在括号中，除非我们想要后面的整个语句都作为 lambda 的函数体。很有趣，由于有柯里化，如下的两段是等价的：

```hs
addThree :: (Num a) => a -> a -> a -> a
addThree x y z = x + y + z

addThree' :: (Num a) => a -> a -> a -> a
addThree' = \x -> \y -> \z -> x + y + z
```

> 这样的函数声明与函数体中都有 `->`，这一来型别声明的写法就很明白了。当然第一段代码更易读，不过第二个函数使得柯里化更容易理解。

有些时候用这种语句写还是挺酷的，我觉得这应该是最易读的 `flip` 函数实现了：

```hs
flip' :: (a -> b -> c) -> b -> a -> c
flip' f = \x y -> f y x
```

> 尽管这与 `flip' f x y = f y x` 等价，但它可以更明白地表示出它会产生一个新的函数。flip 常用来处理一个函数，再将回传的新函数传递给 map 或 filter。所以如此使用 lambda 可以更明确地表现出回传值是个函数，可以用来传递给其他函数作参数。

## `fold` 函数组

与 `map` 和 `filter` 一样，`fold` 函数是 Haskell 最常用的函数之一。

**为什么要有 fold**：回到当初我们学习递归的情景。我们会发现处理 List 的许多函数都有固定的模式，通常我们会将边界条件设置为空 List，再引入 `(x:xs)` 模式，对单个元素和余下的 List 做些事情。这一模式是如此常见，因此 Haskell 引入了一组函数来使之简化，也就是 `fold`。它们与 `map` 有点像，只是它们回传的是单个值。

> 所有遍历 List 中元素并据此回传一个值的操作都可以交给 fold 实现。无论何时需要遍历 List 并回传某值，都可以尝试下 fold。因此，fold的地位可以说与 map 和 filter并驾齐驱，同为函数式编程中最常用的函数之一。

一个 fold 取一个`二元函数`，一个`初始值`(也可以叫累加值)和一个`需要折叠的 List`。

- 这个二元函数有两个参数，即`累加值`和 List 的`首项`(或尾项)，回传值是`新的累加值`。
- 然后，以新的累加值和新的 List 首项调用该函数，如是继续。
- 到 List 遍历完毕时，只剩下一个累加值，也就是最终的结果。

### `foldl` 左折叠

首先看下 `foldl` 函数，也叫做左折叠。它**从 List 的左端**开始折叠，用初始值和 List 的头部调用这二元函数，得一新的累加值，并用新的累加值与 List 的下一个元素调用二元函数。如是继续。

我们再实现下 `sum`，这次用 fold 替代那复杂的递归：

```hs
sum' :: (Num a) => [a] -> a
sum' xs = foldl (\acc x -> acc + x) 0 xs
```

```
ghci> sum' [3,5,2,1]
11
```

<details><summary>解释fold的执行过程</summary>

首先看 foldl 的参数：`\acc x-> acc + x` 是个二元函数，`0` 是初始值，`xs` 是待折叠的 List。

1. 一开始，累加值为 0，当前项为 3，调用二元函数 `0+3` 得 3，作新的累加值。
2. 接着来，累加值为 3，当前项为 5，得新累加值 8。
3. 再往后，累加值为 8，当前项为 2，得新累加值 10。
4. 最后累加值为 10，当前项为 1，得 11。

恭喜，你完成了一次折叠 (fold)！

</details>

如果我们考虑到函数的柯里化，可以写出更简单的实现：

```hs
sum' :: (Num a) => [a] -> a
sum' = foldl (+) 0
```

> 这个 lambda 函数 `(\acc x -> acc + x )` 与 `(+)` 等价。

用左折叠实现 `elem` 函数。用于检查某元素是否属于某 List。

```hs
elem' :: (Eq a) => a -> [a] -> Bool
elem' y ys = foldl (\acc x -> if x == y then True else acc) False ys
```

<details><summary>解释过程</summary>

起始值与累加值都是布尔值。在处理 `fold` 时，累加值与最终结果的型别总是相同的。

> 如果你不知道怎样对待起始值，我们先假设它不存在，以 `False` 开始。我们要是 fold 一个空 List，结果就是 False。

然后我们检查当前元素是否为我们寻找的，如果是，就令累加值为 `True`，如果否，就保留原值不变。若 `False`，及表明当前元素不是。若 `True`，就表明已经找到了。

</details>

### `foldr` 右折叠

右折叠 `foldr` 的行为与左折叠相似，只是累加值是**从 List 的右边开始**。同样，左折叠的二元函数取累加值作首个参数，当前值为第二个参数(即 `\acc x -> ...`)，而右折叠的二元函数参数的**顺序正好相反**(即 `\x acc -> ...`)。这倒也正常，毕竟是从右端开始折叠。

用右折叠实现 `map` 函数：

```hs
map' :: (a -> b) -> [a] -> [b]
map' f xs = foldr (\x acc -> f x : acc) [] xs
```

<details><summary>解释fold执行过程</summary>

如果我们用 `(+3)` 来映射 `[1,2,3]`：

1. 它会先到达 List 的右端，我们取最后那个元素，也就是 `3` 来调用 `(+3)`，得 6。
2. 追加 `(:)` 到累加值上，`6:[]` 得 `[6]` 并成为新的累加值。
3. 用 `2` 调用 `(+3)`，得 5，追加到累加值，于是累加值成了 `[5,6]`。
4. 再对 `1` 调用 `(+3)`，并将结果 4 追加到累加值，最终得结果 `[4,5,6]`。

</details>

当然，我们也完全可以用左折叠来实现它：

```hs
map' f xs = foldl (\acc x -> acc ++ [f x]) [] xs
```

不过问题是，使用 `(++)` 往 List 后面追加元素的**效率要比使用 `(:)` 低得多**。所以在生成新 List 的时候人们**一般都是使用右折叠**。

### 左/右折叠的适用场景

反转一个 List，既也可以通过右折叠，也可以通过左折叠。有时甚至不需要管它们的分别，如 `sum` 函数的左右折叠实现都是十分相似。不过有个大的不同，那就是：

- 右折叠可以处理**无限长度**的数据结构，而左折叠不可以。
- 将无限 List **从中断开执行**左折叠是可以的，不过若是向右，就永远到不了头了。

### `foldl1` 和 `foldr1`

`foldl1` 与 `foldr1` 的行为与 foldl 和 foldr 相似，只是你**无需明确提供初始值**。他们假定 List 的**首个(或末尾)元素**作为起始值，并从旁边的元素开始折叠。

这一来，sum 函数大可这样实现：

```hs
sum' :: (Num a) => [a] -> a
sum' foldl1 (+)
```

注意：这里待折叠的 List 中**至少要有一个元素**，若使用空 List 就会产生一个运行时错误。这种情况下 `foldl` 和 `foldr` 与空 List 相处的就很好。

> 所以在使用 fold 前，应该先想下它会不会遇到空 List，如果不会遇到，大可放心使用 `foldr1` 和 `foldl1`。

### 用 fold 实现几个库函数

为了体会 fold 的威力，我们就用它实现几个库函数：

```hs
maximum' :: (Ord a) => [a] -> a
maximum' = foldr1 (\x acc -> if x > acc then x else acc)

reverse' :: [a] -> [a]
reverse' = foldl (\acc x -> x : acc) []     -- 也可以改成 `foldl (flip (:)) []`

product' :: (Num a) => [a] -> a
product' = foldr1 (*)

filter' :: (a -> Bool) -> [a] -> [a]
filter' p = foldr (\x acc -> if p x then x : acc else acc) []

head' :: [a] -> a
head' = foldr1 (\x _ -> x)

last' :: [a] -> a
last' = foldl1 (\_ x -> x)
```

说明：

- 仅靠模式匹配就可以实现 `head` 和 `last` 函数，而且效率也很高。
- 这个 `reverse'` 定义的相当聪明，用一个空 List 做初始值，并向左展开 List，从左追加到累加值，最后得到一个反转的新 List。`\acc x -> x : acc` 有点像 `:` 函数，只是参数顺序相反。所以我们可以改成 `foldl (flip (:)) []`。

### `scanl` 和 `scanr`

`scanl` 和 `scanr` 与 foldl 和 foldr 相似，只是它们会记录下累加值的所有状态到一个 List。也有 `scanl1` 和 `scanr1`。

```
ghci> scanl (+) 0 [3,5,2,1]
[0,3,8,10,11]
ghci> scanr (+) 0 [3,5,2,1]
[11,8,3,1,0]
ghci> scanl1 (\acc x -> if x > acc then x else acc) [3,4,5,3,7,9,2,1]
[3,4,5,5,7,9,9,9]
ghci> scanl (flip (:)) [] [3,2,1]
[[],[3],[2,3],[1,2,3]]
```

<details><summary>解释最后一个表达式的求值过程</summary>

```hs
scanl (flip (:)) [] [3,2,1]
-- 设 f = flip (:)
=> [] : scanl f (f [] 3) (2:1:[])
=> [] : scanl f [3] (2:1:[])
=> [] : [3] : scanl f [2,3] (1:[])
=> [] : [3] : [2,3] : scanl f [1,2,3] []
=> [] : [3] : [2,3] : [1,2,3] : []
=> [ [], [3], [2,3], [1,2,3] ]
```

</details>

当使用 `scanl` 时，最终结果就是 List 的**最后一个**元素。而在 `scanr` 中则是**第一个**。

`scan` 可以用来跟踪 `fold` 函数的执行过程。

> 想想这个问题，取所有自然数的平方根的和，寻找在何处超过 1000？可以用 `scan` 得到小于 1000 的所有和，若有 `x` 个和小于 1000，那结果就是 `x+1`。

## `$` 函数调用符

`$` 函数是个函数调用符，其定义如下：

```hs
($) :: (a -> b) -> a -> b
f $ x = f x
```

语法：

- 普通的函数调用符（即空格）有最高的优先级，而 `$` 的**优先级则最低**。
- 用空格的函数调用符是左结合的，如 `f a b c` 与 `((f a) b) c` 等价，而 `$` 则是**右结合**的。

### 作用一：减少括号数目

有什么用——它可以**减少代码中括号的数目**。举例说明：

- 试想有这个表达式： `sum (map sqrt [1..130])`，用 `$` 可以简化为 `sum $ map sqrt [1..130]`
- 对于 `sqrt 3 + 4 + 9` 会得到 `9 + 4 + sqrt 3`。如果要取 `(3+4+9)` 的平方根，就得 `sqrt (3+4+9)` 或者用 `$`：`sqrt $ 3 + 4 + 9`
- `f (g (z x))` 与 `f $ g $ z x` 等价

### 作用二：将数据作为函数使用

除了减少括号外，`$` 还可以**将数据作为函数使用**。

例如映射一个函数调用符到一组函数组成的 List：

```hs
ghci> map ($ 3) [(4+),(10*),(^2),sqrt]
[7.0,30.0,9.0,1.7320508075688772]
```

## 函数组合（composition）

在数学中，函数组合是这样定义的：$(f \circ g)(x) = f(g(x))$，表示组合两个函数成为一个函数。

Haskell 中的函数组合与之很像，即 `.` 函数。其定义为：

```hs
(.) :: (b -> c) -> (a -> b) -> a -> c
f . g = \x -> f (g x)
```

> 注意下这型别声明，`f` 的参数型别必须与 `g` 的回传型别相同。所以组合得到的参数类型与 `g` 相同，返回类型与 `f` 相同。

### 作用一：生成新函数

函数组合的用处之一就是生成新函数，并传递给其它函数。当然我们可以用 lambda 实现，但大多数情况下，使用函数组合无疑更清楚。

假设我们有一组由数字组成的 List，要将其全部转为负数，很容易就想到应先取其绝对值，再取负数，像这样：

```hs
-- 用 lambda
ghci> map (\x -> negate (abs x)) [5,-3,-6,7,-3,2,-19,24]
[-5,-3,-6,-7,-3,-2,-19,-24]

-- 用函数组合
ghci> map (negate . abs) [5,-3,-6,7,-3,2,-19,24]
[-5,-3,-6,-7,-3,-2,-19,-24]
```

函数组合是**右结合**的，我们同时组合多个函数。表达式 `f (g (z x))` 与 `(f . g . z) x` 等价。

```hs
-- 用 lambda
ghci> map (\xs -> negate (sum (tail xs))) [[1..5],[3..6],[1..7]]
[-14,-15,-27]

-- 用函数组合
ghci> map (negate . sum . tail) [[1..5],[3..6],[1..7]]
[-14,-15,-27]
```

对于包含多个参数的函数，可以使用**不全调用**使每个函数都只剩下一个参数。

```hs
ghci> sum (replicate 5 (max 6.7 8.9))

-- 可以重写为
ghci> (sum . replicate 5 . max 6.7) 8.9
-- 或者
ghci> sum . replicate 5 . max 6.7 $ 8.9
```

> **技巧**：如果你打算用函数组合来替掉那堆括号，可以先在最靠近参数的函数后面加一个 `$`，接着就用 `.` 组合其所有函数调用，而不用管最后那个参数。

### 作用二：定义 point free style 的函数

函数组合的另一用途就是定义 point free style (也称作 pointless style) 的函数。

#### 什么是 point free style

以之前实现的 `sum` 函数为例：

```hs
sum' :: (Num a) => [a] -> a
sum' xs = foldl (+) 0 xs
```

由于有柯里化，可以将函数定义两边的 `xs` 拿掉：

```hs
sum' = foldl (+) 0
```

这就是 point free style，即**不显式提及参数**的函数定义风格，通过组合其他函数来定义函数。

> 在数学和 Haskell 中，“point”指的是参数（来自拓扑学/范畴论中的“point-free”）。

#### 如何实现 point free style

对于比较复杂的函数，例如下面这个函数怎么改成 point free style？

```hs
fn x = ceiling (negate (tan (cos (max 50 x))))
```

想之前那样简单去掉两端的 `x` 是不行的，解决方法就是使用函数组合：

```hs
fn = ceiling . negate . tan . cos . max 50
```

#### point free style 的适用场景

point free style 会令你去思考函数的组合方式，而非数据的传递方式，更加简洁明了。你可以将一组简单的函数组合在一起，使之形成一个复杂的函数。

不过函数若过于复杂，再使用 point free style 往往会适得其反，因此构造较长的函数组合链是不被鼓励的。

更好的解决方法，就是使用 `let` 语句给中间的运算结果绑定一个名字，或者说把问题分解成几个小问题再组合到一起。这样一来我们代码的读者就可以轻松些，不必要纠结那巨长的函数组合链了。

例如下面这个函数，用于求解小于 10000 的所有奇数的平方的和。

```hs
oddSquareSum :: Integer
oddSquareSum = sum (takeWhile (<10000) (filter odd (map (^2) [1..])))
```

身为函数组合狂人，可能会这么写：

```hs
oddSquareSum :: Integer
oddSquareSum = sum . takeWhile (<10000) . filter odd . map (^2) $ [1..]
```

太长了比较难读，更好的写法是结合 `let` 语句：

```hs
oddSquareSum :: Integer
oddSquareSum =
    let oddSquares = filter odd $ map (^2) [1..]
        belowLimit = takeWhile (<10000) oddSquares
    in  sum belowLimit
```
