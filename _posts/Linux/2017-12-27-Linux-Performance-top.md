---
layout: post
category: Linux
title: Linux性能 -- top命令
---

**本文介绍top命令的用法**
# top
## top 命令的输出解释

首先放一张top命令的截图：  

![](http://oon3ys1qt.bkt.clouddn.com/top.png)

### 第一行
我们看到 top 显示的第一排

内容|解释
---|---
top|表示当前程序的名称
11: 05:18|表示当前的系统的时间
up 8 days,17:12|表示该机器已经启动了多长时间
1 user|表示当前系统中只有一个用户
load average: 0.29,0.20,0.25|分别对应1、5、15分钟内cpu的平均负载

我们该如何看待这个load average 数据呢？  
假设我们的系统是单CPU单内核的，把它比喻成是一条单向的桥，把CPU任务比作汽车。  

• load = 0 的时候意味着这个桥上并没有车，cpu 没有任何任务；  
• load < 1 的时候意味着桥上的车并不多，一切都还是很流畅的，cpu 的任务并不多，资源还很充足；  
• load = 1 的时候就意味着桥已经被车给沾满了，没有一点空隙，cpu 的已经在全力工作了，所有的资源都被用完了，当然还好，这还在能力范围之内，只是有点慢而已；  
• load > 1 的时候就意味着不仅仅是桥上已经被车占满了，就连桥外都被占满了，cpu 已经在全力的工作了，系统资源的用完了，但是还是有大量的进程在请求，在等待。若是这个值大于２，大于３，超过 CPU 工作能力的 2，３。而若是这个值 > 5 说明系统已经在超负荷运作了。  
	
这是单个 CPU 单核的情况，而实际生活中我们需要将得到的**这个值除以我们的核数**来看。我们可以通过一下的命令来查看 CPU 的个数与核心数  

```python
## 查看物理CPU的个数
cat /proc/cpuinfo |grep "physical id"|sort |uniq|wc -l
2
#每个物理cpu的核心数
cat /proc/cpuinfo |grep cores|uniq
12
#查看总共的处理器的个数
cat /proc/cpuinfo |grep processor|wc -l
48
## 由上面的结果得到该lab是否开了超线程hyper-thread:
总处理器个数 = 物理CPU个数*每个物理cpu核数*2
证明开了超线程，如果不乘以2，则没开。
```

通过上面的指数我们可以得知 load 的临界值为 1 ，但是在实际生活中，比较有经验的运维或者系统管理员会将临界值定为0.7。这里的指数都是除以核心数以后的值，不要混淆了  

	• 若是 load < 0.7 并不会去关注他；
	• 若是 0.7< load < 1 的时候我们就需要稍微关注一下了，虽然还可以应付但是这个值已经离临界不远了；
	• 若是 load = 1 的时候我们就需要警惕了，因为这个时候已经没有更多的资源的了，已经在全力以赴了；
	• 若是 load > 5 的时候系统已经快不行了，这个时候你需要加班解决问题了  


通常我们都会先看 15 分钟的值来看这个大体的趋势，然后再看 5 分钟的值对比来看是否有下降的趋势。
### 第二行
来看 top 的第二行数据，基本上第二行是进程的一个情况统计  

内容|解释
---|---
Tasks: 26 total|进程总数
1 running|1个正在运行的进程数
25 sleeping|25个睡眠的进程数
0 stopped|没有停止的进程数
0 zombie|没有僵尸进程数

### 第三行
来看 top 的第三行数据，这一行基本上是 CPU 的一个使用情况的统计了

内容|解释
---|---
Cpu(s): 1.0%us|用户空间占用CPU百分比
1.0% sy|内核空间占用CPU百分比
0.0%ni|用户进程空间内改变过优先级的进程占用CPU百分比
97.9%id|空闲CPU百分比
0.0%wa|等待输入输出的CPU时间百分比
0.1%hi|硬中断(Hardware IRQ)占用CPU的百分比
0.0%si|软中断(Software IRQ)占用CPU的百分比
0.0%st|(Steal time) 是当 hypervisor 服务另一个虚拟处理器的时候，虚拟 CPU 等待实际 CPU 的时间的百分比  

CPU 利用率，是对一个时间段内 CPU 使用状况的统计，通过这个指标可以看出在某一个时间段内 CPU 被占用的情况，Load Average 是 CPU 的 Load，它所包含的信息不是 CPU 的使用率状况，而是在一段时间内 CPU 正在处理以及等待 CPU 处理的进程数情况统计信息，这两个指标并不一样。  

关于CPU和load 的区别，详见这篇文章： [CPU load 和CPU利用率的关系](http://blog.csdn.net/treeclimber/article/details/8424410)   
总结两者的区别：   
**CPU 使用率：** 单位时间内，cpu被进程占用的时间百分比。  
**CPU load：** 一段时间内，cpu正在处理和等待处理的进程个数之和。  
**所以，cpu load要用top的结果除以cpu的核数来看。。**  

### 第四行
来看 top 的第四行数据，这一行基本上是内存的一个使用情况的统计了

内容|解释
---|---
8176740 total|物理内存总量
8032104 used|使用的物理内存总量
144636 free|空闲内存总量
313088 buffers|用作内核缓存的内存量
**注意 **： 系统的中可用的物理内存最大值并不是 free 这个单一的值，而是 free + buffers + swap 中的 cached 的和。  

### 第五行
来看 top 的第五行数据，这一行基本上是交换区的一个使用情况的统计了

内容|解释
---|---
total|交换区总量
used|使用的交换区总量
free|空闲交换区总量
cached|缓冲的交换区总量,内存中的内容被换出到交换区，而后又被换入到内存，但使用过的交换区尚未被覆盖

### 进程信息
在下面就是进程的一个情况了

列名|解释
---|---
PID|进程id
USER|该进程的所属用户
PR|该进程执行的优先级priority 值
NI|该进程的 nice 值
VIRT|该进程任务所使用的虚拟内存的总数
RES|该进程所使用的物理内存数，也称之为驻留内存数
SHR|该进程共享内存的大小
S|该进程进程的状态: S=sleep R=running Z=zombie
%CPU|该进程CPU的利用率
%MEM|该进程内存的利用率
TIME+|该进程活跃的总时间
COMMAND|该进程运行的名字

**注意：**   
**NICE 值** 叫做静态优先级，是用户空间的一个优先级值，其取值范围是-20至19。这个值越小，表示进程”优先级”越高，而值越大“优先级”越低。nice值中的 -20 到 19，中 -20 优先级最高， 0 是默认的值，而 19 优先级最低。   

**PR 值** 表示 Priority 值叫动态优先级，是进程在内核中实际的优先级值，进程优先级的取值范围是通过一个宏定义的，这个宏的名称是MAX_PRIO，它的值为140。Linux实际上实现了140个优先级范围，取值范围是从0-139，这个值越小，优先级越高。而这其中的 0 - 99 是实时的值，而 100 - 139 是给用户的。  

其中 PR 中的 100 to 139 值部分有这么一个对应 PR = 20 + (-20 to +19)，这里的 -20 to +19 便是nice值，所以说两个虽然都是优先级，而且有千丝万缕的关系，但是他们的值，他们的作用范围并不相同。  

**VIRT** 任务所使用的虚拟内存的总数，其中包含所有的代码，数据，共享库和被换出 swap空间的页面等所占据空间的总数  

STAT表示进程的状态，而进程的状态有很多，如下表所示

状态|解释
---|---
R|Running.运行中
S|Interruptible Sleep.等待调用
D|Uninterruptible Sleep.不可中断睡眠
T|Stoped.暂停或者跟踪状态
X|Dead.即将被撤销
Z|Zombie.僵尸进程
W|Paging.内存交换
N|优先级低的进程
<|优先级高的进程
s|进程的领导者
L|锁定状态
l|多线程状态
+|前台进程

## top的交互
在上文我们曾经说过 top 是一个前台程序，所以是一个可以交互的

常用交互命令|解释
---|---
q|退出程序
h|help
I|切换显示平均负载和启动时间的信息
H|thread mod，默认关闭
P|根据CPU使用百分比大小进行排序
M|根据驻留内存大小进行排序
m|显示memory百分比
1/2/3|cpu mode/numa mode
i|忽略闲置和僵死的进程，这是一个开关式命令
s/d|改变top刷新时间
k|终止一个进程，系统提示输入 PID 及发送的信号值。一般终止进程用15信号，不能正常结束则使用9信号。安全模式下该命令被屏蔽。

这里解释一下`I`：用于关闭和打开**irix mode**(默认是打开的)，如果关闭，则进入solaris mode，这时一个进程的cpu使用率会除以总的cpu处理器个数然后显示。  如果默认打开，则cpu使用率显示的是进程占其所在cpu处理器上的使用时间百分比。  

再解释一下`H`，thread模式，默认是关闭的，也就是说top显示的cpu是该进程下面所有thread的cpu的总和，如果打开，则分别显示独立的thread所占cpu百分比，这也是某些进程的cpu会出现超过100%的情况的原因(thread 模式没开)。  

在linux中，有三个基本的概念需要清楚：task，process，thread。详细介绍见[Linux中的task,process, thread 简介](https://www.cnblogs.com/vinozly/p/5585683.html)    
**task,process,thread 区别总结：**  本质上linux只有process，task可以理解成一个process，thread也可以理解成一个process。  

如果一个process有自己独立的地址空间那就是个典型的process，拥有唯一的PID和TGID(thead group id)；  
如果一个process和其他process共用地址空间，那它就是某个process的thread，拥有唯一的PID，但是TGID和其他thread共用一个。
**更多的交互式命令，可以`man top` 查看**  

## top 的命令行参数

常用参数|解释
---|---
-h|help
-b|batch mode可以是top输出到文件中，需配合tee或者>使用
-c|command-line，显示进程执行的具体command
-d|delay time，设置刷新interval
-H|thread mode，显示所有thread的信息
-i|idle，空闲进程将不被显示
-n|-n number,刷新到number之后自动停止
-o|-o field，按指定的field排序输出(例如%CPU)，常搭配-b使用
-O|大o，打印出所有可以用来排序的field
-p|monitor pid，可以查看指定pid的进程，最多20个
-s|secure mode
-S|cumulative，累计时间，CPU会显示进程自启动到当前时间的使用率
-u|user，显示指定的user name或者id下面的进程信息

## ps 查看进程的cpu等信息

查看当前运行的占CPU前三名的进程：
```python
ps aux|head -1;ps aux|grep -v PID|sort -rn -k +3|head -3
```
内存前三名：
```python
ps aux|head -1;ps aux|grep -v PID|sort -rn -k +4|head -3
```
这里需要注意的是ps -aux查出来的进程CPU和top并不一样，其表示从进程启动到目前时间点所占cpu时间使用率的总百分比。
