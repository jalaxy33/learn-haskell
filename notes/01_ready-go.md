# 零基础入门知识

教程：[从零开始](https://learnyouahaskell.mno2.org/zh-cn/ch02/ready-go)

## 基础计算

简单计算：

```
ghci> 2 + 15
17
ghci> 49 * 100
4900
ghci> 1892 - 1472
420
ghci> 5 / 2
2.5
```

布尔代数

```
ghci> True && False
False
ghci> True && True
True
ghci> False || True
True
ghci> not False
True
ghci> not (True && True)
False
```

相等性判定

```
ghci> 5 == 5
True
ghci> 1 == 0
False
ghci> 5 /= 5
False
ghci> 5 /= 4
True
ghci> "hello" == "hello"
True
```

一些内置函数调用：

```
ghci> succ 8
9
ghci> min 9 10
9
ghci> min 3.4 3.2
3.2
ghci> max 100 101
101
```

函数调用拥有最高的优先级，如下两句是等效的

```
ghci> succ 9 + max 5 4 + 1
16
ghci> (succ 9) + (max 5 4) + 1
16
```

## 函数

定义第一个函数

```hs
doubleMe x = x + x
```

可以写入以 `.hs` 为后缀的文件中，在 `ghci` 中用 `:l <模块名>` 加载

```
ghci> :l baby
[1 of 1] Compiling Main             ( baby.hs, interpreted )
Ok, modules loaded: Main.
ghci> doubleMe 9
18
ghci> doubleMe 8.3
16.6
```

定义多元函数

```hs
doubleUs x y = x*2 + y*2
```

函数名中可以包含单引号 `'`：

```hs
doubleSmallNumber' x = (if x > 100 then x else x*2) + 1
conanO'Brien = "It's a-me, Conan O'Brien!"
```

## List

List 用来存储多个**类型相同**的元素，长度无限制。

> 在 ghci 中可以用 `let` 来定义常量（如 `let a=1`），与在脚本中写 `a=1` 等价

```
ghci> let lostNumbers = [4,8,15,16,23,48]
ghci> lostNumbers
[4,8,15,16,23,48]
```

string实际上是 list of chars：

```
ghci> ['h','e','l','l','o']
"hello"
```

List拼接用 `++`

```
ghci> [1,2,3,4] ++ [9,10,11,12]
[1,2,3,4,9,10,11,12]
ghci> "hello" ++ " " ++ "world"
"hello world"
ghci> ['w','o'] ++ ['o','t']
"woot"
```

用 `:` 在list**前端**添加元素：

> `[1,2,3]` 实际上是 `1:2:3:[]` 的语法糖

```
ghci> 'A':" SMALL CAT"
"A SMALL CAT"
ghci> 5:[1,2,3,4,5]
[5,1,2,3,4,5]
```

用 `!!` 来索引元素，序号从 0 开始：

```
ghci> "Steve Buscemi" !! 6
'B'
ghci> [9.4,33.2,96.2,11.2,23.25] !! 1
33.2
```

其他常用函数：

```
-- head返回首个元素
ghci> head [5,4,3,2,1]
5

-- tail返回除了head之外的部分
ghci> tail [5,4,3,2,1]
[4,3,2,1]

-- last返回最后一个元素
ghci> last [5,4,3,2,1]
1

-- init返回除了last之外的部分
ghci> init [5,4,3,2,1]
[5,4,3,2]
```

```
-- length 返回 List 的长度
ghci> length [5,4,3,2,1]
5

-- null 检查 List 是否为空
ghci> null [1,2,3]
False
ghci> null []
True

-- reverse 将 List 反转
ghci> reverse [5,4,3,2,1]
[1,2,3,4,5]
```

```
-- take 返回 List 的前几个元素
ghci> take 3 [5,4,3,2,1]
[5,4,3]
ghci> take 1 [3,9,3]
[3]
ghci> take 5 [1,2]
[1,2]
ghci> take 0 [6,6,6]
[]

-- drop 删除 List 中的前几个元素
ghci> drop 3 [8,4,2,1,5,6]
[1,5,6]
ghci> drop 0 [1,2,3,4]
[1,2,3,4]
ghci> drop 100 [1,2,3,4]
[]
```

```
-- 最大值，最小值
ghci> minimum [8,4,2,1,5,6]
1
ghci> maximum [1,9,2,3,4]
9

-- 元素之和，元素之积
ghci> sum [5,2,1,6,3,2,5,7]
31
ghci> product [6,2,1,2]
24
ghci> product [1,2,5,6,7,9,2,0]
0

-- elem 判断List是否包含某元素，通常以中缀函数的形式调用
ghci> 4 `elem` [3,4,5,6]
True
ghci> 10 `elem` [3,4,5,6]
False
```

## Range

Range 是构造 List 方法之一，其中的值必须是可枚举的。

```
ghci> [1..20]
[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
ghci> ['a'..'z']
"abcdefghijklmnopqrstuvwxyz"
ghci> ['K'..'Z']
"KLMNOPQRSTUVWXYZ"
```

Range 的特点是他还允许你指定每一步该跨多远。仅需用逗号将前两个元素隔开，再标上上限即可。

```
ghci> [2,4..20]
[2,4,6,8,10,12,14,16,18,20]
ghci> [3,6..20]
[3,6,9,12,15,18]
```

也可以不标明 Range 的上限，从而得到一个无限长度的 List。Haskell 是惰性的，它不会对无限长度的 List 求值。可以结合 `take` 来取值：

```
ghci> take 10 (cycle [1,2,3])
[1,2,3,1,2,3,1,2,3,1]
ghci> take 12 (cycle "LOL ")
"LOL LOL LOL "
```

构造无限 list 的方法：

```
-- 无上限 Range
ghci> take 5 [1..]
[1,2,3,4,5]

-- cycle 循环
ghci> take 10 (cycle [1,2,3])
[1,2,3,1,2,3,1,2,3,1]

-- repeat 重复
ghci> take 10 (repeat 5)
[5,5,5,5,5,5,5,5,5,5]
```

## List Comprehesion

Comprehesion 是从既有的集合中按照规则产生一个新集合。

```
ghci> [x*2 | x <- [1..10]]
[2,4,6,8,10,12,14,16,18,20]
```

可以增加限制条件（predicate），来获得符合条件的元素列表

```
ghci> [x*2 | x <- [1..10], x*2 >= 12]
[12,14,16,18,20]

ghci> [ x | x <- [10..20], x /= 13, x /= 15, x /= 19]
[10,11,12,14,16,17,18,20]
```

为方便重用，可以将 comprehension 置于函数中：

```
boomBangs xs = [ if x < 10 then "BOOM!" else "BANG!" | x <- xs, odd x]

ghci> boomBangs [7..13]
["BOOM!","BOOM!","BANG!","BANG!"]
```

如果不关心从 List 中取什么值，可以用 `_` 代替：

```hs
length' xs = sum [1 | _ <- xs]
```

可以从多个List中取元素，会把所有的元素组合交付给我们的输出函数

```
ghci> [ x*y | x <- [2,5,10], y <- [8,10,11]]
[16,20,22,40,50,55,80,100,110]
```

对于嵌套列表，可以使用嵌套 list comprehension 处理：

> 将 List Comprehension 分成多行也是可以的。若非在 ghci 之下，还是将 List Comprehension 分成多行好，尤其是需要嵌套的时候。

```
ghci> let xxs = [[1,3,5,2,3,1,2,4,5],[1,2,3,4,5,6,7,8,9],[1,2,4,2,1,6,3,1,3,2,3,6]]
ghci> [ [ x | x <- xs, even x ] | xs <- xxs]
[[2,2,4],[2,4,6,8],[2,4,2,6,2,6]]
```

## Tuple

Tuple用于组合**多个任意类型**的元素，元素类型和数量一旦确定不可更改。

```
(1, True)
```

使用 Tuple 前应当事先明确一条数据中应该由多少个项，每个不同长度的 Tuple 都是独立的类型。与 List 不同，不允许单元素 Tuple。

序对（pair）即两元素Tuple。两个有用的序对操作函数（**仅对序对有效**）：

```
-- fst 返回一个序对的首项
ghci> fst (8,11)
8
ghci> fst ("Wow", False)
"Wow"

-- snd 返回序对的尾项
ghci> snd (8,11)
11
ghci> snd ("Wow", False)
False
```

一个实用函数——`zip`，用于生成 list of pairs，长度不一致时会截断：

```
ghcVi> zip [1,2,3,4,5] [5,5,5,5,5]
[(1,5),(2,5),(3,5),(4,5),(5,5)]

ghci> zip [1..] ["apple", "orange", "cherry", "mango"]
[(1,"apple"),(2,"orange"),(3,"cherry"),(4,"mango")]
```

tuple 可以用在 list comprehension 中：

```
ghci> let rightTriangles' = [ (a,b,c) | c <- [1..10], b <- [1..c], a <- [1..b], a^2 + b^2 == c^2, a+b+c == 24]
ghci> rightTriangles'
[(6,8,10)]
```

> 函数式编程语言的一般思路：**先取一个初始的集合并将其变形，执行过滤条件，最终取得正确的结果**。
