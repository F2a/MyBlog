---
title: 初识前端模块化
date: 2018-10-01 16:12:20
tags: 架构设计
toc: true
---

### 1. ES6的模块功能
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

##### 重命名 as

```
import { lastName as surname } from './profile.js';
```

