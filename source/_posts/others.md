---
title: 在github上搭建hexo博客踩坑记录
date: 2018-10-15 16:46:36
tags: 其他
toc: true
---

# 环境配置

## 安装Node.js

略

## 安装Git

略

## 安装Hexo

```
$ npm install hexo-cli -g
$ hexo init blog
$ cd blog
$ npm install
$ hexo s # 或者hexo server，可以在http://localhost:4000/ 查看
```

# hexo主题设置

## 安装主题

hexo官网提供许多 [主题](https://hexo.io/themes/)

```
$ hexo clean
$ git clone 主题地址
```

## 启用主题

修改Hexo目录下的_config.yml配置文件中的theme属性。

# 设置Github

## 什么是Github Pages

GitHub Pages 本用于介绍托管在GitHub的项目，不过，由于他的空间免费稳定，用来做搭建一个博客再好不过了。

每个帐号只能有一个仓库来存放个人主页，而且仓库的名字必须是username/projectname.github.io，这是特殊的命名约定。你可以通过http://username.github.io 来访问你的个人主页。

这里特别提醒一下，***需要注意的个人主页的网站内容只能是在master分支下的。***

## 创建Github Pages

1. *新建一个github项目*

直接拉取Github项目到本地

```
git clone https://github.com/yourusername/yourprojectname.git
```

复制代码然后把Hexo项目文件夹下的内容全部复制过来，再npm install。关于Git的使用请自行掌握。

2. *如果是已经把源码关联master分支的项目*

踩坑记录：

- 首先创建一个新的分支为source（用来保存hexo源码）
- 在项目Settings - Branches 切换github项目Default branch为source
- 清空master分支

```
// 如果直接删除会发现删除不了，因为在本地您处在master分支，在远程master为默认分支，所以切换默认分支是必须的

$ git branch -D master //删除本地master分支
$ git push origin :master //删除远程master分支
```

- 创建一个空分支；使用参数 --orphan，这个参数的主要作用有两个，一个是拷贝当前所在分支的所有文件，另一个是没有父结点，可以理解为没有历史记录，是一个完全独立背景干净的分支。

```
$ git checkout --orphan gh-pages
$ git rm -rf . // 删除原来代码树下的所有文件
$ git branch -a // 这时候是看不到当前分支的，不用担心，下一步
$ git commit --allow-empty -m "root commit"  // 在推送到GitHub之前，即使它没有任何内容，您至少需要一次提交，因为您无法推送空分支
$ git push origin empty-branch // 最后，把它推到远程
```

- 复制代码然后把Hexo项目文件夹下的内容全部复制过来，再npm install。

***这样我们就可以在一个项目中同时保存hexo的原始代码和部署文件了***

# hexo部署

hexo deploy可以部署到很多平台，具体可以[参考这个链接](https://hexo.io/docs/deployment.html)。 如果部署到github，需要在配置文件_config.xml中作如下修改：

```
deploy:
  type: git
  repo: git@github.com:username/projectname.github.io.git
  branch: master
```

然后在命令行中执行

```
hexo g // 产生静态文件
hexo d // 将静态文件部署到远程仓库 master 分支下
```

## 踩坑提醒

1. 注意需要提前安装一个扩展：

```
$ npm install hexo-deployer-git --save
```

2. 如果出现下面这样的错误，

```
Permission denied (publickey).
fatal: Could not read from remote repository.
Please make sure you have the correct access rights
and the repository exists.
```

则是因为没有设置好public key所致。
在本机生成public key(参考github帮助)：

```
＃ssh-keygen -t rsa -b 4096 -C "xxx@xxx.com"
```

然后在#user_id/.ssh目录下会生成两个文件，id_rsa.pub和id_rsa.
然后登陆github，在SSH设置页面添加上刚才的public key文件也就是id_rsa.pub的内容即可。

3. 如果github-pages上的网页没有样式

官网文档-配置中已经有解释

修改_config.yml配置：

```
如果您的网站存放在子目录中，例如 http://yoursite.com/blog，
则请将您的 url 设为 http://yoursite.com/blog 并把 root 设为 /blog/。
```
