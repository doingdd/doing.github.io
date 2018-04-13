---
category: 技术
layout: post
title: MapReduce模型简介
---

**本文是一篇wikipedia的翻译：[MapReduce](https://en.wikipedia.org/wiki/MapReduce)**    
**中文版：[MapReduce](https://zh.wikipedia.org/wiki/MapReduce)**  

## MapReduce

MapReduce是一种编程模型和实现方式，主要针对集群上通过并行或分布式算法来生成和处理大数据集合的情况。  

一个MapReduce程序主要包括两方面：  
Map procedure: 映射，主要负责过滤和排序(比如按名字将学生排序，每个名字对应一个队列)  
Reduce method: 剪裁,缩减,归约(不知道怎么翻译，意会吧)(归纳比较恰当)，主要负责汇总的操作(例如对每个名字队列里的学生计数，生成名字频率分析)  

MapReduce系统(或称MapReduce结果或框架)通过对分布式服务器编组，并行执行任务，管理系统不同组件之间的通信和数据传输，提供冗余和容灾等方式来协调程序的执行  

在数据分析中，这种模型是分片--执行--整合策略的一类具体实现，受启发与函数式编程中的map和reduce函数，不过，在MapReduce框架中，其目的已经和函数式编程不一样了。MapReduce模型的核心不是map或者reduce函数，而是通过优化执行引擎实现的大量应用可伸缩性和容错能力。  

例如，单线程的MapReduce不会比non-MapReduce更快，它的优势通常在多线程程序中有所体现。 只有在优化分布式洗牌(distributed shuffle)操作时(减少了网络通讯时间)和错误处理时MapReduce才会起到作用。一个优秀的MapReduce算法的本质就是尽可能的减少通讯开销。  

**ps: distributed shuffle 是什么: [Spark官方文档 - 中文翻译](https://www.cnblogs.com/BYRans/p/5292763.html)**  

MapReduce库根据不同的编程语言有不同的优化等级, 它的实现比较流行的有Apache Hadoop，它是一个开源的支持分布式洗牌的实现。MapReduce这个名字起源于Google的技术专利，后来去商标化了，而且不再使用MapReduce做他的大数据处理模块，转向开发Apache Mahout。  

## 1. 概述

MapReduce是一个使用大量计算机节点并行的处理大数据集的框架，可以理解成一个cluster(集群，所有节点共享网络，硬件类似)或者一个grid(网络，节点跨区域，跨本地网，分布式，硬件不同)，它可以处理非结构化的文件系统中的数据，也可以处理结构化的数据库中的数据。MapReduce可以利用数据的局部性，在存储地点附近进行处理，以尽量减少通信开销。  

一个MapReduce框架通常包括三个部分：   
* **Map**： 每个worker node都执行map功能，将输出临时存储，master node确保冗余的数据输入只会被执行一次map 
* **Shuffle**： worker nodes根据输出的key(由map function产生)重新分配数据，这样同一个key对应的所有数据都会在同一个节点上存储
* **Reduce**： worker nodes 根据key值并行的处理每一组数据

MapReduce允许分布式的执行map和reduce操作。 map可以并行执行，前提是每个map操作都应该各自独立；在实际过程中，独立的数据源数量或者数据源可用的CPU数量决定了map的独立性。同样，一组reduce操作可以同时执行，前提是共享相同key的map操作的所有输出应当同时对应给相同的reducer，或者reduce函数式相互关联的。尽管这一过程与更具顺序性的算法相比效率比较低，但是MapReduce可以处理比商用服务器更大量的数据集--大型服务器集群可以在几小时内对PB级的数据排序，而且，并行性还提供了部分故障恢复的办法：如果一个mapper或者reducer挂了，它的工作可以被重新计划执行，前提是输入数据仍可用。  

另外一个角度来看，MapReduce可以分成并行的分布式的5个步骤：
1. 准备Map()输入 - “MapReduce系统”指定Map处理器，给每个处理器分配K1键值对，并为该处理器提供与该键值相关联的所有输入数据
2. 运行用户提供的Map()代码 -  Map()对每个K1键值运行一次，生成由键值K2组织的输出。
3. 将Map输出“Shuffle”(洗牌，保证同一个key在同一个reducer)到Reduce处理器 -  MapReduce系统指定Reduce处理器，给每个处理器分配K2键值对，并为该处理器提供与该键值对关联的所有Map生成的数据。
4. 运行用户提供的Reduce（）代码 - 对于Map步骤生成的每个K2键值，Reduce（）只运行一次。
5. 产生最终输出 -  MapReduce系统收集所有的Reduce输出，并将其按K2排序以产生最终结果。  


这五个步骤在逻辑上可以认为是按顺序运行 - 每个步骤仅在前一步骤完成后才开始 - 尽管实际上只要最终结果不受影响，它们就可以交错。

在许多情况下，输入数据可能已经在许多不同的服务器中分布（“分片”），在这种情况下，步骤1有时可以通过让Map server处理其本地数据而大大简化。同样，步骤3也可以通过让reduce处理与其最接近的map server的数据来加快处理速度。  

## 逻辑视图

MapReduce的Map和Reduce功能都是以"键值对"对结构化数据定义的。map使用同一数据域中特定类型的一个键值对，返回不同数据域的键值对组成的list(不太理解这句)：  
`Map(k1,v1) → list(k2,v2)`

map对每个键值对(k1,value，k1作为key)的处理时并行的，每次处理将产生一个对组成的序列(以k2为key)，然后，MapReduce框架整合所有的以k2为key值的数据对，每个k2对应着一组数据。  

reduce模块并行地操作每个group，然后同一数据域中的数据整合在一起。  
`Reduce(k2, list (v2)) → list(v3)`
每个reduce call 返回一个value v3或者空，不过一个call是可以允许多个value返回的，返回值会整合成期望了结果list。  

也就是说，MapReduce框架将一个(key,value)数据对组成的list转换成一个纯value组成的list。区别于传统的函数式编程中的map和reduce结合，其将任意value组成的list转换成map返回的整合了所有value的单个value(list -> value)。

为了实现MapReduce，仅仅实现map和reduce的抽象是不够的，针对分布式部署，还需要一个可以联合map和reduce阶段的办法。 它可能是一个分布式文件系统，或者其它的方案，例如map到reduce的直接流式处理，或者map向查询它的reduce提供结果。  

## 例子

1.一个标准的MapReduce例子是对一系列文件中的每个单词进行计数：  

```python
function map(String name, String document):
  // name: document name
  // document: document contents
  for each word w in document:
    emit (w, 1)

function reduce(String word, Iterator partialCounts):
  // word: a word
  // partialCounts: a list of aggregated partial counts
  sum = 0
  for each pc in partialCounts:
    sum += pc
  emit (word, sum)
```
这个例子里，map接受每个document里切割好的words，然后对每个word进行计数，key是word，value是次数。然后MapReduce框架负责将所有map返回的结果整合，将相同word的键值对(word,count)发个同一个reducer，然后，reduce只需要将其输入进行简单的求和，就可以得出改word出现的总次数。

2.另一个例子，有一个数据库，里面有1.1 billion的人(record)，每个record有一些域，姓名，年龄，联系人等等。现在想计算所有人的联系人个数的平均值，并按照年龄进行排序展示。  

用SQL语句可以这么实现：
```mysql
SELECT age, AVG(contacts)
    FROM social.person
GROUP BY age
ORDER BY age
```
使用MapReduce，K1可以定义为1到1100的数字，每个数字代表了一个million的reocrd，K2可以表示人的年龄，可以通过下面的伪代码实现：
```python
function Map is
    input: integer K1 between 1 and 1100, representing a batch of 1 million social.person records
    for each social.person record in the K1 batch do
        let Y be the person's age
        let N be the number of contacts the person has
        produce one output record (Y,(N,1))
    repeat
end function

function Reduce is
    input: age (in years) Y
    for each input record (Y,(N,C)) do
        Accumulate in S the sum of N*C
        Accumulate in Cnew the sum of C
    repeat
    let A be S/Cnew
    produce one output record (Y,(A,Cnew))
end function
```
这个实现中，MapReduce会用到1100个map进程，每个处理其对应的一百万数据。所以整个Map过程会产生11亿个(Y,(N,1))records。其中Y的值表示年龄，假设其范围为8到103岁，因为我们需要的输出是根据年龄来划分的，这样就需要96个reducer实现洗牌的工作，每个reducer处理与其对应年龄的百万级的input record，输出为96个record(Y,A)，最后写入结果文件，sorted by Y。

**注：** 这里解释一下，Map function中的输入为1million的数据，输出(Y,(N,1))，这个Y是年龄，N是contacts number，1是一个计数，表示该年龄有相同联系人个数的人有几个，下面解释为什么要加这个count，假设有个三个map进程，它们处理数据的输出分别是：  
```
-- map output #1: age, quantity of contacts
10, 9
10, 9
10, 9
-- map output #2: age, quantity of contacts
10, 9
10, 9
-- map output #3: age, quantity of contacts
10, 10
```
如果没有count，对map1和mpa2处理时得到的结果，再与map3进行处理，平均值为：((9+9+9+9+9)/5 + 10)/2 = 9.5 而实际上的平均值应该为：(9+9+9+9+9+10)/(3+2+1) = 9.167 

## 数据流
MapReduce框架的frozen part(理解为比较固定的模块)是一个大数据量的分布式排序，它定义的使用比较多的包括：   

* an input reader
* a Map function
* a partition function
* a compare function
* a Reduce  function
* an output writer

1. input reader     
input reader 的作用是从永久性存储媒介(例如分布式文件系统)读取数据，然后将其按照合适的大小切割(通常是64M或者128M)，并输出key/value数据对，每片输出由框架(平台)分发给对应的map进程。  
简单例子就是将一个文件所有内容读入，然后每行数据作为输出record。  

2. Map function  
每个map进程拿到输入的key，value数据对序列之后，经过处理会输出零个或者多个键值对，map的输入和输出格式可以且经常是不一样的。  
如果应用是对单词计数，map的功能就是将一行数据分割成word，然后对每个word输出一个键值对。key就是word本身，value就是该word在该行中出现的次数。  

3. Partition function  
为了实现shard功能(水平分片，把数据库中的表按行为单位分片)，partition模块会给每个map进程分配一个特定的reducer，它的输入是key和reducer的数量，返回分配的reducer的index。  
一个典型的方式是对key进行hash，将其hash值对reducer数量取模，从负载均衡(load-balancing)的角度来说，给每个分片分配近似相同数量的数据尤为重要，否则会出现有些被分配了大数量的reducer执行缓慢导致的MapReduce系统的等待。    
在map和reduce之间，为了把数据从被制造的map node传到被reduce归纳的分片上，数据会重新洗牌(并行排序/node之间交换)，shuffle(洗牌)的时间会受到网络带宽，CPU速度，数据生产时间和map reduce计算时间的影响，有时会比估算时间长。  

4. Comparision function  
比较模块的作用是把map产出的数据从机器上拉过来，然后进行sort排序，将排序后的数据提供给reducer做输入。  

5. reduce function
对排序后的数据序列里的每一个唯一的key，平台都会调用一次reduce模块，Reduce可以遍历(iterate through)与该key关联的value并生成零个或多个输出。   
在对单词计数的例子中，reducer的作用就是将输入按key做sum，输出一个单词和它的总次数(注意，reducer接收的可能是多个map传来的数据，但是key肯定是同一个，这是partiion阶段要保证的)。

6. output writer
写模块将reduce的输出写到存储器中。 

## 性能考虑
MapReduce程序并不是会保证很快，它的优势是能开发出平台的最优洗牌办法，而且只需要更改map和reduce模块。实际上，程序使用者必须考虑shffle因素，实际上partition模块和数据写入量可能对程序的性能和稳定性造成巨大影响。一些额外的模块(例如combiner)可以减少数据写入量并通过网络传输。MapReduce应用程序可以在某些情况下实现亚线性加速。  

设计MapReduce算法时，作者应该权衡计算和通讯成本。通讯成本通常占据计算成本，而且为了灾难恢复，许多MapReduce的实现将所有的通讯写入分布式存储系统中。  

调试MapReduce性能时，应当考虑mapping，shuffle，sorting(grouped by key),reducing的复杂性。影响mapping和reducing之间的计算成本的一个重要参数是mapper生产的数据量。reducing包括了非线性时间复杂度的排序(groupping of keys),因此，减小分区大小会较少排序时间，但是这里要权衡因为reducer的数量会增加。对单位大小的数据再进行分割的影响是微不足道的，平均来说，一些mapper从本地读取数据带来的收益是很小的。  

对于能快速完成的程序，或者单独机器或小集群能加载到内存中的数据量而言，MapReduce不会有什么提升。因为这些框架的设计是为了减少计算时整个节点群挂掉之后的数据恢复成本，所以它们将中间结果进行分布式存储。这种奔溃的恢复代价很昂贵，而且仅当非常多的机器参与计算或者计算时间很长的情况下收益明显。或者是一个当有了error可以秒级重启的程序，或者某个单独机器可以在重启之后快速grow到集群，在这些情况下，所有数据存在内存中，或者数据量很小，非分布式解决方案会比MapReduce更好。  
(这段比较难懂)  

## Distribution and reliability（分布式和可靠性）

MapReduce通过对每个节点的数据集分配一些操作来实现可靠性。每个节点定期报告完成的工作和状态更新，如果一个节点沉默时间超过了时间间隔，主节点则将其标记为dead并将其工作分配给其他节点完成。各个操作使用原子级的修改文件名的操作来检查，来确保没有并行线程冲突，所以，有可能在文件被重命名时有了一个task名字之外的名字(这段什么鬼，不懂)

reduce的操作方式类似于节点操作，由于它们在并行操作的性能较差，因此主节点会尝试在统一节点上或者同一机架上调度reduce。  

MapReduce实现不一定高度可靠，例如早起的Hadoop版本中 NameNode是一个分布式文件系统的单点故障。后来的版本里NameNode才有了主/从的高可用的错误处理机制。  

## 使用
MapReduce的使用非常广泛，包括分布式搜索，分布式排序，网络连接图逆转，奇异值分解，web访问日志统计，**倒排索引构建**，文档聚类，机器学习，静态机器翻译等。 而且MapReduce模型可以适用于多核系统和超核系统([many-core](https://www.quora.com/What-is-many-core-What-is-the-difference-between-multi-core-and-many-core)),桌面网格，多集群，志愿计算环境,动态云环境，移动环境，和高性能计算环境。  

在谷歌，MapReduce被用来完全重新生成谷歌的万维网索引。它取代了旧的 对索引更新并且有大量分析的ad hoc程序。目前，谷歌的开发已经转向诸如Percolator，FlumeJava和MillWheel等技术，它们提供流操作和更新，而不是批处理，允许集成“实时”搜索结果而无需重新构建完整的索引。

## 反对声音
**Lack of novelty(老旧)**  
David DeWitt和Michael Stonebraker，并行数据库和无共享系统领域的专家，一直批评MapReduce的适用范围的问题。它们称其界面过于低级，并且质疑其是否真的像声名的那样支持范式转换。质疑MapReduce支持者对新颖性的主张，并援引Teradata早在二十多年前的先有技术的例子。还鄙视写MapReduce的程序员等等。

