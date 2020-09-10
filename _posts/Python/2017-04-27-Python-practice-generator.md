---
title: Python知识点 -- 装饰器
layout: post
category: Python
---

#### 本文介绍了装饰器的原理和典型应用

# 装饰器原理实现的基础 -- 函数对象化
要想理解python中装饰器的原理，首先理解：python中的一切皆对象。  
在python中，函数作为对象，可以赋给其他的变量，例如：
```python
[root@localhost mystuff]# cat decorator.py
def log():
	print 'Log: this is test log!'

logcopy = log
logcopy()

del log
try:
	log()
except NameError, e:
	print e
```
输出为：
```python
[root@localhost mystuff]# python decorator.py 
Log: this is test log!
name 'log' is not defined
```
注意，函数可以赋值给另一个变量，即使删除原函数，变量也不受影响，依然可以工作，`logcopy = log`这一句就是把函数赋给其他变量，但是并不是执行函数，仅仅是**copy**。  
而且，函数还可以作为返回值，作为参数，这是函数对象拥有的特性：
```python
[root@localhost mystuff]# cat decorator.py 
def log():

	def sub_log():
		print "I'm the function in funcion!"

	print 'Log: this is test log!'
	return sub_log()
log()

[root@localhost mystuff]# python decorator.py 
Log: this is test log!
I'm the function in funcion!
```

```python
[root@localhost mystuff]# cat decorator.py 
def log(func):

	print 'Log: this is test log!'
	print func.__name__, ": I'm the parameter function."

def func():
	pass
log(func) 

[root@localhost mystuff]# python decorator.py 
Log: this is test log!
func : I'm the parameter function.
```
# 装饰器
当有一种需求，既不想要改变函数本身的内容，但是在执行函数的时候还想要加上其他的功能，实现这种需求的机制，就是装饰器。
例如，我有两个函数：
```python
[root@localhost mystuff]# cat decorator.py
def log():
	print 'Log: this is test log.'

def get():
	print "This is to get something."

log() 
get()

[root@localhost mystuff]# python decorator.py 
Log: this is test log.
This is to get something.
```
如果我想在执行他们两个函数之前和之后分别加上start和end的提示语句，但是不想修改函数本身，就可以使用装饰器，对在函数执行之前，"装饰"一番，加上自己想要的功能：
```python
def decorator(func):
        def wrapper():
                print func.__name__, 'start:'
                func()
                print func.__name__, 'end.'
        return wrapper
```
上面这个函数就是一个典型的装饰器，以func为参数传入函数，加上其他功能后，最后返回的值就是被修改之后的func。然后利用python的语法糖调用这个装饰器：
```python
@decorator
def log():
        print 'Log: this is test log.'

def get():
        print "This is to get something."
log()
get()
```
注意，这里的log()函数使用了装饰器，get()没有使用，所以输出为：
```python
[root@localhost mystuff]# python decorator.py 
log start:
Log: this is test log.
log end.
This is to get something.
```
这里解释一下python是怎么执行上面的代码的，首先，在定义完成后，这些语句**并没有被执行**，python解释器会从头到尾将其解释一遍：  
> 1. def decorator(func):   ----将decorator加到内存    
> 2. @decorator
	这一句，会执行decorator的函数，将@decorator下面的函数作为decorator的参数，即decorator(log)  
	内部执行就是将log()这个函数，带入了decorator的函数，包了一层又返回来了。  
	log = decorator(log)  
	当然，在带入前，log这个函数已经被解释器识别并且加载内存里面了，**带入后，log()已经不是原来的log()了**，它的“装饰”会一直存在，直到进程结束。  

执行完上面的一步，log()已经不是原来的log()了，而且这个变化会一直持续，再一次调用log()的时候，已经默认是装饰之后的函数了。所以，如果想在函数的多次调用中分别执行不同的功能，decorator应该是实现不了的，因为decorator只能在函数定义的时候使用，可以连续使用多个，但是只有一次定义的机会。

### 函数带参数的装饰器：
```python
def decorator1(func):
	def wrapper(*args, **kwargs):
		print func.__name__, 'start:'
		func(*args, **kwargs)
		print func.__name__, 'end.'

	return wrapper

@decorator1
def log(*args):
	print 'Log: this is test log.'
	print 'argvs:', args

```
### 装饰器带参数（三层嵌套）
```python
[root@localhost mystuff]# cat decorator.py 
def decorator2(txt):
	def dec(func):
		def wrapper(*args, **kwargs):
			print txt, func.__name__
			return func(*args, **kwargs)
		return wrapper
	return dec

@decorator2('Execute:')
def set():
	print "This is to set sth."

set()

[root@localhost mystuff]# python decorator.py
Execute: set
This is to set sth.
```

