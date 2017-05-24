---
layout: post
category: Linux
title: Linux shell内置字符串操作
---

**本文介绍shell内置的字符串操作方法。参考公众号*Linux爱好者***。  
  
在做shell批处理程序的时候，经常会涉及到字符串相关操作。有很多命令语句，如：awk，sed都可以做字符串的各种操作。其实shell内置了一系列的操作符号，可以达到类似效果，其优点是可以省略启动外部程序的时间，速度很快。  
## 一、判断读取字符串值

表达式|含义  
:---:|:---:  
${var}|变量var的值，与$var相同  
${var-DEFAULT}|如果var没有被声明，则以$DEFAULT为其值  
${var:-DEFAULT}|如果var没声明，或者值为空，则以$DEFAULT为其值  
${var=DEFAULT}|如果var没声明，则以$DEFAULT为其值  
${var:=DEFAULT}|如果var没声明，或者值为空，则以$DEFAULT为其值  
${var+OTHER}|如果var声明了，那么其值则为$OTHER，否则为null字符串  
${var:+OTHER}|如果var被设置了，那么其值为$OTHER，否则为null字符串  
${var?ERR_MSG}|如果var没声明，打印$ERR_MSG  
${var:?ERR_MSG}|如果var没被设置，打印$ERR_MSG  
${!varprefix*}|匹配之前所有已varprefix开头进行声明的变量  
${!varprefix@}|匹配之前所有已varprefix开头进行声明的变量  

上代码:  
```shell
#${var-DEFAULT},事实证明会输出-后面的值，不加$就代表字符串'DEFAULT'，
#而且， -的方式不能改变var的值，只是改变了输出。
[root@localhost ~]# unset var
[root@localhost ~]# echo $var

[root@localhost ~]# DEFAULT='hello world'
[root@localhost ~]# echo ${var-DEFAULT}
DEFAULT
[root@localhost ~]# echo ${var-$DEFAULT}
hello world
[root@localhost ~]# echo ${var}
```
```shell
#等号的方式可以set变量的值
[root@localhost ~]# echo $DEFAULT
hello world
[root@localhost ~]# echo ${var=$DEFAULT}
hello world
[root@localhost ~]# echo $var
hello world
```
**`-`和`=`的区别就是能否改变变量的值**，而`:=`和`=`的区别就是`:=`的判断范围扩大到了空变量，如下：
```python
[root@localhost ~]# unset var
[root@localhost ~]# var=''
[root@localhost ~]# echo $var

[root@localhost ~]# echo ${var=$DEFAULT}

[root@localhost ~]# echo $var

[root@localhost ~]# echo ${var:=$DEFAULT}
hello world
[root@localhost ~]# echo $var
hello world
```
对于`:-`和`-`，情况是一样的，加了冒号之后，可以对空变量进行替换并输出，但是仍然不能改变变量内容：
```shell
[root@localhost ~]# unset var
[root@localhost ~]# var=''
[root@localhost ~]# echo ${var:-$DEFAULT}
hello world
[root@localhost ~]# echo $var

[root@localhost ~]# echo ${var-$DEFAULT}

[root@localhost ~]# echo $var

```
然后是加号的作用，和`-`与`=`相反，如果声明了，则输出另一个值：  
```shell
root@localhost ~]# unset var
[root@localhost ~]# var='Yoo-Yoo'
[root@localhost ~]# echo ${var+$DEFAULT}
hello world
[root@localhost ~]# echo $var
Yoo-Yoo
```

## 二、字符串操作(长度，读取，替换)
表达式|含义  
:---:|:---:  
${#string}|$string的长度  
${string:position}|string中，从位置$position开始提取字符串  
${string:position:length}|string中，从位置$position开始提取长度为length的字符串  
${string#substring}|string中，从头开始匹配substring（最短匹配）并删除，如果没匹配则输出string  
${string##substring}|string中，从头开始匹配substring（最长匹配）并删除，如果没匹配则输出string  
${string%substring}|从string结尾开始匹配(最短匹配)并删除，如果没匹配则输出string  
${string%%substring}|从string结尾开始匹配(最长匹配)并删除，如果没匹配则输出string  
${string/substring/replacement}|使用replacement替代第一个substring  
${string//substring/replacement}|使用replacement替代所有sbustring   
${string/#substring/replacement}|如果string的前缀匹配substring，那么用replacement替换substring  
${string/%substring/replacement}|如果string的后缀匹配substring，那么用replacement替换substring  

**这一组还是比较直观的，比如字符串删除功能： #号代表从开头匹配，%代表从结尾，两个#或者%代表最长匹配；**      
**还有字符串替换功能：一个/代表替换第一个，//则代表全部替换, /#则是开头匹配，/%是结尾匹配。**     


## 三、性能比较
```shell
[root@localhost ~]# time for i in $(seq 10000);do
> a=${#test};done;

real	0m0.108s
user	0m0.094s
sys	0m0.003s
[root@localhost ~]# time for i in $(seq 10000);do
> a=$(expr length $test);done;

real	0m8.145s
user	0m1.679s
sys	0m6.385s
```
差距还是挺大的，所以，在字符串操作成为程序处理时间瓶颈是，可以考虑shell的内置string命令。