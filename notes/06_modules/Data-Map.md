# Data.Map 模块

关联列表(也叫做字典)是按照键值对排列而没有特定顺序的一种 List。例如，我们用关联列表保存电话号码，号码就是值，人名就是键。我们并不关心它们的存储顺序，只要能按人名得到正确的号码就好.

在 Haskell 中表示关联列表的最简单方法就是弄一个**二元组的 List**，而这二元组就首项为键，后项为值。如下便是个表示电话号码的关联列表:

```hs
phoneBook = [("betty","555-2938") ,
             ("bonnie","452-2928") ,
             ("patsy","493-2928") ,
             ("lucille","205-2928") ,
             ("wendy","939-8282") ,
             ("penny","853-2492") ]
```

不理这貌似古怪的缩进，它就是一组二元组的 List 而已。

## 引子：实现关联列表的按键索值

话说对关联列表最常见的操作就是按键索值，我们就写个函数来实现它。

```hs
findKey :: (Eq k) => k -> [(k,v)] -> v
findKey key xs = snd . head . filter (\(k,v) -> key == k) $ xs
```

这个函数取一个键和 List 做参数，过滤这一 List 仅保留键匹配的项，并返回首个键值对。

但若该关联列表中不存在这个键那会怎样? 哼，那就会在试图从空 List 中取 head 时引发一个运行时错误。应该用 Maybe 型别。如果没找到相应的键，就返回 `Nothing`。而找到了就返回 `Just something`。而这 something 就是键对应的值。

```hs
findKey :: (Eq k) => k -> [(k,v)] -> Maybe v
findKey key [] = Nothing
findKey key ((k,v):xs) =
     if key == k then
         Just v
     else
         findKey key xs
```

函数取一个可判断相等性的键和一个关联列表做参数，可能 (Maybe) 得到一个值。听起来不错.这便是个标准的处理 List 的递归函数，可以用 fold 模式处理：

```hs
findKey :: (Eq k) => k -> [(k,v)] -> Maybe v
findKey key = foldr (\(k,v) acc -> if key == k then Just v else acc) Nothing
```

> _Note_: 通常，使用 `fold` 来替代类似的递归函数会更好些。用 `fold` 的代码让人一目了然，而看明白递归则得多花点脑子。

```hs
ghci> findKey "penny" phoneBook
Just "853-2492"
ghci> findKey "betty" phoneBook
Just "555-2938"
ghci> findKey "wilma" phoneBook
Nothing
```

这个就是 Data.List 中的 `lookup` 函数的实现方式。

<details><summary>代码解释</summary>

- 函数体完整的写法是：

  ```hs
  findKey key list = foldr (\(k,v) acc -> if key == k then Just v else acc) Nothing list
  ```

  由于 foldr 的最后一个参数就是列表，可以省略。

- `foldr` 从列表的右端开始折叠，直到遇到终止条件（返回 `Just v`）或遍历完所有元素。

  - 对于每个元素 `(k,v)`，聚合函数先比较 `key` 与当前键 `k`。
  - 若相等，直接返回 `Just v`，忽略剩余的累积值和后续列表。
  - 若不相等，则返回当前的累积值 `acc`，即继续处理左侧元素的结果。

- `foldr` 有**短路特性**：当聚合函数在某个元素处直接返回 `Just v` 时，foldr 不需要再对左侧剩余部分进行求值。

  这就是**短路查找**：一旦找到匹配键，就立即停止，效率高于遍历整个列表。

  > **为什么不用 `foldl`**—— `foldl` 不具备短路特性，必须遍历全部元素。

</details>

## 正式介绍 Data.Map 模块

从现在开始，我们扔掉关联列表，改用 `map`。Data.Map 模块提供了一组好用的函数。

由于 Data.Map 中的一些函数与 Prelude 和 Data.List 模块存在命名冲突，所以我们使用 `qualified import`：

```hs
import qualified Data.Map as Map
```

