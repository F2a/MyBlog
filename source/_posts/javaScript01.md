---
title: JavaScript基础原理（一）
date: 2018-1-20 15:52:50
tags: JS原理
toc: true
---

> 整理自面谱 InterviewMap

## 1. 七种内置类型
    基本类型： null，undefined，boolean，number（浮点类型），string，symbol（es6）。
    对象：Object。

### 类型转换

- typeof:

``` js
typeof 1 // 'number'
typeof '1' // 'string'
typeof undefined // 'undefined'
typeof true // 'boolean'
typeof Symbol() // 'symbol'
typeof b // b 没有声明，但是还会显示 undefined
typeof []  // 'object'
typeof {}  // 'object'
typeof null  // 'object'
typeof console.log // 'function'
```

- valueOf

    对象在转换基本类型时，首先会调用 valueOf 然后调用 toString。并且这两个方法你是可以重写的。

``` js
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

### 四则运算

    只有当加法运算时，其中一方是字符串类型，就会把另一个也转为字符串类型。
    其他运算只要其中一方是数字，那么另一方就转为数字。
    并且加法运算会触发三种类型转换：将值转换为原始值，转换为数字，转换为字符串。

``` js
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

### 冷知识

- NaN 属于 number 类型，并且 NaN 不等于自身。
- undefined 不是保留字，能够在低版本浏览器被赋值 let undefined = 1

## 2. 实例对象

### new

- 在调用 new 的过程中会发生以上四件事情

``` js
// 新生成了一个对象
// 链接到原型
// 绑定 this
// 返回新对象

function new() {
    // 创建一个空的对象
    let obj = new Object()
    // 获得构造函数
    let Con = [].shift.call(arguments)
    // 链接到原型
    obj.__proto__ = Con.prototype
    // 绑定 this，执行构造函数
    let result = Con.apply(obj, arguments)
    // 确保 new 出来的是个对象
    return typeof result === 'object' ? result : obj
}
```

- 执行优先级

``` js
function Foo() {
    return this;
}
Foo.getName = function () {
    console.log('1');
};
Foo.prototype.getName = function () {
    console.log('2');
};

new Foo.getName();   // -> 1
new Foo().getName(); // -> 2

// new Foo() 的优先级大于 new Foo
```

``` js
new (Foo.getName());
(new Foo()).getName();

// 对于第一个函数来说，先执行了 Foo.getName() ，所以结果为 1；
// 对于后者来说，先执行 new Foo() 产生了一个实例，
// 然后通过原型链找到了 Foo 上的 getName 函数，所以结果为 2。
```

### this

- 通用规则
new有最高优先级，利用 call，apply，bind 改变 this，优先级仅次于 new。

``` js
function foo() {
	console.log(this.a)
}
var a = 1
foo()

var obj = {
	a: 2,
	foo: foo
}
obj.foo()

// 以上两者情况 `this` 只依赖于调用函数前的对象，优先级是第二个情况大于第一个情况

// 以下情况是优先级最高的，`this` 只会绑定在 `c` 上，不会被任何方式修改 `this` 指向
var c = new foo()
c.a = 3
console.log(c.a)

// 还有种就是利用 call，apply，bind 改变 this，这个优先级仅次于 new
```

- 箭头函数其实是没有 this 的，这个函数中的 this 只取决于他外面的第一个不是箭头函数的函数的 this。在这个例子中，因为调用 a 符合前面代码中的第一个情况，所以 this 是 window。并且 this 一旦绑定了上下文，就不会被任何代码改变。

### 冷知识

- instanceof 可以正确的判断对象的类型，因为内部机制是通过判断对象的原型链中是不是能找到类型的 prototype。

## 3. 执行上下文

1. 全局执行上下文
2. 函数执行上下文
3. eval 执行上下文

### 属性 VO & AO

变量对象 (缩写为VO)就是与执行上下文相关的对象，它存储下列内容：
1. 变量 (var, VariableDeclaration);
2. 函数声明 (FunctionDeclaration, 缩写为FD);
3. 函数的形参

