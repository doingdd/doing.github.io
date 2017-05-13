---
category: Python
layout: post
title: Python标准库 -- json
---
**本文介绍python标准库的json模块， 参考：**  
[官网](https://docs.python.org/2/library/json.html?highlight=json#module-json)  
[python解析json-hihite](http://www.cnblogs.com/kaituorensheng/p/3877382.html)  
# json模块的函数：
**`json.dumps(obj, skipkeys=False, ensure_ascii=True, check_circular=True, allow_nan=True, cls=None, indent=None, separators=None, encoding="utf-8", default=None, sort_keys=False, **kw)`**  
json.dumps()函数将**python对象编码**转换成字符串。  
**`json.loads(s[, encoding[, cls[, object_hook[, parse_float[, parse_int[, parse_constant[, object_pairs_hook[, **kw]]]]]]]])`**  
json.loads()函数将json格式的字符串转换成python对象。    

**注意**，虽然两个函数意义上是完全可逆，但是有可能一个dict对象经过dumps和loads之后并不会和原dict完全一致，因为json.dumps会将所有的key和value转换成**字符串**，而如果dict含有non-string key，则会导致差异。

`skipkeys`: 如果为True，不属于基本类型(str, unicode, int, long, float, bool, None)的dict的key会skip，否则，raise一个TypeError.  
`ensure_ascii`: 如果为True，所有non-ASCII字符会转换成\uXXX.  
`check_circular`:  如果为false，则不会check circular reference，会导致OverflowError或者更坏的结果。  
`allow_nan`： 如果为False，当float超出范围时，raise ValueError，如果为True(默认)，使用JavaScript(NaN, Infinity, -Infinity).  
`intent`:  pretty print. 如果制定一个非负值，则根据level来pretty-printed。如果为0或者负数，则仅插入新行。默认为None，紧凑表示。  
**注意**，如果指定intent，最好指定separater(item_separator, key_separator) 为：(',', ':')，默认为(', ', ': ')，注意默认时冒号后面的空格。  
`encoding`: 编码格式，默认UTF-8.  
`sort-keys`: 如果为True， dictionary输出时会按key值排序(dict是没有顺序的)。   
python数据类型到json的转化关系：  

Python	|JSON
---|---
dict	|object
list, tuple	|array
str, unicode	|string
int, long, float|	number
True	|true
False	|false
None	|null

# 例子

json.dumps(), dict转换成字符串：
```python
>>> import json
>>> data1 = {'b':789,'c':456,'a':123}
>>> d1 = json.dumps(data1,sort_keys=True,indent=4)
>>> print d1
{
    "a": 123, 
    "b": 789, 
    "c": 456
}

>>> d1
'{"a": 123, "b": 789, "c": 456}'
>>> data1
{'a': 123, 'c': 456, 'b': 789}
```
json.loads()，字符串转化成dict：
```python
>>> import json
>>> d1 = '{"a": 123,"b": 789,"c": 456}'
>>> data1 = json.loads(d1)
>>> d1
'{"a": 123,"b": 789,"c": 456}'
>>> data1
{u'a': 123, u'c': 456, u'b': 789}
```
json.load()处理json文件：
```python
[root@localhost python]# cat ppalp.json 
[
    {
        "path": "/u/ainet/yidu/rtdb_tar/GCIPL28G.tar",
        "FILE_SIZE":"122m",
        "CACHE_SIZE":"121m"
    },
    {
        "path": "/u/ainet/yidu/rtdb_tar/SIMDB28I.tar",
        "RTDBVG":"repluser2"
    }
]

>>> import json
>>> j = json.load(open('ppalp.json'))
>>> j
[{u'CACHE_SIZE': u'121m', u'path': u'/u/ainet/yidu/rtdb_tar/GCIPL28G.tar', u'FILE_SIZE': u'122m'}, {u'path': u'/u/ainet/yidu/rtdb_tar/SIMDB28I.tar', u'RTDBVG': u'repluser2'}]
>>> j[0].keys()
[u'CACHE_SIZE', u'path', u'FILE_SIZE']
>>> j[1].keys()
[u'path', u'RTDBVG']
```