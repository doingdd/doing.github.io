---
category: Linux
layout: post
title: Bash脚本调试和编写技巧
---
**本文来源于微信公众号Linux爱好者，加上自己平用过的bash编写总结。**

## 当有命令运行失败时退出(set -e)
exit简称，bash中即使某些命令运行失败，脚本仍然会继续运行，有时会导致后续结果不可测，可以在脚本中添加以下命令，让其有任何命令失败即退出：
```shell
set -o errexit
或者
set -e
```
```shell
#!/bin/bash
set -e
ls /home/yidu/haha
echo "Done"
```
输出：
```
[yidu@SPVM49 bin]$ ./test.sh 
ls: /home/yidu/haha: No such file or directory
```
如果取消set -e，输出：
```shell
Done
```

## 当使用了未声明变量时退出(set -u)
unset简称，同样，如果调用了未声明变量，退出脚本：
```shell
set -o nounset
或者
set -u
```
## 打印脚本执行过的每一行(set -v)
verbose简称，打开shell脚本的verbose模式：
```shell
set -v
echo "heihei"
```
## 只读取不执行(set -n)
noexec简称，语法检查模式，只读取不执行。
```shell
set -n
```
## debug 模式(set -x)
xtrace的简称，在想要debug的代码前后分别set -x(开启) 和set +x(禁止)可以在执行的过程中打印变量的debug信息：
```shell
set -x
name=yidu
echo $name
set +x
```

## 使用$(command)而不是\`command\`
注意，不能有空格存在：
```shell
user=$(whoami)
echo $user
yidu
```

## 使用readonly声明只读变量
静态变量一旦定义后不能被修改:
```shell
readonly passwd_file="/etc/passwd"
readonly group_file="/etc/group"
```
