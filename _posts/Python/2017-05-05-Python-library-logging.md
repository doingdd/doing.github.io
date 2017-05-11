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

# 2. 介绍logging的 Module-Level Functions
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
logging.basicConfig函数各参数:  
`filename`: 指定日志文件名  
`filemode`: 和file函数意义相同，指定日志文件的打开模式，'w'或'a'  
`format`: 指定输出的格式和内容，format可以输出很多有用信息，如上例所示:  
 `%(levelno)s`: 打印日志级别的数值  
 `%(levelname)s`: 打印日志级别名称  
 `%(pathname)s`: 打印当前执行程序的路径，其实就是sys.argv[0]  
 `%(filename)s`: 打印当前执行程序名  
 `%(funcName)s`: 打印日志的当前函数  
 `%(lineno)d`: 打印日志的当前行号  
 `%(asctime)s`: 打印日志的时间  
 `%(thread)d`: 打印线程ID  
 `%(threadName)s`: 打印线程名称  
 `%(process)d`: 打印进程ID  
 `%(message)s`: 打印日志信息  
datefmt: 指定时间格式，同time.strftime()  
level: 设置日志级别，默认为logging.WARNING  
stream: 指定将日志的输出流，可以指定输出到sys.stderr,sys.stdout或者文件，默认输出到sys.stderr，当stream和filename同时指定时，stream被忽略  

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
# 3. 介绍logging module的各个object
logging模块主要包含几个部分：loggers, handlers, filters, formatters.
## loggers
Logger 对象包括三类功能。  
首先，提供几个方法接口以供应用调用并保存日志信息。  
其次，根据重要性(默认筛选功能)或其他filter对象决定执行哪些log。  
第三，logger 对象向其它相关的handler传递log。  
总结起来，logger对象就是，保存log，筛选log和传递log，或者按照文档说法：  
最普遍的用法有两方面： **配置和消息发送。**  
logger的常用的**配置**方法：  
`Logger.setLevel()`，顾名思义，设置log级别  
`Logger.addHandler()`, Logger.removeHandler(),添加和删除handler对象给logger对象。  
`Logger.addFilter()`, Logger.removeFilter(), 添加，删除filter对象。  
`logging.getLogger()`,返回一个特定名字(默认为`root`)的logger实例的引用，名字是以`.`分隔的，有继承结构的。  
当多个call以同一名字同时调用logging.getLogger()时，返回同一个logger对象。当名字时继承list里的下一级时，对应对象是上一级名字对应对象的继承。例如：logger 名字是`foo`的对象，是所有logger名字为`foo.tar`, `foo.file`, `foo.pdf`的上一级，后者是children。   
例如：  
`logger = logging.getLogger(__file__)` 返回的是名字为当前文件名的logger对象，配置完成后可以输出log: `logger.info('hi') `

Loggers 有一个explicit level的概念，就是Logger 对象必须有一个明确的级别，如果当前没有，则使用其父辈的level，一直往上找，直到找到`root`这个级别。这个级别用来决定当一个log事件发生时，是否将其传给handlers处理。

子loggers用其父类的loggers的handler发送消息，所以，不用给每一个logger配置handler，只需要给最高级的logger配置即可，当然，也可以set `propagate` 为`False`.
## Handlers
Hanlder 对象 负责分派合适的log信息(根据logger的level)给特定的目的地。Logger对象可以通过addHandler()方法添加0个或多个handler对象。举例，如果需要log发送给文件，stdout和email，则需要配置三个handler，分别处理一个每一个location。  
常用的handler可以参考： [Useful Handlers](https://docs.python.org/2.7/howto/logging.html#useful-handlers)  
最常用的handler：     
**logging.FileHandler(filename, mode='a', encoding=None, delay=False)**    
将log以指定模式存进指定文件  
**logging.StreamHandler(stream=None)**    
将log发送给标准流输出。  
## Formatters
Formatter对象配置log信息的最后顺序，结构和内容。formatter有两个可选参数，信息的格式字符串和日期格式字符串。  
**logging.Formatter.__init__(fmt=None,datafmt=None)**  
举例：
```python
sys_fmt = '%(asctime)s %(levelname)s %(filename)s:%(lineno)d %(processName)s MSGCLS=%(message)s'
datefmt = '%Y%m%d%H%M%S'
sys_formatter = logging.Formatter(sys_fmt, datefmt)
```

如果没有message format string，则使用原始message，如果没有date format string，则使用如下格式： 
`%Y-%m-%d %H:%M:%S`后面再加上事件发生的毫秒数。   
message format string的基本格式是`**%(<dictionary key>)s**`.如下例，列出了时间，级别和log内容：  
```python
'%(asctime)s - %(levelname)s - %(message)s'
```
Formatters默认使用time.localtime(),如果需要，可以设置`converter`属性为time.gmtime()，显示GMT格式的时间。  

# 概念有点乱，上例子

定义logger：
```python
import logging

logger = logging.getLogger('my_log')
logger.setLevel(logging.DEBUG)
```
定义handler，这里既要存文件，又要打印输出：
```python
file_h = logging.FileHandler('test.log')
file_h.setLevel(logging.DEBUG)

console_h = logging.StreamHandler()
console_h.setLevel(logging.DEBUG)
```
定义formatter，这里更改了默认的时间格式，不想输出毫秒。
```python
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
formatter.datefmt='%Y/%m/%d %H:%M:%S'
```
把formatter给set给handler，再把handler赋给logger
```python
file_h.setFormatter(formatter)
console_h.setFormatter(formatter)

logger.addHandler(file_h)
logger.addHandler(console_h)
```
最后 打印log：
```python
logger.debug('cool')
logger.error('bad')
```

