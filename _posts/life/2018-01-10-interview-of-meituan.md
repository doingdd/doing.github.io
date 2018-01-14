---
category: life
layout: post
title: interview of 美团
---


## 1.软件架构，测试的典型场景，测试的点在哪里

c/s架构，client/server，在server端业务逻辑处理模块是三层架构(protocol,call flow, service层)，消息分发，数据存储模块是分布式的。典型的测试场景以一个上网使用流量包的过程举例，涉及到分片和结算，动态规划，证明了软件是CPU bound，对CPU的使用时大于disk 读写的。  

测试的点感觉还是没表达的特别确切，从系统集成测试看，测试点多且离散，可以是系统的一个shell脚本，一个功能模块(例如给用户提供的修改软件参数的接口),也可以系统的容灾功能，升级功能等等，这些功能有的可以抛开软件业务逻辑，有的需要和一个业务请求功能测试。  

这里被challenge的点是互联网行业的典型软件架构，技术栈不熟，比如b/s架构，http协议，等等。  

## 2. 算法：字符串，返回字符串中每个字符的index(第一次)和出现次数

```python
#!/usr/bin/python
def f(s):
    di = {}
    dn = {}
    for i in range(len(s)):
        di[s[i]] = di.get(s[i],s.index(s[i])) 
        dn[s[i]] = dn.get(s[i],0) + 1
    for k,v in di.items():
        print "charactor: {0}, index: {1}".format(k,v)

    for k,v in dn.items():
        print "charactor: {0}, number: {1}".format(k,v)
f('abca')
```
然后就着这个程序设计测试用例：
```
f('abc')
f('abca')
f('aaba')
f('aaa')
f('abb')
f('abab')
f('')
```
经提醒，需要考虑特殊字符在不同语言中可能会有不同的结果，需要考虑进来。  

## 3.算法：数组，找出和为给定值的数组中的两个数
见[interview of didi](http://doing.cool/2018/01/09/interview-didi.html), 第11题。  
注意，这里被challenge了自己的用key:value实现的思路，因为这个语句`if k in d:`会导致遍历字典，时间复杂度为O(n)

## 4.项目经历，讲解做过的和web相关的项目

这里拿python爬虫做了举例，详细列出了程序的整个流程，和使用的模块，详见：
[](http://doing.cool/2017/07/13/Spider-Liepin-tester-job.html)  

## 5. 项目经历，讲解实现的性能测试自动化脚本结构

经提醒，这个项目属于c/s结构，被问道为什么不用b/s结构，可视化会更加完善，回答是觉得b/s会影响服务端的性能，结果被鄙视想多了。。。
这里如果详细讲的话，可以讲如何使用python调用远程linux脚本，使用subprocess，使用wxpython等等。

## 6.情景考察，四部电梯，考虑所有能考虑到的功能模块，并选择一个展开讨论所有的测试场景

这种题目比较考察平时积累的思路，比较通用性的技巧就是在考虑场景时使用典型的测试技巧：  
边界值，有效等价类等等。