---
category: Linux
layout: post
title: Linux里的两个“软硬”：软硬中断与软硬连接
---

**本文讨论linux系统中涉及到的两个软和硬的概念，软硬中断和软硬连接。 ** 
参考： [硬中断和软中断](http://blog.csdn.net/zhangskd/article/details/21992933)   
    [Linux中断的上半部和下半部](https://www.cnblogs.com/sky-heaven/p/5746730.html)   
**鸟哥Linux私房菜**
## 软中断和硬中断

**由于目前没有涉及到内核编程，所以这里只简单介绍概念相关，目的在于理解。**  
### 1. 硬中断

从字面上理解，硬中断就是由硬件产生的中断，例如键盘，网卡等其它连接CPU的硬件设备，在某个操作出发了中断信号后，传输给中断处理器和CPU,使CPU暂时中断当前工作转而完成相应的中断处理工作，再回到原处继续完成当前工作的行为。 参考blog里的一张图概括了linux里硬中断的基本流程：  
![](http://oon3ys1qt.bkt.clouddn.com/IRQ.png)  
主要包括几个过程：  
中断触发和识别：  每个设备或设备集都有其独立的IRQ(中断请求)，基于IRQ，CPU可以将请求发送到对应的硬件驱动上（硬件驱动程序通常是内核中的一个子程序，而不是一个独立的进程）。  

中断处理：处理中断的程序是需要运行在CPU上的， 因此，当中断产生的时候，CPU会中断当前的任务来处理中断，这时内核上的相关代码会被触发。在多核系统上，一个中断请求通常只能中断一颗CPU。中断代码本身也可以被其他的**硬**中断请求中断（不能是同一类型的硬中断）。  

### 2. 软中断

软中断即使软件产生的中断，仅仅由当前正在运行的程序产生。软中断触发后，不会直接中断CPU，而通常是对I/O的请求。这些I/O请求会调用内核中可以调度I/O的程序。对某些设备，I/O请求需要被立即处理，而磁盘I/O通常可以排队并且稍后处理。   

### 3. 软硬中断的区别

1. 软中断是由命令产生，硬中断由外设硬件产生。  

2. 硬中断的中断号是由中断控制器提供， 软中断直接由指令发出。  

3. 硬中断会中断CPU当前运行的代码，软中断不会中断CPU，但会中断当前的代码流程。

4. 硬中断可屏蔽，软中断不可屏蔽。  

5. 硬中断相当于中断的**上半部**，包括硬件中断触发；软中断为**下半部**，主要是用指令模拟中断信号的发出，然后主要负责后面的中断程序处理等。  

### 4. 上半部(top half)， 下半部(bottom half)

linux 中断分为两个半部，其中上半部负责的是“中断登记”，当一个中断发生时，它进行相应的中断读写后就把中断例程的下半部挂到该设备的下半部执行队列中去。因此上半部的执行速度就会很快，可以处理更多的中断请求。

但是仅有“中断登记”是不够的，因为中断需要执行的动作可能很复杂，这就需要在登记中断完成后，来执行中断的下半部来完成中断事件的大部分操作。

通常的硬中断可归为中断的上半部，下半部的实现通常使用软中断或者tasklet  

## 软连接，硬链接

为了更好的理解软硬连接的概念和原理，首先介绍一下linux的文件系统。
### 1. Linux的Ext2文件系统
我们都知道，在使用硬盘之前应该对硬盘进行格式化，这是由于对于不同操作系统而言，它们所能支持的文件属性、文件权限、格式都不尽相同，为了存放这些文件所需要的数据，需要对分区进行格式化，以成为操作系统能够利用的文件系统格式。  

每种操作系统支持的文件系统格式都不尽相同，Windows98前是FAT(FAT16), Windows2000后出现了NTFS文件系统，而Linux的正规文件系统则为**Ext2**（Linux second extended file system, EXt2fs)，当然linux还有**ext3，ext4**，**brtfs, xfs**等等(brtfs目的取代ext3，支持copy on write(COW)，xfs较ext4也优点颇多)。  
```python
## 怎么判断自己的文件系统类型？
# File system: btrfs
[root@localhost ~]# df -T -h
Filesystem     Type      Size  Used Avail Use% Mounted on
/dev/sda2      btrfs     2.2T   90G  2.1T   5% /
devtmpfs       devtmpfs   63G     0   63G   0% /dev
tmpfs          tmpfs      63G     0   63G   0% /dev/shm
tmpfs          tmpfs      63G  9.3M   63G   1% /run
tmpfs          tmpfs      63G     0   63G   0% /sys/fs/cgroup
/dev/sda2      btrfs     2.2T   90G  2.1T   5% /home
/dev/sda1      xfs      1016M  141M  875M  14% /boot
tmpfs          tmpfs      13G     0   13G   0% /run/user/0

# File system: xfs
[root@localhost ~]# cat /etc/fstab
# /etc/fstab
# Created by anaconda on Tue Jan 17 10:55:08 2017
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/centos-root /                       xfs     defaults        0 0
UUID=dda847d9-5d2c-4c9d-94d8-b94e52e1689c /boot                   xfs     defaults        0 0
/dev/mapper/centos-swap swap                    swap    defaults        0 0

```

文件系统的实现是针对文件数据而言的，通常除了文件内容本身，文件数据还包括许多其他的属性，例如Linux系统的rwx权限，文件属性(用户、用户组、时间等),文件系统会把这两大部分内容分别存放在不同的块，**权限与属性相关的存放在inode中，文件的实际数据则存放在block data中，还有一个超级块(super block)记录文件系统的整体信息，包括inode域block的总量，使用量，剩余量等。**  

**inode: 记录文件的属性，一个文件占用一个inode，同时记录此文件的数据所在的block编号；**    
**block：记录实际文件内容，若文件太大时，占用多个block，但是文件如果小于一个block的大小，该block也不能再存放其他的文件，其剩余大小实际被浪费(一个block只能存放一个文件)。 ** 

Linux系统的Ext2文件系统，使用inode索引+data block数据的模式，也称为索引式文件系统(indexed allocation)。区别与这种系统还有FAT模式(U盘经常使用这种)，它的block编号不统一存放，每一个block号码都存放在前一个block当中，这种模式的缺点是，当同一个文件的不同block太过离散，会影响到文件的读取性能，所以这也是碎片整理的由来。

好了，绕了一大圈，关于文件系统的部分核心内容就是inode和block的作用，这是linux系统中软硬连接机制的基础。  

### 2. 软硬链接
**硬链接(hard link)：** 当多个文件名同时指向同一个inode的时候，其实就相当于hard link。   
这时，由于inode是同一个，只是文件名不一样，所以hard link的文件和源文件的所有属性都相同。
```python
## 使用ln命令创建硬链接：
[root@localhost temp]# ln /etc/crontab crontab2
root@localhost temp]# ls -la /etc/crontab ./crontab2 
-rw-r--r--. 2 root root 451 Jun  9  2014 ./crontab2
-rw-r--r--. 2 root root 451 Jun  9  2014 /etc/crontab
``` 
第二个字段为2：表示有多少个文件名连接到这个inode的意思。   
可以看到所有属性完全一致，如果删除其中一个，另一个不会受到影响。  

**软连接(symbolic link):** 没错，它的英文是"symbolic",所以，严格来说它不应该叫做软连接，应该叫符号链接更准确，而且，它的意义也确实类似于windows里的快捷方式。    
基本上，symbolic link就是创建了一个独立的文件，这个文件会让数据的读取转向它连接的文件的文件名。  
由于只是利用文件来进行指向的操作，如果源文件被删除，会导致symbolic link文件"打不开".
```python
[root@localhost temp]# ln -s /etc/crontab crontab3
[root@localhost temp]# ls -al crontab3
lrwxrwxrwx. 1 root root 12 Nov 20 11:42 crontab3 -> /etc/crontab
```
可以很清晰的看出，当前目录下的crontab3是一个symbolic link文件。

### 3. hard link, symbolic link 区别
1. hard link 不能连接到目录，由于连接到目录的hard link需要很大的目录复杂度，所以目前不支持。 而symbolic link文件可以连接到目录，但是注意不要随意删除其中文件，因为所有改动会同步到源目录。 

2. hard link 不能跨文件系统(symbolic是否可以跨有待验证？)

3. 删除hard link的源文件，不影响其link文件，但是symbolic link文件的源文件删除后，link文件失效。  

最后，注意，无论是hard link还是symbolic link，修改link文件的内容都会同步更新到源文件内容，理解了它们的原理，这个也就不难理解了。
