# 开发笔记与说明

这篇就用中文写了……

## 前言与介绍

这是我在大二上学期《软件设计实践》这门课上的课程设计。

我最初有做一个 todolist 应用的想法，其实是在看过少数派上的[《三天时间，我写出了自己的 Todo 应用》][sspai_1]这篇文章之后。当时，我脑子里冒出了一个想法：如果用类似 Github Issue 的方式来管理 todo 会是什么感觉呢？虽然我不像文章里那样~~有女朋友~~有那么迫切的 Todolist 需求，但是多写写总是好的嘛！于是，趁着这次课的机会，我就写了这个应用。

最开始，这个应用其实不叫 iL；它叫 Issual。当时起这个名字的寓意就是要用管理 Issue 的方式管理 Todo。后来，因为 Issual 不太好念（~~其实 iL 也不好念啊~~），以及与 issue 的关系太密切，就改成了现在的 iL。

[sspai_1]: https://sspai.com/post/45679

## 开发环境与框架

iL 在编写时使用的是 Flutter 框架，以及与之配套的 Dart 语言。开发 iL 的时候使用的编辑器是 VSCode。

## 开发中的难点和解决方式

数据库！绝对是数据库！UI 设计什么的都好说，sql 语句能整死人！尤其是在做 Todo - category（其实还有 tag，但是没时间做了）对应的时候根本不知道怎么在不支持树状结构的 SQLite 里存。

后来用三个表给存上了。

## Q&A

### 现在这么多待办事项列表应用，你为啥要再开发一个

课设，课设，课设，重要的事情说三遍！

还有就是我对现在市场上存在的都不是特别满意，有一些想自己添加的功能。

### 为什么不用 Java

因为 Java 麻烦啊 (￣ ▽ ￣) 而且我也没用过 Java

其实是因为这几点原因：

- Flutter 框架所使用的 Dart 语言语法与 JS 相似，容易上手
- Flutter 框架适合这种敏捷开发的环境，很多控件都有做好的轮子
- Flutter 框架可以快速绘制组件树，适合这种一更新就更新整个组件树的环境
- Flutter 框架严格遵守 Material Design 设计规范，做出来的应用好看，还好布局
- Flutter 框架不慢，而且还支持热更新

### 你代码好乱

是这样的。回头会考虑把各种类分开一点。

### iL 怎么念啊

我个人认为 /il/ 和 /ai 'æl/ 都行，但是偏向后者。

### iL 在课程结束后还会继续开发吗

看心情吧？按理说是会的，当然也不排除忙其他项目就把这边摸了的情况。（Rynco Bot & Konamirr: ...)

### 继续开发的话还会加什么功能啊

现在计划添加的功能，按优先度排序：

- Tag
- 修改/状态变化记录
- Deadline 提醒（日历）
- 重复事件
- 分享？

### 根目录的那个大标题的字体是什么

Aller，[这里][aller_font]可以下载（协议不允许嵌入应用程序，所以应用里就没用）

### 描述 (Description) 区域支持 Markdown 的话我是不是可以把它当成笔记应用啊

吼啊

### 你是大佬么

不是

[aller_font]: https://www.fontsquirrel.com/fonts/Aller?q%5Bterm%5D=aller

## 致谢

### 在设计过程中提供帮助的大佬们

- Mad0ka （设计）~~北蓝女神码垛卡！~~
- Rami3L （交互）
- JogleLew （选题）
- ion2018

### 提供各种开源轮子的大佬们

- Tekartik ([sqflite](https://pub.dartlang.org/packages/sqflite))
- agilord (Istvan Soos | [ulid](https://pub.dartlang.org/packages/ulid))
- letsar (Romain Rastel | [flutter_slidable](https://pub.dartlang.org/packages/flutter_slidable))
- The Flutter Team (Flutter Framework, [url_launcher](https://pub.dartlang.org/packages/url_launcher), [flutter_markdown](https://pub.dartlang.org/packages/flutter_markdown)),
