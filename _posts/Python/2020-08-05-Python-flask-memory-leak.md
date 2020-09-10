---
category: Python
layout: post
title: 记一次flask 内存泄漏的排查
---

**一台flask服务器，在处理日常api请求的时候出现了内存跳跃上涨，并无法降回，最终内存爆满**

首先定位到是哪个view会引起内存上涨，这里用到了ps，进程的初始内存使用情况:
```
ps aux|head -1;ps aux|grep datahub|grep flask
USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
admin     32692 17.3  0.0 430228 52596 pts/1    Sl   15:26   0:01 /export/data/doing/datahub/venv/bin/../bin/python -m flask run -h 0.0.0.0

```
%MEM是进程占用系统的内存使用率，VSZ是虚拟内存，RSS是真实内存(单位Kb)，通常这三个是同时涨,在调用了一次可疑接口之后
```
ps aux|head -1;ps aux|grep datahub|grep flask
USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
admin     32692 20.3  0.0 2698536 98692 pts/1   Sl   15:26   0:34 /export/data/doing/datahub/venv/bin/../bin/python -m flask run -h 0.0.0.0

```
可以看出RSS从52596涨到98692,涨了近40M

具体到哪里涨了，先使用了memory_profiler模块：
```
from memory_profiler import profile
@profile
def upload_files():
    '''
        for sdk
    '''
    #gc.set_debug(gc.DEBUG_LEAK)
    objgraph.show_growth()
    rt_json = {'code':'200','message':'','data':[]}
....
```
通过给函数加@profile装饰器，可以打印出每一句话的内存占用，这里定位到一句话：
```
109.2 MiB     46.3 MiB           all_project_file = git_manager.download_repo(project_id,'master','.')
```
第二列表示的新增内存，但是这个新增内存应该是这个all_project_file导致的，它是个大字典，按说在函数执行结束后会自动释放这一部分的内存(垃圾回收)，应该是有一些原因导致这个all_project_file没有被释放掉

再尝试用objgraph,这个库包装了一些gc库的用法，可以按照对象展示内存的增长
```
import objgraph
def upload_files():
    '''
        for sdk
    '''
    #gc.set_debug(gc.DEBUG_LEAK)
    objgraph.show_growth()
    ...
    ...
    objgraph.show_growth()
    return
```
分别在函数的开始和结尾调用show_growth()方法，自动打印了两次相关的信息：
```
function              18078    +18078
dict                   8199     +8199
tuple                  7230     +7230
list                   4925     +4925
weakref                3933     +3933
type                   2133     +2133
cell                   1946     +1946
getset_descriptor      1636     +1636
set                    1498     +1498
wrapper_descriptor     1239     +1239


tuple                 8257     +1027
dict                  8892      +693
function             18605      +527
cell                  2348      +402
weakref               4311      +378
type                  2423      +290
list                  5084      +159
getset_descriptor     1682       +46
set                   1531       +33
PropRegistry            60       +30
GroupMilestoneManager       47       +47
GroupVariableManager        47       +47
GroupSubgroupManager        47       +47

```
看到结尾多了几个Manager的对象，猜测可能和这些对象没有随着view函数的执行完成而释放有关，经查，恰好和前面memory_profiler定位到的那句话git_manager有关，结合python内存泄漏常见的两种情况：要么是有对象长期占用了这个对象，要么是对象定义了__del__导致垃圾回收无法识别，怀疑就是这个对象没有被释放导致的内存增长，手动释放一下试试：
```
del git_manager
```
show_growth确实不显示最后面的三个Manager有增长了，但是实际增长的内存没有变小，看来是那个字典变量的原因了，重复多次打请求，观察每一次的内存增长情况，发现除了第一次涨了40M以外，以后每一次会涨1M左右，也就是说一定有一个对象没有随着每次请求结束而释放掉
