---
layout: post
title: Linux 目录结构
category: Linux
---

**图片和总结来自[实验楼](https://www.shiyanlou.com/courses/1/labs/59/document)**

Linux的目录使用FHS标准：
> FHS（英文：Filesystem Hierarchy Standard 中文：文件系统层次结构标准），多数 Linux 版本采用这种文件组织形式，FHS 定义了系统中每个区域的用途、所需要的最小构成的文件和目录同时还给出了例外处理与矛盾处理。

FHS 定义了两层规范，第一层是`/` 下面的各个目录应该要放什么文件数据，例如`/etc`应该放置设置文件，`/bin`与`/sbin`则应该放置可执行文件等等。

第二层则是针对`/usr`及`/var`这两个目录的子目录来定义。例如`/var/log`放置系统登录文件，`/usr/share`放置共享数据等等。
[FHS_2.3标准文档](http://refspecs.linuxfoundation.org/FHS_2.3/fhs-2.3.pdf)

**目录结构图**
![](http://oon3ys1qt.bkt.clouddn.com/Linux_Content_tree.png)
**命令行查看目录结构：**
```python
yum install -y tree
[root@localhost ~]# tree -d -L 1 /
/
├── bin -> usr/bin
├── boot
├── dev
├── etc
├── home
├── lib -> usr/lib
├── lib64 -> usr/lib64
├── media
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin -> usr/sbin
├── srv
├── sys
├── tmp
├── usr
└── var
```
FHS 依据文件系统使用的频繁与否以及是否允许用户随意改动，将目录定义为四种交互作用的形态，如下表所示：  
![图片来源实验楼](http://oon3ys1qt.bkt.clouddn.com/wm.png)
