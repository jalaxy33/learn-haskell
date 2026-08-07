# Type 和 Typeclass

## Type

在 `ghci` 中使用 `:t` 可以查看表达式的类型，类型用 `::` 标注。

```
ghci> :t 'a'
'a' :: Char
ghci> :t True
True :: Bool
ghci> :t "HELLO!"
"HELLO!" :: [Char]
ghci> :t (True, 'a')
(True, 'a') :: (Bool, Char)
ghci> :t 4 == 5
4 == 5 :: Bool
```

编译器可以自动推断函数类型，但是也可以为函数明确声明类型，这是好习惯：

```hs
removeNonUppercase :: [Char] -> [Char]
removeNonUppercase st = [ c | c <- st, c `elem` ['A'..'Z']]
```

### 常见类型

- `Int` 表示有界整数，跟位数有关。对 32 位的机器而言，上限一般是 2147483647，下限是 -2147483648。
- `Integer` 表示无界整数，可以用来存放非常大的数，效率不如 `Int` 高

  ```
  factorial :: Integer -> Integer
  factorial n = product [1..n]

  ghci> factorial 50
  30414093201713378043612608166064768844377641568960512000000000000
  ```

- `Float` 表示单精度浮点数

  ```
  circumference :: Float -> Float
  circumference r = 2 * pi * r

  ghci> circumference 4.0
  25.132742
  ```

- `Double` 表示双精度浮点数

  ```
  circumference' :: Double -> Double
  circumference' r = 2 * pi * r

  ghci> circumference' 4.0
  25.132741228718345
  ```

- `Bool` 表示布尔值，它只有两种值：`True` 和 `False`。

- `Char` 表示一个字符。一个字符由单引号括起，**一组字符的 `List` 即为字串**。

- `Tuple` 的型别取决于它的长度及其中项的型别。注意，空 Tuple 同样也是个型别，它只有一种值：`()`。

## Typeclasses

类型定义行为的接口，如果一个类型属于某 Typeclass，那它**必实现了该 Typeclass 所描述的行为**。易于理解起见，可以把它看做是 Java 的 interface。

例如，查看 `==` 函数的类型声明：

```
ghci> :t (==)
(==) :: (Eq a) => a -> a -> Bool
```

这里出现了 `=>` 符号，左边的部分叫做**型别约束**。

> 这段型别声明说的是："相等函数取两个相同型别的值作为参数并回传一个布尔值，而这两个参数的型别同在 Eq 类之中"

### 常见 Typeclass

#### Eq

`Eq` 提供了判断相等性的接口，提供实现的函数是 `==` 和 `/=`。

```
ghci> 5 == 5
True
ghci> 5 /= 5
False
ghci> 'a' == 'a'
True
ghci> "Ho Ho" == "Ho Ho"
True
ghci> 3.432 == 3.432
True
```

`elem` 函数的型别为: `(Eq a)=>a->[a]->Bool`。这是它在检测值是否存在于一个 List 时使用到了`==`的缘故。

#### Ord

`Ord` 包含可比较大小的型别，包含了`<`, `>`, `<=`, `>=` 之类用于比较大小的函数。型别若要成为 `Ord` 的成员，必先加入 `Eq` 家族。

> 除了函数以外，我们目前所谈到的所有型别都属于 `Ord` 类。

```
ghci> :t (>)
(>) :: (Ord a) => a -> a -> Bool
```

`compare` 函数取两个 `Ord` 类中的相同型别的值作参数，回传比较的结果。这个结果是如下三种型别之一：`GT`, `LT`, `EQ`。

```
ghci> "Abrakadabra" < "Zebra"
True
ghci> "Abrakadabra" `compare` "Zebra"
LT
ghci> 5 >= 2
True
ghci> 5 `compare` 3
GT
```

#### Show

`Show` 的成员为可用字串表示的型别。最常用的函数表示 `show`，它可以取任一Show的成员型别并将其转为字串。

> 目前为止，除函数以外的所有型别都是 `Show` 的成员。