- 只有全局上下文的变量对象允许通过VO的属性名称间接访问(因为在全局上下文里，全局对象自身就是一个VO(稍后会详细介绍)。在其它上下文中是不可能直接访问到VO的，因为变量对象完全是实现机制内部的事情。当我们声明一个变量或一个函数的时候，同时还用变量的名称和值，在VO里创建了一个新的属性。

激活对象是函数上下文里的激活对象AO中的内部对象，它包括下列属性：
1. callee — 指向当前函数的引用；
2. length —真正传递的参数的个数；
3. properties-indexes(字符串类型的整数)

- 属性的值就是函数的参数值(按参数列表从左到右排列)。 properties-indexes内部元素的个数等于arguments.length. properties-indexes 的值和实际传递进来的参数之间是共享的。(译者注：共享与不共享的区别可以对比理解为引用传递与值传递的区别)

### 属性 this&作用域链

``` js
b() // call b
console.log(a) // undefined

var a = 'Hello world'

function b() {
	console.log('call b')
}
```

- 以上众所周知因为函数和变量提升的原因。通常提升的解释是说将声明的代码移动到了顶部。但是更准确的解释应该是：在生成执行上下文时，会有两个阶段。第一个阶段是创建的阶段（具体步骤是创建 VO），JS解释器会找出需要提升的变量和函数，并且给他们提前在内存中开辟好空间，函数的话会将整个函数存入内存中，变量只声明并且赋值为 undefined，所以在第二个阶段，也就是代码执行阶段，我们可以直接提前使用。

- 在提升的过程中，相同的函数会覆盖上一个函数，并且函数优先于变量提升

``` js
b() // call b second

function b() {
	console.log('call b fist')
}
function b() {
	console.log('call b second')
}
var b = 'Hello world'
```

- 对于非匿名的立即执行函数需要注意以下一点

``` js
var foo = 1
(function foo() {
    foo = 10
    console.log(foo)
}()) // -> ƒ foo() { foo = 10 ; console.log(foo) }  打印出立即执行函数自身
// 内部独立作用域，不会影响外部的值
```

### 一个面试题

循环中使用闭包解决 var 定义函数的问题

``` js
for ( var i=1; i<=5; i++) {
	setTimeout( function timer() {
		console.log( i );
	}, i*1000 );
}
// 因为 setTimeout 是个异步函数，所有会先把循环全部执行完毕，这时候 i 就是 6 了，所以会输出一堆 6。
```

解决办法

第一种使用闭包

``` js
for (var i = 1; i <= 5; i++) {
  (function(j) {
    setTimeout(function timer() {
      console.log(j);
    }, j * 1000);
  })(i);
}
```

第二种就是使用 setTimeout 的第三个参数

``` js
for ( var i=1; i<=5; i++) {
	setTimeout( function timer(j) {
		console.log( j );
	}, i*1000, i);
}
// 第三个参数及以后的参数都可以作为func函数的参数，例：
function a(x, y) {
    console.log(x, y) // 2 3
}
setTimeout(a, 1000, 2, 3)
```

第三种就是使用 let 定义 i 了

``` js
for ( let i=1; i<=5; i++) {
	setTimeout( function timer() {
		console.log( i );
	}, i*1000 );
}
```

因为对于 let 来说，他会创建一个块级作用域，相当于

``` js
{ // 形成块级作用域
  let i = 0
  {
    let ii = i
    setTimeout( function timer() {
        console.log( i );
    }, i*1000 );
  }
  i++
  {
    let ii = i
  }
  i++
  {
    let ii = i
  }
  ...
}
```

## 4. 深浅拷贝

### 浅拷贝

- 通过 Object.assign

``` js
let a = {
    age: 1
}
let b = Object.assign({}, a)
a.age = 2
console.log(b.age) // 1
```

- 通过 展开运算符（…）

``` js
let a = {
    age: 1
}
let b = {...a}
a.age = 2
console.log(b.age) // 1
```

- 弊端：浅拷贝只解决了第一层的问题。如果接下去的值中还有对象的话，那么就又回到刚开始的话题了，两者享有相同的引用。要解决这个问题，我们需要引入深拷贝。

### 深拷贝

- 通过 JSON.parse(JSON.stringify(object))

``` js
let a = {
    age: 1,
    jobs: {
        first: 'FE'
    }
}
let b = JSON.parse(JSON.stringify(a))
a.jobs.first = 'native'
console.log(b.jobs.first) // FE
```

该方法也是有局限性的：会忽略 undefined，忽略函数，不能解决循环引用的对象

``` js
let obj = {
  a: 1,
  b: {
    c: 2,
    d: 3,
  },
}
obj.c = obj.b
obj.e = obj.a
obj.b.c = obj.c
obj.b.d = obj.b
obj.b.e = obj.b.c
let newObj = JSON.parse(JSON.stringify(obj)) // 会报错
console.log(newObj)
```

- 如果你的数据中含有以上三种情况下，通过  lodash 的深拷贝函数，或者使用 MessageChannel

``` js
function structuralClone(obj) {
  return new Promise(resolve => {
    const {port1, port2} = new MessageChannel();
    port2.onmessage = ev => resolve(ev.data);
    port1.postMessage(obj);
  });
}

var obj = {a: 1, b: {
    c: b
}}
// 注意该方法是异步的
// 可以处理 undefined 和循环引用对象
const clone = await structuralClone(obj);
```
