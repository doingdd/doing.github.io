---
layout: post
title: Python IO 文件处理
category: Python
---

### 本文列举了python中常用的文件操作。

首先弄清两个基本概念“模式”，“操作(或方法)”
python对文件的使用都基于一个前提，就是文件被打开，只有被打开的文件才能进行下一步操作。
所以 **“模式”** 就是文件的打开模式，也就是说在文件被打开的时候就需要决定我要对文件做什么，从而选择正确的模式。  
**“操作”** 就是对文件想要执行的内容，读，写，既读又写等等。
个人感觉仅对文件的操作没有shell那么简便，当然也许是还没有体会到它的强大。

# 1. 文件打开模式

open函数中模式参数的常用值：

值| 描述
---|---
'r'|读模式
'w'|写模式
'a'|追加模式
'b'|二进制模式（可与其他模式共用）
'+'|读/写模式（可与其他模式共用）

### 'r'模式
只读，不可写，为默认模式。
### 'w'模式
只写，不可读，文件不存在则创建，存在则清空。
### 'a'模式
追加写，不可读，不存在会创建，存在则追加。
### 'b'模式
可以处理二进制文件，例如声音或者图像文件，愿意是文本模式打开非文本文件可能会对文件进行修改，如换行符等，破坏二进制文件。
'b'模式可以与其他模式一起用
### '+'模式
可读可写，与不同的模式公用有不同的作用：  
**'r+'与'w+'的区别：** r+可读可写，如果不存在则报错；w+可读可写，如果不存在则创建，存在则清空。  
**'r+'与'a+'的区别：** r+如果进行写操作，默认从文件的开始写，会覆盖原文件内容； a+则从文件末尾追加。  
**NOTE:**   
* 普通的读写操作加上加号以后，相当于只加入了“可读可写”的功能，原功能实际没有变化。  
* w和w+模式的清空文件操作，等于只要使用w或w+文件内容肯定是要被清空的。这一点类似于shell的'>'
* a和a+的追加模式，写操作可以理解为shell的'>>'		  

# 2. 文件的方法
文件的基本方法就是open(),close(),read(),write(),readline(),readlines(),writelines(),seek()等等
## 读
**read([size])**  

	>>> f = open('file.test','w')
	>>> f.write('1\n2\n3\n4')
	>>> f.seek(0)
	>>> print f.read()
	1
	2
	3
	4
	>>> f.seek(0)
	>>>> f.read()
	'1\n2\n3\n4'

注意两点：  
1.f.read()是从文件当前指针读取内容直到文件末尾也就是EOF结束，如果在write之后不加seek改变指针位置，读出来的**内容为空**。
2.read()的返回值是一个字符串，只不过print函数自动把换行符"\n"转换成换行，实际上，print会转换原始字符串成易读的状态。
  
	>>> print 1000L
	1000

Question: in python help(file), don't know what this mean, what's non-blocking mode:  
`Notice that when in non-blocking mode, less data than what was requested may be returned, even if no size parameter was given.`

**readline([size]), readlines([size])**

readline默认每次读取一行，返回**string**；readlines默认循环读取行，直到EOF,返回**list**
```python
[root@localhost ~]# cat file.test 
first line
Second line
2
3
4
	
>>> f = open('file.test')
>>> f.readlines()
['first line\n', 'Second line\n', '2\n', '3\n', '4\n', '\n']

>>> f.seek(0)
>>> f.readline()
'first line\n'
>>> f.readline(3)
'Sec'
>>> f.readline()
'ond line\n'
#当文件末尾时，分别返回空字符串和空列表：
>>> f.readlines()
['2\n', '3\n', '4\n', '\n']

>>> f.readline()
''
>>> f.readlines()
[]
>>> f.close()
```
**注意：** readline的参数是指定读取的字符个数，readlines的参数，根据网上信息，如果给定参数的读取内容小于缓冲区8k，则取整，每次读取8k，如果大于8192，则读取指定参数大小的内容。  


## 写
**write(str)**  
write方法的参数是单个string，在当前指针出插入一行，不自动插入换行符。

	>>> f = open('file.test', 'w+')
	>>> f.write('Hello World!')
	>>> f.write('to be or not to be')
	>>> f.close()
	>>> f = open('file.test')
	>>> f.read()
	'Hello World!to be or not to be'
	>>> f.close()

