---
title: Linux 环境变量
layout: post
category: Linux
---

#### 本文简单列举一下linux环境变量的区别和范围。

通常我们会涉及到的环境变量有三种：  
• 当前 Shell 进程私有用户自定义变量，如上面我们创建的 temp 变量，只在当前 Shell 中有效。  
• Shell 本身内建的变量。  
• 从自定义变量导出的环境变量。  
也有三个与上述三种环境变量相关的命令，set，env，export。这三个命令很相似，都可以用于打印相关环境变量,区别在于涉及的是不同范围的环境变量，详见下表：  

|命令|说明|
|---|---|
|set|显示当前 Shell 所有环境变量，包括其内建环境变量（与 Shell 外观等相关），用户自定义变量及导出的环境变量|
|env|显示与当前用户相关的环境变量，还可以让命令在指定环境中运行|
|export|显示从 Shell 中导出成环境变量的变量，也能通过它将自定义变量导出为环境变量|

set, env 和 export的范围如下图：    

![](http://oon3ys1qt.bkt.clouddn.com/linux-value.png-reduce_50_percent)
