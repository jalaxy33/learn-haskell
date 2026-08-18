# Data.Char 模块

`Data.Char` 模块包含了一组用于处理字符的函数。由于字串的本质就是一组字符的 List，所以往往会在 `filter` 或 `map` 字串时用到它.

## 判断字符范围的函数

`Data.Char` 模块中含有一系列用于判定字符范围的函数：

- `isControl` 判断一个字符是否是控制字符
- `isSpace` 判断一个字符是否是空格字符，包括空格，tab，换行符等
- `isLower` 判断一个字符是否为小写. `isUper` 判断一个字符是否为大写。
- `isAlpha` 判断一个字符是否为字母. `isAlphaNum` 判断一个字符是否为字母或数字
- `isPrint` 判断一个字符是否是可打印的
- `isDigit` 判断一个字符是否为数字. `isOctDigit` 判断一个字符是否为八进制数字. `isHexDigit` 判断一个字符是否为十六进制数字.
- `isLetter` 判断一个字符是否为字母.
- `isMark` 判断是否为 unicode 注音字符，你如果是法国人就会经常用到的.
- `isNumber` 判断一个字符是否为数字.
- `isPunctuation` 判断一个字符是否为标点符号.
- `isSymbol` 判断一个字符是否为货币符号.
- `isSeperater` 判断一个字符是否为 unicode 空格或分隔符.
- `isAscii` 判断一个字符是否在 unicode 字母表的前 128 位。 `isLatin1` 判断一个字符是否在 unicode 字母表的前 256 位.
- `isAsciiUpper` 判断一个字符是否为大写的 ascii 字符. `isAsciiLower` 判断一个字符是否为小写的 ascii 字符.

以上所有判断函数的型别声明皆为 `Char -> Bool`，用到它们的绝大多数情况都无非就是过滤字串或类似操作。

假设我们在写个进程，它需要一个由字符和数字组成的用户名。要实现对用户名的检验，我们可以结合使用 Data.List 模块的 `all` 函数与 Data.Char 的判断函数.

```hs
ghci> all isAlphaNum "bobby283"
True
ghci> all isAlphaNum "eddy the fish!"
False
```

> all 函数取一个判断函数和一个 List 做参数，若该 List 的所有元素都符合条件，就返回 True.

也可以使用 `isSpace` 来实现 Data.List 的 `words` 函数.

```hs
ghci> words "hey guys its me"
["hey","guys","its","me"]
ghci> groupBy ((==) `on` isSpace) "hey guys its me"
["hey"," ","guys"," ","its"," ","me"]
ghci>
```

有点 `words` 的样子了。只是还有空格在里面，用 `filter` 筛掉：

```hs
ghci> filter (not . any isSpace) . groupBy ((==) `on` isSpace) $ "hey guys its me"
["hey","guys","its","me"]
```

<details><summary>代码解释</summary>

回顾基本函数与操作符：

- `isSpace`：来自 Data.Char，类型为 `Char -> Bool`，判断一个字符是否为空白字符（空格、制表符、换行等）。
- `groupBy`：来自 Data.List，类型为 `(a -> a -> Bool) -> [a] -> [[a]]`。它遍历列表，将相邻且满足谓词的元素归为同一组。
- `on`：来自 Data.Function，定义为 `on :: (b -> b -> c) -> (a -> b) -> a -> a -> c`。
  表达式 ``(==) `on` isSpace`` 等价于 `\x y -> isSpace x == isSpace y`，即比较两个字符的“空白状态”是否相同。
- `any`：来自 Data.List，类型为 `(a -> Bool) -> [a] -> Bool`，检查列表中是否存在满足谓词的元素。
- `.`（函数组合）：`(f . g) x = f (g x)`，将两个函数串联起来。
- `$`（函数应用）：低优先级右结合应用，用于避免过多的括号，例如 `f $ g x = f (g x)`。

求值过程，给定输入字符串 `"hey guys its me"`：

1. **分组**.

   相邻字符的空白状态相同则合并，最终分组为：

   ```hs
   ghci> groupBy ((==) `on` isSpace) "hey guys its me"
   ["hey"," ","guys"," ","its"," ","me"]
   ```

   每个分组要么全部由非空白字符组成，要么全部由空白字符组成。

