---
title: Python知识点 -- 迭代器和生成器
layout: post
category: Python
---

**本文介绍迭代器，生成器的概念及用法**  
参考文章：  
[知乎：https://www.zhihu.com/question/20829330](https://www.zhihu.com/question/20829330)  
[廖雪峰](http://www.liaoxuefeng.com/wiki/001374738125095c955c1e6d8bb493182103fac9270762a000/00138681965108490cb4c13182e472f8d87830f13be6e88000)  

# 迭代，迭代器
## 1. 迭代的几个概念
迭代(Interation): 重复一件事情很多次。  
可迭代对象(Iterable)： 可以直接作为for循环**in**后面的对象都是可迭代对象，list，tuple，dictionary等。  
迭代器(Iterator): 可以被next()函数调用(或调用next函数，python3)并且不断返回下一个值的对象。  
**Why Interation?**  
迭代一次仅计算一个元素，对于大序列的循环使用，或者无穷大的集合非常适合(节省内存)。  

可迭代对象不一定是迭代器，但是任何可迭代对象都具有一个内建函数iter()
```python
>>> help(list)
>>> help(tuple)
__iter__(...)
      x.__iter__() <==> iter(x)
```
这个iter的作用，就是将可迭代对象转化成迭代器。
```python
##可以看出，list并不是迭代器， 没有next()方法
>>> a = range(10)
>>> next(a)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: list object is not an iterator
##用iter()方法转化后，产生了迭代器
>>> a = iter(a)
>>> next(a)
0
>>> print a
<listiterator object at 0x7f313fe4e0d0>
```
而next()的作用，就是返回迭代器的下一个值
所以有几个结论：
1. 内置函数iter()仅仅是调用了对象的__iter()方法，所以list对象内部一定存在方法iter__()  
2. 内置函数next()仅仅是调用了对象的__next()方法，所以list对象内部一定不存在方法next__()，但是Itrator中一定存在这个方法。
3. for循环内部事实上就是先调用iter()把Iterable变成Iterator在进行循环迭代的。

**iterable需要包含有__iter()方法用来返回iterator，而iterator需要包含有next__()方法用来被循环。如果自己定义迭代器，需要在类中定义iter()方法返回一个对象，对象里面包含next()方法用来循环。**
## 2. 迭代器举例
前面提到，可以使用iter方法将可迭代对象转化成迭代器，实际上，只要具备以下两个特点的对象，都可以当做迭代器：
1. iter()方法，返回迭代器本身；
2. next（）方法，返回下一个元素或者跑出StopIteration异常。

所以，我们可以自定义迭代器，以斐波那契数列为例，说明迭代器的用法：
```python
[root@localhost python]# cat Fib.py
#!/usr/bin/python

# Fibonacci Sequence
#By definition, the first two numbers in the Fibonacci sequence are either 1 and 1, or 0 and 1.
#Each subsequent number is the sum of the previous two.

from sys import argv
value = int(argv[1])
class Fib(object):
	def __init__(self, max):
		self.n, self.a, self.b = 0, 0, 1	
		self.max = max

	def __iter__(self):
		return self

	def next(self):
		if self.n < self.max: 
			if self.n == 0:  
				self.n +=1
				return self.a
			else:
				r = self.b
				self.a, self.b = self.b, self.a + self.b
				self.n += 1
				return r
		raise StopIteration()

for i in Fib(value):
	print i
```
斐波那契数列，从第三位开始，每一位是前两位元素之和.[0, 1, 1, 2, 3, 5, 8, 13....].  
只要看next方法，当第一次迭代n==0时，返回0；0 < n < max 时，返回前两个元素之和，迭代次数超过max次之后抛出异常：  
```python
[root@localhost py]# ./Fib.py 5
0
1
1
2
3
```
# 生成器
## 1. 生成器概念
生成器是一类特殊的迭代器，内部自动包含了迭代器协议，也就是iter和next两个方法。   
在成功定义了一个生成器的同时，实际上它已经是一个迭代器了。  
也就是说，生成器首先包含了迭代器的所有特点，而且，还具备普通迭代器没有的代码简洁特性。  
通常，可以用两种办法创建一个生成器：  
1. 生成器函数。带有关键字yield的函数成为生成器函数。常规函数使用return返回结构，生成器用yield返回结果。  
2. 生成器表达式：类似于列表推导，只不过列表推导使用的是[]返回一个列表，生成器表达式使用()返回一个生成器。

## 2. Why 生成器
先上结论，生成器和迭代器的优点一样：节省内存。
```python
sum([i for i in xrange(10000000000)])
sum(i for i in xrange(10000000000))
```
在python解释器中分别运行上面两句，可以发现明显的区别，对于前一个表达式，我的虚机内存直接打爆(512M)，对于后一个，只是cpu占用100%,但是还能正常工作。
所以在大数据，文件大小未知等情况下，生成器的优势非常明显。

## 3. 生成器的使用
**首先**，使用生成器函数，完成上例中斐波那契数列：
```python
def Fab(max):
        n, a, b = 0, 0, 1
        if n == 0:
                n += 1
                yield a

        while n < max:
                yield b
                n +=1
                a, b = b, a + b
        raise StopIteration()
```
使用yield之后，python解释器将Fab()解释成一个generator，调用Fab(value)不会执行函数，而是返回一个iterator对象，然后再for循环中执行，执行到yield的一行则保存当前环境，并跳出，返回yield的参数值，下次迭代时，从yield的下一句继续执行。

**然后**使用另一种生成器的创建方法，生成器表达式：
```python
>>> a = (x**2 for x in range(4))
>>> print a
<generator object <genexpr> at 0x7f1a127857d0>
>>> for i in a:
...     print i
... 
0
1
4
9
```
上例可以看出，使用()定义之后，返回的a是一个生成器对象，不是list。
## 4. 生成器的注意事项
生成器除了定义时和普通函数不一样，在使用的时候也不能直接调用，这在之前的例子中已经提到。还有一点需要注意，**生成器只能调用一次**。  
```python
>>> a = (x**2 for x in range(4))
>>> sum(a)
14
>>> next(a)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
```
上例中使用生成器表达式创建了生成器a，然后用`sum`完成了生成器的迭代，如果再执行`next()`函数发现，生成器的迭代已经到了末尾，不能循环使用了。
**注意**，这里的`sum`和`for`一样，都可以对可迭代对象，或者是满足迭代协议的对象进行迭代操作，所以，它可以直接计算生成器所有迭代元素之和。

