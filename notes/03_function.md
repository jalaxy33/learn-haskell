# 函数语法

## 模式匹配 (Pattern matching)

在定义函数时，你可以为不同的模式分别定义函数本身，这就让代码更加简洁易读。你可以匹配一切数据型别 --- 数字，字符，List，元组，等等。

例如，下面的函数会检查传入的参数是不是 7

```hs
lucky :: (Integral a) => a -> String
lucky 7 = "LUCKY NUMBER SEVEN!"
lucky x = "Sorry, you're out of luck, pal!"

ghci> lucky 7
"LUCKY NUMBER SEVEN!"
ghci> lucky 5
"Sorry, you're out of luck, pal!"
```

> 在调用 lucky 时，模式会**从上至下**进行检查，一旦有匹配，那对应的函数体就被应用了。

利用模式匹配实现阶乘：

```hs
factorial :: (Integral a) => a -> a
factorial 0 = 1
factorial n = n * factorial (n - 1)
```

如果模式不够全面，则可能会使模式匹配失败报错：

```hs
charName :: Char -> String
charName 'a' = "Albert"
charName 'b' = "Broseph"
charName 'c' = "Cecil"

ghci> charName 'a'
"Albert"
ghci> charName 'b'
"Broseph"
ghci> charName 'h'
"*** Exception: tut.hs:(53,0)-(55,21): Non-exhaustive patterns in function charName
```

### 对 tuple 使用模式匹配

对 tuple 也可以使用模式匹配，可以写出更简洁的代码：

```hs
-- 如果不了解模式匹配可能写出这样的代码：
addVectors :: (Num a) => (a, a) -> (a, a) -> (a, a)
addVectors a b = (fst a + fst b, snd a + snd b)

-- 更好的写法
addVectors :: (Num a) => (a, a) -> (a, a) -> (a, a)
addVectors (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)
```

### 在 list comprehension 中使用模式匹配

在 list comprehension 中使用模式匹配，一旦模式匹配失败，它就简单挪到下个元素：

```
ghci> let xs = [(1,3), (4,3), (2,4), (5,3), (5,6), (3,1)]
ghci> [a+b | (a,b) <- xs]
[4,7,6,8,11,4]
```

### 对 list 使用模式匹配

对 list 本身也可以使用模式匹配，可以像 `x:xs` 这样的模式可以将 List 的头部绑定为 `x`，尾部绑定为 `xs`。如果这 List 只有一个元素，那么 xs 就是一个空 List。

> `[1,2,3]` 本质上是 `1:2:3:[]` 的语法糖。`x:xs` 这模式的应用非常广泛，尤其是递归函数。不过它只能匹配长度大于等于 1 的 List。

如果你要把 List 的前三个元素都绑定到变量中，可以使用类似 `x:y:z:xs` 这样的形式。它只能匹配长度大于等于 3 的 List。

用 list 模式匹配来实现自己的 `head` 函数：

```hs
head' :: [a] -> a
head' [] = error "Can't call head on an empty list, dummy!"
head' (x:_) = x

ghci> head' [4,5,6]
4
ghci> head' "Hello"
'H'
```

> 注意下，你若要绑定多个变量(用 _ 也是如此)，我们**必须用括号将其括起**。同时注意下我们用的这个 `error` 函数，它可以生成一个运行时错误，用参数中的字串表示对错误的描述。它会直接导致进程崩溃，因此应谨慎使用。

用模式匹配和递归重新实现 `length` 函数：

```hs
length' :: (Num b) => [a] -> b
length' [] = 0
length' (_:xs) = 1 + length' xs
```

用模式匹配实现 `sum` 函数：

```hs
sum' :: (Num a) => [a] -> a
sum' [] = 0
sum' (x:xs) = x + sum' xs
```

另外要注意，你**不可以在模式匹配中使用 `++`**。

> 若有个模式是 `(xs++ys)`，那么这个 List 该从什么地方分开呢？不靠谱吧。

### as模式

还有个东西叫做 as 模式，就是将一个名字和 `@` 置于模式前，可以在按模式分割什么东西时仍保留对其整体的引用。

如这个模式 `xs@(x:y:ys)`，它会匹配出与 `x:y:ys` 对应的东西，同时你也可以方便地通过 `xs` 得到整个 List，而不必在函数体中重复 `x:y:ys`。

```hs
capital :: String -> String
capital "" = "Empty string, whoops!"
capital all@(x:xs) = "The first letter of " ++ all ++ " is " ++ [x]

ghci> capital "Dracula"
"The first letter of Dracula is D"
```

