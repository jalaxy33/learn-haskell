# 模块

检索 Haskell 函数和模块可以用这个网站： [Hoogle](https://hoogle.haskell.org/)

## 加载模块

在 Haskell中，装载模块的语法为 `import`，这必须得在函数的定义之前，所以一般都是将它置于代码的顶部。一段代码中可以装载很多模块，只要将 `import` 语句分行写开即可。

当模块被加载后，其中的所有函数都进入了全局命名空间。

```hs
import Data.List

numUniques :: (Eq a) => [a] -> Int
numUniques = length . nub
```

<details><summary>代码解释</summary>

`Data.List` 模块包含一个 `nub` 函数，可以筛掉一个 List 中的所有重复元素。用点号将 `length` 和 `nub` 组合: `length . nub`，即可得到一个与 `(\xs -> length (nub xs))` 等价的函数。

</details>

### 在 ghci 中加载模块

也可以在 ghci 中装载模块，若要调用 `Data.List` 中的函数，就这样:

```hs
ghci> :m Data.List
```

若要在 ghci 中装载多个模块，不必多次 `:m` 命令，一下就可以全部搞定:

```hs
ghci> :m Data.List Data.Map Data.Set
```

### 只加载或排除某些函数

如果只用得到某些函数：

```hs
import Data.List (nub, sort)
```

如果想排除一些函数，用 `hiding` 关键字：

```hs
import Data.List hiding (nub)
```

### 避免命名冲突

避免命名冲突的方法，就是用 `qualified import`：

```hs
import qualified Data.Map
```

之后调用 `Data.Map` 中的 `filter` 函数，必须写全称：`Data.Map.filter`。

不过每次都这么写就太烦人了，可以用 `as` 给模块起个别名：

```hs
import qualified Data.Map as M
```

再调用 `filter` 的话仅需 `M.filter` 就行了。

## 常用模块

- [Data.List](./06_modules/Data-List.md)


