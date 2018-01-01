---
layout: post
category: Linux
title: Linux性能 -- CPU
---

**本文介绍linux性能之cpu篇，主要通过介绍各个CPU相关的命令来介绍CPU的相関概念和监测方式.**
[Linux中CPU与内存性能监测](http://blog.csdn.net/chenleixing/article/details/46678413)   
[linux下的CPU、内存、IO、网络的压力测试](http://blog.csdn.net/liushi558/article/details/50771853)   
[linux CPU性能及工作状态查看指令](http://blog.csdn.net/z1134145881/article/details/52089698)  

# 查看CPU相关命令

## top

top是实时动态的查看，可交互，详细介绍见这里：  
[Linux性能 -- top命令](http://doing.cool/2017/12/27/Linux-Performance-top.html)  

## vmstat

vmstat可以展现给定时间间隔的服务器的状态值,包括服务器的CPU使用率，内存使用，虚拟内存交换情况,IO读写情况。主要输出的是系统整体的情况，而不是某一个进程。  

vmstat的基本格式：  
```shell
vmstat [options] [delay [count]]
```

options|说明
---|---
-a|显示active和inavtive的内存情况
-f|显示总fork的个数，可以理解为总task的个数
-m|slabs,显示slabs信息(?)
-n|oneliner,头信息只显示 一次
-s|显示内存的一些静态信息
-d|硬盘信息
-D|硬盘信息汇总
-p|partition信息
-u|1024/1000单位转换


-f显示的是自系统启动以来总task的个数，一个process可以有多个task，取决于是否是多线程的process。  
ps：vmstat在option之后接delay秒数和count个数，可以实时显示系统的信息，第一次显示的多为系统从启动到当前时刻的平均值，从第二次开始，显示的是delay秒数内，系统信息的平均值。  

```shell
root@Doing:~/jump_game/wechat_jump_game# vmstat -a
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 2  0      0 736092 105620 109360    0    0     0     1    1    0  0  0 100  0  0

root@Doing:~# vmstat -s
      1016032 K total memory
        41316 K used memory
       155324 K active memory
       146868 K inactive memory
       630712 K free memory
        64440 K buffer memory
       279564 K swap cache

root@Doing:~# vmstat -d
disk- ------------reads------------ ------------writes----------- -----IO------
       total merged sectors      ms  total merged sectors      ms    cur    sec
vda    32557      0 1085058  265984 2641474 822788 35600480 8007144      0    346
vdb      400      0   21258     244   1258 114875  929040 1105152      0      8
sr0        0      0       0       0      0      0       0       0      0      0

root@Doing:~# vmstat -D
           11 disks 
            2 partitions 
        32957 total reads
            0 merged reads
      1106316 read sectors
       266228 milli reading
      2642744 writes
       937672 merged writes
     36529688 written sectors
      9112296 milli writing
            0 inprogress IO
          354 milli spent IO

root@Doing:/dev# vmstat -p /dev/vda1
vda1          reads   read sectors  writes    requested writes
               32474    1080938    2616245   35601184

```

这里解释一下最常用的vmstat功能的各个输出参数的意义：
```shell
# vmstat -w 2
procs -----------------------memory---------------------- ---swap-- -----io---- -system-- --------cpu--------
 r  b         swpd         free         buff        cache   si   so    bi    bo   in   cs  us  sy  id  wa  st
 0  0            0     68920704     35295036     24808888    0    0     1     5    0    0   0   0 100   0   0
 0  0            0     68925128     35295036     24809276    0    0     0     2 2928 4667   0   0 100   0   0
 0  0            0     68919216     35295036     24808908    0    0     0    56 3918 5151   0   0 100   0   0
```
`r` 表示运行队列(就是说多少个进程真的分配到CPU)，我测试的服务器目前CPU比较空闲，没什么程序在跑，当这个值超过了CPU数目，就会出现CPU瓶颈了。这个也和top的负载有关系，一般负载超过了3就比较高，超过了5就高，超过了10就不正常了，服务器的状态很危险。top的负载类似每秒的运行队列。如果运行队列过大，表示你的CPU很繁忙，一般会造成CPU使用率很高。  
`b` 表示阻塞的进程,这个不多说，进程阻塞，大家懂的。  
swpd 虚拟内存已使用的大小，如果大于0，表示你的机器物理内存不足了，如果不是程序内存泄露的原因，那么你该升级内存了或者把耗内存的任务迁移到其他机器。  
`free`   空闲的物理内存的大小，我的机器内存总共8G，剩余3415M。  
`buff`   Linux/Unix系统是用来存储，目录里面有什么内容，权限等的缓存，我本机大概占用300多M  
`cache` cache直接用来记忆我们打开的文件,给文件做缓冲，我本机大概占用300多M(这里是Linux/Unix的聪明之处，把空闲的物理内存的一部分拿来做文件和目录的缓存，是为了提高 程序执行的性能，当程序使用内存时，buffer/cached会很快地被使用。)  
`si`  每秒从磁盘读入虚拟内存的大小，如果这个值大于0，表示物理内存不够用或者内存泄露了，要查找耗内存进程解决掉。我的机器内存充裕，一切正常。  
`so`  每秒虚拟内存写入磁盘的大小，如果这个值大于0，同上。  
`bi`  块设备每秒接收的块数量，这里的块设备是指系统上所有的磁盘和其他块设备，默认块大小是1024byte，我本机上没什么IO操作，所以一直是0，但是我曾在处理拷贝大量数据(2-3T)的机器上看过可以达到140000/s，磁盘写入速度差不多140M每秒  
`bo` 块设备每秒发送的块数量，例如我们读取文件，bo就要大于0。bi和bo一般都要接近0，不然就是IO过于频繁，需要调整。  
`in` 每秒CPU的中断次数，包括时间中断  
`cs` 每秒上下文切换次数，例如我们调用系统函数，就要进行上下文切换，线程的切换，也要进程上下文切换，这个值要越小越好，太大了，要考虑调低线程或者进程的数目,例如在apache和nginx这种web服务器中，我们一般做性能测试时会进行几千并发甚至几万并发的测试，选择web服务器的进程可以由进程或者线程的峰值一直下调，压测，直到cs到一个比较小的值，这个进程和线程数就是比较合适的值了。系统调用也是，每次调用系统函数，我们的代码就会进入内核空间，导致上下文切换，这个是很耗资源，也要尽量避免频繁调用系统函数。上下文切换次数过多表示你的CPU大部分浪费在上下文切换，导致CPU干正经事的时间少了，CPU没有充分利用，是不可取的。  
`us` 用户CPU时间，我曾经在一个做加密解密很频繁的服务器上，可以看到us接近100,r运行队列达到80(机器在做压力测试，性能表现不佳)。  
`sy` 系统CPU时间，如果太高，表示系统调用时间长，例如是IO操作频繁。  
`id`  空闲 CPU时间，一般来说，id + us + sy = 100,一般我认为id是空闲CPU使用率，us是用户CPU使用率，sy是系统CPU使用率。  
`wt` 等待IO CPU时间。  

## iostat

iostat可以按interval显示系统设备的I/O信息，第一次显示的是系统自启动以来的I/O信息，之后显示的是固定时间间隔内的平均值。
参数介绍：

参数|解释
---|---
-c|显示CPU使用率信息
-d|显示device使用率信息
-g|结尾显示总数
-h|human，格式人性化(没发现)
-H|和使用时必须加-g，只显示总数
-k/-m|单位为kb/mb
-N|显示mapper的divice的相关信息
-p|接divice名字，可以显示指定partition
-t|显示时间
-x|显示扩展的信息(信息更全)
-y|隐藏第一次信息的显示
-z|隐藏采样时间内非活跃设备的信息

下面解释一下-x参数输出时各个域的含义：
```shell
# iostat -x -k -d sda 2
Linux 3.10.0-514.21.1.el7.x86_64 (hpbj14-0-0-1)         12/31/17        _x86_64_        (48 CPU)

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               0.01     2.37    0.58    3.18    67.07    77.22    76.84     0.06   15.41    8.07   16.75   3.31   1.24

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               0.00     2.50    0.00    8.00     0.00    44.00    11.00     0.09   11.00    0.00   11.00   1.50   1.20
```
如上是显示了系统中sda这块盘每隔2秒的扩展信息。  

`rrqm/s`和`wrqm`表示读和写，表示每秒这个设备相关的读取/写入请求有多少被Merge了（当系统调用需要读取/写入数据的时候，VFS将请求发到各个FS，如果FS发现不同的读取/写入请求读取的是相同Block的数据，FS会将这个请求合并Merge）

`r/s`和`w/s`:每秒读取/写入的扇区数sector.

`rKB/s`和`wKB/s`：每秒读取/写入的字节数。  

`avgrq-sz`：平均请求的扇区大小。  

`avgqu-sz`: 平均请求的队列长度，越小越好。  

`await`和`r_await`和`w_await`: 平均每个请求（读取/写入）等待的时间(ms),可以理解为IO的响应时间，一般地系统IO响应时间应该低于5ms，如果大于10ms就比较大了。  
这个时间包括了队列时间和服务时间，也就是说，一般情况下，await大于svctm，它们的差值越小，则说明队列时间越短，反之差值越大，队列时间越长，说明系统出了问题。

`svctm`:表示平均每次设备I/O操作的服务时间（以毫秒为单位）。如果svctm的值与await很接近，表示**几乎没有I/O等待**，磁盘性能很好，如果await的值远高于svctm的值，则表示I/O队列等待太长，系统上运行的应用程序将变慢。

`util`:在统计时间内所有**处理IO时间**，除以总共统计时间。例如，如果统计间隔1秒，该设备有0.8秒在处理IO，而0.2秒闲置，那么该设备的%util = 0.8/1 = 80%，所以该参数暗示了设备的繁忙程度。   
一般地，如果该参数是100%表示设备已经接近满负荷运行了（当然如果是多磁盘，即使%util是100%，因为磁盘的并发能力，所以磁盘使用未必就到了瓶颈）。  