## 什么是 guard

模式用来检查一个值是否合适并从中取值，而 guard 则用来**检查一个值的某项属性是否为真**。咋一听有点像是 if 语句，实际上也正是如此。不过处理多个条件分支时 guard 的可读性要高些，并且与模式匹配契合的很好。

用一个例子来说明：

```sh
bmiTell :: (RealFloat a) => a -> String
bmiTell bmi
    | bmi <= 18.5 = "You're underweight, you emo, you!"
    | bmi <= 25.0 = "You're supposedly normal. Pffft, I bet you're ugly!"
    | bmi <= 30.0 = "You're fat! Lose some weight, fatty!"
    | otherwise   = "You're a whale, congratulations!"
```

guard 由跟在函数名及参数后面的竖线标志，通常他们都是靠右一个缩进排成一列。一个 guard **就是一个布尔表达式**，如果为真，就使用其对应的函数体。如果为假，就送去见下一个 guard，如之继续。

最后的那个 guard 往往都是 `otherwise`，它的定义就是简单一个 `otherwise = True` ，捕获一切。这与模式很相像，只是模式检查的是匹配，而它们检查的是布尔表达式 。

要注意一点，**函数的名字和参数的后面并没有 `=`**。许多初学者会造成语法错误，就是因为在后面加上了 `=`。

另一个简单的例子：写个自己的 `max` 函数。

```hs
max' :: (Ord a) => a -> a -> a
max' a b
    | a > b     = a
    | otherwise = b
```

再来试试用 guard 实现我们自己的 `compare` 函数：

```hs
myCompare :: (Ord a) => a -> a -> Ordering
a `myCompare` b
    | a > b     = GT
    | a == b    = EQ
    | otherwise = LT

ghci> 3 `myCompare` 2
GT
```

> 通过反单引号，我们不仅可以以中缀形式调用函数，也可以在定义函数的时候使用它。有时这样会更易读。

## 关键字where

`where` 关键字跟在 guard 后面(最好是与竖线缩进一致)，可以定义多个名字和函数。这些名字对每个 guard 都是可见的，这一来就避免了重复。

```hs
-- 如果不用 where
bmiTell :: (RealFloat a) => a -> a -> String
bmiTell weight height
    | bmi <= 18.5 = "You're underweight, you emo, you!"
    | bmi <= 25.0 = "You're supposedly normal. Pffft, I bet you're ugly!"
    | bmi <= 30.0 = "You're fat! Lose some weight, fatty!"
    | otherwise   = "You're a whale, congratulations!"
    where bmi = weight / height ^ 2

-- 用 where 减少重复逻辑
bmiTell :: (RealFloat a) => a -> a -> String
bmiTell weight height
    | bmi <= skinny = "You're underweight, you emo, you!"
    | bmi <= normal = "You're supposedly normal. Pffft, I bet you're ugly!"
    | bmi <= fat    = "You're fat! Lose some weight, fatty!"
    | otherwise     = "You're a whale, congratulations!"
    where bmi = weight / height ^ 2
          skinny = 18.5
          normal = 25.0
          fat = 30.0
```

函数在 `where` 绑定中定义的名字只对本函数可见，因此我们不必担心它会污染其他函数的命名空间。

> `where` 绑定不会在多个模式中共享。如果你在一个函数的多个模式中重复用到同一名字，就应该把它置于全局定义之中。

where 绑定也可以使用模式匹配，前面那段代码可以改成：

```hs
...
where bmi = weight / height ^ 2
      (skinny, normal, fat) = (18.5, 25.0, 30.0)
```

where 绑定可以定义名字，也可以定义函数。保持健康的编程语言风格，我们搞个计算一组 bmi 的函数：

```hs
calcBmis :: (RealFloat a) => [(a, a)] -> [a]
calcBmis xs = [bmi w h | (w, h) <- xs]
    where bmi weight height = weight / height ^ 2
```

> 在这里将 bmi 搞成一个函数，是因为我们不能依据参数直接进行计算，而必须先从传入函数的 List 中取出每个序对并计算对应的值。

where 绑定还可以一层套一层地来使用。 有个常见的写法是，在定义一个函数的时候也写几个辅助函数摆在 where 绑定中。 而每个辅助函数也可以透过 where 拥有各自的辅助函数。

## 关键字 let

`let` 绑定与 `where` 绑定很相似。

