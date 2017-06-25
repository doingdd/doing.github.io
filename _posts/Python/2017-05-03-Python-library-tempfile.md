---
title: Python标准库 -- tempfile
layout: post
category: Python
---

**本文介绍tempfile，主要参考[The Python Standard Library](https://docs.python.org/2/library/tempfile.html)**

tempfile这个module可以工作在任何操作系统，主要用来生成临时文件和临时文件夹。  
从python 2.3版本之后，tempfile module进行了修改，提供三个新function: `NamedTemporaryFile()`, `mkstemp()`, `mkdtemp()`，新建的临时文件名字包含六位随机字符，取代之前的PID。  
而且， 现在的tempfile可以提供参数来决定临时文件的位置和名字，不过为了保留原有格式，参数的顺序有些奇怪，所以，建议使用关键字参数。

## function

### tempfile.TemporaryFile
`tempfile.TemporaryFile([mode='w+b'[, bufsize=-1[, suffix=''[, prefix='tmp'[, dir=None]]]]])`  
返回一个有临时存储空间的类文件对象，是通过`mkstemp()`创建的。一旦关闭，这个文件就会被破坏掉(包括对象垃圾回收导致的close)。在Unix中，文件入口在文件被创建的时候就已经remove掉了(文件名不可见)，在其他系统中则不会这样，所以其他code不应该依赖于这个function创建的文件对象，无论在文件系统中它有没有可见的名字。  
它的参数见下面关于`tempfile.mkstemp`的介绍。  
这个类文件对象可以使用with语句，像一个真正的文件一样。
```python
>>> test_file = tempfile.TemporaryFile(mode = 'w+t')
>>> test_file
<open file '<fdopen>', mode 'w+t' at 0x7f0f16cc95d0>
>>> test_file.writelines(['First', '\n', 'Second line'])
>>> test_file.seek(0)
>>> print test_file.read()
First
Second line
>>> test_file.close()
>>> print test_file
<closed file '<fdopen>', mode 'w+t' at 0x7f0f16cc95d0>
```
```python
>>> with tempfile.TemporaryFile(mode = 'w+t') as test_file:
...     test_file.writelines(['First', '\n', 'Second line'])
... 
>>> test_file.seek(0)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ValueError: I/O operation on closed file
```
可以看到临时文件在close后即销毁的特性
### tempfile.NamedTemporaryFile
`tempfile.NamedTemporaryFile([mode='w+b'[, bufsize=-1[, suffix=''[, prefix='tmp'[, dir=None[, delete=True]]]]]])`  
这个function的与TemporaryFile()的唯一区别是用它创建的类文件对象有一个可见的文件名，名字存在`name`属性中。  
在Unix中，这个name可以重复open第二次，在Window下不行。  
如果delete=True(默认), 文件会在关闭的时候删除。 
```python
>>> with tempfile.NamedTemporaryFile(mode = 'w+t', suffix = '.tmp') as test_file:
...     test_file.name
... 
'/tmp/tmptQDq38.tmp'
```
### tempfile.SpooledTemporaryFile
`tempfile.SpooledTemporaryFile([max_size=0[, mode='w+b'[, bufsize=-1[, suffix=''[, prefix='tmp'[, dir=None]]]]]])`  
这个function和TemporaryFile()的唯一区别是用它创建的文件，数据是存在内存中的，直到大小超过了`max_size`，或者是调用了`fileno()`，数据会像Temporary()一样写到硬盘上。 而且，它的`truncate`方法不支持`size`参数。  
这个function有一个额外的方法：`rollover()`，用来使文件继续硬盘上的另一个文件写入，无论大小(不懂)？
### tempfile.mkstemp
`tempfile.mkstemp([suffix=''[, prefix='tmp'[, dir=None[, text=False]]]])`  
创建一个临时文件，对其user可读可写，不可执行，描述符不可继承。  
和TemporaryFile()不同的是，它需要使用者负责临时文件的删除。  
如果指定`suffix`，文件名后面会追加一个后缀名，但是不会用`.`隔开，需要手动在suffix的开头加`.`。  
如果指定`prefix`，文件名前会加前缀，如果不指定，使用默认值。  
如果指定`dir`，文件将会创建在指定目录，否则，使用默认值。默认值会在平台的dependent-list中选择，用户也可以通过设定`TMPDIR`, `TEMP`或者`TMP`环境变量控制。所以，不保证文件具备任何好的属性，比如不需要引号就可以传递给`os.open()`  
如果指定`text`，意味着是否以二进制模式(默认)打开文件，如果是True，则是text模式。在一些平台，针对纯文本文件，它们没有区别。  
**mkstemp()返回的是一个tuple，包括了类文件对象(类似于os.open())和绝对路径。**  
### tempfile.mkdtemp
`tempfile.mkdtemp([suffix=''[, prefix='tmp'[, dir=None]]])`  
创建一个临时文件夹，对其user可读可写可搜索。  
使用者负责删除。  
`prefix1, dir, suffix` 和mkstemp()一样。  
**它的返回值是临时文件夹的绝对路径。**  
### tempfile.tempdir
**`tempfile.tempdir`**:
当设置其非NONE时，它被用于指定所有function的dir参数。  
如果为空，或者unset了，python会搜索一个list：
1. `TMPDIR` 环境变量指定的location 
2. `TEMP` 环境变量指定的location
3. `TMP`环境变量指定的location
4. 因平台而异的location：
  windows： 	`C:\TEMP`, `C:\TMP`, `\TEMP`, and `\TMP`, in that order.
  all other platform: `/tmp`, `/var/tmp`, and `/usr/tmp`, in that order.
5. 最后，如果上面都找不到，则设置为当前目录。

### tempfile.gettempdir()
返回当前的temp file将被创建的目录，如果tempfile.tempdir被set，则返回set值，否则，按照遍历规则返回查找到的值。

### tempfile.gettempprefix()
返回filename的prefix前缀，不包括目录名
