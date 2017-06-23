---
layout: post
category: Python
title: Python中优雅的用法
---

1. 递归重构嵌套list(两重嵌套):

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
2. 遍历元素
```python
for i in xrange(6）：
  print i
```

3. 同时遍历索引和值：
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
4. 遍历字典
```python
for k, v in iteritems(dict):
        print k, "-->", v
```
5. 字符串连接：
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

6. 装饰器
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