- `where` 绑定是在函数底部定义名字，对包括所有 guard 在内的整个函数可见。
- `let` 绑定则是个表达式，允许你在任何位置定义局部变量，而对不同的 guard 不可见。正如 Haskell 中所有赋值结构一样，let 绑定也可以使用模式匹配。

```hs
cylinder :: (RealFloat a) => a -> a -> a
cylinder r h =
    let sideArea = 2 * pi * r * h
        topArea = pi * r ^2
    in  sideArea + 2 * topArea
```

let 的格式为 `let [bindings] in [expressions]`。在 let 中绑定的名字仅对 `in` 部分可见。let 里面定义的名字也得对齐到一列。

与 where 的不同之处在于，`let` 绑定**本身是个表达式**，而 `where` 绑定则是个语法结构。与 if 类似，可以随处安放：

```hs
-- 用if语句
ghci> 4 * (if 10 > 5 then 10 else 0) + 2
42

-- 用 let 绑定也可以实现
ghci> 4 * (let a = 9 in a + 1) + 2
42
```

let 也可以定义局部函数：

```hs
ghci> [let square x = x * x in (square 5, square 3, square 2)]
[(25,9,4)]
```

若要在一行中绑定多个名字，再将它们排成一列显然是不可以的。不过可以用**分号**将其分开。

```hs
ghci> (let a = 100; b = 200; c = 300 in a*b*c, let foo="Hey "; bar = "there!" in foo ++ bar)
(6000000,"Hey there!")
```

> 最后那个绑定后面的分号不是必须的，不过加上也没关系。

你可以在 let 绑定中使用模式匹配。这在从 Tuple 取值之类的操作中很方便。

```hs
ghci> (let (a,b,c) = (1,2,3) in a+b+c) * 100
600
```

你也可以把 let 绑定放到 List Comprehension 中。我们重写下那个计算 bmi 值的函数，用个 `let` 替换掉原先的 `where`。

```hs
calcBmis :: (RealFloat a) => [(a, a)] -> [a]
calcBmis xs = [bmi | (w, h) <- xs, let bmi = w / h ^ 2]
```

List Comprehension 中 let 绑定的样子和限制条件差不多，只不过它做的不是过滤，而是绑定名字。let 中绑定的名字**在输出函数及限制条件中都可见**。这一来我们就可以让我们的函数只返回胖子的 bmi 值：

```hs
calcBmis :: (RealFloat a) => [(a, a)] -> [a]
calcBmis xs = [bmi | (w, h) <- xs, let bmi = w / h ^ 2, bmi >= 25.0]
```

> 在 `(w, h) <- xs` 这里无法使用 bmi 这名字，因为它在 let 绑定的前面。

在 List Comprehension 中我们忽略了 let 绑定的 `in` 部分，因为名字的可见性已经预先定义好了。不过，把一个 `let...in` 放到限制条件中也是可以的，这样名字只对这个限制条件可见。在 ghci 中 in 部分也可以省略，名字的定义就在整个交互中可见。

```hs
ghci> let zoot x y z = x * y + z
ghci> zoot 3 9 2
29
ghci> let boot x y z = x * y + z in boot 3 4 2
14
ghci> boot
< interactive>:1:0: Not in scope: `boot'
```

## case表达式

`case` 表达式取一个变量，对它模式匹配，执行对应的代码块。模式匹配本质上不过就是 `case` 语句的语法糖而已。

这两段代码就是完全等价的：

```hs
head' :: [a] -> a
head' [] = error "No head for empty lists!"
head' (x:_) = x

head' :: [a] -> a
head' xs = case xs of
            [] -> error "No head for empty lists!"
            (x:_) -> x
```

看得出，case表达式的语法十分简单：

```hs
case expression of pattern -> result
                   pattern -> result
                   pattern -> result
                   ...
```

函数参数的模式匹配只能在定义函数时使用，而 `case` 表达式可以用在任何地方。例如：

```hs
describeList :: [a] -> String
describeList xs = "The list is " ++ case xs of
                    [] -> "empty."
                    [x] -> "a singleton list."
                    xs -> "a longer list."
```

这在表达式中作模式匹配很方便，由于模式匹配本质上就是 case 表达式的语法糖，那么写成这样也是等价的：

```hs
describeList :: [a] -> String
describeList xs = "The list is " ++ what xs
    where what [] = "empty."
          what [x] = "a singleton list."
          what xs = "a longer list."
```
