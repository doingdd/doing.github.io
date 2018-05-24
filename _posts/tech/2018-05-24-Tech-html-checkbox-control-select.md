---
category: 技术
layout: post
title: html实现checkbox控制select输出到后台
---
##本文记录了一次html的问题解决过程，涉及form，checkbox，select，script等html的元素

**背景是这样的：html的数据以行为单位，每一行有一个select，现在需要增加选择按钮，可以选择想要发送给后台的select数据，而不是全部发送，如果使用一个表单form和submit，默认是会将form里的所有select发送过去，所以需要引入checkbox来控制发送的内容。**

参考了各种标签，对象和方法的使用：  
[w3cschool](http://www.w3school.com.cn/tags/tag_input.asp)  
[w3cschool](https://www.w3schools.com/howto/tryit.asp?filename=tryhow_js_display_checkbox_text)  

## 效果
最终的实现效果如图：

选中某个checkbox之后，与其对应的select标签可用，然后submit会将选中的checkbox对应的select标签的内容发送给后台，未选中的不发送，如果没有选中的，会弹窗告警

##代码
省略大量的查找过程，直接上解决方案：

网页上所有checkbox和select都包在一个form里，然后通过checkbox的点击事件控制与其对应的select对象的可用与否，如果可用，则submit会自动发送，反之则忽略。

完整代码：
```html
<html>
<head>
<script >
function checkclick(){
    //getElementsByName会返回一个所有名字为指定值的数组
    var my_checkbox = document.getElementsByName("query_checkbox");
	var my_select = document.getElementsByName("data");
	var send = false
    //遍历数组元素，如果checkbox选中，则置select为可用，反之不可用
	for(var i=0;i<my_checkbox.length;i++)
	{
		if (my_checkbox[i].checked == true){
		    my_select[i].disabled = false
		    send = true
        } 
		else {
		    my_select[i].disabled = true
		}
	}
    //定义个flag标志，看是不是至少一个checkbox被选中
	if(send == true)
	{
	    return true
	}
	else{
	    alert("At least 1 query should be to choose to submit")
	    return false
	}
	}
</script>
</head>

<body>
  <!--使用了form的onsubmit事件，如果submit被点击，则调用函数checkclick()-->
  <form id="my_form" action="/example/html/form_action.asp" method="get" onsubmit="return checkclick()" >

  <input type="checkbox" name="query_checkbox" onclick = "checkclick()" > I have a bike </input>
  <select name="data" disabled = true ><option value="金士顿;good"  >好召回结果</option>
  <option value="金士;bad"  >差</option></select>
  </br>
  
  <!--使用了checkbox的onclick事件，如果被点击，则调用函数checkclick()-->
  <input type="checkbox" name="query_checkbox" onclick = "checkclick()" > I have a car</input> 
  <select name="data" disabled = true><option value="哇咔咔;good"  >好召回结果</option>
  <option value="哇;bad"  >差</option></select>
  
  <input type="submit" value="Submit" id="submit"> </input>
  </form>

  <p>请在提交按钮上单击，输入会发送到服务器上名为 "form_action.asp" 的页面。</p>

</body>
</html>
```

##总结
在这个问题上卡了半天：选中的checkbox数据发送到后台没问题，但是会把html页面上所有的select的值都发送给后台（因为在同一个form里），尝试着在function里对对应的select的value清空，像这样：  
```
if (my_checkbox[i].checked == true){
...
}
else {
my_select[i].value = ""
```
这样确实不会发送未被选中的checkbox对应的select内容，但是一旦取消选中一次之后，再重新选择该checkbox时，其对应的select的value就再也找不回来了。。。尝试了无数种办法，也不能把这个value重新reset回原始值。最后，发现了disabled这个神奇的属性，尝试了一次发现完美符合，问题解决。