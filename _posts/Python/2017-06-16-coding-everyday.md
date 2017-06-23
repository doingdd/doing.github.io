---
layout: post
category: 技术
title: 每天一点coding
---
**本文记录每天的coding题目**  
## 1. 列表按相同元素分割
题目： [0,0,0,1,1,2,3,3,3,2,3,3,0,0] 分割成：[[0,0,0],[1,1],[2],[3,3,3],[2],[3,3],[0,0]]  
解答思路，拿到前一个元素和后一个元素不相等时的索引值，按索引值切片分割：
```python
[root@heatvm yidu_bk]# cat test.py 
#!/usr/bin/python

lst = [0,0,0,1,1,2,3,3,3,2,3,3,0,0]
def return_cut_list(input):
        rt = []
        n = 0
        for i in range(len(lst)-1):
                if lst[i] != lst[i+1]:
                        rt.append(lst[n:i+1])
                        n = i+1
        return rt

print return_cut_list(lst)
```
输出：
```python
[root@heatvm yidu_bk]# ./test.py 
[[0, 0, 0], [1, 1], [2], [3, 3, 3], [2], [3, 3]]
```
还有个更简单的，用itertools.groupby: 
```python
>>> from itertools import groupby
>>> [list(v) for k, v in groupby([0,0,0,1,1,2,3,3,3,2,3,3,0,0])]
[[0, 0, 0], [1, 1], [2], [3, 3, 3], [2], [3, 3], [0, 0]]
```
itertools.groupby(iterable[, key]),输入一个可迭代对象，返回对象里按vaule相等分成的groups的集合的可迭代对象。   
注意，返回的是一个迭代器，需要用for读取。

## 2. 斐波那契数列的实现
题目： 输出斐波那契数列[0, 1, 1, 2, 3, 5, 8, 13......]  
思路： 除了第0，1个元素以外，每个元素等于其前两个元素之和，顺序迭代： `a, b = b, a + b`
```python
-> cat Fib.py
#!/usr/bin/python
import sys
value = int(sys.argv[1])
def Fib(max):

  n, a, b = 0, 0, 1

  while n < max:
    if n == 0:
      yield a
      n += 1
    else:
      yield b
      a, b = b, a + b
      n += 1 

  raise StopIteration

print [i for i in Fib(value)]
```
输出：
```python
-> ./Fib.py 5
[0, 1, 1, 2, 3]
```