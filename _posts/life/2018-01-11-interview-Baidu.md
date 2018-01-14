---
layout: post
category: life
title: interview--百度
---

## 1. 算法：字符串，给定字符串，统计其中每一个字符出现的次数。
```python
#!/usr/bin/python
def calc_charac(s):
    #type s: str
    d={}
    for i in range(len(s)):
        d[s[i]] = d.get(s[i],0) + 1
    return d

print calc_charac('hello world')
print calc_charac('')
print calc_charac('aaa')
print calc_charac('abcabc')
print calc_charac('abababab')
```
使用key:value形式记录每个字符出现的次数。 这里解释一下`d.get(s[i],0)`，表示当d中没有以s[i]为key的元素值时，使用默认值0，有的话就用当前的d[s[i]]的值。  

## 2. shell,python, 两个日志文件合二为一。
题目：两个日志文件，格式一样，都是`logid 字段1 字段2`的格式，logid是字符串，要求将两个文件中logid相同的行打印到另一个文件，logid没同时出现在两个文件中则忽略。  


```shell
root@Doing:~/sorting# cat logid_merge.sh 
#!/bin/bash
file="./c"
while read line_a;do
    id_a=$(echo $line_a|awk '{print $1}')
    while read line_b;do
        id_b=$(echo $line_b|awk '{print $1}')
        if [ "$id_a" == "$id_b" ];then
            grep $line_a $file > /dev/null 2>&1
            [ "$?" -ne 0 ] && echo -e "$line_a\n$line_b" >> $file \
                           || echo "$line_b" >> $file
        fi
    done < ./b
done < ./a
```
这个办法比较笨，用了两个while循环，思路就是读取文件a的一行，然后遍历文件b，看看有没有logid相同的行，有的话就一起放在文件c，没有就什么也不做，比如文件a和文件b如下：  
```shell
root@Doing:~/sorting# cat a
1-1 00:00:00 Aeijing
1-2 00:00:01 Aeijin
1-3 00:00:02 Aeiji
1-4 00:00:03 Aeij
1-5 00:00:04 Aei
1-6 00:00:05 Ae
1-7 00:00:06 A
root@Doing:~/sorting# cat b
1-1 00:00:00 Beijing
1-2 00:00:01 Beijin
1-3 00:00:02 Beiji
1-4 00:00:03 Beij
1-5 00:00:04 Bei
2-6 00:00:05 Be
2-7 00:00:06 B
```
执行之后合并成一个文件c：
```shell
root@Doing:~/sorting# cat c
1-1 00:00:00 Aeijing
1-1 00:00:00 Beijing
1-2 00:00:01 Aeijin
1-2 00:00:01 Beijin
1-3 00:00:02 Aeiji
1-3 00:00:02 Beiji
1-4 00:00:03 Aeij
1-4 00:00:03 Beij
1-5 00:00:04 Aei
1-5 00:00:04 Bei
```
**python实现：**  
```python
root@Doing:~/sorting# cat logid_merge.py 
#!/usr/bin/python
def merge_logfile():
    with open('./c','w') as f: 
        for line_a in open('./a'):
            id_a = line_a.split(' ')[0]
            for line_b in open('./b'):
                id_b = line_b.split(' ')[0]
                if id_a == id_b:
                    f.writelines([line_a,line_b])

merge_logfile()
```

实际上，文件合并的问题在shell里面有几个命令就可以实现：`join`和`paste`(cat等)  
**用join实现一下：**  
```shell
root@Doing:~/sorting# join a b
1-1 00:00:00 Aeijing 00:00:00 Beijing
1-2 00:00:01 Aeijin 00:00:01 Beijin
1-3 00:00:02 Aeiji 00:00:02 Beiji
1-4 00:00:03 Aeij 00:00:03 Beij
1-5 00:00:04 Aei 00:00:04 Bei
```
相当于合并成一行了(join合并前先排好序，join可以指定按哪一列合并，用-j参数)  

**paste的功能是按行合并，不管重复与否：**  
```shell
root@Doing:~/sorting# paste -d ' ' a b
1-1 00:00:00 Aeijing 1-1 00:00:00 Beijing
1-2 00:00:01 Aeijin 1-2 00:00:01 Beijin
1-3 00:00:02 Aeiji 1-3 00:00:02 Beiji
1-4 00:00:03 Aeij 1-4 00:00:03 Beij
1-5 00:00:04 Aei 1-5 00:00:04 Bei
1-6 00:00:05 Ae 2-6 00:00:05 Be
1-7 00:00:06 A 2-7 00:00:06 B
```

## 3. 冒泡排序
```python
#!/usr/bin/python
def bubble_sort(A):
    #type A: list
    i = len(A) - 1
    while i >= 0:
        for j in range(i):
            if A[j] > A[j+1]:
                A[j],A[j+1] = A[j+1],A[j]
    i -= 1

    return A
print bubble_sort([])
print bubble_sort([2,1])
print bubble_sort([4,3,2,1,0])
```
bubble_sort和选择不要搞混，一个是最大放末尾，一个是最小放开头。  

