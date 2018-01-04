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
选择排序和冒泡其实很相似，它的思路是每一趟都选择一个最小的数放在序列的前面，然后无序区的元素越来越少，有序区的元素越来越多，最后保证全部有序。需要注意的是记录最小值的时候可以使用一个指针，不需要每次比较之后赋值给变量。
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

## 插入排序
将待排序的数组划分为局部有序子数组subSorted和无序子数组subUnSorted，每次排序时从subUnSorted中挑出第一个元素，从后向前将其与subSorted各元素比较大小，按照大小插入合适的位置，插入完成后将此元素从subUnSorted中移除，重复这个过程直至subUnSorted中没有元素，总之就时从后向前，一边比较一边移动。
```python
def insert_sort(A)
    ## type A: list
    for i in (1,len(A)):
        j = i - 1
    