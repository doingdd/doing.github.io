---
title: Python知识点 -- lambda表达式
layout: post
category: Python
---

####本文介绍python中lambda表达式的概念和用法，涉及到python内建函数map

**lambda,** 希腊字符的第十一个字符：`λ`，抛开起数学原理不谈，只关注在python中的使用和概念。  
在python中，lambda又叫匿名函数，顾名思义，lambda语句使用来创建一个没有名字的函数对象的，它的返回值是一个函数。最简单的用法：
```python
>>> func = lambda x:x+1
>>> func(5)
6
```
可以这样认为,lambda作为一个表达式，定义了一个匿名函数，上例的代码`x`为入口参数，`x+1`为函数体。在这里lambda简化了函数定义的书写形式。是代码更为简洁，但是使用函数的定义方式更为直观，易理解。
再来一个简单的：
```python
>>> f = lambda x:x*x
>>> f(2)
4
```
在python中，lambda的函数体语句只能有一句，这样是为了方式lambda的滥用，如果想要多语句执行，还是老老实实def一个函数吧。  
lambda经常和python的内建函数一起使用：  

**map(function, iterable, ...)**
map的参数是函数，和想要在函数中执行的迭代对象，上例子:
```python
>>> map(lambda x:x*x, [1, 2, 3])
[1, 4, 9]
```
上例中就是把list[1, 2, 3]给匿名函数顺序迭代执行，返回的也是list。它实际上就是下面这种方式的简写：
```python
>>> def sqr(x):
...     return x*x
...
>>> map(sqr, [1, 2, 3])
[1, 4, 9]
```
当然，map还可以加若干个参数：
```python
>>> map(lambda x,y:x+y, [1, 2, 3], [4, 5, 6])
[5, 7, 9]
```
这里实际上给map传入了两个interabl参数,[1, 2, 3]和[4, 5, 6]，在执行时，是**并行**地将两个list里面的元素取出来传给lambda的函数，所以相当于执行：
```python
1+4  
2+5  
3+6  
```
类似的，可以继续加若干个参数，目前来看，在批量的函数运算中会比较有用

**filter(function or None, sequence)**
filter的使用方法和map类似，也是传入函数和序列，不同的是，map是带入并执行，filter是带入并筛选，换句话说，map返回的是“值”,filter返回的是“true则留”，"false则走".  
返回十以内被三整除的整数：
```
>>> filter(lambda x:x%3 == 0, range(10))
[0, 3, 6, 9]
```

**reduce(function, sequence[, initial])**
reduce的使用方法仍然类似于map和filter，但是有一点不同，它的list必须包含两个及以上元素，它的函数必须有且仅有两个参数，它的作用是，用sequence里的元素循环调用function，直到全部元素调用完结束，返回结果，如下例从1加到100：
```python
>>> reduce(lambda x,y:x+y, range(101))
5050
```


