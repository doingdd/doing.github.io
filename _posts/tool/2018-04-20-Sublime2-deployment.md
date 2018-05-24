---
category: 工具
layout: post
title: sublime text2使用总结
---

## 开启和关闭Vim
首先按以下方式进入配置文件编辑界面
Preferences -> Settings  

然后在Preferences.sublime-settings--User用户设置中的ignored_packages对应的列表中控制Vintage这一项，删除或者注释掉是打开vim模式，保留(默认)是关闭vim
```
{
	"font_size": 14,
	"tab_size": 4,
	"ignored_packages":
	[
//		"Vintage"
	]
}
```

## TAB转四个空格
设置 sublime 的 tab 自动转换为空格: preferences -> settings-users ->
```
{
    "font_size": 12,
    "tab_size": 4,
    "translate_tabs_to_spaces": true
}
```