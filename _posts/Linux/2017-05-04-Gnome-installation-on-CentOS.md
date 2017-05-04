---
title: centos 安装gnome和vnc
layout: post
category: Linux
---
**本文介绍在最小化安装的centos 7上安装vnc的过程，前提是有一个正常工作的yum源和网络环境。**    
首先确认vncserver没有安装：  
`rpm -qa|grep vnc`
# 安装 X window
```shell
[root@localhost ~]# yum check-update
[root@localhost ~]# yum groupinstall -y "X Window System"
```
# 安装GNOME Desktop
```shell
[root@localhost ~]# yum groupinstall -y GNOME Desktop
[root@localhost ~]# unlink /etc/systemd/system/default.target
[root@localhost ~]# ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target

```
# 安装vnc server
```shell
yum install tigervnc-server -y
```
## 创建配置文件
```shell
cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
```
## 修改配置文件的用户名：
```shell
[root@localhost ~]# vi /etc/systemd/system/vncserver@:1.service
```
## 修改<USER>为root：
```shell
ExecStart=/usr/sbin/runuser -l root -c "/usr/bin/vncserver %i"
PIDFile=/home/root/.vnc/%H%i.pid
```
## 重启服务
```shell
systemctl daemon-reload
```
## 修改密码
```shell
vncpasswd
```
## 开启服务
```shell
[root@localhost ~]# systemctl enable vncserver@:1.service
Created symlink from /etc/systemd/system/multi-user.target.wants/vncserver@:1.service to /etc/systemd/system/vncserver@:1.service.
systemctl start vncserver@:1.service
```
**Q1, 启动vncserver时报错：**  
* [root@localhost ~]#  systemctl start vncserver@:1.service
Job for vncserver@:1.service failed because a configured resource limit was exceeded. See "systemctl status vncserver@:1.service" and "journalctl -xe" for details.
* 解决方案： 修改/etc/systemd/system/vncserver@:1.service文件里的type为simple。  
systemctl daemon-reload
再启动vncserver

## 查看防火墙
查看防火墙是否开启，如果开启则需要配置：  
```shell
systemctl status firewalld.service
sudo firewall-cmd --permanent --add-service vnc-server
sudo systemctl restart firewalld.service
```
## 查看vnc状态，通过vnc client连接  
![](http://oon3ys1qt.bkt.clouddn.com/vnc.png)
下载vnc client  
[官网地址](https://www.realvnc.com/download/viewer/)
**Q2, vnc viewer failed to connect 操作成功完成 : **  

![](http://oon3ys1qt.bkt.clouddn.com/vncQ2.png)  
* 确保vncserver的：1起起来：
`netstat -anp|grep Xvnc` 

* 查看pid进程是不是起起来了。
```shell
  ls ~/.vnc/ |grep pid
  ps -ef|grep "pid"
```
* 查看防火墙是否开启：
  `ps -ef|grep iptables`
  修改防火墙文件，增加下面第一行内容到 `/etc/sysconfig/iptables`，并重启防火墙
```shell
-A INPUT -m state --state NEW -m tcp -p tcp --dport 5900:5903 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited

# systemctl restart iptables
```
意思是允许5900到5903端口被访问。



