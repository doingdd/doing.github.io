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
还有一种写法，返回小于某个特定值的斐波那契：
```python
def fib(n):
  a, b = 0, 1
  while a < n:
    yield a
    a, b = b, a + b
```
输出：
```python
>>> for i in fib(10):
...     print i
...     
0
1
1
2
3
5
8
```
## leetcode Q1: Two Sum
Question:
Given an array of integers, return indices of the two numbers such that they add up to a specific target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.  

Example:
```python
Given nums = [2, 7, 11, 15], target = 9,

Because nums[0] + nums[1] = 2 + 7 = 9,
return [0, 1].
```
思路：遍历list中的每个元素与其余元素的和，判断是否为target，如果是，需要返回这两个元素的index。用到了两次遍历：
```python
class Solution(object):
    def twoSum(self, nums, target):
        """
        :type nums: List[int]
        :type target: int
        :rtype: List[int]
        """
        for key in xrange(len(nums)-1):
            for k, v in enumerate(nums[key+1:]):
                if nums[key] + v == target:
                    return [key, key+k+1]
```
和solution 方法一类似，属于暴力循环，时间复杂度O(n^2)  
顺便写一下leetcode报过错的几个测试用例，从测试的角度看很有意义：
case1: 输入 [3, 4, 2], target = 6  
case2: 输入[3,3]，target = 6  
case3: 输入[3, 2, 3]， target = 6  
值得一提的是case2和case3，case2直接导致使用list.index(value)的办法失效，因为其返回的index只能是第一个匹配的index， case3导致使用if len(nums) == 2这种判断方式不能覆盖，所以产生了最后的答案：return [key, key+k+1]，两个case的本质是临界条件输入，玩的溜。    
**最后，看看人家写的时间复杂度O(n)的方案，wonderful：**  
```python
class Solution(object):
    def twoSum(self, nums, target):
        d = {}
        for i, n in enumerate(nums):
            m = target - n
            if m in d:
                return [d[m], i]
            else:
                d[n] = i
```
