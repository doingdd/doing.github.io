---
layout: post
category: Linux
title: Linux性能 -- CPU
---

**本文介绍linux性能之cpu篇，主要通过介绍各个CPU相关的命令来介绍CPU的相関概念和监测方式.**
[Linux中CPU与内存性能监测](http://blog.csdn.net/chenleixing/article/details/46678413)   
[linux下的CPU、内存、IO、网络的压力测试](http://blog.csdn.net/liushi558/article/details/50771853)   
[linux CPU性能及工作状态查看指令](http://blog.csdn.net/z1134145881/article/details/52089698)  

# 查看CPU相关命令

## top

top是实时动态的查看，可交互，详细介绍见这里：  
[Linux性能 -- top命令](http://doing.cool/2017/12/27/Linux-Performance-top.html)  

## vmstat

vmstat可以展现给定时间间隔的服务器的状态值,包括服务器的CPU使用率，内存使用，虚拟内存交换情况,IO读写情况。主要输出的是系统整体的情况，而不是某一个进程。  

vmstat的基本格式：  
```shell
vmstat [options] [delay [count]]
```

options|说明
---|---
-a|显示active和inavtive的内存情况


```shell
root@Doing:~/jump_game/wechat_jump_game# vmstat -a
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 2  0      0 736092 105620 109360    0    0     0     1    1    0  0  0 100  0  0
```