### 内置装饰器 property
property也叫属性函数，它的作用是有两点：
>1. 将类方法转换为只读属性
>2. 重新实现属性的setter和getter方法

首先看一个类方法调用的例子：
```python
[root@localhost python]# cat prop.py 
class Person(object):
    def __init__(self, first_name, last_name):
        """Constructor"""
        self.first_name = first_name
        self.last_name = last_name
 
    def full_name(self):
        """
        Return the full name
        """
        return "%s %s" % (self.first_name, self.last_name)

me = Person('Du', 'Ying')
print me.full_name()

>>> import prop
Du Ying
>>> print prop.me.first_name
Du
>>> print prop.me.last_name
Ying
>>> print prop.me.full_name
<bound method Person.full_name of <prop.Person object at 0x7f924150aed0>>
>>> print prop.me.full_name()
Du Ying
```
注意到full_name()这个类的方法，如果调用，需要使用加括号的方式执行，而且，如果想对full_name的返回值做其他限制，需要在调用的时候写其他的函数名。如果加上property装饰器，可以把full_name()这个方法转化成类的属性，直接对full_name进行操作。
```python
class Person(object):
    def __init__(self, first_name, last_name):
        """Constructor"""
        self.first_name = first_name
        self.last_name = last_name
    @property 
    def full_name(self):
        """
        Return the full name
        """
        return "%s %s" % (self.first_name, self.last_name)

[root@localhost python]# python
>>> import prop
>>> me = prop.Person('Du', 'Ying')
>>> me.full_name
'Du Ying'
```
只定义@property实际上是对属性只读，如果想修改属性，可以调用一个setter：
```python
[root@localhost python]# cat prop.py
class Person(object):
    def __init__(self, first_name, last_name):
        """Constructor"""
        self.first_name = first_name
        self.last_name = last_name
    @property 
    def full_name(self):
        """
        Return the full name
        """
        try:
            return self._full_name
        except AttributeError:
            return "%s %s" % (self.first_name, self.last_name)

    @full_name.setter
    def full_name(self, a):
        self._full_name = a 
```
try except的目的是让对象创建时，返回一个初始的full_name，而且这个full_name可以在后续进行修改：
```python
[root@localhost python]# python
Python 2.7.5 (default, Nov  6 2016, 00:28:07) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-11)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import prop
>>> me = prop.Person('a', 'b')
>>> me.full_name
'a b'
>>> me.full_name = "Du Ying"
>>> me.full_name
'Du Ying'
```

目前看这几个例子并没有看出装饰器property有什么优势？感觉也没有省掉很多代码量，期待后续的学习会有所收获。

###多个装饰器的执行顺序
对于简单定义的多个装饰器装饰的函数，其调用的顺序就是从上到下的，比如：
```python
def dec1(func):
    #print 'out 1'
    def wrapper():
        print 'inner 1'
        func()

    return wrapper

def dec2(func):
    #print 'out 2'
    def wrapper():
        print 'inner 2'
        func()

    return wrapper

```
定义一个测试函数，用两个装饰器包起来：
```python
@dec1
@dec2
def run():
    print "run"

run()

```
执行结果是：
```python
inner 1
inner 2
run
```
可以看到是从上到下执行的，但是如果把dec中的两行print注释打开，发现顺序有变化：
```python
def dec1(func):
    print 'out 1'
    def wrapper():
        print 'inner 1'
        func()

    return wrapper

def dec2(func):
    print 'out 2'
    def wrapper():
        print 'inner 2'
        func()

    return wrapper

@dec1
@dec2
def run():
    print "run"

run()

#执行结果：
out 2
out 1
inner 1
inner 2
run

```
先打印了out2，这是因为在函数的定义阶段，python解释器检测到@语法糖，会对run函数进行一次“从里到外”的定义，可以理解成：   
1.run函数先被dec2包了一层，这时执行了dec2函数，但并未执行dec2里的wrapper，print out 2  
 
2.run函数又被dec1包了一层，这是执行了dec1函数，同样，也不涉及wrapper的执行  print out 1

3.定义完成，调用run()函数时，先执行最外层的dec2定义的好的wrapper， print inner 1  

4.再执行最里层的dec1定义好的wrapper，print inner 2 

