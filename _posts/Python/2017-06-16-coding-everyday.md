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

## leetcode, Q3: Longest Substring Without Repeating Characters
**问题：** 给定一个字符串，找到其长度最长的不包含重复字符的子字符串。   
**例：**   
"abcabcbb"，答案是"abc",输出为3    
"bbbbb",答案是"b",输出为1     
"pwwkew",答案是"wke"，输出为3   
"",输出为0    
"a",输出为1    

**思路：**一开始的思路是用两层遍历，将遍历过的元素从在一个列表中，然后查看元素是否已经出现过，如果出现过则把当前的列表长度记下来，再把原字符串的第一个元素剔除，再继续下一轮。这种暴力循环虽然能解决问题，但是遇到长字符串的case就time out了，所以有了如下改进版，时间复杂度为O(n):  
```python
class Solution(object):
    def lengthOfLongestSubstring(self, s):
        """
        :type s: str
        :rtype: int
        """
		# 把字符串转成列表
        l = list(s)
    	# 创建一个列表用来存放所有符合要求的子字符串的长度
        len_list = []
		# 创建一个list，用来存放子字符串，每次遍历的元素都要和其比对
        return_sub_l = []
        
        for v in l:
            if v not in return_sub_l:
                return_sub_l.append(v)
            else:
				# 如果元素已经出现过，则把之前的子字符串的长度保存
				# 并把子字符串中重复元素前的元素全删除，继续遍历
                len_list.append(len(return_sub_l))
                return_sub_l[:return_sub_l.index(v)+1] =[]
                return_sub_l.append(v)
      
        len_list.append(len(return_sub_l))

        return max(len_list)
```
然后，看看大神的方法，发现它们经常用字典解决问题(字典是hastable，时间复杂度为O(1)：
```python
class Solution:
    # @return an integer
    def lengthOfLongestSubstring(self, s):
        start = maxLength = 0
        usedChar = {}
        
        for i in range(len(s)):
            if s[i] in usedChar and start <= usedChar[s[i]]:
                start = usedChar[s[i]] + 1
            else:
                maxLength = max(maxLength, i - start + 1)

            usedChar[s[i]] = i

        return maxLength
```
这个逻辑有点复杂，相当于计算起始位和截止位之差的思路，用userChar存放元素和其位置，然后只要没循环到重复字符，长度就一直随着i的增长而加一，一旦碰到重复字符，就将起始位设成当前字符所在位置。maxlenth用来存放之前循环过的子字符串最长长度。

## leetcode Q7.Reverse Integer
**题目：** 反转整数    
**例**： x = 123, return 321  
x = -123, return -321
**假设：**  输入为32位带符号整数，如果反转后超过32位限制，应该返回0  

**思路**：将整数转换成字符串再转换成list，然后reverse list返回。需要判断是否为负数的情况，结果需要判断是否overflow。
```python
class Solution(object):
    def reverse(self, x):
        """
        :type x: int
        :rtype: int
        """
        if x >= 0:
			# 整数为正则直接转换后反转
            temp = ''.join(list(str(x))[::-1])
        else:
			# 为负则先反转不带符号的位数，再加上符号位
            temp = '-' + ''.join(list(str(x))[:0:-1])
        
        reverse_x = int(temp)

		# 带符号32位整数的范围是 -2**31 ~~ 2**31-1
        if -(2**31) <= reverse_x < 2**31:
            return reverse_x
        else:
            return 0
            
```
然后，膜拜一下牛人的写法：  
```python
def reverse(self, x):
    s = cmp(x, 0)
    r = int(`s*x`[::-1])
    return s*r * (r < 2**31)
```
`cmp(x,y)`的用法是比较两数大小，返回值分别为1(>), -1(<), 和0(==).
反引号"`"的作用是特定的对象转换成string，这里的第二句:  
```python
r = int(`s*x`[::-1])
```
首先用符号位s乘以数字本身，得到了其绝对值，再转成字符串接着切片反转，返回的是整数绝对值的reverse结果，cool。  
最后s*r把符号位附上，接着乘以一个flag(overflow则乘以0，不overflow则乘以1)。  
总结几点：  
1.反引号的用法  
2.cmp的用法  
3.整数绝对值的取法
4.string也可以切片，不用非得转成list
5.判断x<y的返回值实际上等价于0或者1  

## leetcode Q5.Longest Palindromic Substring
**题目：**给定字符串s，找出其最长回文串，假设字符串不超过1000位。    
**例：**input：'babad' -> output: 'bab' or 'aba'   
input: 'cbbd -> output: 'bb'    
input: 'abc' -> output: 'c'  
input: '' -> output: ''  
**思路：**回文串指的的是正读反读都一样的字符串,aba, abcba, cc等都属于正反都一样的。核心思路是遍历字符串，判断当前字符是否在之前出现过，如果出现过则切片形成子字符串，然后判断其正序和逆序是否相等。找出所有的回文串之后，判断其长度并返回最长的。  
给这个题跪了，case情况是完全覆盖了，可是只能写出复杂度O(n^2)的答案了(slicing and reverse is O(k) where k is the sliced/reversed string length)，leetcode没给过，超时了。。。其实最长的case也就处理384ms，想不出更好的办法了，如下：  
```python
def longestPalindrome(self, s):
        """
        :type s: str
        :rtype: str
        """
		# d used to store single charactor and its index.
		# consider one charactor appears several times, its value is a list as d = {'a':[0, 1]}
        d = {}
		# palin_s store the palindormic substring and its length.
        palin_s = {}
        max_len = 0
        max_palin_s = ""
        if len(s) == 1:
            return s
        if not s:
            return ""
        for k, v in enumerate(s[:]):
            if v in d:
                for i in d[v]:
                    t_s = s[i:k+1]
                    if t_s[:] == t_s[::-1]:
                        palin_s[t_s] = len(t_s)
                
            d[v] = d.get(v,[])
            d[v].append(k)
        palin_s[v] = 1
    
        for k, v in palin_s.items():
           # print "k,v = {},{}".format(k, v)
            if v > max_len:
                print "v = ", v
                max_len = v
                max_palin_s = k
                
        return max_palin_s
```
迫不及待看看大牛的办法： 
```python
class Solution:
    # @return a string
    def longestPalindrome(self, s):
        if len(s)==0:
        	return 0
        maxLen=1
        start=0
        for i in xrange(len(s)):
        	if i-maxLen >=1 and s[i-maxLen-1:i+1]==s[i-maxLen-1:i+1][::-1]:
        		start=i-maxLen-1
        		maxLen+=2
        		continue

        	if i-maxLen >=0 and s[i-maxLen:i+1]==s[i-maxLen:i+1][::-1]:
        		start=i-maxLen
        		maxLen+=1
        return s[start:start+maxLen]
```
这个复杂度严格说不算O(n^2)，它比O(n^2)要快的多，因为分片是调用c接口实现的，实际上的复杂度应该是O(k)。