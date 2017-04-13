---
layout: post
title: Python list usage
category: Python
---

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

# 2. list 函数

	