Data.Map 里面有不少函数，[这个文档](https://hackage.haskell.org/package/containers-0.3.0.0/docs/Data-Map.html)中的列表很全。

### fromList

`fromList` 取一个关联列表，返回一个与之等价的 Map。若其中存在重复的键，就**将其忽略**。

```hs
ghci> Map.fromList [("betty","555-2938"),("bonnie","452-2928"),("lucille","205-2928")]
fromList [("betty","555-2938"),("bonnie","452-2928"),("lucille","205-2928")]
ghci> Map.fromList [(1,2),(3,4),(3,2),(5,5)]
fromList [(1,2),(3,2),(5,5)]
```

其型别声明如下：

```hs
Map.fromList :: (Ord k) => [(k,v)] -> Map.Map k v
```

这表示它取一组键值对的 List，并返回一个将 k 映射为 v 的 `map`。

注意一下，当使用普通的关联列表时，只需要键的可判断相等性就行了。而在这里，它还**必须得是可排序的**。这在 Data.Map 模块中是强制的。因为它会按照某顺序将其组织在一棵树中。

> 在处理键值对时，只要键的型别属于 Ord 型别类，就应该尽量使用 Data.Map.

### empty

`empty` 返回一个空 map.

```hs
ghci> Map.empty
fromList []
```

### insert

`insert` 取一个键，一个值和一个 map 做参数，给这个 map 插入新的键值对，并返回一个新的 map。

```hs
ghci> Map.empty
fromList []
ghci> Map.insert 3 100 Map.empty
fromList [(3,100)]
ghci> Map.insert 5 600 (Map.insert 4 200 ( Map.insert 3 100  Map.empty))
fromList [(3,100),(4,200),(5,600)]
ghci> Map.insert 5 600 . Map.insert 4 200 . Map.insert 3 100 $ Map.empty
fromList [(3,100),(4,200),(5,600)]
```

通过 `empty`，`insert` 与 `fold`，我们可以编写出自己的 `fromList`。

```hs
fromList' :: (Ord k) => [(k,v)] -> Map.Map k v
fromList' = foldr (\(k,v) acc -> Map.insert k v acc) Map.empty
```

### null

`null` 检查一个 map 是否为空.

```hs
ghci> Map.null Map.empty
True
ghci> Map.null $ Map.fromList [(2,3),(5,5)]
False
```

### size

`size` 返回一个 map 的大小。

```hs
ghci> Map.size Map.empty
0
ghci> Map.size $ Map.fromList [(2,4),(3,3),(4,2),(5,4),(6,4)]
5
```

### singleton

`singleton` 取一个键值对做参数,并返回一个只含有一个映射的 map.

```hs
ghci> Map.singleton 3 9
fromList [(3,9)]
ghci> Map.insert 5 9 $ Map.singleton 3 9
fromList [(3,9),(5,9)]
```

### lookup

`lookup` 与 Data.List 的 `lookup` 很像,只是它的作用对象是 map，如果它找到键对应的值。就返回 `Just something`，否则返回 `Nothing`。

### member

`member` 是个判断函数，它取一个键与 map 做参数，并返回该键是否存在于该 map。

```hs
ghci> Map.member 3 $ Map.fromList [(3,6),(4,3),(6,9)]
True
ghci> Map.member 3 $ Map.fromList [(2,5),(4,5)]
False
```

### map 和 filter

`map` 与 `filter` 与其对应的 List 版本很相似:

```hs
ghci> Map.map (*100) $ Map.fromList [(1,1),(2,4),(3,9)]
fromList [(1,100),(2,400),(3,900)]
ghci> Map.filter isUpper $ Map.fromList [(1,'a'),(2,'A'),(3,'b'),(4,'B')]
fromList [(2,'A'),(4,'B')]
```

### toList

`toList` 是 `fromList` 的反函数。

```hs
ghci> Map.toList . Map.insert 9 2 $ Map.singleton 4 3
[(4,3),(9,2)]
```

### keys 和 elems

`keys` 与 `elems` 各自返回一组由键或值组成的 List。

- `keys` 与 `map fst . Map.toList` 等价
- `elems` 与 `map snd . Map.toList` 等价

### fromListWith

`fromListWith` 是个很酷的小函数，它与 `fromList` 很像，只是它**不会直接忽略掉重复键**，而是交给一个函数来处理它们。

假设一个姑娘可以有多个号码，而我们有个像这样的关联列表:

```hs
phoneBook =
    [("betty","555-2938")
    ,("betty","342-2492")
    ,("bonnie","452-2928")
    ,("patsy","493-2928")
    ,("patsy","943-2929")
    ,("patsy","827-9162")
    ,("lucille","205-2928")
    ,("wendy","939-8282")
    ,("penny","853-2492")
    ,("penny","555-2111")
    ]
```

如果用 `fromList` 来生成 map，我们会丢掉许多号码! 如下才是正确的做法:

```hs
phoneBookToMap :: (Ord k) => [(k, String)] -> Map.Map k String
phoneBookToMap xs = Map.fromListWith (\number1 number2 -> number1 ++ ", " ++ number2) xs
```

```hs
ghci> Map.lookup "patsy" $ phoneBookToMap phoneBook
"827-9162, 943-2929, 493-2928"
ghci> Map.lookup "wendy" $ phoneBookToMap phoneBook
"939-8282"
ghci> Map.lookup "betty" $ phoneBookToMap phoneBook
"342-2492,555-2938"
```

一旦出现重复键，这个函数会将不同的值组在一起，同样，也可以缺省地将每个值放到一个单元素的 List 中，再用 `++` 将他们都连接在一起。

```hs
phoneBookToMap :: (Ord k) => [(k,a)] -> Map.Map k [a]
phoneBookToMap xs = Map.fromListWith (++) $ map (\(k,v) -> (k,[v])) xs
```

```hs
ghci> Map.lookup "patsy" $ phoneBookToMap phoneBook
["827-9162","943-2929","493-2928"]
```

很简洁! 它还有别的玩法，例如在遇到重复元素时，单选最大的那个值.

```hs
ghci> Map.fromListWith max [(2,3),(2,5),(2,100),(3,29),(3,22),(3,11),(4,22),(4,15)]
fromList [(2,100),(3,29),(4,22)]
```

或是将相同键的值都加在一起.

```hs
ghci> Map.fromListWith (+) [(2,3),(2,5),(2,100),(3,29),(3,22),(3,11),(4,22),(4,15)]
fromList [(2,108),(3,62),(4,37)]
```

### insertWith

`insertWith` 之于 `insert`，恰如 `fromListWith` 之于 `fromList`。它会将一个键值对插入一个 map 之中，而该 map 若已经包含这个键，就问问这个函数该怎么办。

```hs
ghci> Map.insertWith (+) 3 100 $ Map.fromList [(3,4),(5,103),(6,339)]
fromList [(3,104),(5,103),(6,339)]
```
