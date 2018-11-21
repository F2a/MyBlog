---
title: 优化项目，增强体验（二）
date: 2018-9-11 17:58:42
tags: 性能优化
toc: true
---

> 整理自面谱 InterviewMap

# 图片优化

1. 优化图片大小

对于一张 100 \* 100 像素的图片来说，图像上有 10000 个像素点，如果每个像素的值是 RGBA 存储的话，那么也就是说每个像素有 4 个通道，每个通道 1 个字节（8 位 = 1个字节），所以该图片大小大概为 39KB（10000 \* 1 \* 4 / 1024）。

了解了如何计算图片大小的知识，那么对于如何优化图片，想必大家已经有 2 个思路了：

- 减少像素点
- 减少每个像素点能够显示的颜色
- 借助一些第三方软件来进行压缩，比如[https://tinypng.com/]
2. 优化图片加载

- 不用图片。很多时候会使用到很多修饰类图片，其实这类修饰图片完全可以用 CSS 去代替，css Sprites。
- 对于移动端来说，屏幕宽度就那么点，完全没有必要去加载原图浪费带宽。一般图片都用 CDN 加载，可以计算出适配屏幕的宽度，然后去请求相应裁剪好的图片。
- 小图使用 base64 格式
- 将多个图标文件整合到一张图片中（雪碧图）
- 选择正确的图片格式：
    - 对于能够显示 WebP 格式的浏览器尽量使用 WebP 格式。因为 WebP 格式具有更好的图像数据压缩算法，能带来更小的图片体积，而且拥有肉眼识别无差异的图像质量，缺点就是兼容性并不好
    - 小图使用 PNG，其实对于大部分图标这类图片，完全可以使用 SVG 代替
    - 照片使用 JPEG

3. 图片过多

- 将图片服务和应用服务分离

对于服务器来说，图片始终是最消耗系统资源的，如果将图片服务和应用服务放在同一服务器的话，应用服务器很容易会因为图片的高I/O负载而崩溃，所以当网站存在大量的图片读写操作时，建议使用图片服务器.

(注:图片服务器是专门为图片读写操作优化的独立服务器，运行网站的服务器称为应用服务器)

另外浏览器在同一时间对同一域名下的资源的并发请求数目是有限制的，一般在2-6之间，超过限制数目的请求就会被阻塞.一些主流浏览器对 HTTP1.1 和 HTTP 1.0 的最大并发连接数目

把图片服务器与应用服务器分开，图片服务器采用独立域名 ，css、js和图片就可以并发请求了

- 懒加载

{% post_link internet01 跳转到 优化项目，增强体验（一） 相关内容 %}

- 图片压缩成base64格式来节约请求

将图片压缩成base64，随html或者css一起下载到浏览器，不需要额外的请求，这样就节约了请求.

我们知道图片在传输过程中是流传输，如果将图片转换成base64，实际上是变大了，并且浏览器在decode  base64编码的图片时需要耗费很多时间的，所以如果我们选择此种方案的话，最好选择一些小图片，不然得不偿失，在webpack中可以设置最大多少byte的图片压缩成base64

# 文件优化

- CSS 文件放在 head 中
- 服务端开启文件压缩功能
- 将 script 标签放在 body 底部，因为 JS 文件执行会阻塞渲染。当然也可以把 script 标签放在任意位置然后加上 defer ，表示该文件会并行下载，但是会放到 HTML 解析完成后顺序执行。对于没有任何依赖的 JS 文件可以加上 async ，表示加载和渲染后续文档元素的过程将和 JS 文件的加载与执行并行无序进行。
- 执行 JS 代码过长会卡住渲染，对于需要很多时间计算的代码可以考虑使用 Webworker。Webworker 可以让我们另开一个线程执行脚本而不影响渲染。

```
<script type="text/javascript" defer="defer">
// defer 属性规定是否对脚本执行进行延迟，直到页面加载为止。

<script type="text/javascript" src="demo_async.js" async="async"></script>
// async 属性规定一旦脚本可用，则会异步执行。脚本相对于页面的其余部分异步地执行（当页面继续进行解析时，脚本将被执行）
// async 属性仅适用于外部脚本（只有在使用 src 属性时）。
```

CDN

- 静态资源尽量使用 CDN 加载，由于浏览器对于单个域名有并发请求上限，可以考虑使用多个 CDN 域名。对于 CDN 加载静态资源需要注意 CDN 域名要与主站不同，否则每次请求都会带上主站的 Cookie。

# 优化项目

Webpack

- 对于 Webpack4，打包项目使用 production 生产模式，这样会自动开启代码压缩
- 使用 ES6 模块来开启 tree shaking，这个技术可以移除没有使用的代码
- 优化图片，对于小图可以使用 base64 的方式写入文件中
- 按照路由拆分代码，实现按需加载
- 给打包出来的文件名添加哈希，实现浏览器缓存文件

监控

对于代码运行错误，通常的办法是使用 window.onerror 拦截报错。该方法能拦截到大部分的详细报错信息，但是也有例外

- 对于跨域的代码运行错误会显示 Script error. 对于这种情况我们需要给 script 标签添加 crossorigin 属性
- 对于某些浏览器可能不会显示调用栈信息，这种情况可以通过 arguments.callee.caller 来做栈递归
- 对于异步代码来说，可以使用 catch 的方式捕获错误。比如 Promise 可以直接使用 catch 函数，async await 可以使用 try catch

但是要注意线上运行的代码都是压缩过的，需要在打包时生成 sourceMap 文件便于 debug。

```
source maps
Webpack打包生成的.map后缀文件，使得我们的开发调试更加方便
它能帮助我们链接到断点对应的源代码的位置进行调试（//# souceURL）
而devtool-此选项控制是否生成，以及如何生成source-maps的配置方式。
```

对于捕获的错误需要上传给服务器，通常可以通过 img 标签的 src 发起一个请求。

补充：

script标签的crossorigin属性

在HTML5中，一些 HTML 元素提供了对 CORS 的支持， 例如 `<img>` 和 `<video>` 均有一个跨域属性 (crossOrigin property)，它允许你配置元素获取数据的 CORS 请求。 这些属性是枚举的，并具有以下可能的值：

|关键字 | 描述
|----|
|anonymous | 对此元素的CORS请求将不设置凭据标志。
|use-credentials	| 对此元素的CORS请求将设置凭证标志; 这意味着请求将提供凭据。

- 通常我们使用`window.onerror`来捕获js脚本的错误信息。
- 但是对于跨域调用的js脚本，onerror事件只会给出很少的报错信息：error: Script error.
- 这个简单的信息很明显不足以看出脚本的具体错误，所以我们可以使用crossorigin属性，使得加载的跨域脚本可以得出跟同域脚本同样的报错信息：

```
<script crossorigin  src="http://www.lmj.com/demo/crossoriginAttribute/error.js"></script>

//　如果是这样，www.lmj.com的服务器必须给出一个Access-Control-Allow-Origin的header，否则无法访问此脚本。
```

## 面试题

如何渲染几万条数据并不卡住界面

这道题考察了如何在不卡住页面的情况下渲染数据，也就是说不能一次性将几万条都渲染出来，而应该一次渲染部分 DOM，那么就可以通过 `requestAnimationFrame` 来每 16 ms 刷新一次。

```
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>Document</title>
</head>
<body>
  <ul>控件</ul>
  <script>
    setTimeout(() => {
      // 插入十万条数据
      const total = 100000
      // 一次插入 20 条，如果觉得性能不好就减少
      const once = 20
      // 渲染数据总共需要几次
      const loopCount = total / once
      let countOfRender = 0
      let ul = document.querySelector("ul");
      function add() {
        // （1）优化性能，插入不会造成回流
        const fragment = document.createDocumentFragment();
        for (let i = 0; i < once; i++) {
          const li = document.createElement("li");
          li.innerText = Math.floor(Math.random() * total);
          fragment.appendChild(li);
        }
        ul.appendChild(fragment);
        countOfRender += 1;
        loop();
      }
      function loop() {
        if (countOfRender < loopCount) {
          // （2）
          window.requestAnimationFrame(add);
        }
      }
      loop();
    }, 0);
  </script>
</body>
</html>
```

1. `DocumentFragments` 是DOM节点。它们不是主DOM树的一部分。通常的用例是创建文档片段，将元素附加到文档片段，然后将文档片段附加到DOM树。在DOM树中，文档片段被其所有的子元素所代替。因为文档片段存在于内存中，并不在DOM树中，所以将子元素插入到文档片段时不会引起页面回流（对元素位置和几何上的计算）。因此，使用文档片段通常会带来更好的性能。

2. `window.requestAnimationFrame()` 方法告诉浏览器您希望执行动画并请求浏览器在下一次重绘之前调用指定的函数来更新动画。该方法使用一个回调函数作为参数，这个回调函数会在浏览器重绘之前调用。
