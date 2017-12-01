---
layout: post
category: 技术
title: linux ssh认证原理(转)
---
**本文介绍ssh公玥认证原理，原文：**  
[ssh密钥认证原理](http://itindex.net/detail/48724-ssh-%E8%AE%A4%E8%AF%81-%E5%8E%9F%E7%90%86?utm_source=tuicool&utm_medium=referral)  

## ssh密钥认证原理

SSH之所以能够保证安全，原因在于它采用了公钥加密。

整个ssh密码登录过程是这样的：

1）用户向远程主机发登录请求：ssh user@远程主机 

2）远程主机收到用户的登录请求，把自己的公钥发给用户。

2）用户使用这个公钥，将登录密码加密后，发送回远程主机。

3）远程主机用自己的私钥，解密登录密码，如果密码正确，就同意用户登录。

整体流程图如下：  
![](http://oon3ys1qt.bkt.clouddn.com/sshlogin.png)

在linux上，如果你是第一次登录对方主机，系统会出现下面的提示：
```shell
$ ssh user@host    
　　The authenticity of host 'host (12.18.429.21)' can't be established.    
　　RSA key fingerprint is 98:2e:d7:e0:de:9f:ac:67:28:c2:42:2d:37:16:58:4d.    
　　Are you sure you want to continue connecting (yes/no)?    
```

这段话的意思是，无法确认host主机的真实性，只知道它的公钥指纹，问你还想继续连接吗？   
所谓"公钥指纹"，是指公钥长度较长（这里采用RSA算法，长达1024位），很难比对，所以对其进行MD5计算，将它变成一个128位的指纹。上例中是98:2e:d7:e0:de:9f:ac:67:28:c2:42:2d:37:16:58:4d，再进行比较，就容易多了。   
很自然的一个问题就是，用户怎么知道远程主机的公钥指纹应该是多少？回答是没有好办法，远程主机必须在自己的网站上贴出公钥指纹，以便用户自行核对。   
假定经过风险衡量以后，用户决定接受这个远程主机的公钥。   
```shell
Are you sure you want to continue connecting (yes/no)? yes
```

系统会出现一句提示，表示host主机已经得到认可。 
```shell
　Warning: Permanently added 'host,12.18.429.21' (RSA) to the list of known hosts.
```

然后，会要求输入密码。 
```
Password: (enter password)
```

如果密码正确，就可以登录了。   
当远程主机的公钥被接受以后，它就会被保存在文件$HOME/.ssh/known_hosts之中。下次再连接这台主机，系统就会认出它的公钥已经保存在本地了，从而跳过警告部分，直接提示输入密码。   
每个SSH用户都有自己的known_hosts文件，分别在自己的$HOME目录下，此外操作系统也有一个这样的文件，通常是/etc/ssh/ssh_known_hosts，保存一些对所有用户都可信赖的远程主机的公钥。 

## 使用公钥登录（免输入密码)  
使用密码登录，每次都必须输入密码，非常麻烦。好在SSH还提供了公钥登录，可以省去输入密码的步骤。 
所谓"公钥登录"，原理很简单，就是用户将自己的公钥储存在远程主机上。登录的时候，远程主机会向用户发送一段随机字符串，用户用自己的私钥加密后，再发回来。远程主机用事先储存的公钥进行解密，如果成功，就证明用户是可信的，直接允许登录shell，不再要求输入密码，这和之前的ssh账号密码也没有直接关系。   
流程图如下：  
![](http://oon3ys1qt.bkt.clouddn.com/ssh_nopass_login.png)

这种方法要求用户必须提供自己的公钥。如果没有现成的，可以直接用ssh-keygen生成一个： 
```shell
$ ssh-keygen
```

运行上面的命令以后，系统会出现一系列提示，可以一路回车。其中有一个问题是，要不要对私钥设置口令（passphrase），如果担心私钥的安全，这里可以设置一个。 
运行结束以后，在$HOME/.ssh/目录下，会新生成两个文件：id_rsa.pub和id_rsa。前者是你的公钥，后者是你的私钥。 
这时再输入下面的命令，将公钥传送到远程主机host上面： 
```shell  
$ ssh-copy-id user@host
```

好了，从此你再登录远程主机，就不需要输入密码了。 
如果还是不行，就打开远程主机的/etc/ssh/sshd_config这个文件，检查下面几行前面"#"注释是否取掉。
```shell 
RSAAuthentication yes   
PubkeyAuthentication yes   
AuthorizedKeysFile .ssh/authorized_keys
```
然后，重启远程主机的ssh服务。 

关于authorized_keys文件 
远程主机将用户的公钥，保存在登录后的用户主目录的$HOME/.ssh/authorized_keys文件中。公钥就是一段字符串，只要把它追加在authorized_keys文件的末尾就行了。 

如果不使用上面的ssh-copy-id命令，改用下面的命令也可以： 
```shell
# scp -P 22 id_rsa.pub root@192.168.1.77:/root/.ssh/authorized_keys 
root@192.168.1.77's password:   <-- 输入机器Server的root用户密码 
id_rsa.pub                                                              100%  218     0.2KB/s   00:00 
```
如果远程主机的authorized_keys文件已经存在，也可以往里添加公钥： 
先将公钥文件上传到远程主机中， 
```shell
#scp -P 2007 ~/.ssh/id_rsa.pub root@192.168.1.91:/root/ 
SSH到登陆到远程主机，将公钥追加到 authorized_keys 文件中 
cat /root/id_rsa.pub >> /root/.ssh/authorized_keys 
或直接运行命令: 
cat ~/.ssh/id_dsa.pub|ssh -p 22 root@192.168.1.91 `cat - >> ~/.ssh/authorized_keys` 
写入authorized_keys文件后，公钥登录的设置就完成了。
```


