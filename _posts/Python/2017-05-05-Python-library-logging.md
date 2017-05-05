---
layout: post
category: Python
title: Python标准库 -- logging
---
**本文介绍python标准库，先从最基本的开始，主要参考: [Logging HOWTO](https://docs.python.org/2/howto/logging.html#logging-basic-tutorial)**  
# 1. 什么时候用logging
logging提供了几个方便的function，包括debug(), info(), warning(), error()和critical().
关于具体的使用时机，guide上给出了下面这个表格：

想要执行的任务|适合的tool
---|---
显示命令行工具或者程序的标准输出|print()
程序运行时正常的事件记录(例如错误分析时的状态监测)|logging.info()(或logging.debug()显示详细信息)
针对运行的事件的警告|warning.warn():如果问题可避免，而且应该被修复。logging.warnig(): 如果软件无法修复，但仍需注意的问题。
运行的事件错误|raise an exception抛出异常
报告错误但无需抛出异常(例如长时间运行的进程错误)|logging.error(),logging.exception()或logging.critical()

logging function 的级别介绍(按重要级别递增)：  

level|numerical level|使用情景
:---:|:---:|:---
DEBUG|10|细节信息，常用于诊断问题
INFO|20|正常工作的确认信息
WARNING|30|不希望的事件已经发生或者即将发生，但仍然正常运行
ERROR|40|由于更严重的问题，软件不能执行某些功能
CRITICAL|50|严重问题，软件无法运行

默认的level是warning，高于warning级别的log会显示
例：
```python
>>> import logging
>>> logging.warning('Watch out!')
WARNING:root:Watch out!
>>> logging.info('I told you so')
>>> 
```
info信息默认不会显示

# 首先，介绍logging的 Module-Level Functions
## logging to a file
设置默认level为DEBUG，并输出到文件, 所有logging信息都可以打印出来。这个例子涉及到了`logging.basicConfig()`,`logging.debug()`等等.
```python
>>> import logging
>>> logging.basicConfig(filename='example.log', level=logging.DEBUG)
>>> logging.debug('This message should go to the log file')
>>> logging.info('This is an info log line')
>>> logging.critical('Wow, critical')
>>> logging.error('ha')
>>> logging.error('There is an error')
>>> logging.warning('Warn: ')

[root@localhost ~]# cat example.log 
DEBUG:root:This message should go to the log file
INFO:root:This is an info log line
CRITICAL:root:Wow, critical
ERROR:root:ha
ERROR:root:There is an error
WARNING:root:Warn: 
```
下面的例子是利用logging的level，获取它的数字level，并进行一些判断和处理，作用是可以让使用者自己定义log的level，用到了getattr这个内建函数：  
```python
# assuming loglevel is bound to the string value obtained from the
# command line argument. Convert to upper case to allow the user to
# specify --log=DEBUG or --log=debug
numeric_level = getattr(logging, loglevel.upper(), None)
if not isinstance(numeric_level, int):
    raise ValueError('Invalid log level: %s' % loglevel)
logging.basicConfig(level=numeric_level, ...)
```
也可以设置log file每次写之前清除原有内容：
```python
logging.basicConfig(filename='example.log', filemode='w', level=logging.DEBUG)
```
上例中的getattr举例：  
```python
>>> getattr(logging,'INFO')
20
#实际上就相当于：
>>> logging.INFO
20
```
**getattr的作用就是返回对象的属性值。**
## logging 变量
```python
>>> import logging
>>> logging.basicConfig(level=logging.INFO)
>>> my_name = 'doing'
>>> logging.info('%s is my name', my_name)
INFO:root:doing is my name
```
和print的标准字符串很像，只是格式有一点差异，而且，logging的输出支持`str.format()`和`string.template`,这种用法，放在string的文章中详细介绍。

## logging显示格式和显示时间
```python
>>> import logging
>>> logging.basicConfig(format='%(asctime)s %(levelname)s:%(message)s', 
>>> logging.warning('Please notice the CPU utibily!')
2017-05-05 12:58:18,379 WARNING:Please notice the CPU utibily!
```
也可以更改时间格式：
```python
>>> import logging
>>> logging.basicConfig(format='%(asctime)s %(levelname)s:%(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.DEBUG)
>>> logging.warning('Please notice the CPU utibily!')
05/05/2017 01:06:22 PM WARNING:Please notice the CPU utibily!
```
更多的格式说明可以参考 [time.strftime()](https://docs.python.org/2/library/time.html#time.strftime)
# 其次，介绍logging module的各个object
logging模块主要包含几个部分：loggers, handlers, filters, formatters.
