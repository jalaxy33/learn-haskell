# Data.Set 模块

Data.Set 模块提供了对数学中集合的处理。集合既像 List 也像 Map：它里面的**每个元素都是唯一的**，且内部的数据由一棵树来组织(这和 Data.Map 模块的 map 很像)，**必须得是可排序的**。

同样是插入，删除，判断从属关系之类的操作，使用集合要比 List 快得多。对一个集合而言，最常见的操作莫过于并集，判断从属或是将集合转为 List.

由于 Data.Set 模块与 Prelude 模块和 Data.List 模块中存在大量的命名冲突，所以我们使用 `qualified import`：

```hs
import qualified Data.Set as Set
```

## 函数

假定我们有两个字串，要找出同时存在于两个字串的字符：

```hs
text1 = "I just had an anime dream. Anime... Reality... Are they so different?"
text2 = "The old man left his garbage can out and now his trash is all over my lawn!"
```

### fromList

`fromList` 函数同你想的一样，它取一个 List 作参数并将其转为一个集合

```hs
ghci> let set1 = Set.fromList text1
ghci> let set2 = Set.fromList text2
ghci> set1
fromList " .?AIRadefhijlmnorstuy"
ghci> set2
fromList " !Tabcdefghilmnorstuvwy"
```

如你所见，所有的元素都被排了序。而且每个元素都是唯一的。

### 交集，差集，并集

`intersection` 取交集，返回共同包含的元素:

```hs
ghci> Set.intersection set1 set2
fromList " adefhilmnorstuy"
```

`difference` 函数可以得到存在于第一个集合但不在第二个集合的元素

```hs
ghci> Set.difference set1 set2
fromList ".?AIRj"
ghci> Set.difference set2 set1
fromList "!Tbcgvw"
```

使用 `union` 得到两个集合的并集

```hs
ghci> Set.union set1 set2
fromList " !.?AIRTabcdefghijlmnorstuvwy"
```

### 常用函数

`null`，`size`，`member`，`empty`，`singleton`，`insert`，`delete` 这几个函数就跟你想的差不多

```hs
ghci> Set.null Set.empty
True
ghci> Set.null $ Set.fromList [3,4,5,5,4,3]
False
ghci> Set.size $ Set.fromList [3,4,5,3,4,5]
3
ghci> Set.singleton 9
fromList [9]
ghci> Set.insert 4 $ Set.fromList [9,3,8,1]
fromList [1,3,4,8,9]
ghci> Set.insert 8 $ Set.fromList [5..10]
fromList [5,6,7,8,9,10]
ghci> Set.delete 4 $ Set.fromList [3,4,5,4,3,4,5]
fromList [3,5]
```

### 判断子集

判断子集与真子集：

- `isSubsetOf` 判断子集：如果集合 A 中的元素都属于集合 B，那么 A 就是 B 的子集
- `isProperSubsetOf` 判断真子集：如果 A 中的元素都属于 B 且 B 的元素比 A 多，那 A 就是 B 的真子集

```hs
ghci> Set.fromList [2,3,4] `Set.isSubsetOf` Set.fromList [1,2,3,4,5]
True
ghci> Set.fromList [1,2,3,4,5] `Set.isSubsetOf` Set.fromList [1,2,3,4,5]
True
ghci> Set.fromList [1,2,3,4,5] `Set.isProperSubsetOf` Set.fromList [1,2,3,4,5]
False
ghci> Set.fromList [2,3,4,8] `Set.isSubsetOf` Set.fromList [1,2,3,4,5]
False
```

### map 和 filter

对集合也可以执行 `map` 和 `filter`:

```hs
ghci> Set.filter odd $ Set.fromList [3,4,5,6,7,2,3,4]
fromList [3,5,7]
ghci> Set.map (+1) $ Set.fromList [3,4,5,6,7,2,3,4]
fromList [3,4,5,6,7,8]
```

### toList

集合有一常见用途，那就是先 `fromList` 删掉重复元素后再 `toList` 转回去。

尽管 Data.List 模块的 `nub` 函数完全可以完成这一工作，但在**对付大 List 时**则会明显的力不从心。使用集合则会快很多。

> nub 函数只需 List 中的元素属于 `Eq` 型别类就行了，而若要使用集合，它**必须得属于 `Ord` 型别类**

```hs
ghci> let setNub xs = Set.toList $ Set.fromList xs
ghci> setNub "HEY WHATS CRACKALACKIN"
" ACEHIKLNRSTWY"
ghci> nub "HEY WHATS CRACKALACKIN"
"HEY WATSCRKLIN"
```

区别：

- 在处理较大的 List 时，`setNub` 要比 `nub` 快，
- 但也可以从中看出，`nub` 保留了 List 中元素的原有顺序，而 `setNub` 不。
