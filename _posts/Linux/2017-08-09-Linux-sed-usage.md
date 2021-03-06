---
layout: post
category: Linux
title: Linux sed命令用法
---

**本文详细介绍sed的用法，不定期更新**    
[sed简明教程](https://coolshell.cn/articles/9104.html)   

sed是将数据按行操作的文本处理工具，可以分析standard input，可以对数据进行替换，删除，新增，选取特定行等功能，默认支持基础正则，可以加-r参数支持扩展正则。  

基本的用法规则如下：
```shell
[root@www ~]# sed [-nefri] [动作]
选项与参数：
-n  ：使用安静(silent)模式。在一般 sed 的用法中，所有来自 STDIN 的数据一般都会被列出到萤幕上。   
但如果加上 -n 参数后，则只有经过sed 特殊处理的那一行(或者动作)才会被列出来。

-e  ：直接在命令列模式上进行 sed 的动作编辑；

-f  ：直接将 sed 的动作写在一个文件内， -f filename 则可以运行 filename 内的 
sed 动作；

-r  ：sed 的动作支持的是延伸型正规表示法的语法。(默认是基础正规表示法语法)

-i  ：直接修改读取的文件内容，而不是由屏幕输出。

动作说明：  [n1[,n2]]function
n1, n2 ：不见得会存在，一般代表『选择进行动作的行数』，举例来说，如果我的动作
         是需要在 10 到 20 行之间进行的，则『 10,20[动作行为] 』

function 有底下这些咚咚：
a   ：新增， a 的后面可以接字串，而这些字串会在新的一行出现(目前的下一行)～
c   ：取代， c 的后面可以接字串，这些字串可以取代 n1,n2 之间的行！
d   ：删除，因为是删除啊，所以 d 后面通常不接任何咚咚；
i   ：插入， i 的后面可以接字串，而这些字串会在新的一行出现(目前的上一行)；
p   ：列印，亦即将某个选择的数据印出。通常 p 会与参数 sed -n 一起运行～
s   ：取代，可以直接进行取代的工作哩！通常这个 s 的动作可以搭配
      正规表示法！例如 1,20s/old/new/g 就是啦！

```

sed 的命令结构比较复杂，参数和动作都有不同的组合方式，下面按照不同的功能进行介绍。
### 新增行/删除行
**1.仅在屏幕输出上新增/删除**  
下例用到sed动作里的a,和i，a表示指定行后插入行(append?)，i表示指定行前插入(insert)
```shell
# test文件的原内容
[root@localhost ~]# nl test 
     1  root:x:0:0:root:/root:/bin/bash
     2  bin:x:1:1:bin:/bin:/sbin/nologin
     3  daemon:x:2:2:daemon:/sbin:/sbin/nologin

#在屏幕输出上直接新增一行,内容为'wakaka'
[root@localhost ~]# nl test|sed '2i wakaka'
     1  root:x:0:0:root:/root:/bin/bash
wakaka
     2  bin:x:1:1:bin:/bin:/sbin/nologin
     3  daemon:x:2:2:daemon:/sbin:/sbin/nologin

# 在第二行后面新增一行
[root@localhost ~]#  nl test|sed '2a wakaka'
     1  root:x:0:0:root:/root:/bin/bash
     2  bin:x:1:1:bin:/bin:/sbin/nologin
wakaka
     3  daemon:x:2:2:daemon:/sbin:/sbin/nologin

#插入多行
[root@localhost ~]# nl test|sed '2a wakaka\
> heihei'
     1  root:x:0:0:root:/root:/bin/bash
     2  bin:x:1:1:bin:/bin:/sbin/nologin
wakaka
heihei
     3  daemon:x:2:2:daemon:/sbin:/sbin/nologin

#删除2-3行
[root@localhost ~]# nl test|sed '2,3d'
     1  root:x:0:0:root:/root:/bin/bash
```
**2.直接修改文件内容新增行和删除行**    
sed对文件直接操作的参数是-i, 所以在上例的基础上加上-i参数即可
```shell
[root@localhost ~]# sed -i '2a heihei' test
[root@localhost ~]# nl test
     1  root:x:0:0:root:/root:/bin/bash
     2  bin:x:1:1:bin:/bin:/sbin/nologin
     3  heihei
     4  daemon:x:2:2:daemon:/sbin:/sbin/nologin
```
### 打印指定行到屏幕 
涉及到sed的-n模式
```shell
#指定打印特定行到屏幕
[root@localhost ~]# nl test|sed -n "2p"
     2  daemon:x:2:2:daemon:/sbin:/sbin/nologin
```
注意，打印的功能是p实现的，-n的功能是安静模式，即仅输出处理过的行，它们俩常在一起使用。

### 行替换

```shell
[root@localhost ~]# cat test | sed '2c haha'
root:x:0:0:root:/root:/bin/bash
haha
```

### 字符串替换
很常用的功能，用到s这个function，可支持正则，所以可以实现很多功能。   

基本的语法格式是:     
`sed 's/原字符串/新字符串/g'`     
其中原字符串和新字符串都可以为空,这时直接连写两个//即可，详情如下。  

**简单的替换：**
```shell
[root@localhost ~]# cat test 
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin

[root@localhost ~]# sed -i 's/daemon/doing/g' test
[root@localhost ~]# cat test 
doing:x:2:2:doing:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
```

**截取一段字符串：**
```shell
[root@localhost ~]# ip a|grep "inet 10"
    inet 10.100.103.13/24 brd 10.100.103.255 scope global eth0
[root@localhost ~]# ip a|grep "inet 10"|sed -r 's/^.*inet|brd.*$//g'
 10.100.103.13/24 
```

**取消和添加注释:**  
```shell
[root@localhost ~]# cat test
#root:x:0:0:root:/root:/bin/bash
daemon:x:2:2:daemon:/sbin:/sbin/nologin

# 取消注释：
[root@localhost ~]# cat test|sed 's/^#//g'
root:x:0:0:root:/root:/bin/bash
daemon:x:2:2:daemon:/sbin:/sbin/nologin
# 添加注释
[root@localhost ~]# cat test| sed '2s/^/#/g'
#root:x:0:0:root:/root:/bin/bash
#daemon:x:2:2:daemon:/sbin:/sbin/nologin
```

**行尾加东西：**  
```shell
sed -i 's/$/===/g' passwd
```

**删除注释行：**  
```shell
sed -i '/^#.*/d' SIMDB311_config_info
```

**删除空白行:**   
```shell
sed -i '/^$/d' SIMDB311_config_info
```

**文件末尾加入新行:**  
```shell
# "$"代表文件的最后一行
sed -i '$a #Hi, This is me' test

# 文件头加一行呢：
 sed -i '1i #File start!' test
```

**替换换行符(多行合并，两行合并)：**
第一种是替换每一行的换行符为逗号，第二种为每两行合并成一行：
```shell

echo "a,b,c,d" |sed 's/,/\n/g'|sed ':x;N;s/\n/,/;b x'
a,b,c,d

echo "a,b,c,d" |sed 's/,/\n/g'|sed 'N;s/\n/,/'
a,b
c,d
```
解释：   
`:x`是定义一个标签，用来实现跳转处理，名字可以随便取(label),后面的b x就是跳转指令  

`N;`  N是sed的一个处理命令，追加文本流中的下一行到模式空间进行合并处理，因此是换行符可见

`s/\n/,/` s是sed的替换命令，将换行符替换为逗号

`;`不同的命令用分号隔开  

**&号的用法**  
```shell
echo hello|sed 's/hello/(&)/'
(hello)

sed -i -e 's/^.*dump.sh/#&/' control.sh
```
&号就表示匹配的内容本身，上面第一行中就表示hello，然后给hello加了个括号   
第二行就是匹配"dump.sh"，如果匹配到就在前面加井号，注释掉，注意sed是以行为单位的，所以第二行会把文件中所有包含dump.sh的行注释掉

**分隔符的用法**  
sed中的分隔符不仅可以使用默认的`/`，还可以用`%`,`:`和`,`等，而且可以直接使用不用任何声名，其目的就是为了区分pattern中的特殊符号，如果：  
将`/etc/my`替换成`/etc/your`：  
```shell
[duying23@BJYFF3-Client-198134 ~]$ echo '/etc/my' |sed 's:/etc/my:/etc/your:g'
/etc/your
[duying23@BJYFF3-Client-198134 ~]$ echo '/etc/my' |sed 's/\/etc\/my//etc/your/g'
sed: -e expression #1, char 15: unknown option to `s'
[duying23@BJYFF3-Client-198134 ~]$ echo '/etc/my' |sed 's/\/etc\/my/\/etc\/your/g'
/etc/your
[duying23@BJYFF3-Client-198134 ~]$ echo '/etc/my' |sed 's%/etc/my%/etc/your%g'
/etc/your
[duying23@BJYFF3-Client-198134 ~]$ echo '/etc/my' |sed 's,/etc/my,/etc/your,g'
/etc/your

```  
可以看到如果pattenr里有`/`还用`/`做分隔符的话必须用`\`转义，否则报错，其它符号同理