发现个有意思的现象，注意read，readlines和readline在下面情况下的返回值区别：
```python
>>> f = open('file.test', 'w+')
>>> f.write('Hello World!')
>>> f.read()
''
>>> f.seek(0)
>>> f.read()
'Hello World!'
>>> f.close()
>>> f = open('file.test', 'w+')
>>> f.write('Hello World!')
>>> f.readlines()
[]
>>> f.seek(0)
>>> f.readlines()
[]
>>> f.read()
''
>>> f = open('file.test', 'w+')
>>> f.write('Hello World!')
>>> f.readline()
''
>>> f.seek(0)
>>> f.readline()
'Hello World!'
#但是如果按如下执行，readlines又能读出数据：
>>> f = open('file.test', 'w+')
>>> f.write('Hello World!')
>>> f.seek(0)
>>> f.read()
'Hello World!'
>>> f.seek(0)
>>> f.readline()
'Hello World!'
>>> f.seek(0)
>>> f.readlines()
['Hello World!']
```
也就是说，目前证实，在'w+'模式，write完之后，指针在文件末尾，直接跟readlines会导致当前的文件清空，不知道什么原因？  
A, 怀疑是buffer的原因

**writelines(sequence_of_strings)**  

writelines的参数是一个序列，只能以变量名形式传入，不自动添加换行，实际上，他和readlines正好相反。
```python
>>> f = open('file.test', 'w')
>>> f.writelines('a','b')
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: writelines() takes exactly one argument (2 given)

>>> l = ['a', 'b', 'c']
>>> f.writelines(l)
>>> f.close()
>>> print open('file.test').read()
abc
>>> l.append('\n')
>>> l.insert(0, '\n')
>>> l
['\n', 'a', 'b', 'c', '\n']
>>> print open('file.test').read()
abc
abc
```
## 文件指针
**seek(offset[, whence])**    
seek用于调整文件的指针位置，可以理解成shell下vi的光标吧，read，write的操作都是基于当前光标位置做的。在前后的例子中已经多次用到seek方法。  
-offset: 开始的偏移量，也就是代表需要移动偏移的字节数.    
-whence：可选，默认值为 0。给offset参数一个定义，表示要从哪个位置开始偏移；0代表从文件开头开始算起，1代表从当前位置开始算起，2代表从文件末尾算起。      
```python
[root@localhost ~]# cat file.test 
Hello World
To be or not to be
Is a question
[root@localhost ~]# python
Python 2.7.5 (default, Nov  6 2016, 00:28:07) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-11)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> f = open('file.test')
>>> f.read()
'Hello World\nTo be or not to be\nIs a question\n'
>>> f.seek(0)
>>> f.readline()
'Hello World\n'
>>> f.seek(5)
>>> f.readline()
' World\n'
>>> f.seek(5, 1)
>>> f.readline()
' or not to be\n'
>>> f.seek(8,2)
>>> f.readline()
''
>>> f.seek(-9,2)
>>> f.readline()
'question\n'
```
**tell()**  
tell方法可以返回当前的指针位置，返回值为从文件开始到当前位置的字符个数：
	
	>>> f = open('file.test')
	>>> f.readline()
	'Hello World\n'
	>>> f.tell()
	12
	>>> f.seek(0)
	>>> f.readline(5)
	'Hello'
	>>> f.tell()
	5
	
## 关闭文件
python在写入文件后，可能不会立即写入到磁盘，出于效率考虑可能会把数据写缓存，这样，在非正常情况的程序退出，写入有可能会丢失。所以，关闭文件来出发写入磁盘操作非常重要。  
Question：“可能”写缓存是什么意思？在哪些情况下会缓存，哪些情况不会？

**close()**    
close()没有返回值，直接关闭文件，**注意**，如果不加括号的调用close不会真正关闭文件类，例如：
```python
[root@localhost ~]# cat file.test 
abc
abc
	[root@localhost ~]# python
Python 2.7.5 (default, Nov  6 2016, 00:28:07) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-11)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> f = open('file.test')
>>> f.read()
'abc\nabc\n'
>>> f.seek(0)
>>> f.close
  <built-in method close of file object at 0x7fbc54b6c5d0>
>>> f.read()
'abc\nabc\n'
>>> f.close()
>>> f.read()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ValueError: I/O operation on closed file
```
**try...finally**  

	#Open your file here
	try:
		#Write data to your file
	finally:
		file.close()

