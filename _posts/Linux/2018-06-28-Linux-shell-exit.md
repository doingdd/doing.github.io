---
title: shell中exit不能退出脚本的情况分析
layout: post
category: Linux
---
**本文记录几个写shell脚本时碰到的exit不能退出脚本的情况**

## 现象
举个例子：
```shell
#!/bin/bash
[ "a" == "b" ] && echo "match" || (echo "haha" && exit)
echo "heihei"
```
这个脚本目的是执行`(echo "haha" && exit)`之后退出脚本，但是实际上的输出是：
```shell
haha
heihei
```
再例:
```shell
#!/bin/bash
echo -e "1\n2\n3"|while read line;do
    echo $line
    exit
done
echo "heihei"
```
同理，执行之后，仍然输出'heihei'，证明脚本确实被执行完了

## 为什么exit退出不了脚本
官方解释：
```shell
exit [n]
              Cause  the  shell  to  exit with a status of n.  If n is omitted, the
              exit status is that of the last command executed.  A trap on EXIT  is
              executed before the shell terminates.
```
简单说，就是exit只能退出当前shell，但是脚本可能会启动多个子shell，如果在子shell中执行exit命令的话，实际上只退出了一层shell，不能退出整个脚本。

## 启动子shell的情况
参考：  
[进入子shell的各种情况分析](https://blog.csdn.net/ma524654165/article/details/77673082)

这里简单记录几个exit不能达到预期的情况：
1. `getopts`
2. `&& || (echo "hei" && exit)`
3. `cat a| while read line;do`
4. `echo $(echo $BASHPID)`
	