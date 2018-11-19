---
title: 初识前端模块化
date: 2018-10-01 16:12:20
tags: 架构设计
toc: true
---

### 1. ES6的模块功能

有 Babel 的情况下，我们可以直接使用 ES6 的模块化。
主要由两个命令构成：export和import。

#### export

##### 正确的写法

```
// profile.js
export var firstName = 'Michael';
export var lastName = 'Jackson';
export var year = 1958;
```

```
// profile.js
var firstName = 'Michael';
var lastName = 'Jackson';
var year = 1958;

export {firstName, lastName, year};
```

```
export function multiply(x, y) {
  return x * y;
};
// 对外输出一个函数multiply。
```

##### 错误的写法

export命令规定的是对外的接口，必须与模块内部的变量建立一一对应关系。

```
// 报错
export 1;

// 报错
var m = 1;
export m;

// 没有提供对外的接口。第一种写法直接输出 1，第二种写法通过变量m，还是直接输出 1。1只是一个值，不是接口。正确的写法是下面这样。

// 写法一
export var m = 1;

// 写法二
var m = 1;
export {m};

// 写法三
var n = 1;
export {n as m};

// function和class的输出，也必须遵守这样的写法。

// 报错
function f() {}
export f;

// 正确
export function f() {};

// 正确
function f() {}
export {f};
```

export命令可以出现在模块的任何位置，只要处于模块顶层就可以。如果处于块级作用域内，就会报错

```
function foo() {
  export default 'bar' // SyntaxError 报错
}
foo()
```

export语句输出的接口，与其对应的值是动态绑定关系，即通过该接口，可以取到模块内部实时的值。

```
export var foo = 'bar';
setTimeout(() => foo = 'baz', 500);
// 上面代码输出变量foo，值为bar，500 毫秒之后变成baz。
```

##### export default

1. 为了给用户提供方便，让他们不用阅读文档就能加载模块，就要用到export default命令，为模块指定默认输出。
2. 一个模块只能有一个默认输出，因此export default命令只能使用一次。
3. export default也可以用来输出类。

```
// export-default.js
export default function () {
  console.log('foo');
}

// 或者写成
function foo() {
  console.log('foo');
}
export default foo;

// 上面代码是一个模块文件export-default.js，它的默认输出是一个函数。
// 其他模块加载该模块时，import命令可以为该匿名函数指定任意名字。

// import-default.js
import customName from './export-default';
customName(); // 'foo'
// 注意的是，这时import命令后面，不使用大括号。
```

下面的写法是有效的。

```
// modules.js
function add(x, y) {
  return x * y;
}
export {add as default};
// 等同于
// export default add;

// app.js
import { default as foo } from 'modules';
// 等同于
// import foo from 'modules';

// 如果想在一条import语句中，同时输入默认方法和其他接口，可以写成下面这样。
import _, { each, forEach } from 'lodash';
```

##### 重命名 as

```
function v1() { ... }
function v2() { ... }

export {
  v1 as streamV1,
  v2 as streamV2,
  v2 as streamLatestVersion
};
```

#### import

使用export命令定义了模块的对外接口以后，其他 JS 文件就可以通过import命令加载这个模块。

##### 正确的写法

import命令接受一对大括号，里面指定要从其他模块导入的变量名。大括号里面的变量名，必须与被导入模块（profile.js）对外接口的名称相同。

```
// main.js
import {firstName, lastName, year} from './profile.js';

function setName(element) {
  element.textContent = firstName + ' ' + lastName;
}
```

import后面的from指定模块文件的位置，可以是相对路径，也可以是绝对路径，.js后缀可以省略。如果只是模块名，不带有路径，那么必须有配置文件，告诉 JavaScript 引擎该模块的位置。

```
import {myMethod} from 'util';
```

import命令具有提升效果，会提升到整个模块的头部。import命令是编译阶段执行的，在代码运行之前。

```
foo();

import { foo } from 'my_module';
```

import语句会执行所加载的模块
```
// 仅仅执行lodash模块，但是不输入任何值。
import 'lodash';

// 下面代码加载了两次lodash，但是只会执行一次。
import 'lodash';
import 'lodash';
```

```
import { foo } from 'my_module';
import { bar } from 'my_module';

// 等同于
import { foo, bar } from 'my_module';
```

##### 错误的写法

import是静态执行，所以不能使用表达式和变量

```
// 报错
import { 'f' + 'oo' } from 'my_module';

// 报错
let module = 'my_module';
import { foo } from module;

// 报错
if (x === 1) {
  import { foo } from 'module1';
} else {
  import { foo } from 'module2';
}
```

