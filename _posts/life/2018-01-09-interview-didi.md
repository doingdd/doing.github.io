---
title: Interview of 滴滴
category: life
layout: post
---


## 1. 自我介绍，介绍软件的架构

A.分布式系统，每个服务器有不同的角色，有统筹规划的pilot，有db，io，还有跑逻辑的application，这里问了一个问题，pilot如何知道消息该分发给哪一个app去处理，回答的是通过某一些配置文件，没答到点子上，这里应该是通过哈希算法实现的，但是具体的确实不了解。  

A. 这里一直没有完整的说出软件的架构究竟是什么，需要进一步思考，什么是架构？  

## 2. 负责的集成测试的点究竟在哪 

A. 这里也没有用最短的语言解释清楚，这个集成测试究竟是在测什么，关注什么？

总结： 首先集成测试，测的是服务器端，软件功能和系统功能的集合测试。 保证软件在打开各个新加feature的情况下，可以在系统上完整执行，并且处理正确；保证系统在平台版本更新之后，升级功能正常(upgrade),基本服务,典型逻辑使用正常(sanity test)，基本的错误处理机制正常(break test),服务器安全扫描正常(security test). 而且还包括一些涉及到多个网源，或者消息格式发生变化的新feature level的系统测试，主要关注的是消息是否可以分发正确。 
举例：平台配置LV的工具，add/delete/resize LV正常；新feature在消息中引入了一个新的域，则需要在模拟的客户环境中实现功能。  

## 3. 性能测试主要关注哪些指标？

A. TPS，disk io和memory。主要负责性能的benchmark测试，在把每个软件进程cpu usage推到65%的前提下，记录当前实际的TPS(通过5min内处理并正确返回的实际请求数计算每秒的请求数)，根据这个TPS和0.65的比例，计算出每一个请求所花费的CPU时间，这个时间作为performance benchmark test的一个结果，与上一个软件版本进行对比，得出结论并在必要的时候探寻原因。  

除此之外，还要关注disk io和memory的变化，通过平台提供的间隔5min的log，得到5min里每块磁盘的disk io，和软件进程的memory信息，这里，如果想实时地查看，可以通过top，iostat和vmstat等命令查看。当然，还有ps命令。  

