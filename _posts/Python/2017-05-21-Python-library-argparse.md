---
layout: post
category: Python
title: Python标准库 -- argparse
---
**本文主要介绍Python官方推荐的命令行参数处理模块： argparse**
[Python Standar Library](https://docs.python.org/2/library/argparse.html?highlight=argparse#module-argparse)  
[Argparse Tutorial](https://docs.python.org/2/howto/argparse.html#id1)  

## 1. 简单的命令行处理流程
```python
[root@localhost python]# cat prog.py
#!/usr/bin/python
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("square", help="display a square of a given number",type=int)
parser.add_argument("--verbosity", help="increase output verbosity")
args = parser.parse_args()
print args.square**2
if args.verbosity:
	print "verbosity turned on"
```
简单看一共三步：
1. `ArgumentParser()`创建一个parser对象。
2. `add_argument()`添加想定义的参数，可调用多次，每次定义一个参数，这里的-h也就是--help参数是模块自动添加的，作用是显示usage。
3. `parse_args()`解析定义的参数，将参数的名字以`parser.args`格式，`args`就是自定义的参数。

参数类型分为positional argument和optional argument，必要参数和可选参数。命令行的参数顺序不受限制。	

## 2. argparse模块详细介绍
#### 1.argparse.ArgumentParser()
argparse.ArgumentParser(prog=None, usage=None, description=None, epilog=None, parents=[], formatter_class=argparse.HelpFormatter, prefix_chars='-', fromfile_prefix_chars=None, argument_default=None, conflict_handler='error', add_help=True)  

`prog` - The name of the program (default: sys.argv[0])
`usage` - The string describing the program usage (default: generated from arguments added to parser)
`description` - Text to display before the argument help (default: none)
`epilog` - Text to display after the argument help (default: none)
`parents` - A list of ArgumentParser objects whose arguments should also be included
`formatter_class` - A class for customizing the help output
`prefix_chars` - The set of characters that prefix optional arguments (default: ‘-‘)
`fromfile_prefix_chars` - The set of characters that prefix files from which additional arguments should be read (default: None)
`argument_default` - The global default value for arguments (default: None)
`conflict_handler` - The strategy for resolving conflicting optionals (usually unnecessary)
`add_help` - Add a -h/--help option to the parser (default: True)


#### 2. argparse.add_argument()
ArgumentParser.add_argument(name or flags...[, action][, nargs][, const][, default][, type][, choices][, required][, help][, metavar][, dest])  

`name or flags` - Either a name or a list of option strings, e.g. foo or -f, --foo.    
如果指定的参数以-开头，则成为必选参数，其他的不以-开头的参数为可选参数。    

`action` - The basic type of action to be taken when this argument is encountered at the command line.  
给参数指定一个action，常用的有`store_const`(跟const参数一起用),`store_true`（将参数设为flag，默认为true）, `store_false`（将参数设定为false）,`count`(使参数可以累积次数，常用语参数的详细等级)，`version`可以定义软件版本。  
    
`nargs` - The number of command-line arguments that should be consumed.   
一个参数(action)可以对应多个参数后面的输入参数，以list形式存储。  `nargs=N`是n次，`?`是可以出现一次或零次；`*`0到多次；`+`1到多次，0次报错。  

`const` - A constant value required by some action and nargs selections.  
指定一个参数的常量    

`default` - The value produced if the argument is absent from the command line.  
参数的默认值    

`type` - The type to which the command-line argument should be converted.
参数类型，常见的有`type=int`, str, file等，默认为str。    

`choices` - A container of the allowable values for the argument.  
设定参数的选择范围，超出范围报错: `choices=range(1, 4)`.    

`required` - Whether or not the command-line option may be omitted (optionals only).   
默认情况将`-`开头的参数设为可选参数，如果想要其成为必选，`required=true`。    

`help` - A brief description of what the argument does.  
指定参数的help信息，默认时打开的，`help="This is help."`    

`metavar` - A name for the argument in usage messages.   
在usage信息里面参数的自定义名字， 不改变参数的实际名字。  

`dest` - The name of the attribute to be added to the object returned by parse_args().
真正自定义参数名字。  


#### 3. ArgumentParser.parse_args()
ArgumentParser.parse_args(args=None, namespace=None)  
将参数转化为命名空间里的对象，返回命名空间。
**指定参数值**： 
```python 
>>> parser = argparse.ArgumentParser(prog='PROG')
>>> parser.add_argument('-x')
>>> parser.add_argument('--foo')
#第一种方法，参数和值用list传递：
>>> parser.parse_args(['-x', 'X'])
Namespace(foo=None, x='X')
>>> parser.parse_args(['--foo', 'FOO'])
Namespace(foo='FOO', x=None)
第二种方法，用等式：
>>> parser.parse_args(['--foo=FOO'])
Namespace(foo='FOO', x=None)
第三种方法，直接连一起：
>>> parser.parse_args(['-xX'])
Namespace(foo=None, x='X')
>>> parser.parse_args(['-xyzZ'])
Namespace(x=True, y=True, z='Z')
```
**无效参数：**    
参数type不对，使用未指定参数，或者参数数目不对都会报错：
```python
>>> parser = argparse.ArgumentParser(prog='PROG')
>>> parser.add_argument('--foo', type=int)
>>> parser.add_argument('bar', nargs='?')

>>> # invalid type
>>> parser.parse_args(['--foo', 'spam'])
usage: PROG [-h] [--foo FOO] [bar]
PROG: error: argument --foo: invalid int value: 'spam'

>>> # invalid option
>>> parser.parse_args(['--bar'])
usage: PROG [-h] [--foo FOO] [bar]
PROG: error: no such option: --bar

>>> # wrong number of arguments
>>> parser.parse_args(['spam', 'badger'])
usage: PROG [-h] [--foo FOO] [bar]
PROG: error: extra arguments found: badger
```
还有对负数参数的处理，prefix match等等。
## 3. 上例子
```python
parser = argparse.ArgumentParser()
        parser.add_argument("-t", "--tool", metavar="clist", type=file, help="'clist' is an example file name which include commands to be executed line by line")
        parser.add_argument("-i", "--install", metavar="<DB.tar>", nargs="+", help="The DB tar file shoud be given one by one with this option. Both relative and absolute path are supported.")

        try:
                args = parser.parse_args()
                ndb = NDB()

                if args.tool:
                        ndb.ndb_tool(args.tool.readlines())
                if args.install:
                        print args.install[:]
                        ndb.ndb_install(args.install[:])
        except IOError:
                parser.print_help()
```
这个例子简单加了两个参数，-i和-t，然后判断参数内容args.tool, args.install,还用到了parser.print_help()
```python
STG2-0-0-9:/u/ainet/yidu/tools-# ./ndb.py -h
usage: ndb.py [-h] [-t clist] [-i <DB.tar> [<DB.tar> ...]]

optional arguments:
  -h, --help            show this help message and exit
  -t clist, --tool clist
                        'clist' is an example file name which include commands
                        to be executed line by line
  -i <DB.tar> [<DB.tar> ...], --install <DB.tar> [<DB.tar> ...]
                        The DB tar file shoud be given one by one with this
                        option. Both relative and absolute path are supported.
```