import命令输入的变量都是只读的，因为它的本质是输入接口。也就是说，不允许在加载模块的脚本里面，改写接口。

```
import {a} from './xxx.js'

a = {}; // Syntax Error : 'a' is read-only;
```

```
import {a} from './xxx.js'

a.foo = 'hello'; // 合法操作

//a的属性可以成功改写，并且其他模块也可以读到改写后的值。不过，这种写法很难查错，建议凡是输入的变量，都当作完全只读，轻易不要改变它的属性。
```

##### 整体加载

用星号（*）指定一个对象，所有输出值都加载在这个对象上面。

```
// circle.js

export function area(radius) {
  return Math.PI * radius * radius;
}

export function circumference(radius) {
  return 2 * Math.PI * radius;
}
```

```
import { area, circumference } from './circle';
console.log('圆面积：' + area(4));
console.log('圆周长：' + circumference(14));
// 同等于
import * as circle from './circle';
console.log('圆面积：' + circle.area(4));
console.log('圆周长：' + circle.circumference(14));
```

模块整体加载所在的那个对象（上例是circle），应该是可以静态分析的，所以不允许运行时改变

```
import * as circle from './circle';

// 下面两行都是不允许的
circle.foo = 'hello';
circle.area = function () {};
```

##### 动态加载

import和export命令只能在模块的顶层

```
// 报错
if (x === 2) {
  import MyModual from './myModual';
}

// 引擎处理import语句是在编译时，这时不会去分析或执行if语句，所以import语句放在if代码块之中毫无意义，因此会报句法错误，而不是执行时错误
```

因此，有一个提案，建议引入import()函数，完成动态加载。

```
const main = document.querySelector('main');

import(`./section-modules/${someVariable}.js`)
  .then(module => {
    module.loadPageInto(main);
  })
  .catch(err => {
    main.textContent = err.message;
  });
```

import()函数可以用在任何地方，不仅仅是模块，非模块的脚本也可以使用。它是运行时执行，也就是说，什么时候运行到这一句，就会加载指定的模块。另外，import()函数与所加载的模块没有静态连接关系，这点也是与import语句不相同。import()类似于 Node 的require方法，区别主要是前者是异步加载，后者是同步加载。

```
// 按需加载。
button.addEventListener('click', event => {
  import('./dialogBox.js')
  .then(dialogBox => {
    dialogBox.open();
  })
  .catch(error => {
    /* Error handling */
  })
});

// 条件加载。
if (condition) {
  import('moduleA').then(...);
} else {
  import('moduleB').then(...);
}

// 动态的模块路径
// import()允许模块路径动态生成。
import(f())
.then(...);
```

```
// default输出接口，可以用参数直接获得。
import('./myModule.js')
.then(myModule => {
  console.log(myModule.default);
});

// 上面的代码也可以使用具名输入的形式。
import('./myModule.js')
.then(({default: theDefault}) => {
  console.log(theDefault);
});

// 如果想同时加载多个模块，可以采用下面的写法。
Promise.all([
  import('./module1.js'),
  import('./module2.js'),
  import('./module3.js'),
])
.then(([module1, module2, module3]) => {
   ···
});

// import()也可以用在 async 函数之中。
```

##### 重命名 as

```
import { lastName as surname } from './profile.js';
```

### 2. CommonJS

CommonJs 是 Node 独有的规范，浏览器中使用就需要用到 Browserify 解析。

```
// a.js
module.exports = {
    a: 1
}
// or
exports.a = 1

// b.js
var module = require('./a.js')
module.a // -> log 1
```

来说说 module.exports 和 exports，用法其实是相似的，但是不能对 exports 直接赋值，不会有任何效果。

对于 CommonJS 和 ES6 中的模块化的两者区别是：

- 前者支持动态导入，也就是 require(${path}/xx.js)，后者目前不支持，但是已有提案 import()
- 前者是同步导入，因为用于服务端，文件都在本地，同步导入即使卡住主线程影响也不大。而后者是异步导入，因为用于浏览器，需要下载文件，如果也采用同步导入会对渲染有很大影响
- 前者在导出时都是值拷贝，就算导出的值变了，导入的值也不会改变，所以如果想更新值，必须重新导入一次。但是后者采用实时绑定的方式，导入导出的值都指向同一个内存地址，所以导入值会跟随导出值变化
- 后者会编译成 require/exports 来执行的

### 3. AMD

AMD 是由 RequireJS 提出的

```
// AMD
define(['./a', './b'], function(a, b) {
    a.do()
    b.do()
})
define(function(require, exports, module) {
    var a = require('./a')
    a.doSomething()
    var b = require('./b')
    b.doSomething()
})
```

> 整理自面谱 InterviewMap


