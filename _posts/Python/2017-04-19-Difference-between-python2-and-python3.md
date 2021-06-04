---
title: Python2和Python3的区别
layout: post
category: Python
---

### 本文来自公众号`Python开发者`的一篇文章，简单介绍了python2和python3主要区别。

Python是一种极具可读性和通用的性的编程语言。Python名字的灵感来自英国戏剧团体Monty Python，它的开发团队有一个重要的目标，就是使语言使用起来更有趣。  
Python是一种多范式语言，支持多种编程风格，包括脚本和面向对象。  

虽然Python2.7和Python3有很多类似的功能，但他们不应该被认为是完全可互换的。虽然你可以在任一版本中编写出优秀的代码和有用的程序，但是值得了解的是，在代码语法和处理方面两者会有一些相当大的差异。

# print
在python2中， print被视为一个语句而不是函数，这是一个典型的容易混淆的地方，因为python中的很多操作都需要括号内的参数来执行。
```python
#python 2.7
print "Hello world"
Hello world
#python 3
print ("Hello world")
Hello world
```
这一特点向后兼容python2.7
# 整数的除法
在python 2中，键入任何不带小数的数字会被认为是整数的编程类型，而且，整数在python 2中是强类型的，不会变成带小数位的浮点数
```python
#python 2.7
print 5/2
2
print 5.0/2
2.5
#python 3
print 5/2
2.5
print 5//2
2
```
这一特点不向后兼容python2.7

#支持Unicode
当编程语言处理字符串类型时，也就是一个字符序列，它们可以用几种不同的方式来做，以便计算机将数字转换为字母和其他符号。

python 2默认使用ASCII字母表，如果想用Unicode字符编码，需要使用:
```python
#u代表Unicode
print u"Hello world"
``` 
python 2: 字符串以 8-bit 字符串存储  
python 3: 字符串以 16-bit Unicode 字符串存储  
python 3默认使用Unicode，所以可以轻松的在程序中键入和显示更多的字符。
# input raw_input
python 2中input函数得到的是int类型（输入不带引号的前提下），raw_input得到的是string。
python 3 中input得到的是string。
```python
#python 2.7
>>> input_me = raw_input("> ")
> 123
>>> type(input_me)
<type 'str'>
```
# 迭代器方法next()
next()在python3中变成了内建函数：  
python2： it.next()  
python3: next(it)  
在class中定义next方法：
python2: def next():
python3: def __next__():
# super()
python2: super(classb, self).__init__(), 用于调用父类的__init__  
python3: super可以不加参数，仍然work  
# callable()
callable在pyhon2里可以查看函数是否可调用，在python3中不再可用:
```python
>>> x = 3
>>> y = x**x
>>> callable(x)
False

>>> def y():
...     return 123
... 
>>> callable(y)
True
```
在python3中，需要使用hasattr(func, __call__)代替。
# open()
built-in function open() has some more parameters in python 3:   

python2.7: `open(name[, mode[, buffering]])`      

python3.5: `open(file, mode='r', buffering=-1, encoding=None, errors=None, newline=None, closefd=True, opener=None)`
# range(), xrange()
python2: range()返回list，xrange()返回迭代对象节省内存。
python3: 没有xrange，range()扩展了这一功能。

 
####未完待续。。。
