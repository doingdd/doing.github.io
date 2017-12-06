---
title: Linux中shell的理解和不同shell的区别
layout: post
category: Linux
---

#### 本文介绍linux中shell的概念，和不同shell用法的区别
# 1. 概念
个人理解shell，狭义上说是一种软件，广义上说是一种接口，它的作用是连接计算机的内核和使用者，它的位置应该是在内核之上，应用软件之下。  
shell的英文意思是“壳”，“壳”里面是“核”，也就是内核kernel，也有一种说法是shell是操作系统的最外层，也不无道理。  
关于shell的定位可以参考鸟哥教材里面的一张图：

![图片来源于鸟哥私房菜](http://oon3ys1qt.bkt.clouddn.com/HW_Kernel_Shell.png)

**Question1.** Shell是一种语言吗？
**A** 从使用上看，shell是一种语言，也可以叫命令解释器，它有自己的变量，参数和语言结构，包括循环分支等等，它通过解释器将代码转换成机器语言，操作和控制内核资源。但是shell本身又是用C语言写的。

# 2.常用shell种类
第一个比较流行的shell是Steven Bourne发展出来的，为了纪念他，就成为Bourne Shell，简称为:   
sh(`/bin/sh`, 后来被bash取代)  
后来出现了C语言写的C shell: csh(`/usr/bin/csh`)   
Bourne Again Shell:  bash(`/bin/bash`)   
Kornshell 发展出来的： ksh(`/usr/bin/ksh`, 兼容于bash)  
ksh发展的：zsh(功能更大的ksh, `/bin/zsh`)  

目前，接触比较多的`/bin/bash` 和`/usr/bin/ksh`
查看当前系统支持的shell种类：
```python
[root@localhost ~]# cat /etc/shells
/bin/sh
/bin/bash
/sbin/nologin
/usr/bin/sh
/usr/bin/bash
/usr/sbin/nologin
```
查看正在使用的shell：
```python
[root@localhost ~]# echo $0
-bash

[root@localhost ~]# sh
sh-4.2# echo $0
sh
```
查看当前terminal的默认shell
```python
sh-4.2# env|grep SHELL
SHELL=/bin/bash
[root@localhost ~]# echo $SHELL
/bin/bash
```
查看任意用户的默认shell：
```python
[root@localhost ~]# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
```
修改用户的默认shell(下次生效)：
```python
[root@localhost ~]# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
[root@localhost ~]# chsh -s /bin/sh
Changing shell for root.
Shell changed.
[root@localhost ~]# cat /etc/passwd
root:x:0:0:root:/root:/bin/sh
```
# ksh 和 bash的主要区别
ksh和bash互相兼容，但是在使用上还有很多区别。    
ksh在unix上用的比较多，bash在linux上比较多

## 中括号判断，布尔表达式
ksh的括号是[[]]，bash是[]；  
ksh的布尔表达可以用&& ||, bash是-a， -o
```python
[root@localhost temp]# cat ksh.sh 
#!/usr/bin/ksh
if [[ "1" && "2" ]];then
  echo "It's Ture."
fi
[root@localhost temp]# ./ksh.sh
It's Ture.
[root@localhost temp]# cat bash.sh
#!/bin/bash
if [ 1 -a 2 ];then
  echo "It's True"
fi
[root@localhost temp]# ./bash.sh 
It's True
```

## 数组设置方式不同
ksh： set -A array 1 2 3   
bash: array=(1 2 3)   
关于数组index个数，ksh最多只能到1023，bash没有限制（这一条验证失败，尝试创建超过1024个元素的数组，仍然成功）   
可以看到，ksh两种方式设置数组都可以：
```python
[root@localhost temp]# cat ksh.sh 
#!/usr/bin/ksh
set -A list 1 2 3 
echo ${list[2]}

array=(1 2 3)
echo ${array[2]}
[root@localhost temp]# ./ksh.sh 
3
3
```
但是bash只支持一种方式的数组定义：
```python
[root@localhost temp]# cat bash.sh 
#!/bin/bash
set -A list 1 2 3 4
echo ${list[3])}
array=(1 2 3 4)
echo ${array[2]}
[root@localhost temp]# ./bash.sh 
./bash.sh: line 2: set: -A: invalid option
set: usage: set [-abefhkmnptuvxBCHP] [-o option-name] [--] [arg ...]

3
```

## 双括号运算的区别
今天偶然发现，ksh中的双括号可以浮点运算，而bash中的双括号会报错：
```shell
Single-0-0-1:/u/ainet/workplace/Ptools-# echo $0
-ksh
Single-0-0-1:/u/ainet/workplace/Ptools-# echo $((123.33/3))
41.11

Single-0-0-1:/u/ainet/workplace/Ptools-# bash
Single-0-0-1:/u/ainet/workplace/Ptools-# echo $0
bash
Single-0-0-1:/u/ainet/workplace/Ptools-# echo $((123.33/3))
bash: 123.33/3: syntax error: invalid arithmetic operator (error token is ".33/3")
```
