---
title: 一次H5开发的踩坑记录
date: 2019-01-17 17:59:52
tags: CSS
toc: true
---

# 地图定位在手机浏览器和微信页面的坑

因为这次开发，公司没提供微信公众号的权限验证配置，所有这次开发没有引用微信js-sdk来做地图开发。

1. 最开始采用高德地图提供的api，发现在移动端完全不能用。通过google到高德地图在移动端获取定位需要在https协议下才行（H5原生定位也是如此）

2. 然后，转采用腾讯地图（纯粹是折腾了），同时腾讯地图很多api都是服务端的，开发起来不方便。

3. 采用腾讯地图后在非https协议下，可以成功定位，但是在安卓手机的微信中调起的页面不能定位（原因也是协议的问题）。

4. 最后只能在有https协议的服务器下发布网页了。。。

# 一些CSS知识盲点和好用的写法

## margin 合并的几个条件

- 这些margin都处于普通流中，并在同一个BFC中；
- 这些margin没有被非空内容、padding、border 或 clear 分隔开；
- 这些margin在垂直方向上是毗邻的，包括以下几种情况：
    1. 一个box的top margin与第一个子box的top margin
    2. 一个box的bottom margin与最后一个子box的bottom margin，但须在该box的height 为auto的情况下
    3. 一个box的bottom margin与紧接着的下一个box的top margin
    4. 一个box的top margin与其自身的bottom margin，但须满足没创建BFC、零min-height、零或者“auto”的height、没有普通流的子box

垂直方向上毗邻的box不会发生折叠的情况：

- 根元素的外边距不会参与折叠
- 一个有clearance的box的上下margin毗邻，它会与紧接着的下一个box发生margin折叠，但折叠后的margin不会再与它们父box的bottom margin折叠
折叠边距的计算

当两个margin都是正值的时候，取两者的最大值；当 margin 都是负值的时候，取的是其中绝对值较大的，然后，从 0 位置，负向位移；当有正有负的时候，先取出负 margin 中绝对值中最大的，然后，和正 margin 值中最大的 margin 相加。但必须注意，所有毗邻的margin要一起参与运算，不能分步进行。

## 实现固定长宽比的几种方案

HTML结构

```html
<div class="box" data-ratio="2:1">
    <div class="content"></div>
</div>
```

1. 垂直方向的padding

```css
.box {
    position: relative;  // 内部子元素用绝对定位排版
    height: 0;           // 容器高度是由padding来控制，盒模型原理告诉你一切
    width: 100%;
    padding-bottom: 50%; // 宽高比2：1
}

// 让其子元素的宽高和容器.aspectration一样大小

.box > * {
    position: absolute;
    left: 0; top: 0;
    width: 100%;
    height: 100%;
}
```

2. CSS变量计算

```css
.box{
    padding-top: calc(100% * 1 / 2);
}

// 或者 使用CSS的变量时，可以把HTML中data-ratio去掉了。换成style="--aspect-ratio:1/2"

.box[style*="--aspect-ratio"] {
  padding-top: calc(100% * (var(--aspect-ratio)));
}
```

3. 视窗单位vw

CSS长度单位vw。100vw表示的就是浏览器的视窗宽度(Viewport)。50vw表示浏览器的视窗宽度的一半。

```css
.box{
    width: 100vw;
    height: 50vw;
}
```

4. 其他方法

使用一个隐藏的图片来实现。

这个方法简单无脑，而且不需要考虑任何兼容性。以上方法中css变量和vw都是css3的新特性，使用时要慎重考虑。

操作步骤：

容器内部添加一张符合我们宽高比例的图片，给图片设置宽度100%；高度auto。然后把图片转码成base64避免多余的http请求。

## letter-spacing影响文字居中？

[设置letter-spacing之后设置文字text-align:center不能居中？](https://segmentfault.com/q/1010000003091391)

为什么？

因为letter-spacing相当于每个文字的margin-right 最后一个字符也会存在

## 左边div固定宽度，右边div自适应撑满剩下的宽度

[左边div固定宽度，右边div自适应撑满剩下的宽度](https://blog.csdn.net/wulala_hei/article/details/80445700)


## div宽度适应文字内容并且该div水平居中

html结构

```html
  <div class="textCenter">
    <p>我宽度自适应文字，并且还居中</p>
  </div>
```

css结构

```css
.textCenter{
  width: 300px;
  text-align: center;
  background-color: #2aa198;
}
.textCenter>p{
  max-width: 100%;       // 设置最大宽度，使其过长能自动折行
  display: inline-block;
  word-wrap:break-word;
}
```

如果还需垂直居中，就加上

```css
.textCenter{
  display: table;
}
.textCenter>p{
  vertical-align: middle;
}
```

##

1. 使用float

```html
<div class="use-float">
    <div class="left"></div>
    <div class="right"></div>
</div>

<style>
    .left {
        width: 100px;
        float: left;
    }

    .right {
        overflow: hidden;
    }
</style>
```

2. 使用 flex

```html
<div class="use-flex">
    <div class="left"></div>
    <div class="right"></div>
</div>

<style>
    .use-flex {
        display: flex;
    }

    .left {
        flex: none;
        width: 100px;
    }

    .right {
        flex: 1;
    }
</style>
```

# 用elf遇到的img引用和打包的坑


# 总结需要学习的知识盲点

- 单页面路由的基础原理和实现

- 数据单/双向绑定的基础原理和实现

- js生成img元素为什么在webpack中不显示图片，也不会被打包

- flex 深入学习


