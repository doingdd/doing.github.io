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

