---
layout: post
title: Python list usage
category: Python
---

#### 本文列举了一些常用的列表操作，随着学习的深入持续更新

# 1. 序列的通用操作
##  索引
list的定义及索引：

	>>> number = [1, 2, 3, 'Tom', 'James']
	>>> number[0]
	1
	>>> number[4]
	'James'
	>>> mix = ['Yidu', number]
	>>> mix[1]
	[1, 2, 3, 'Tom', 'James']

注意，索引的下标从**0**开始

##  分片

索引是访问单个元素，分片是访问一定范围的元素，举例：  

	#使用range函数创建一个list	
	>>> numbers = range(10)
	>>> numbers
	[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	#注意，"0:9"选取范围包括"第0个"，不包括"第9个"
	>>> numbers[0:9]
	[0, 1, 2, 3, 4, 5, 6, 7, 8]
## pythonic way of list using
列出全部元素：

	>>> numbers = range(10)
	>>> numbers[:]
	[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

列出最后一个元素：

	>>> numbers[-1]
	9

列出后三个元素：

	>>> numbers[-3:]
	[7, 8, 9]


列出前三个元素：

	>>> numbers[:3]
	[0, 1, 2]

步长提取：

	>>> numbers[0:5:2]
	[0, 2, 4]

从右到左提取（步长为负）：

	# 注意起始元素包含，结尾元素不包含
	>>> numbers[5:0:-2]
	[5, 3, 1]

得到了逆序排列list的方法：

	>>> numbers[::-1]
	[9, 8, 7, 6, 5, 4, 3, 2, 1, 0]


##  序列相加
只有同类能相加

	#相加不会改变a或b的值
	>>> a = [1, 2, 3]
	>>> b = [4, 5, 6]
	>>> a + b
	[1, 2, 3, 4, 5, 6]  
	
	>>> 'hello' + 'world'
	'helloworld'
	>>> a + 'hello'
	Traceback (most recent call last):
	  File "<stdin>", line 1, in <module>
	TypeError: can only concatenate list (not "str") to list

##  乘法
字符串乘法：

	>>> 'ha' * 10
	'hahahahahahahahahaha'

list乘法：

	>>> ['hei'] * 10
	['hei', 'hei', 'hei', 'hei', 'hei', 'hei', 'hei', 'hei', 'hei', 'hei']
	
	>>> a = [1, 2, 3]
	>>> a * 5
	[1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]

## len, max and min

	>>> numbers = range(10)
	>>> len(numbers)
	10
	>>> max(numbers)
	9
	>>> min(numbers)
	0

# 2. list 方法
方法是与对象有紧密关系的函数。

## append
append在list末尾添加新的对象，注意，append会修改原list、

	a = [1, 2, 3]
	>>> a.append('last')
	>>> a
	[1, 2, 3, 'last']


## extend
extend在list末尾追加**多个**值，注意和append的区别：

	>>> a = [1, 2, 3]
	>>> b = [4, 5, 6]
	>>> a.append(b)
	>>> a
	[1, 2, 3, [4, 5, 6]]
	>>> a.extend(b)
	>>> a
	[1, 2, 3, [4, 5, 6], 4, 5, 6]
而且，extend和“+”的区别是， 加号操作不会更改原list，extend会

## count

	>>> ['to', 'be', 'or', 'not', 'to', 'be'].count('to')
	2
	>>> ['to', 'be', 'or', 'not', ['to', 'be']].count('to')
	1
	>>> ['to', 'be', 'or', 'not', ['to', 'be']].count(['to', 'be'])
	1

上面这几行证明count只计算“对象”的次数，而不是某个字符串。

## index
index 可以理解成反向索引，是知道list元素的内容，获取它的第一次出现的位置

	>>> Shakespeare = ['to', 'be', 'or', 'not', 'to', 'be']
	>>>> Shakespeare.index('be')
	1
	>>> Shakespeare[1]
	'be'

## insert

	>>> numbers = range(10)
	>>> numbers
	[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	>>> numbers.insert(3, 'hei')
	>>> numbers
	[0, 1, 2, 'hei', 3, 4, 5, 6, 7, 8, 9]

insert 会在给定的位置插入，当前位置的元素全部后移

## list元素的删除，del, pop, remove

	>>> numbers = range(10) + ['to', 'be', 'not to be']
	>>> numbers
	[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'to', 'be', 'not to be']
	>>> del numbers[9]    #删除位置“9”上的元素
	>>> numbers
	[0, 1, 2, 3, 4, 5, 6, 7, 8, 'to', 'be', 'not to be']
	>>> numbers.remove('be')   # 删除元素值为‘be’第一个匹配元素
	>>> numbers
	[0, 1, 2, 3, 4, 5, 6, 7, 8, 'to', 'not to be']
	>>> numbers.pop()     #默认删除最后一个元素
	'not to be'
	>>> numbers
	[0, 1, 2, 3, 4, 5, 6, 7, 8, 'to']
	>>> numbers.pop(2)    #删除位置‘2’上的元素
	2
	>>> numbers
	[0, 1, 3, 4, 5, 6, 7, 8, 'to']

**注意**，pop和append的正好相反，相当于对堆栈的操作(先进后出，LIFO),如果要实现先进先出(FIFO),则需用**pop(0)**和append来实现。
而且，pop是唯一的可以修改list并返回元素值的方法

## reverse

	reverse 将list中的元素反向存放，更改list内容：
	>>> numbers = range(10)
	>>> numbers.reverse()
	>>> numbers
	[9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

也可以不更改list的值，仅做逆向排序（加上片提取，逆向排序有两种方法了）：

	>>> numbers = range(10)
	>>> list(reversed(numbers))
	[9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
	>>> numbers
	[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

## sort 排序
sort排序更改原list的内容，但是没有返回值：

	>>> numbers = [3, 2, 4, 1, 5]
	>>> numbers.sort()
	>>> numbers
	[1, 2, 3, 4, 5]

直接获取sort的返回值是错误的：

	>>> numbers = [3, 2, 4, 1, 5]
	>>> y = numbers.sort()
	>>> print y
	None

如果想保留原list，并且获取sort后的输出：

	>>> numbers = [3, 2, 4, 1, 5]
	>>>> x = numbers[:]   #注意，直接使用x=numbers会导致两个list只想同一地址，也就是共同变化
	>>> x.sort()
	>>> print x, '\n', numbers
	[1, 2, 3, 4, 5] 
	[3, 2, 4, 1, 5]
	#另一种办法，使用sorted：
	>>> numbers = [3, 2, 4, 1, 5]
	>>> x = sorted(numbers)
	>>> print x
	[1, 2, 3, 4, 5]
	>>> print numbers
	[3, 2, 4, 1, 5]

sort还有一些参数可以指定：

	#按字符串长度排序
	>>> x = ['to be', 'Shakspear', 'not to be', 'whatever']
	>>> x.sort(key=len)
	>>> x
	['to be', 'whatever', 'Shakspear', 'not to be']
	
	#反向排序
	>>> numbers = range(10)
	>>> numbers.sort(reverse = True)
	>>> numbers
	[9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