2. **筛选**.

   `filter (not . any isSpace)` 遍历上面的分组列表，对每个分组字符串 `s` 计算 `not (any isSpace s)`：

   - 若 s 包含任何空白字符（即分组为空白串），则 `any isSpace s` 为 True，取反后为 False，该分组被丢弃。
   - 若 s 不包含空白（即纯单词），则 `any isSpace s` 为 False，取反为 True，保留。

   因此，空白分组 `" "` 被过滤掉，剩下：

   ```hs
   ["hey", "guys", "its", "me"]
   ```

</details>

## 字符分类

Data.Char 中也含有与 `Ordering` 相似的型别。Ordering 是个枚举，表示两个元素做比较的可能结果，有三个值（`LT`,`GT` 和 `EQ`）。

`GeneralCategory` 型别也是个枚举，它表示了一个字符可能所在的分类，总共有 31 个分类。而得到一个字符所在分类的主要方法就是使用 `generalCategory` 函数，型别为 `generalCategory :: Char -> GeneralCategory`：

```hs
ghci> generalCategory ' '
Space
ghci> generalCategory 'A'
UppercaseLetter
ghci> generalCategory 'a'
LowercaseLetter
ghci> generalCategory '.'
OtherPunctuation
ghci> generalCategory '9'
DecimalNumber
ghci> map generalCategory " \t\nA9?|"
[Space,Control,Control,UppercaseLetter,DecimalNumber,OtherPunctuation,MathSymbol]
```

由于 `GeneralCategory` 型别**是 `Eq` 型别类的一部分**，使用类似 `generalCategory c == Space` 的代码也是可以的.

## 字符转换函数

- `toUpper` 将一个字符转为大写字母，若该字符不是小写字母，就按原值返回. `toLower` 将一个字符转为小写字母，若该字符不是大写字母，就按原值返回.
- `toTitle` 将一个字符转为 title-case，对大多数字元而言，title-case 就是大写.
- `digitToInt` 将一个字符转为 Int 值，而这一字符必须得在 `'1'..'9'`，`'a'..'f'` 或 `'A'..'F'` 的范围之内.

  ```hs
  ghci> map digitToInt "34538"
  [3,4,5,3,8]
  ghci> map digitToInt "FF85AB"
  [15,15,8,5,10,11]
  ```

  `intToDigit` 是 `digitToInt` 的反函数。它取一个 0 到 15 的 Int 值作参数，并返回一个小写的字符.

  ```hs
  ghci> intToDigit 15
  'f'
  ghci> intToDigit 5
  '5'
  ```

- `ord` 与 `chr` 函数可以将字符与其对应的数字相互转换.

  ```hs
  ghci> ord 'a'
  97
  ghci> chr 97
  'a'
  ghci> map ord "abcdefgh"
  [97,98,99,100,101,102,103,104]
  ```

  两个字符的 `ord` 值之差就是它们在 unicode 字符表上的距离.

### 示例：实现 Caesar ciphar 加密算法

Caesar ciphar 是加密的基础算法，它将消息中的每个字符都按照特定的字母表进行替换。它的实现非常简单：

```hs
encode :: Int -> String -> String
encode shift msg =
  let ords = map ord msg
      shifted = map (+ shift) ords
  in map chr shifted
```

> 用函数组合的写法是：`map (chr . (+ shift) . ord) msg`

先将一个字串转为一组数字，然后给它加上某数，再转回去。试一下它的效果:

```hs
ghci> encode 3 "Heeeeey"
"Khhhhh|"
ghci> encode 4 "Heeeeey"
"Liiiii}"
ghci> encode 1 "abcd"
"bcde"
ghci> encode 5 "Marry Christmas! Ho ho ho!"
"Rfww~%Hmwnxyrfx&%Mt%mt%mt&"
```

不错。再简单地将它转成一组数字，减去某数后再转回来就是解密了.

```hs
decode :: Int -> String -> String
decode shift msg = encode (negate shift) msg
```

```hs
ghci> encode 3 "Im a little teapot"
"Lp#d#olwwoh#whdsrw"
ghci> decode 3 "Lp#d#olwwoh#whdsrw"
"Im a little teapot"
ghci> decode 5 . encode 5 $ "This is a sentence"
"This is a sentence"
```
