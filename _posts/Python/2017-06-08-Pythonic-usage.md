---
layout: post
category: Python
title: Python中优雅的用法
---

## 递归重构嵌套list(两重嵌套):  

```python
>>> lst
[[u'0-0-5', u' 0-0-13'], [u'0-0-2', u' 0-0-10', u' 0-0-3', u' 0-0-11']]
>>> sum(lst,[])
[u'0-0-5', u' 0-0-13', u'0-0-2', u' 0-0-10', u' 0-0-3', u' 0-0-11']

>>> reduce(lambda x,y: x+y, lst)
[u'0-0-5', u' 0-0-13', u'0-0-2', u' 0-0-10', u' 0-0-3', u' 0-0-11']

>>> [item for sublist in lst for item in sublist]
[u'0-0-5', u' 0-0-13', u'0-0-2', u' 0-0-10', u' 0-0-3', u' 0-0-11']
```

```python
>>> a = [[1, 2], [3, 4], [5, 6]]
>>> list(itertools.chain.from_iterable(a))
[1, 2, 3, 4, 5, 6]

>>> sum(a, [])
[1, 2, 3, 4, 5, 6]

>>> [x for l in a for x in l]
[1, 2, 3, 4, 5, 6]
```
##  遍历元素
```python
for i in xrange(6）：
  print i
```
## 切片
```python
iterms = range(10)
# 从索引值为1到索引值为3的元素：
iterms[1:4]
# 奇数
items[1::2]
# 拷贝
copy_iterms = iterms[:]
```
详见[Python list usage](http://doing.cool/2017/04/13/Python-list-usage.html)

##  同时遍历索引和值：
```python
>>> colors = ['red', 'green', 'blue', 'yellow']
>>> for i, color in enumerate(colors):
...     print i, '-->', color
... 
0 --> red
1 --> green
2 --> blue
3 --> yellow
```
## 遍历字典
```python
for k, v in iteritems(dict):
        print k, "-->", v
```
## 获取字典元素
正常用法（如果存在返回值，不存在返回指定值）：
```python
d = {'name': 'foo'}
if d.has_key('name'):
  print d['name']
else:
  print 'unknown'
```
pythonic:
```python
d.get('name', 'unknown')
```
也可以用于字典赋值：
```python
d['name'] = d.get('name', 'doing')
```

## 字符串连接：
```python
# 加号：
>>> url = "111" + "222"
>>> url
'111222'
# 直接连：
>>> url = "111" "222"
>>> url
'111222'
# join list转字符串：
>>> url = ["111", "222"]
>>> ' '.join(url)
'111 222'
>>> print ','.join(url)
111,222
>>> ''.join(url)
'111222'
```

## 6. 装饰器
简单的装饰器定义：
```python
#!/usr/bin/python

def decorator(func):
        def wrapper():
                print func.__name__, "Start:"
                func()
                print func.__name__, "End."
        return wrapper
```
调用和显示：
```python
def log():
        print "I'm thinking something."

@decorator
def doing():
        print "Now just do it."

log()
doing()
```
```python
BJATCA7-0-0-1:/u/ainet/yidu/tools-> ./decorator.py 
I'm thinking something.
doing Start:
Now just do it.
doing End.
```

## 真值判断
检查某个对象是否为真或者是否不为空时，pythonic的用法是直接if 后接对象， python中的真假值对照表：

类型|False|True
---|---|---
布尔|False(与0等价)|True(与1等价)
字符串|""(空字符串)|非空字符串(如" ", "blog")
数值|0, 0.0| 非零的数值(如0.1， -1)
容器|{},(),[]| 至少有一个元素(如[None], (None,), [""])
None|None|非None对象

```python
>>> lst = (None,)
>>> print lst if lst else "Nothing"
(None,)

>>> lst = []
>>> print lst if lst else "Nothing"
Nothing

>>> lst = [None]
>>> print lst if lst else "Nothing"
[None]

>>> lst = 0.0
>>> print lst if lst else "Nothing"
Nothing
>>> lst = -1
>>> print lst if lst else "Nothing"
-1
```

## 三目运算

已经在**真值运算**里用到： b?x:y的形式.
```python
text = '男' if gender == 'male' else '女'
```
注意else后不要重复写运行语句，`text = '女'`， 会报错
```python
>>> gender = 'female'
>>> text = '男' if gender == 'male' else '女'
>>> print text
女