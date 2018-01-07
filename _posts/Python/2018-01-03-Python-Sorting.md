---
category: Python
layout: post
title: 七大排序算法的python实现
---

**本文介绍七大排序算法的思路，以及他们的python实现。**

# 排序算法
排序算法可以分成两大类，内部排序和外部排序，内部排序在总量不大的情况下，数据在内存中进行排序，外部排序是因为排序的数据比较大，一次不能容纳全部的排序记录，在程序运行中需要访问外存。  

常见的内部排序算法有七种，下图列出了它们的时间和空间复杂度、稳定性等特点。    

![](http://oon3ys1qt.bkt.clouddn.com/sorting_differ.png)   

其中，稳定性指的是如果序列中有相同值，在排序之后，如果相同值之间的位置没有发生变化则稳定，反之则不稳定。  

## 1.冒泡排序

冒泡排序是通过比较相邻两个数的大小来实现排序的，在第一趟遍历元素中，两两比较并把大的数放在右边，知道遍历到最后一个元素，这时该数组的最大值像一个浮出水面的泡泡"浮到"序列"顶端"(末尾)。然后第二趟遍历，知道倒数第二个元素为止，以此类推，在n-1趟遍历之后，数组保证有序。 

```python
def bubble_sort(A):
    ## type A: list
    i = len(A)-1
    while i > 0:
        for j in range(i):
            if A[j] > A[j+1]:
                A[j],A[j+1] = A[j+1],A[j]
        i -= 1
    return A

print bubble_sort([])
print bubble_sort([1])
print bubble_sort([2,1])
print bubble_sort([1,3,2])
print bubble_sort([2,2,3,1,2,4,4,1,5])
```
注意内部遍历的时候，不要超越数组长度，因为有一个`j+1`的调用。

## 2. 选择排序
选择排序和冒泡其实很相似，它的思路是每一趟都选择一个最小的数放在序列的前面，然后无序区的元素越来越少，有序区的元素越来越多，最后保证全部有序。  
```python
def select_sort(A):
    for i in range(len(A)):
        min = i
        for j in range(i,len(A)):
            min = j if A[j] < A[min] else min
        A[i],A[min] = A[min],A[i]
    return A

print select_sort([])
print select_sort([1,2])
print select_sort([2,1])
print select_sort([1,3,2])
print select_sort([2,1,3,3,])
print select_sort([1,1,4,3,5,5,2])
print select_sort([1,1,5])
```
这个思路的关键在于最小数的选择，使用指针min来记录最小值的位置，然后循环一遍之后直接把最小值和有序区最后一位交换。

## 3. 插入排序
将待排序的数组划分为局部有序子数组subSorted和无序子数组subUnSorted，每次排序时从subUnSorted中挑出第一个元素，从后向前将其与subSorted各元素比较大小，按照大小插入合适的位置，插入完成后将此元素从subUnSorted中移除，重复这个过程直至subUnSorted中没有元素，总之就时从后向前，一边比较一边移动。

```python 
def insert_sort(A) 
    ## type A: list 
    for i in range(1,len(A)): 
        j = i - 1
        val = A[i]
        while j >= 0:
            if val < A[j]:
                A[j+1] = A[j]
                A[j] = val
            j -= 1

    return A

print insert_sort([])
print insert_sort([1,2])
print insert_sort([2,1])
print insert_sort([1,3,2])
print insert_sort([2,1,3,3,])
print insert_sort([1,1,4,3,5,5,2])
print insert_sort([1,1,5])
```
这个思路使用的是交换插入的办法，比较需要插入的值和当前值，如过小于则把当前值后移一位，把插入值放在当前值的位置上，如果大于则什么也不做(因为一旦大于说明插入值的位置是正确的不需要再变化)。

## 4. 希尔排序
希尔排序可以理解成插入排序的升级版，在插入排序的思路基础上，有一个步长的概念，即在给待插入值选择位置的时候，每次向前跳一个步长，而不是每次移动一位，这样可以加快效率，所以它的时间复杂度是O(nlogn).    

希尔排序由希尔在1959年提出，基于插入排序发展而来。希尔排序的思想基于两个原因：

1）当数据项数量不多的时候，插入排序可以很好的完成工作。

2）当数据项基本有序的时候，插入排序具有很高的效率。

基于以上的两个原因就有了希尔排序的步骤：

a.将待排序序列依据步长(增量)划分为若干组，对每组分别进行插入排序。初始时，step=len/2，此时的增量最大，因此每个分组内数据项个数相对较少，插入排序可以很好的完成排序工作（对应1）。

b.以上只是完成了一次排序，更新步长step=step/2,每个分组内数据项个数相对增加，不过由于已经进行了一次排序，数据项基本有序，此时插入排序具有更好的排序效率(对应2)。直至增量为1时，此时的排序就是对这个序列使用插入排序，此次排序完成就表明排序已经完成。
```python
def shell_sort(A):
    # type A: list
    step = len(A) / 2
    while step > 0:
        for n in range(step):
            for i in range(n+step,len(A)):
                j = i - step
                val = A[i]
                while j >= 0:
                    if val < A[j]:
                        A[j+step] = A[j]
                        A[j] = val
                    j -= step
        step /= 2
    return A
print shell_sort([])
print shell_sort([1,2])
print shell_sort([2,1])
print shell_sort([1,3,2])
print shell_sort([2,1,3,3,])
print shell_sort([1,1,4,3,5,5,2])
print shell_sort([1,1,5])
```
写希尔排序的思路可以是先写出一个插入排序，然后再在插入排序外层包两层，第一层while用来控制step,每次循环step除2，第二层用来控制group，由于step的引入，相当于把序列分成了step-1个子序列组，每个子序列里面执行的就是步长为step的插入排序了，相当于把所有插入排序里面的数字`1`替换成`step`.  

## 5. 归并排序
归并的含义就是将两个或多个有序序列合并成一个有序序列的过程，归并排序就是将若干有序序列逐步归并，最终形成一个有序序列的过程。以最常见的二路归并为例，就是将两个有序序列归并。归并排序由两个过程完成：有序表的合并和排序的递归实现。
下图举例说明了归并排序的递归实现原理：   
 
![](http://oon3ys1qt.bkt.clouddn.com/merge_sort.png)

```python
def merge(left,right):
    # type left,right: sorted list
    # rt: sorted merge list
    i = j = 0
    result =[]
    while i < len(left) and j < len(right):
        if left[i] < right[j]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1
    if i < len(left):
        result.extend(left[i:])
    if j < len(right):
        result.extend(right[j:])

    return result

def merge_sort(A):
    # type A: list
    # rt: sorted list
    #print A
    if len(A) <= 1:
        return A
    num = len(A) / 2
    left = merge_sort(A[:num])
    right = merge_sort(A[num:])
    A = merge(left,right)

    return A

print merge_sort([])
print merge_sort([1,2])
print merge_sort([2,1])
print merge_sort([1,3,2])
print merge_sort([2,1,3,3,])
print merge_sort([1,1,4,3,5,5,2])
```
这个写法有两点：一是递归的调用merge_sort函数，目的是将数组分成不大于1的长度，所以必须处理数组长度为一时的情况，这也是递归调用必须要考虑的，否则就变成无限递归了；二是merge函数的思路，需要考虑指针溢出的情况，所以while循环使用的and关键词，保证任何指针都不溢出，这样一来，就需要下面的两个if判断，将merge这一过程完成。  

## 6. 快速排序

快排有两种实现，递归和非递归，这里仅讨论递归的实现；算法的核心在于找到一个基准值，把所有小于它的值放左边，大于的放右边；然后递归的使用相同的方法去排序这个基准值左边的和右边的子序列，直到子序列的长度为1为止。  

首先选定基准值(选第一个元素为基准不好，尽量选中值)，把中值和序列末尾的数值交换；并且定义两个指针i 和 j，j从后往前遍历直到找到比基准值小的数字停止，i从前往后直到找到比基准值大的数字停止，这时在i和j没有相遇过的情况下，交换i和j位置上的元素(如果相遇或者相错则这一轮的循环停止，不做任何交换)，交换之后j继续向前，i继续向后，重复直到i和j相遇或相错开，一轮循环停止，将序列末尾的值交换回i当前指向的位置，这时，i的左边一定小于等于基准值，右边一定大于等于基准值。  

然后就是递归的实现左子序列和又子序列的排序了，代码如下：
```python
def quick_sort(A):
    if len(A) <= 1:
        return A
    # use mid value as pivot
    mid = A[len(A)/2]
    # exchange the mid value to the last.
    A[len(A)/2],A[-1] = A[-1],A[len(A)/2]
    i = 0
    j = len(A) - 2
    while i < j:
        # use j to find the value that <= mid
        while j > 0 and A[j] > mid:
            j -= 1
        # use i to find value that >= mid
        while A[i] < mid:
            i += 1
        if i <= j:
            A[i],A[j] = A[j],A[i]
    A[i],A[-1] = A[-1],A[i]

    ## recursion, no need to recurs the pivot: A[i]
    A = quick_sort(A[:i]) + [A[i]] + quick_sort(A[i+1:])
    return A

print quick_sort([])
print quick_sort([1])
print quick_sort([1,1])
print quick_sort([5,4,3,2,1])
print quick_sort([5,4,3])
print quick_sort([1,3,1])
print quick_sort([1,2])
print quick_sort([2,1])
print quick_sort([3,2,4,1])
```
这里顺便提一下测试用例的设计，尽量考虑边界值条件，例如[3,2,4,1]，使用这个算法会导致选定的基准值本身就是序列的最大值，这样可以测试子序列的划分是否正确，同理[3，1，4]；又如[1,1]可以测出这个算法的无限递归的风险，因为最后递归调用的时候，如果不把基准值单取出来，而是加入递归里面继续排序的话，会导致两个元素的序列形成无限递归。  




