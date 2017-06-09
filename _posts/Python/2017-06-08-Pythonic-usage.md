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