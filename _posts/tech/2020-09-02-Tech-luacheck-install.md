---
layout: post
title: lua静态代码检查工具luacheck的本地安装
category: 技术
---

**在非外网环境的安装，参考：https://www.cnblogs.com/coding-my-life/p/12044483.html  
https://www.jianshu.com/p/500984a2d1a5  
https://luarocks.github.io/luarocks/releases/  
https://github.com/mpeterv/luacheck#installation  

**

首先下载几个包：  

luarocks: https://luarocks.github.io/luarocks/releases/  
luacheck: https://github.com/mpeterv/luacheck  
luafilesystem:  https://luarocks.org/modules/hisham/luafilesystem/1.8.0-1  
argparse:  https://luarocks.org/modules/mpeterv/argparse/0.6.0-1  
当然，还有lua本身


##先安装luarocks
解压地址为usr/local/luarocks  

然后找到 lua安装路径下的lua.h的位置，即find / -name "lua.h"，我的路径是/usr/local/lua/src/lua.h
在usr/local/luarocks下执行
```
./configure --prefix=/usr/local/luarocks --with-lua-include=/usr/local/lua/src  
```
其中，predix是指定LuaRocks 安装路径， with-lua-include指定lua文件位置，默认为$LUA_DIR/include
查看参数详情

执行 
```
make bootstrap
```

安装完成，将/usr/local/luarocks/bin添加到环境变量中即可。

##然后用luarocks安装luacheck
解压luacheck，进入到解压后的路径：
```
ls
appveyor.yml  CHANGELOG.md  luacheck-dev-1.rockspec         scripts
bin           docsrc        luafilesystem-1.8.0-1.src.rock  spec
build         LICENSE       README.md                       src

```
将前面下载好的argparse-0.6.0-1.src.rock和luafilesystem-1.8.0-1.src.rock这两个依赖文件放到luacheck的路径下，并执行：
```
luarocks install argparse-0.6.0-1.src.rock
luarocks install luafilesystem-1.8.0-1.src.rock
```

然后执行：
```
#luarocks make luacheck-dev-1.rockspec

luacheck dev-1 depends on lua >= 5.1, < 5.4 (5.1-1 provided by VM)
luacheck dev-1 depends on argparse >= 0.6.0 (0.6.0-1 installed)
luacheck dev-1 depends on luafilesystem >= 1.6.3 (1.8.0-1 installed)
luacheck dev-1 is now installed in /usr/local/luarocks (license: MIT)


```
然后就可以愉快的使用了



