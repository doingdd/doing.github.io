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
json 的转化关系：  

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