```
ghci> show 3
"3"
ghci> show 5.334
"5.334"
ghci> show True
"True"
```

#### Read

`Read` 是与 `Show` 相反的 Typeclass。`read` 函数可以将一个字串转为 Read 的某成员型别。

```
ghci> read "True" || False
True
ghci> read "8.2" + 3.8
12.0
ghci> read "5" - 2
3
ghci> read "[1,2,3,4]" ++ [3]
[1,2,3,4,3]
```

`read` 的回传值属于 ReadTypeclass，但我们若用不到这个值，它就永远都不会得知该表达式的型别。所以需要在一个表达式后跟 `::` 的型别注释，以明确其型别。

```
ghci> read "5" :: Int
5
ghci> read "5" :: Float
5.0
ghci> (read "5" :: Float) * 4
20.0
ghci> read "[1,2,3,4]" :: [Int]
[1,2,3,4]
ghci> read "(3, 'a')" :: (Int, Char)
(3, 'a')
```

#### Enum

`Enum` 的成员都是**连续的**型别 -- 也就是可枚举。

- Enum 类存在的主要好处就在于我们可以在 `Range` 中用到它的成员型别：每个值都有后继子 (successer) 和前置子 (predecesor)，分别可以通过 `succ` 函数和 `pred` 函数得到。

- 该 Typeclass 包含的型别有：`()`, `Bool`, `Char`, `Ordering`, `Int`, `Integer`, `Float` 和 `Double`。

```
ghci> ['a'..'e']
"abcde"
ghci> [LT .. GT]
[LT,EQ,GT]
ghci> [3 .. 5]
[3,4,5]
ghci> succ 'B'
'C'
```

#### Bounded

Bounded 的成员都有一个上限和下限。

`minBound` 和 `maxBound` 函数很有趣，它们的型别都是 `(Bounded a) => a`。可以说，它们都是**多态常量**。

```
ghci> minBound :: Int
-2147483648
ghci> maxBound :: Char
'\1114111'
ghci> maxBound :: Bool
True
ghci> minBound :: Bool
False
```

如果其中的项都属于 `Bounded` Typeclass，那么该 Tuple 也属于 `Bounded`

```
ghci> maxBound :: (Bool, Int, Char)
(True,2147483647,'\1114111')
```

#### Num

`Num` 是表示数字的 Typeclass，它的成员型别都具有数字的特征。型别只有亲近 `Show` 和 `Eq`，才可以加入 `Num`。

**所有的数字都是多态常量**，它可以作为所有 `Num` Typeclass 中的成员型别。

```
ghci> :t 20
20 :: (Num t) => t
```

检测 `*` 运算子的型别，可以发现它可以处理一切的数字：

```
ghci> :t (*)
(*) :: (Num a) => a -> a -> a
```

> 它只取两个相同型别的参数。所以 `(5 :: Int) * (6 :: Integer)` 会引发一个型别错误，而 `5 * (6 :: Integer)` 就不会有问题。

#### Integral 和 Floating

`Integral` 同样是表示数字的 Typeclass。Num 包含所有的数字：实数和整数。而 Integral 仅包含整数，其中的成员型别有 `Int` 和 `Integer`。

`Floating` 仅包含浮点型别：`Float` 和 `Double`。

有个函数在处理数字时会非常有用，它便是 `fromIntegral`。其型别声明为： `fromIntegral :: (Num b, Integral a) => a -> b`。取一个整数做参数并回传一个更加通用的数字，这在同时处理整数和浮点时会尤为有用。

> 举例来说，length 函数的型别声明为：`length :: [a] -> Int`，如果取了一个 List 长度的值再给它加 3.2 就会报错，因为这是将浮点数和整数相加。面对这种情况，我们就用 `fromIntegral (length [1,2,3,4]) + 3.2` 来解决。

注意到，`fromIntegral` 的型别声明中用到了多个型别约束。如你所见，**只要将多个型别约束放到括号里用逗号隔开即可**。
