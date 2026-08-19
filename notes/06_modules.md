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
- [Data.Char](./06_modules/Data-Char.md)
- [Data.Map](./06_modules/Data-Map.md)
- [Data.Set](./06_modules/Data-Set.md)

## 构建自己的模块

在编程时，将功能相近的函数和型别至于同一模块中会是个很好的习惯。这样一来，你就可以轻松地一个 `import` 来重用其中的函数.

### 构建单文件模块

接下来我们将构造一个由计算机几何图形体积和面积组成的模块，先从新建一个 `Geometry.hs` 的文件开始.

1. 定义模块

   在模块的开头定义模块的名称，如果文件名叫做 `Geometry.hs` 那它的名字就得是 `Geometry`。在声明出它含有的函数名之后就可以编写函数的实现：

   ```hs
   module Geometry
   ( sphereVolume
   , sphereArea
   , cubeVolume
   , cubeArea
   , cuboidArea
   , cuboidVolume
   ) where
   ```

2. 继续定义函数体:

   ```hs
   module Geometry
   ( sphereVolume
   , sphereArea
   , cubeVolume
   , cubeArea
   , cuboidArea
   , cuboidVolume
   ) where

   sphereVolume :: Float -> Float
   sphereVolume radius = (4.0 / 3.0) * pi * (radius ^ 3)

   sphereArea :: Float -> Float
   sphereArea radius = 4 * pi * (radius ^ 2)

   cubeVolume :: Float -> Float
   cubeVolume side = cuboidVolume side side side

   cubeArea :: Float -> Float
   cubeArea side = cuboidArea side side side

   cuboidVolume :: Float -> Float -> Float -> Float
   cuboidVolume a b c = rectangleArea a b * c

   cuboidArea :: Float -> Float -> Float -> Float
   cuboidArea a b c = rectangleArea a b * 2 + rectangleArea a c * 2 + rectangleArea c b * 2

   rectangleArea :: Float -> Float -> Float
   rectangleArea a b = a * b
   ```

要使用我们的模块，只需:

```hs
import Geometry
```

注意此时 `Geometry.hs` 在用到它的进程文件的同一目录之下。

> 如果要在 gchi 中调用，先 `:l Geometry` 再 `import Geometry`

### 构建包含子模块的模块

模块也可以按照分层的结构来组织，每个模块都可以含有多个子模块。而子模块还可以有自己的子模块。我们可以把 `Geometry` 分成三个子模块，而一个模块对应各自的图形对象.

建立一个 `Geometry` 文件夹，注意**首字母要大写**，在里面新建三个文件

- Sphere.hs
  ```hs
  module Geometry.Sphere
  ( volume
  , area
  ) where

  volume :: Float -> Float
  volume radius = (4.0 / 3.0) * pi * (radius ^ 3)

  area :: Float -> Float
  area radius = 4 * pi * (radius ^ 2)
  ```
- Cuboid.hs

  ```hs
  module Geometry.Cuboid
  ( volume
  , area
  ) where

  volume :: Float -> Float -> Float -> Float
  volume a b c = rectangleArea a b * c

  area :: Float -> Float -> Float -> Float
  area a b c = rectangleArea a b * 2 + rectangleArea a c * 2 + rectangleArea c b * 2

  rectangleArea :: Float -> Float -> Float
  rectangleArea a b = a * b
  ```

- Cube.hs

  ```hs
  module Geometry.Cube
  ( volume
  , area
  ) where

  import qualified Geometry.Cuboid as Cuboid

  volume :: Float -> Float
  volume side = Cuboid.volume side side side

  area :: Float -> Float
  area side = Cuboid.area side side side
  ```

一般来说，可以这么导入子模块：

```hs
import Geometry.Sphere
```

注意下，在三个模块中我们定义了许多名称相同的函数，因为所在模块不同，所以不会产生命名冲突。若要跨模块使用重名函数，就必须要 `qualified import`：

```hs
import qualified Geometry.Sphere as Sphere
import qualified Geometry.Cuboid as Cuboid
import qualified Geometry.Cube as Cube
```

然后就可以调用 `Sphere.area`，`Sphere.volume`，`Cuboid.area` 了，而每个函数都只计算其对应物体的面积和体积.

> 在 gchi 中调用：先 `:l Geometry/Sphere.hs`，然后再 `import qualified Geometry.Sphere as Sphere`