**with...as**  
with as 可以简化try/finally的代码，使代码更加清晰，with的作用是自动释放对象，这样即使程序异常结束，文件也可以正确的关闭。

	[root@localhost ~]# cat file.test 
	abc
	abc
	
	>>> with open('file.test') as f:
	...     f.read()
	... 
	'abc\nabc\n'
	>>> f.seek(0)
	Traceback (most recent call last):
	  File "<stdin>", line 1, in <module>
	ValueError: I/O operation on closed file

with实际上是使用了python中的上下文管理器的模式，包括__enter__和__exit__两个方法，分别在进入和退出with的时候被调用。  
__enter__方法返回值绑定在as后面的变量，本例中就是f类文件；__exit__方法有三个参数（异常类型，异常对象和异常回溯），具体的高级用法留待继续学习。

# 文件迭代
文件迭代指的就是循环操作文件的特定内容，可以按字节迭代，按行迭代。迭代的方式也多种多样，while循环，for循环，fileinput模块等等。  
从python2.2开始，文件对象是可以直接迭代的，包括显式和非显式。
**显式迭代：**

	f = open(filename)
	for line in f:  
	        process(line)
	f.close()

	
下面这种方法是**非显式的打开文件**，所以不能显式的关闭，需要依赖python负责关闭：
```python
>>> f = open('file.test', 'w')
>>> f.write('First line\n')
>>> f.write('Second line\n')
>>> f.write('Third line\n')
>>> f.close()
>>> lines = list(open('file.test'))
>>> lines
['First line\n', 'Second line\n', 'Third line\n']
>>> first, second, third = open('file.test')
>>> first
'First line\n'
>>> second
'Second line\n'
>>> third
'Third line\n'
>>> print list(open('file.test'))
['First line\n', 'Second line\n', 'Third line\n']
```
当然，这两种迭代方式是针对读文件的，关于迭代器的详细内容留待继续学习。  
## QA
1.遇到一个writelines异常的问题：  
```python
>>> f = open('test', 'a+')
>>> content = f.readlines()
>>> content
['you need me\n', 'wakak\n', '3\n', '4\n', '5\n']
>>> content[0] = 'you do not need me' 
>>> f.seek(0)
>>> f.writelines(content)
>>> f.tell()
54
>>> f.readlines()
[]
>>> f.seek(0)
>>> f.readlines()
['you need me\n', 'wakak\n', '3\n', '4\n', '5\n']
# 注意，上面的代码证明writelines写操作没有实时更新。
>>> f.flush()
>>> f.tell()
24
>>> f.seek(0)
>>> f.readlines()
['you need me\n', 'wakak\n', '3\n', '4\n', '5\n']
# 执行了flush之后也没有更新。
>>> f.seek(0)
>>> f.writelines(content)
>>> f.readlines()
['you need me\n', 'wakak\n', '3\n', '4\n', '5\n']
>>> f.seek(0)
>>> f.readlines()
['you need me\n', 'wakak\n', '3\n', '4\n', '5\n']
>>> f.seek(0)
>>> f.writelines(content)
>>> f.seek(0)
>>> f.readlines()
['you need me\n', 'wakak\n', '3\n', '4\n', '5\n', 'you do not need mewakak\n', '3\n', '4\n', '5\n']
# 奇怪的事出现，上面这段证明在writelines之后跟readlines不会读最新内容，但是writelines跟seek后，会在文件末尾开始更新。
```
继续证明，结果显示可能跟'a+'模式的特点有关，下面的代码证明了，a+模式下的seek(0)即使回到了文件开头，这时候的写操作仍然从文件末尾开始：
```python
>>> f = open('test', 'a+')
>>> content = f.readlines()
>>> content 
['you need me\n', 'wakak\n', '3\n', '4\n', '5\n']
>>> content[0] = 'you do not need me'
>>> content
['you do not need me', 'wakak\n', '3\n', '4\n', '5\n']
>>> f.seek(0)
>>> f.writelines(content)
>>> f.close()
>>> f = open('test')
>>> f.readlines()
['you need me\n', 'wakak\n', '3\n', '4\n', '5\n', 'you do not need mewakak\n', '3\n', '4\n', '5\n']
```
