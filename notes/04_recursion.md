# 递归

递归在 Haskell 中非常重要。命令式语言要求你提供求解的步骤，Haskell 则倾向于让你提供问题的描述。这便是 Haskell 没有 `while` 或 `for` 循环的原因，递归是我们的替代方案。

以 `maximum` 函数为例，在 Haskell 中实现它：

```hs
maximum' :: (Ord a) => [a] -> a
maximum' [] = error "maximum of empty list"
maximum' [x] = x
maximum' (x:xs)
    | x > maxTail = x
    | otherwise = maxTail
    where maxTail = maximum' xs
```

> 递归的思路：先定下一个边界条件，即处理单个元素的 List 时，回传该元素。如果该 List 的头部大于尾部的最大值，我们就可以假定较长的 List 的最大值就是它的头部。而尾部若存在比它更大的元素，它就是尾部的最大值。

如你所见，模式匹配与递归简直就是天造地设！大多数命令式语言中都没有模式匹配，于是你就得造一堆 if-else 来测试边界条件。而在这里，我们仅需要使用模式将其表示出来。

> 第一个模式说，如果该 List 为空，崩溃！就该这样，一个空 List 的最大值能是啥？我不知道。第二个模式也表示一个边缘条件，它说， 如果这个 List 仅包含单个元素，就回传该元素的值。
>
> 现在是第三个模式，执行动作的地方。 通过模式匹配，可以取得一个 List 的头部和尾部。这在使用递归处理 List 时是十分常见的。出于习惯，我们用个 where 语句来表示 maxTail 作为该 List 中尾部的最大值，然后检查头部是否大于尾部的最大值。若是，回传头部；若非，回传尾部的最大值。

改用 `max` 函数会使代码更加清晰。如果你还记得，max 函数取两个值做参数并回传其中较大的值。

```hs
maximum' :: (Ord a) => [a] -> a
maximum' [] = error "maximum of empty list"
maximum' [x] = x
maximum' (x:xs) = max x (maximum' xs)
```

## 几个递归函数的例子

### replicate函数

用递归实现 `replicate` 函数。它取一个 Int 值和一个元素做参数, 回传一个包含多个重复元素的 `List`, 如 `replicate 3 5` 回传 `[5,5,5]`.

```hs
replicate' :: (Num i, Ord i) => i -> a -> [a]
replicate' n x
    | n <= 0    = []
    | otherwise = x:replicate' (n-1) x
```

> `Num` 不是 `Ord` 的子集, 表示数字不一定得拘泥于排序, 这就是在做加减法比较时要将 Num 与 Ord 型别约束区别开来的原因.

### take函数

接下来实现 `take` 函数, 它可以从一个 List 取出一定数量的元素. 如 `take 3 [5,4,3,2,1]`, 得 `[5,4,3]`. 若要取零或负数个的话就会得到一个空 List. 同样, 若是从一个空 List中取值, 它会得到一个空 List. 注意, 这儿有两个边界条件, 写出来:

```hs
take' :: (Num i, Ord i) => i -> [a] -> [a]
take' n _
    | n <= 0   = []
take' _ []     = []
take' n (x:xs) = x : take' (n-1) xs
```

首个模式辨认若为 0 或负数, 回传空 List. 同时注意这里用了一个 guard 却没有指定 `otherwise` 部分, 这就表示 n 若大于 0, **会转入下一模式**.

第二个模式指明了若试图从一个空 List 中取值, 则回传空 List.

第三个模式将 List 分割为头部和尾部, 然后表明从一个 List 中取多个元素等同于令 x 作头部后接从尾部取 n-1 个元素所得的 List.

### reverse 函数

`reverse` 函数简单地反转一个 List, 动脑筋想一下它的边界条件! 该怎样呢? 想想...是空 List! 空 List 的反转结果还是它自己. Okay, 接下来该怎么办? 好的, 你猜的出来. 若将一个 List 分割为头部与尾部, 那它反转的结果就是反转后的尾部与头部相连所得的 List.

```hs
reverse' :: [a] -> [a]
reverse' [] = []
reverse' (x:xs) = reverse' xs ++ [x]
```

> Haskell 支持无限 List，所以我们的递归就不必添加边界条件。这样一来，它可以对某值计算个没完, 也可以产生一个无限的数据结构，如无限 List。而无限 List 的好处就在于我们可以在任意位置将它断开.

### repeat 函数

`repeat` 函数取一个元素作参数, 回传一个仅包含该元素的无限 List. 它的递归实现简单的很:

```hs
repeat' :: a -> [a]
repeat' x = x:repeat' x
```

调用 `repeat 3` 会得到一个以 3 为头部并无限数量的 3 为尾部的 List, 可以说 repeat 3 运行起来就是 `3:repeat 3`, 然后 `3:3:3:3` 等等. 若执行 `repeat 3`, 那它的运算永远都不会停止。而 `take 5 (repeat 3)` 就可以得到 5 个 3, 与 `replicate 5 3` 差不多.

### zip 函数

`zip` 取两个 List 作参数并将其捆在一起。`zip [1,2,3] [2,3]` 回传 `[(1,2),(2,3)]`, 它会把较长的 List 从中间断开, 以匹配较短的 List.

用 `zip` 处理一个 List 与空 List 又会怎样? 嗯, 会得一个空 List, 这便是我们的限制条件, 由于 `zip` 取两个参数, 所以要有两个边缘条件

```hs
zip' :: [a] -> [b] -> [(a,b)]
zip' _ [] = []
zip' [] _ = []
zip' (x:xs) (y:ys) = (x,y):zip' xs ys
```

前两个模式表示两个 List 中若存在空 List, 则回传空 List. 第三个模式表示将两个 List 捆绑的行为, 即将其头部配对并后跟捆绑的尾部.

### elem 函数

再实现一个标准库函数 -- `elem`! 它取一个元素与一个 List 作参数, 并检测该元素是否包含于此 List. 而边缘条件就与大多数情况相同, 空 List. 大家都知道空 List 中不包含任何元素, 便不必再做任何判断

```hs
elem' :: (Eq a) => a -> [a] -> Bool
elem' a [] = False
elem' a (x:xs)
    | a == x    = True
    | otherwise = a `elem'` xs
```

这很简单明了。若头部不是该元素, 就检测尾部, 若为空 List 就回传 `False`.

## 用递归实现快速排序

假定我们有一个可排序的 List, 其中元素的型别为 Ord Typeclass 的成员. 现在用快速排序算法将它排序。

> 尽管它在命令式语言中也不过 10 行, 但在 Haskell 下边要更短, 更漂亮, 俨然已经成了 Haskell 的招牌了.

```hs
quicksort :: (Ord a) => [a] -> [a]
quicksort [] = []
quicksort (x:xs) =
  let smallerSorted = quicksort [a | a <- xs, a <= x]
      biggerSorted = quicksort [a | a <- xs, a > x]
  in smallerSorted ++ [x] ++ biggerSorted
```

它的型别声明应为 `quicksort :: (Ord a) => [a] -> [a]`, 没啥奇怪的. 边界条件呢? 如料，空 List。排过序的空 List 还是空 List。

接下来便是算法的定义：排过序的 List 就是**令所有小于等于头部的元素在先**（它们已经排过了序）, 后跟大于头部的元素(它们同样已经排过了序)。 

