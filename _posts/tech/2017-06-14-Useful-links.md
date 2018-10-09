---
layout: post
category: 技术
title: 有用的收藏汇总
---

**本文将平时看到的一些有用的link列下来， 以便日后翻阅**

1. stack overflow: [Calling an external command in Python](https://stackoverflow.com/questions/89228/calling-an-external-command-in-python)    
主要介绍几种调用shell命令的方法， subprocess是公认最好用的办法

2. stack overflow: [How do I check whether a file exists using Python?](https://stackoverflow.com/questions/82831/how-do-i-check-whether-a-file-exists-using-python)    
主要是os.path.isfile 和os.path.exists  

3. stack-overflow: [What is a metaclass in Python?](https://stackoverflow.com/questions/100003/what-is-a-metaclass-in-python)     
解释元类的概念。  

4. [ssh 认证原理](http://itindex.net/detail/48724-ssh-%E8%AE%A4%E8%AF%81-%E5%8E%9F%E7%90%86?utm_source=tuicool&utm_medium=referral)   
解释了一般ssh登陆的主要过程和公玥免密码的原理。

5. software engineering[Why is Global State so Evil?](https://softwareengineering.stackexchange.com/questions/148108/why-is-global-state-so-evil)    
介绍了全局变量或者全局状态的弊端。

6. [python内置结构算法的时间复杂度](https://www.douban.com/note/491584335/)    
介绍大部分的时间复杂度。

7. [python是解释型的还是编译型的？为什么有这么多python](http://www.oschina.net/translate/why-are-there-so-many-pythons)  
详细介绍了python各种实现的关系，还有python究竟算成解释型还是编译型(确切说Cpython是解释型，但具备编译特性)

8. [如何理解云计算？很简单，就像吃货想吃披萨了...](http://www.chinacloud.cn/show.aspx?id=19758&cid=18)  
形象的比喻，解释了Iaas, Paas, Saas的概念及区别。

9. [Linux shell中各种括号的用法](http://www.dwhd.org/20150708_211624.html)    
介绍了shell中各种括号的用法，比较详细，包括shell的数学运算，没介绍正则中括号的用法。

10. [shell 文件执行：source,sh,"./"的区别](https://www.cnblogs.com/pcat/p/5467188.html)

11. [linux sort命令详解](https://www.cnblogs.com/51linux/archive/2012/05/23/2515299.html)   
详细介绍了sort的用法，还有-k参数的排序机制，比较全面

12. [UTF8 or UTF-8?](https://stackoverflow.com/questions/41680533/is-coding-utf-8-also-a-comment-in-python?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa)   
介绍了python中声名文件编码类型的办法和原理，重点是python的正则匹配规则

13. [Find and kill a process in one line using bash and regex](https://stackoverflow.com/questions/3510673/find-and-kill-a-process-in-one-line-using-bash-and-regex)   
介绍了shell中如何优雅的kill掉一个进程，其中grep [p]rocess这种加中括号的方法非常之tricky

14. [stack and heap](https://stackoverflow.com/questions/79923/what-and-where-are-the-stack-and-heap)    
介绍了堆和栈的特点和区别，它们本质上是内存的不同分配方式

15. [difference between "Redirection" and "Pipe"](https://askubuntu.com/questions/172982/what-is-the-difference-between-redirection-and-pipe)  
介绍了重定向">"和管道"|"之间的区别，及为什么不能用一个代替另外一个，简单说就是输出不同，一个给文件，一个给程序  

16. [fix a broken pipe error](https://superuser.com/questions/554855/how-can-i-fix-a-broken-pipe-error)   
linux中的broken pipe error发生的原因，也简单说明了pipe的工作机制  