A. 这里会涉及到TPS在随着并发用户数的增多而变化的曲线，也是性能测试模型的典型曲线，参考：[性能测试模型之曲线拐点模型](https://jingyan.baidu.com/article/5553fa82ba40be65a23934a6.html)，总结如下： 

![](http://oon3ys1qt.bkt.clouddn.com/performance.png)

在图中，我们的曲线图主要分为3个区域，分别是：light load ：轻压力区；heavy load ：重压力区；和bockle load 。  

图中的3条曲线，分别表示资源的利用情况（Utilization，包括硬件资源和软件资源）、吞吐量（Throughput，这里是指每秒事务数）以及响应时间（Response Time）。

图中坐标轴的横轴从左到右表现了并发用户数（Number of Concurrent Users）的不断增长。

在进行性能测试的时候，我们需要对图的曲线进行分析。分开来看的时候，相应时间（RT）、吞吐量（TPS）和资源利用率的变化情况分别是：
响应时间：随着并发用户数的增加，在前两个区，响应时间基本平稳，小幅递增。在第三个区域：急剧递增。在第三个区的点为拐点。
吞吐量：随着并发用户数的增加，在前两个区，对于一个良好的系统来说，并发用户数的增加，请求增加，吞吐量增加，中间的区域，处理达到顶点。
在第三个区：资源利用率：呈直线，表示饱和。

整体的分析思路：
当系统的负载等于最佳并发用户数时，系统的整体效率最高，没有资源被浪费，用户也不需要等待；当系统负载处于最佳并发用户数和最大并发用户数之间时，系统可以继续工作，但是用户的等待时间延长，满意度开始降低，并且如果负载一直持续，将最终会导致有些用户无法忍受而放弃；而当系统负载大于最大并发用户数时，将注定会导致某些用户无法忍受超长的响应时间而放弃。  

这个曲线，目前还没有在系统中实际测试过，可以有机会试一试。

## 5. mysql，查询表有多少行

SELECT COUNT(*) FROM table_name

## 6. mysql，复制一整个表到另一个数据库

SELECT * INTO new_table_name [IN externaldatabase] FROM old_tablename  

注意，into是在from之前用的，如果是外部数据库，使用in这个关键词，如果在当前数据库复制，则中括号里的内容去掉。  

## 7. shell，文件处理

日志文件，每一行三个域，以逗号隔开： `IP content url`    
找出IP出现次数最多的前五个IP。  

A. 
```shell
awk '{print $1}' file | sort |uniq -c|sort|tail -5
```

## 8. python 元类
在python中一切皆对象，元类就是可以动态创建类的类，在python中，所有内建类都来自元类type，可以用__class__属性查看，元类在ORM(object-relation-mapping,对象关系映射)中使用比较多，在实现一个自定义的数据库框架的时候，需要将每个表定义成一个类，每一行是其对象，这时会使用到自定义元类。  

## 9. 算法：数组，二分查找。
输入有序数组，和一个待查找的值。
返回该值在数组中的index，如果没有则返回-1
```python
#!/usr/bin/python

def bin_search(A,val):
    ## type A: list, val: int
    start = 0
    end = len(A) - 1
    while start <= end:
        mid = (start + end) / 2
        if val == A[mid]:
            return mid
        elif val > A[mid]:
            start = mid + 1
        else:
            end = mid - 1
    else:
        return -1


print bin_search([1,3,4,5,6],4)
print bin_search([1,3,4,5,6],1)
print bin_search([1,3,4,5,6],6)
print bin_search([1,3,4,5,6],2)
```

## 10. 算法：数组，n个数字的连续有序数组，尽量均匀的分成m份。
输入： 数字n，数字m   
返回：m个子数组   
例： 输入14，5，返回：[1,2,3],[4,5,6],[7,8,9],[10,11,12],[13,14]. 共五个数组，数组长度差不超过1.

```python
#!/usr/bin/python

def f(n,m):
    i = n % m
    j = n / m
    start = 0
    end = j + 1
    while i > 0:
        sub = []
        for k in range(start,end):
            sub.append(k)
        start += (j+1)
        end += (j+1)
        i -= 1
        print sub
    il = m - n % m
    end = start + j
    while il > 0:
        sub = []
        for k in range(start,end):
            sub.append(k)
        start += j
        end += j
        il -= 1
        print sub



f(14,5)
f(20,6)
f(14,4)
```
思路： n % m得到的是有多少个子数组的元素个数比较多，多1个。    
n/m 得到的是每个元素个数比较少的数组有几个元素。  
剩下的就是循环，先把元素个数多的子数组循环打印完，再打印元素个数比较少的子数组。

## 11. 算法：数组，给定有序数组和一个值，判断数组中是否有两个数之和等于这个给定值。  
A.对于给定数组A和值val，使用字典，需要空间复杂度O(n),遍历数组，判断当前值val是否存在在字典的key中，如果不存在，则创建一个key=(val-当前值)，value=当前值 的键值对，目的就是在遍历的过程中，寻找这个key；所以如果存在，则说明这个值被找到，这时，字典中的key:value一定存在在数组中，而且和为val。这个思路适用于无序的数组。 

面试官提出，如果数组有序，有什么办法，经过引导，决定用首尾字符相加的办法。
```python
def f(A,val):
    i = 0
    j = len(A) - 1
    while i <= j:
        if A[i] + A[j] < val:
            i += 1
        elif A[i] + A[j] > val:
            j -= 1
        else:
            print i,":",A[i],j,":",A[j]
            j -= 1
            i += 1

f([1,2,3,4,5,6],9)
```
这个写法还有一点要考虑的是，数组中是否有重复数字的问题，上解没有考虑，如果考虑，则需要在else里加很多判断，比较复杂。

## 12. 算法：字符串，找出最长子数字字符串。
给定字符串，返回它的最长的连续数字的子字符串。  

```python
#!/usr/bin/python

def f(s):
    j = 0
    max = 0
    for m in range(len(s)):
        try:
            int(s[m])
            max = m-j+1 if max < m-j+1 else max
        except:
            j = m+1
    return max

print f("abc1234c1c32")
```
这个仅实现了返回长度，还需要加点指针之类的返回最长字符串本身。

## 13. 算法：字符串，找字符串中的1的个数
要求，给定一个int整形，返回它之前的正整数中1出现的次数之和。
思路： 经过提示，可以简化成判断一个整数中1出现的个数，可以使用将该整数取整合取余的方法判断。
```python
#!/usr/bin/python
def f(n):
    result = 0
    for i in range(n+1):
        while i/10:
            if i % 10 == 1:
                result += 1
            i /= 10
        else:
            if i % 10 == 1:
                result += 1

    return result
print f(10)
print f(11)
print f(121)
```
就是先判断一个数对10取余是否等于1，如果等于则说明个位是1，然后在除以10之后继续这个过程来判断十位是否为1，然后判断百位千位，直到移位完成，这里需要考虑一个特殊情况就是数字以1开头的，所以加上了else里的判断。  

## 14.情景：滴滴打车过程，有什么着重需要测试的点？

A. 这个需要结合具体的业务场景分析，可以举一个平时打快车的例子，从下单开始，上车开始，计费，结算等几个方面考虑功能性的测试；也可以从系统稳定性，容灾性的方面考虑，比如当打车的时候断网，停电等情况的考虑；也可以从服务器端的性能方面考虑，大量用户的请求处理，地图定位，计费结算等等。综合考虑，这种不谈需求谈测试的问题能说的很多，但是也不容易说道点子上，还是需要日常多多思考这一类的问题，增强测试规划的能力。

## 15.算法：字符串，把字符串中的每一个空格替换成'20%'
给定字符串'hello world, i'm Doing'将其中的空格替换成'20%'，要求不要用内建函数。  
这个题目考察的是对内存空间的理解，因为空格占用一个字符，而20%占用三个，所以要多开辟内存空间来存放新的字符串，可以当时没有意识到这个题目的考点，仅用python写了个遍历，检测到空格则替换(而且错以为字符串可以直接s[i] = j这样赋值，实际上字符串是不可变对象，不可以这么赋值)，这里写下满足正确考察点的python吧：
```python
#!/usr/bin/python
def replace_s(s):
    # type s: string
    count = 0
    j = 0
    for i in s:
        if i == ' ':
            count += 1
    l = [[]] * (len(s) + count*2)
    for i in range(len(s)):
        if s[i] == ' ':
            l[j] = '2'
            l[j+1] = '0'
            l[j+2] = '%'
            j += 3
        else:
            l[j] = s[i]
            j += 1
    return ''.join(l)


print replace_s('hello world, im doing')
```
输出：
```python
hello20%world,20%im20%doing
```
思路就是，先遍历字符串得出空格的个数，然后开辟一个空间，长度为"字符串长度+空格个数*2",然后再遍历原字符串，遇空格则一次放入2，0，%，当然，这需要一个额外的指针j来完成(指针j加3)，如果不是空格，则原样copy，并且指针j加1.