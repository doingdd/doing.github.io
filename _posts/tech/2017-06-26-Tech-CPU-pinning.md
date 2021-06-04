---
category: 技术
layout: post
title: CPU pinning(Processor affinity)
---
**本文介绍cpu pinning的相关概念，译自[Wikipedia -- Processor affinity](https://en.wikipedia.org/wiki/Processor_affinity)**   
## CPU pinning(Processor affinity)
### 概念
Processor affinity 中文叫**处理器关联**(或者cpu pinning: 处理器亲和)，提供了进程或者线程与特定CPU的绑定和解绑功能。可以看做是在对称多处理（SMP,symmetric multiprocessing）操作系统中的本地中心队列的调度算法的改进(好绕)。队列中的每个元素都有一个标签指向其关联CPU，分配资源时，每个任务优先分给其绑定CPU。  
### 优点
处理器关联的优点是： 当一个进程在处理器上运行后，其残留(例如数据缓存)会存在在当前CPU上，如果在进程调度的时候保证每个进程只在同一个CPU上运行，可以提高其性能(减少了缓存丢失的事件发生)。  处理器关联的一个典型应用是多个实例(非多线程)软件，如图形渲染软件。   
### 实现
然而，不同的调度算法对处理器关联有一些不同。有些调度算法在它认为合适的情况下会允许把一个任务调度到不同的处理器上。例如，两个任务(task A and task B)同时关联到同一个处理器上，但是有另一个处理器处于空闲状态，为了最大化处理器使用效率，许多算法会将task B移到空闲处理器上运行，而且，task B会重新建立起和空闲处理器的绑定， task A维持不变。  

### 超线程系统
处理器亲和性能够有效地解决一些高速缓存的问题，但却不能缓解负载均衡的问题。而且，在异构系统中，处理器亲和性问题会变得更加复杂。例如，在双核超线程CPU系统(hyper-threading: 超线程，一个核模拟两个CPU线程)中的算法实现。  

通过超线程实现的在同一个核上的两个虚拟CPU是完全相关(亲和)的；而一个物理处理器上的不同核之间是部分相关(亲和)的，原因是核与核之间共享了部分的cache；不同的物理处理器是完全不相关的。   

由于其他系统资源的共享(内存等)，处理器关联不能作为CPU调度的基础规则.如果一个进程之前在某个core上的虚拟CPU上运行过，但是现在这个CPU是busy状态，**缓存**关联(cache affinity)会将这个进程分配到它的空闲的partner虚拟CPU上运行(两个虚拟CPU属于同一个核)，然而，本质上同一个核上的两个虚拟CPU在使用计算资源，内存和缓存资源时会有竞争，在这种情况下，分配程序到另一个空闲的核上或者物理CPU上更加有效。即使程序重新分配缓存会导致**惩罚**(cache penalty：缓存失效开销，cache未命中，从内存取出相应块并替换cache中某块的时间之和)，但由于避免了CPU内部的资源竞争，总体性能仍然会得到提高。

## 查看CPU信息
物理cpu个数：
```shell
cat /proc/cpuinfo |grep "physical id"|sort |uniq|wc -l
```
查看每个物理CPU的核数：
```shell
cat /proc/cpuinfo |grep cores |uniq
```
查看总cpu线程个数：
```shell
cat /proc/cpuinfo | grep processor |wc -l
```
实际上，知道了上面三个信息，可以算出改server是否开启了hyper-threading，如果：    
`总线程个数 = CPU个数 * 每个CPU核数`表示一核对应一个线程，未开启。   
`总线程个数 = CPU个数 * 每个CPU核数 *2`，表示开启了超线程   

还可以查看CPU型号等等：  
```shell
cat /proc/cpuinfo |grep "model name"|uniq
model name      : Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz
```
