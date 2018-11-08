---
title: 深入了解JavaScript底层原理
date: 2018-11-01 15:52:50
tags: aaaaaaa
toc: true
---
[TOC]
1. 七种内置类型
2. 对象

### 1. 七种内置类型
    基本类型： null，undefined，boolean，number（浮点类型），string，symbol。
    对象：Object。
#### API：
- typeof:

```
typeof 1 // 'number'
typeof '1' // 'string'
typeof undefined // 'undefined'
typeof true // 'boolean'
typeof Symbol() // 'symbol'
typeof b // b 没有声明，但是还会显示 undefined
typeof []  // 'object'
typeof {}  // 'object
typeof null  // 'object'
typeof console.log // 'function'
```
- valueOf

    对象在转换基本类型时，首先会调用 valueOf 然后调用 toString。并且这两个方法你是可以重写的。
```
let a = {
    valueOf() {
    	return 0
    toString() {
    return '1';
  },
// Symbol.toPrimitive ，该方法在转基本类型时调用优先级最高。
  [Symbol.toPrimitive]() {
    return 2;
  }
}
1 + a // => 3
'1' + a // => '12'
```

- 比较运算符
```
如果是对象，就通过 toPrimitive 转换对象
如果是字符串，就通过 unicode 字符索引来比较
```
#### 四则运算
    只有当加法运算时，其中一方是字符串类型，就会把另一个也转为字符串类型。
    其他运算只要其中一方是数字，那么另一方就转为数字。
    并且加法运算会触发三种类型转换：将值转换为原始值，转换为数字，转换为字符串。
```
1 + '1' // '11'
2 * '2' // 4
[1, 2] + [2, 1] // '1,22,1'
// [1, 2].toString() -> '1,2'
// [2, 1].toString() -> '2,1'
// '1,2' + '2,1' = '1,22,1'

// 对于加号需要注意这个表达式 'a' + + 'b'
'a' + + 'b' // -> "aNaN"
// 因为 + 'b' -> NaN
```

#### 冷知识：
- NaN 属于 number 类型，并且 NaN 不等于自身。
- undefined 不是保留字，能够在低版本浏览器被赋值 ```let undefined = 1```

### 2. 对象
