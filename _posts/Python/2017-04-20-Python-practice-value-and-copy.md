---
title:  Python知识点--变量赋值与深浅copy
layout: post
category: python
---

#### 本系列列举一些常见的Python知识点，本文涉及变量的赋值，存储和深浅拷贝。
首先上结论： 赋值，浅拷贝，深拷贝中，源数据和目标数据的相关性为 

**赋值 < 浅copy < 深copy**  

赋值：a = b，a和b只是名字不同，内容完全共同变化。    
copy： 浅拷贝的第一层不共同变化，如果有嵌套list，则嵌套部分共同变化。  
deepcopy： 深拷贝所有内容完全独立，无共同变化。
### 1. 先举例，请解释输出的原理

```python
[root@localhost mystuff]# cat it01.py 
## explain follow return value of list and why?

def extendList(val, list = []):
	list.append(val)
	return list

list1 = extendList(10)
list2 = extendList(123, [])
list3 = extendList('a')

print "list1 = %s" % list1
print "list2 = %s" % list2
print "list3 = %s" % list3


[root@localhost mystuff]# python it01.py 
list1 = [10, 'a']
list2 = [123]
list3 = [10, 'a']
```
**首先**解释为什么list3是[10， 'a'] 而不是 ['a']。因为函数extendList的参数默认值：list = []只有在函数被定义的时候（或者第一次调用的时候？）定义一次，如果继续进行函数调用，函数参数的默认值是不进行定义的，因为这时候这个参数已经有了值，无论这个值是否被改变，它都已经固定了，当然这是不给函数传递参数的前提下。  
**然后**解释为什么list1会随着list3的赋值而变化。这里涉及到python变量存储和深浅copy的知识如下：  
参考[Eva_J的博客](http://www.cnblogs.com/Eva-J/p/5534037.html)
  
#### python的变量存储
python中变量的存储采用引用语义的方式，存储的只是一个变量的值所在的**内存地址**，而不是变量的值本身。
顺便提一下，C语言不是这种方式，是值语义，即变量存储的就是一个值本身。
所以，python变量的大小都是一样的，因为**内存地址**的大小一致。而C语言的变量大小是不固定的。  
python中一切皆对象，即使不同的变量类型， 本质上也都是存储地址，如下图：  
![](http://oon3ys1qt.bkt.clouddn.com/python_value_storage.png)

#### 数据初始化对内存地址的影响

变量每一次初始化， 都开辟了一个新空间，然后将新内容的新地址赋给变量：
```python
>>> st1 = "Hello World."
>>> print id(st1)
139715299268008
>>> st1 = "to be"
>>> print id(st1)
139715299265296
```
等等，不同内容的地址肯定是不一致的，但是相同内容的地址就一定一致么？答案是no：
```python
>>> st1 = "Hello World."
>>> print id(st1)
139715299268008
>>> st2 = "Hello World."
>>> print id(st2)
139715299268064
```
再等等，那相同内容的地址，肯定也不一致么，那岂不是浪费很多内存空间？答案还是no：
```python
>>> st1 = 123
>>> st2 = 123
>>> print id(st1), id(st2)
34236496 34236496

>>> st1 = 123456123
>>> st2 = 123456123
>>> print id(st1), id(st2)
34569208 34569016
```
找不到规律，**目前唯一能确定的是：不同内容的内存地址是不一样的,而且，对简单数据结构(string)的重新初始化，会使内存地址变动**
```python
>>> st1 = 123
>>> st2 = st1
>>> print id(st1), id(st2)
34236496 34236496

>>> st1 = 456
>>> print "st1: %d, st1 address: %d" % (st1, id(st1)) 
st1: 456, st1 address: 34569208
>>> print "st2: %d, st2 address: %d" % (st2, id(st2)) 
st2: 123, st2 address: 34236496

```

#### 数据结构内部元素的变化对内存地址的影响
```python
>>> lst1 = [1, 2, 3, 'a']
>>> print "lst1: %r, address is %d" % (lst1, id(lst1))
lst1: [1, 2, 3, 'a'], address is 139715299231864
>>> lst1.append('to be')
>>> print "lst1: %r, address is %d" % (lst1, id(lst1))
lst1: [1, 2, 3, 'a', 'to be'], address is 139715299231864
>>> lst1.insert(0,0)
>>> print "lst1: %r, address is %d" % (lst1, id(lst1))
lst1: [0, 1, 2, 3, 'a', 'to be'], address is 139715299231864
>>> lst1[0] = 'to be'
>>> print "lst1: %r, address is %d" % (lst1, id(lst1))
lst1: ['to be', 1, 2, 3, 'a', 'to be'], address is 139715299231864

```
当对列表中的元素进行一些增删改的操作的时候，是不会影响到lst1列表本身的整个列表地址的，只会改变其内部元素的地址引用。可是当我们对于一个列表重新初始化(赋值)的时候，就给lst1这个变量重新赋予了一个地址，覆盖了原本列表的地址，这个时候，lst1列表的内存id就发生了改变。上面这个道理用在所有复杂的数据类型中都是一样的。
**这个原理就解释了最初本例中的list3 为什么会等于list1了，因为append对列表元素的操作不会更改内存地址，所以list1 and list3是一致的**

### 2. copy
首先，为什么要copy，从python的赋值原理可以看出， 对于list，dict等复杂数据结构来说，赋值等于完全共享资源。然而有时候需要既要保存原始数据，又要对数据进行新的操作，这时就需要copy了。
python的copy模块，有两种方法，一种是普通的copy，也叫浅拷贝；一种是deepcopy，又叫深拷贝。

#### 浅拷贝，copy
浅copy，无论多么复杂的数据结构， 浅拷贝只copy一层数据结构。
浅拷贝的形式有几种：

**切片操作：list_b = list_a[:]   或者 list_b = [each for each in list_a]
工厂函数：list_b = list(list_a)
copy函数：list_b = copy.copy(list_a)**

```python
>>> import copy
## 浅copy，将lst2 copy成copylst
>>> lst1 = ['a', 'b', 'c']
>>> lst2 = ['str1', 'str2', 'str3', lst1]
>>> copylst = copy.copy(lst2)
>>> print " The source lst is: ", lst2
 The source lst is:  ['str1', 'str2', 'str3', ['a', 'b', 'c']]
>>> print "The copy list is: ", copylst
The copy list is:  ['str1', 'str2', 'str3', ['a', 'b', 'c']]

##更改lst2内容，copylst不变
>>>lst2.append('lst2 str5')
>>> print " The source lst is: ", lst2
 The source lst is:  ['str1', 'str2', 'str3', ['a', 'b', 'c'], 'lst2 str5']
>>> print "The copy list is: ", copylst
The copy list is:  ['str1', 'str2', 'str3', ['a', 'b', 'c']]

##更改lst1内容，copylst和lst2共同变化，更改copylst的话，也会引起lst1变化
>>> lst1[0] = 'biubiu'
>>> print " The source lst is: ", lst2
 The source lst is:  ['str1', 'str2', 'str3', ['biubiu', 'b', 'c'], 'lst2 str5']
>>> print "The copy list is: ", copylst
The copy list is:  ['str1', 'str2', 'str3', ['biubiu', 'b', 'c']]
```
也就是说， 在字典套字典、列表套字典、字典套列表，列表套列表，以及各种复杂数据结构的嵌套中，浅拷贝只能copy“最外面的一层”数据，使其指向的地址无变化，但是对于复杂的数据，即使地址不变，里面的内容还可能发生变化(如例子里的lst1)，所以这时候，源数据和copy数据就会共同变化。

#### 深拷贝，deepcopy

deepcopy的原理就是完全开辟一块新的内存空间，无论数据结构有几层，都把其地址中指向的内容层层找到，然后复制下来，放在新的地址里，源数据和目标数据的地址完全隔离，所以也就不会再有关联了。
```python
>>> import copy
>>> lst1 = ['a', 'b', 'c']
>>> lst2 = ['str1', 'str2', 'str3', lst1]
>>> dcopylst = copy.deepcopy(lst2)
>>> print lst2
['str1', 'str2', 'str3', ['a', 'b', 'c']]
>>> print dcopylst
['str1', 'str2', 'str3', ['a', 'b', 'c']]

## 无论更改lst2还是lst1，都不会对deepcopy的dcopylst有影响
>>> lst2.append('lst2 biubiubiu')
>>>lst1.append('lst1 bobobo')
>>> print lst2
['str1', 'str2', 'str3', ['a', 'b', 'c', 'lst1 bobobo'], 'lst2 biubiubiu']
>>> print dcopylst
['str1', 'str2', 'str3', ['a', 'b', 'c']]

##反之亦然
>>> dcopylst[3].append('lst1 bububu')
>>> print dcopylst
['str1', 'str2', 'str3', ['a', 'b', 'c', 'lst1 bububu']]
>>> print lst1
['a', 'b', 'c', 'lst1 bobobo']
>>> print lst2
['str1', 'str2', 'str3', ['a', 'b', 'c', 'lst1 bobobo'], 'lst2 biubiubiu']
```

