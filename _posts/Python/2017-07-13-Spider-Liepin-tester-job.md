---
layout: post
category: Python
title: python爬虫--猎聘测试岗位
---
**本文灵感来源于知乎上的一篇分享，附上原作者的GitHub: [如何使用爬虫分析python招聘岗位情况](https://github.com/chenjiandongx/51job)**  
由于本人属于测试岗位，对测试程序员在行业的现状，未来的职业发展比较感兴趣，因为个人对测试还是很喜欢的，所以借着python练手之际，索性分析一下主流公司们对测试人员的要求究竟是什么。

## 先上结论
本文分别爬了猎聘网在**测试**搜索结果下的，薪资为10-15，15-20，20-30的400个岗位需求，目标行业为互联网电商，先来张图云感受一下：  
![](http://oon3ys1qt.bkt.clouddn.com/worldcloud2.jpg)  
图中词语的大小跟其在岗位描述中被提到的次数有关，次数越大，则词语显示越大。  
可以看到，处理**测试**以外，比较大的词汇有**开发**，**自动化**，**产品**等等，可以对测试人员必备技能点有一个感性的认识。  
比较有意思的是，**开发**这个词语在10-15万年薪的岗位中提到的次数远比20-30万的要少，是不是可以理解为，随着年薪的提高，对测试人员的开发能力要求也水涨船高？  

下图坐了个综合对比，主要指标就是词语出现的次数，从三组数据(10-15， 15-20， 20-30)中，手动剔除了比较中性的词语之后，例如**经验、负责、能力、产品、熟悉**等等，留下了几个频度较高且比较**硬**的词汇：  
![](http://oon3ys1qt.bkt.clouddn.com/%E6%B5%8B%E8%AF%95%E6%8A%80%E8%83%BD%E7%82%B9%E8%A6%81%E6%B1%82%E9%A2%91%E5%BA%A6%E5%9B%BE.png)  

实话说，看到这个结果，个人表示是有点无语的，一个测试岗，除了**测试**(已剔除)这个词以外，无论哪个薪资阶段，开发这个词稳定占据榜首，不得不说测试和开发真是相亲相爱相杀啊。

当然，很多岗位对测试人员的写代码能力提出了明确要求，所以，不得不遗憾的承认，单纯的**测试**在国内是没有出路的，一个合格的测试人员，必须是掌握了测试核心思想的，对主流测试框架拿来就用的，测试计划高效可用，并且可以给自己乃至公司写测试框架的，具备相当的开发水平的一个人。实际上涵盖了测试和开发两个方向的知识点，顿时觉得测试高大上了有没有。  

值得一提的是，仅针对测试能力而言，自动化和性能测试看来还是加分最多的选项，测试用例和测试工具算是基础技能吧，由此大概勾勒出基础版的测试技能，应该是这个样子：  
![](http://oon3ys1qt.bkt.clouddn.com/%E6%B5%8B%E8%AF%95%E6%8A%80%E8%83%BD.png)  

## 再谈实现
这个程序主要涉及了一下模块：   
requests负责爬取   
bs4负责解析  
jieba负责分词      
wordcloud生成图云   
csv负责存取数据到文件  
先定义spider类,定义headers和User-Agent：  
```python
class JobSpider():
    def __init__(self):
        self.company = []
        self.text = ""
        self.headers = {'X-Requested-With': 'XMLHttpRequest',
                        'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:47.0) Gecko/20100101 Firefox/47.0',
                        'Referer': 'https://passport.liepin.com/ajaxproxy.html'}
```
然后定义个爬取函数，命名为spider,使用google开发者工具确定需要的tag：
```python
def spider(self):
	# 20-30万
    urls = ["https://www.liepin.com/zhaopin/?pubTime=&compkind=&fromSearchBtn=2&ckid=9ebc3054fd98e3c3&isAnalysis=&init=-1&searchType=1&flushckid=1&dqs=010&industryType=industry_01&jobKind=&sortFlag=15&industries=030&salary=20$30&compscale=&key=%E6%B5%8B%E8%AF%95&clean_condition=&headckid=4da58c2fba8525a9"]
    #这里是第一次爬取，先把每一页的url存起来，然后再遍历爬取
    r = requests.get(urls[0], headers=self.headers).content
    page_list = BeautifulSoup(r, 'lxml').find("div", class_="pagerbar").find_all("a", string = re.compile('\d+'))
    urls.extend([i['href'] for i in page_list if i['href'] != 'javascript:;'])
        
```
将爬取的内容按格式存到csv文件：  
```python
        with open(r'.\data\jobs.csv', 'w') as f:
            f.write(codecs.BOM_UTF8)
            f_csv = csv.writer(f)
            for job in many_jobs:
                row = [job.get('company_name').encode('utf-8'),job.get('title').encode('utf-8'),
                       job.get('condition').encode('utf-8'),job.get('industry').encode('utf-8'),
                       job.get('time').encode('utf-8'),job.get('description').encode('utf-8')]
                f_csv.writerow(row)
```
这里为了在windows下可以直接打开查看csv，不出现乱码，加了一句f.write(codecs.BOM_UTF8)。  
bs4解析后的内容个默认时unicode，这个将其转成UTF-8存储。  

然后用jieba分词：
```python
    # 先用re删除几个词，description是一个包含所有内容的字符串
    r1 = "[(进行)(以上)(以及)]+".decode('utf-8')
    description = re.sub(r1, "".decode('utf-8'), description.decode('utf-8'))
    #load自定义词典
    jieba.load_userdict(r".\data\user_dict.txt")
    #分词，返回所有词语的list
    seg_list = jieba.cut(description, cut_all=False)
    #词频统计，词语长度大于1则加一次
    counter = dict()
    for seg in seg_list:
        if len(seg) > 1:
            counter[seg] = counter.get(seg, 1) + 1
```

再将分词之后的词频统计传给wordcloud，生成图云：
```python
 wordcloud = WordCloud(font_path=r".\font\msyh.ttf",
                              max_words=100, height=600, width=1200).generate_from_frequencies(counter)
```
这里加载了提前下载好的ttf文件，定义字体大小。

最后，源代码见GitHub：