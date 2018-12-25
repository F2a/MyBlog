---
title: '解析 Array.apply(null, { length: 20 })'
date: 2018-12-17 12:02:07
tags: JS原理
toc: true
---

# 前言

今天在群里看到有人贴了一段代码：

```js
render: function (createElement) {
  return createElement('div',
    Array.apply(null, { length: 20 }).map(function () {
      return createElement('p', 'hi')
    })
  )
```

其中 `Array.apply(null, { length: 20 })` 一句让人费解。于是挖一下这段代码想实现功能，以及相关的原理。

# 数组的元素的初始化

在chrome控制台中打印 `Array.apply(null, { length: 20 })` ，输入值是长度为20的空数组；那为什么不直接 `Array(20)`呢?这其中就涉及到了数组的初始化。

```js
var a = Array(20); // 等价于var a = new Array(20);
```

***注意该数组的元素并没有被初始化***

```js
console.log(0 in a); // false
console.log(1 in a); // false, 因为数组下标还未初始化
console.log(a[0]);   // undefined, 因为数组下标0还未初始化,访问不存在的属性返回undefined
```

# apply函数与鸭式辨型

apply函数的第二个参数除了可以是数组外，还可以是类数组对象（即 鸭式辨型）。

```js
console.log(a[0]); // undefined
// 可以转成真正的数组
var a = Array.prototype.slice.call({length: 1});
console.log(Array.isArray(a)) // true
```

`鸭式辨型来自于James Whitecomb Riley的名言："像鸭子一样走路并且嘎嘎叫的就叫鸭子。"通过制定规则来判定对象是否正确`

James Whitecomb Riley 判定鸭子为包含属性：像鸭子一样走路 & 嘎嘎叫。

类数组对象的判定：即包含length属性，且length属性值是个数字的对象。对象`{length: 20}`就是一个类数组对象。

再回头看看 `Array.apply(null, { length: 20 })` 他就等价于：

（方便书写用 `Array.apply(null, { length: 2 })` ）

```js
// 1、{length: 2}作为Array.apply第二个参数等同于[undefined, undefined]作为Array.apply第二个参数
Array.apply(null, [undefined, undefined]);
// 2、apply方法的执行结果
Array(undefined, undefined);
// 3、Array方法直接调用和new方式调用等价
new Array(undefined, undefined);
```

所以 `Array.apply(null, { length: 2 })` 输入一个长度为2，且每个元素值都被初赋值为undefined的数组。（注意直接`Array(20)`元素是没有初始化。）

***为什么要初始化？***

重新回顾下代码：

```js
render: function (createElement) {
  return createElement('div',
    Array.apply(null, { length: 20 }).map(function () {
      return createElement('p', 'hi')
    })
  )
```

即是因为map函数并不会遍历数组中没有初始化或者被delete的元素，所以...

巩固一下，看一道面试题，下面代码输出什么

```
var ary = Array(3);
ary[0]=2
ary.map(function(elem) { return '1'; });
// 答案在底部
```

# 补充

- 与`map`有相同限制还有`forEach, reduce`方法
- 几乎所有的数组方法都适用于类数组对象（鸭式辨型）

例子`pop`:

```js
var o = {0:"cat", 1:"dog", 2:"cow", 3:"chicken", 4:"mouse", length:5}
var item = Array.prototype.pop.call(o);
console.log(o); // Object {0: "cat", 1: "dog", 2: "cow", 3: "chicken", length: 4}
console.log(item); // mouse
```

但如果类数组对象不具有length属性，那么该对象将被创建length属性，length值为0。如下：

```js
var o = {0:"cat", 1:"dog", 2:"cow", 3:"chicken", 4:"mouse"}
var item = Array.prototype.pop.call(o);
console.log(array); // Object {0: "cat", 1: "dog", 2: "cow", 3: "chicken", 4: "mouse", length: 0}
console.log(item); // undefined
```

- 其他等价的写法

```js
Array.apply(null, Array(20)); // 第二个参数用Array(20)代替{length: 20}

// ES6的API
Array.from({length: 20})

Array(20).fill(null)
```
- `Array(2) 等价于[,,]，不等价于[undefined, undefined]`

*答案*

array 上的操作会跳过未初始化的'坑'。
所以答案是 ["1", undefined × 2]

